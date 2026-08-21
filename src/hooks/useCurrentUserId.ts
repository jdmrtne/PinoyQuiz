import { useEffect, useState } from "react";
import { supabase, ensureAnonymousSession } from "../lib/supabase";

/**
 * The current browser's Supabase Auth user id (from its persisted
 * anonymous session — `persistSession: true` in src/lib/supabase.ts means
 * this survives a page refresh, unlike React Router's `location.state`).
 *
 * Phase 8: GameRoom/Results used to know "who am I in this game" only from
 * `location.state.playerId`/`isHost`, which is set when navigating in from
 * CreateGame/JoinGame but is lost on a hard refresh or a link opened
 * directly — exactly the "rejoining an in-progress game from the UI" gap
 * docs/MASTER_HANDOFF.md's Phase 8 section called out. Since
 * `players.user_id` is already readable by any participant (RLS policy
 * `players_select_same_game`, Phase 2), comparing this id against the
 * already-fetched roster (`useGameRealtime`) is enough to re-derive
 * "which player row is mine" — and therefore `isHost`, which is also just
 * a column on that same row — without adding any new server code.
 */
export function useCurrentUserId(): string | null {
  const [userId, setUserId] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    ensureAnonymousSession()
      .then(() => supabase.auth.getUser())
      .then(({ data }) => {
        if (!cancelled) setUserId(data.user?.id ?? null);
      })
      .catch(() => {
        if (!cancelled) setUserId(null);
      });
    return () => {
      cancelled = true;
    };
  }, []);

  return userId;
}
