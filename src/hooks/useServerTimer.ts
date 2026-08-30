import { useEffect, useState } from "react";
import { computeRemainingSeconds } from "../game-engine/timeRemaining";
import { calibrateServerClock, getServerNow } from "../lib/serverClock";

/**
 * Computes remaining seconds from a server-set start timestamp, not from
 * when the client happened to render — so a slow-loading client still sees
 * a correct (lower) remaining time rather than a full fresh countdown.
 * This is purely a *display* timer; actual answer-window enforcement is a
 * server-side concern that lands with submit_answer in Phase 6.
 *
 * The actual math lives in src/game-engine/timeRemaining.ts (Phase 11) so
 * it can be unit tested directly; this hook is just that function plus the
 * re-render tick.
 *
 * Host pause (0037_host_pause_resume.sql): while `pausedAtIso` is set, the
 * countdown freezes — computeRemainingSeconds is called with `pausedAtIso`
 * standing in for "now" instead of the real wall clock, and the re-render
 * interval stops entirely, so the displayed value stays exactly where it
 * was the instant the host paused. resume_game shifts `startedAtIso`
 * forward (via games.question_started_at, kept live over Realtime) by
 * however long the pause lasted, so once unpaused this same math picks up
 * counting down from that frozen value with no special-casing needed here.
 */
export function useServerTimer(
  startedAtIso: string | null,
  durationSeconds: number,
  pausedAtIso: string | null = null
): number {
  // Only used to force a re-render every 250ms so the returned value below
  // stays fresh. The actual remaining-time value is computed synchronously
  // in the render body (not cached in state) so that the very first render
  // after `startedAtIso` becomes non-null already reflects the real elapsed
  // time — using state+effect here previously left `remaining` stuck at its
  // stale initial value (0, since duration is 0 before the question loads)
  // for one render, which was enough to trip the "time's up" logic in
  // GameRoom immediately after the first question appeared.
  const [, forceRerender] = useState(0);

  // Kick off (or reuse) clock calibration — see serverClock.ts. Cheap and
  // idempotent, so just doing it on every mount is fine.
  useEffect(() => {
    calibrateServerClock().then(() => forceRerender((n) => n + 1));
  }, []);

  useEffect(() => {
    if (!startedAtIso || pausedAtIso) return;
    const interval = setInterval(() => forceRerender((n) => n + 1), 250);
    return () => clearInterval(interval);
  }, [startedAtIso, pausedAtIso]);

  // Paused: freeze using the server's own paused_at timestamp — no device
  // clock involved, so this is exact regardless of any client/server
  // clock drift. Running: compare against getServerNow() (device clock
  // corrected by the calibrated offset) instead of the raw device clock,
  // so resuming doesn't expose that drift as a sudden jump — see
  // serverClock.ts for why that jump happens otherwise.
  return pausedAtIso
    ? computeRemainingSeconds(startedAtIso, durationSeconds, new Date(pausedAtIso).getTime())
    : computeRemainingSeconds(startedAtIso, durationSeconds, getServerNow());
}
