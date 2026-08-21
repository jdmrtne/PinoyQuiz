import { useEffect, useState } from "react";
import type { RealtimePostgresChangesPayload } from "@supabase/supabase-js";
import { supabase, ensureAnonymousSession } from "../lib/supabase";
import type { Database } from "../types/database.types";

export type GameRow = Database["public"]["Tables"]["games"]["Row"];
export type PlayerRow = Database["public"]["Tables"]["players"]["Row"];

type LoadState =
  | { status: "loading" }
  | { status: "error"; message: string }
  | { status: "ready" };

interface UseGameRealtimeResult {
  state: LoadState;
  game: GameRow | null;
  players: PlayerRow[];
}

/**
 * Loads a game + its player roster by room code, then subscribes to
 * Supabase Realtime so both stay in sync as players join/leave/reconnect
 * or the host changes the game's status — without polling or a manual
 * refresh.
 *
 * Realtime delivery for these two tables was not (and cannot be, from this
 * sandbox) exercised against a live project — Supabase's Realtime service
 * is a separate hosted component from the Postgres database itself, so it
 * isn't something a local Postgres instance can stand in for. The
 * `postgres_changes` subscription pattern below follows the documented
 * supabase-js v2 API exactly; what's actually new/untested-by-me here is
 * the live wire behavior, not the SQL or the RLS model underneath it
 * (both of which *were* validated — see docs/ARCHITECTURE.md).
 */
export function useGameRealtime(
  roomCode: string | undefined
): UseGameRealtimeResult {
  const [state, setState] = useState<LoadState>({ status: "loading" });
  const [game, setGame] = useState<GameRow | null>(null);
  const [players, setPlayers] = useState<PlayerRow[]>([]);

  useEffect(() => {
    if (!roomCode) return;
    const code = roomCode;
    let cancelled = false;
    let channel: ReturnType<typeof supabase.channel> | null = null;

    async function init() {
      try {
        await ensureAnonymousSession();

        const { data: gameRow, error: gameError } = await supabase
          .from("games")
          .select("*")
          .eq("room_code", code)
          .single();

        if (gameError || !gameRow) {
          throw new Error(
            "Couldn't find that room. It may have ended, or the link is wrong."
          );
        }

        const { data: playerRows, error: playersError } = await supabase
          .from("players")
          .select("*")
          .eq("game_id", gameRow.id)
          .order("joined_at", { ascending: true });

        if (playersError) throw new Error(playersError.message);
        if (cancelled) return;

        setGame(gameRow);
        setPlayers(playerRows ?? []);
        setState({ status: "ready" });

        channel = supabase
          .channel(`game-room:${gameRow.id}`)
          .on(
            "postgres_changes",
            {
              event: "*",
              schema: "public",
              table: "players",
              filter: `game_id=eq.${gameRow.id}`,
            },
            (payload: RealtimePostgresChangesPayload<PlayerRow>) => {
              setPlayers((prev) => applyPlayerChange(prev, payload));
            }
          )
          .on(
            "postgres_changes",
            {
              event: "UPDATE",
              schema: "public",
              table: "games",
              filter: `id=eq.${gameRow.id}`,
            },
            (payload: RealtimePostgresChangesPayload<GameRow>) => {
              if (payload.new && "id" in payload.new) {
                setGame(payload.new as GameRow);
              }
            }
          )
          .subscribe();
      } catch (err) {
        if (cancelled) return;
        setState({
          status: "error",
          message: err instanceof Error ? err.message : "Something went wrong.",
        });
      }
    }

    init();

    return () => {
      cancelled = true;
      if (channel) supabase.removeChannel(channel);
    };
  }, [roomCode]);

  return { state, game, players };
}

function applyPlayerChange(
  prev: PlayerRow[],
  payload: RealtimePostgresChangesPayload<PlayerRow>
): PlayerRow[] {
  switch (payload.eventType) {
    case "INSERT": {
      const incoming = payload.new as PlayerRow;
      if (prev.some((p) => p.id === incoming.id)) return prev;
      return [...prev, incoming].sort((a, b) =>
        a.joined_at.localeCompare(b.joined_at)
      );
    }
    case "UPDATE": {
      const updated = payload.new as PlayerRow;
      return prev.map((p) => (p.id === updated.id ? updated : p));
    }
    case "DELETE": {
      const removedId = (payload.old as Partial<PlayerRow>).id;
      return prev.filter((p) => p.id !== removedId);
    }
    default:
      return prev;
  }
}
