import { useEffect, useState } from "react";

/**
 * Computes remaining seconds from a server-set start timestamp, not from
 * when the client happened to render — so a slow-loading client still sees
 * a correct (lower) remaining time rather than a full fresh countdown.
 * This is purely a *display* timer; actual answer-window enforcement is a
 * server-side concern that lands with submit_answer in Phase 6.
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

  if (!startedAtIso) return durationSeconds;

  const startedAt = new Date(startedAtIso).getTime();
  const elapsed = (Date.now() - startedAt) / 1000;
  return Math.max(0, Math.ceil(durationSeconds - elapsed));
}
