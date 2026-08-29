import { useEffect } from "react";
import { autoAdvanceGame } from "../lib/gameApi";
import type { GameModeRow, GameStatusRow } from "../types/database.types";

// Deliberately shorter than useHeartbeat's 8s — this is what stands in for
// COUNTDOWN/QUESTION/REVEAL/LEADERBOARD's server-side timer actually
// firing, so a game shouldn't visibly stall for several seconds after each
// phase's duration elapses. 500ms keeps the perceived lag well under the
// smallest phase duration (LEADERBOARD_SECONDS is 2s as of
// 0017_faster_automatic_mode_timing.sql — a full second of poll lag on top
// of that would itself have been a noticeable chunk of a 2s phase). See
// auto_advance_game — the function itself is a no-op until the real
// elapsed time has passed, so polling this often just means the transition
// lands within ~500ms of being due, not that anything expensive runs twice
// a second. auto_advance_game's rate limit (60 calls / 20s per user, i.e.
// an average of 3/s) comfortably allows 500ms's 2/s.
const AUTO_ADVANCE_INTERVAL_MS = 500;

const ACTIVE_STATUSES: GameStatusRow[] = [
  "COUNTDOWN",
  "QUESTION",
  "REVEAL",
  "LEADERBOARD",
];

/**
 * Automatic mode's client-side half. Every connected participant — not
 * just the host — polls auto_advance_game while the game is in a timed
 * phase and game_mode is AUTOMATIC. Because every client does this
 * independently, the game keeps advancing as long as at least one tab is
 * open, even if the host disconnects (see this migration's header comment
 * for why that's the honest guarantee this stack can make, given it has no
 * server-side cron/Edge Functions). Any resulting games.status change
 * reaches every client through the existing Realtime subscription
 * (useGameRealtime) — this hook never touches local state directly.
 *
 * No-op for Host-Controlled games, before gameId/playerId are known, once
 * the game isn't in a timed phase, or while the host has the game paused
 * (0037_host_pause_resume.sql) — auto_advance_game already no-ops itself
 * while paused, so this is purely to stop the pointless polling client-side
 * for as long as the pause lasts.
 */
export function useAutoAdvance(
  gameId: string | null,
  playerId: string | null,
  gameMode: GameModeRow | null,
  status: GameStatusRow | null,
  isPaused: boolean = false
): void {
  useEffect(() => {
    if (!gameId || !playerId) return;
    if (gameMode !== "AUTOMATIC") return;
    if (!status || !ACTIVE_STATUSES.includes(status)) return;
    if (isPaused) return;

    let cancelled = false;
    function tick() {
      if (cancelled || !gameId) return;
      autoAdvanceGame(gameId).catch(() => {
        // Same rationale as useHeartbeat: a missed tick just means the
        // next one (500ms later, from this client or another) tries again.
      });
    }

    tick();
    const interval = setInterval(tick, AUTO_ADVANCE_INTERVAL_MS);
    return () => {
      cancelled = true;
      clearInterval(interval);
    };
  }, [gameId, playerId, gameMode, status, isPaused]);
}
