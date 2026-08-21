import { useEffect } from "react";
import { heartbeat, markStalePlayers } from "../lib/gameApi";

// Matches STALE_SECONDS's reasoning in
// supabase/migrations/0013_disconnect_reconnect.sql: 8s between beats
// means a real drop is caught within ~2-3 missed beats (~20s server-side
// threshold), while staying well under even the shortest question timer
// (5s minimum per games_time_limit_range).
const HEARTBEAT_INTERVAL_MS = 8000;

/**
 * Phase 8: keeps this player's `connected`/`last_seen_at` fresh, and
 * opportunistically sweeps the rest of the roster for anyone who's gone
 * stale — see 0013_disconnect_reconnect.sql for why *every* client (not
 * just the host's) does the sweep. Both calls are cheap SECURITY DEFINER
 * RPCs; any resulting `players.connected` change reaches every client
 * through the existing Realtime subscription (Phase 4), so this hook never
 * touches local state directly.
 *
 * No-op whenever gameId/playerId aren't known yet (e.g. before the roster
 * has loaded enough to resolve "which player is me" — see
 * useCurrentUserId.ts) or once the game has finished and GameRoom has
 * navigated away.
 */
export function useHeartbeat(
  gameId: string | null,
  playerId: string | null,
  active: boolean
): void {
  useEffect(() => {
    if (!gameId || !playerId || !active) return;

    let cancelled = false;
    function tick() {
      if (cancelled || !gameId) return;
      heartbeat(gameId).catch(() => {
        // Transient network errors are fine to ignore here — the next
        // tick retries, and a real, sustained drop is exactly what this
        // whole feature is meant to handle gracefully elsewhere.
      });
      markStalePlayers(gameId).catch(() => {});
    }

    tick(); // beat immediately on mount/rejoin, don't wait for the first interval
    const interval = setInterval(tick, HEARTBEAT_INTERVAL_MS);
    return () => {
      cancelled = true;
      clearInterval(interval);
    };
  }, [gameId, playerId, active]);
}
