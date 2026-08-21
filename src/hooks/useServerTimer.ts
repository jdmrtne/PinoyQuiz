import { useEffect, useState } from "react";
import { computeRemainingSeconds } from "../game-engine/timeRemaining";

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
 */
export function useServerTimer(
  startedAtIso: string | null,
  durationSeconds: number
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

  useEffect(() => {
    if (!startedAtIso) return;
    const interval = setInterval(() => forceRerender((n) => n + 1), 250);
    return () => clearInterval(interval);
  }, [startedAtIso]);

  return computeRemainingSeconds(startedAtIso, durationSeconds);
}
