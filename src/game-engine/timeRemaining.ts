/**
 * Pure calculation of remaining display seconds from a server-set start
 * timestamp. Framework-agnostic by design (no React import) so it can be
 * unit tested without a DOM/hook renderer — this is the "game-engine"
 * folder's originally-intended purpose (see Phase 1's CHANGELOG entry:
 * "framework-agnostic logic that can be unit tested without a DB"),
 * finally given something to hold now that Phase 11 introduced a test
 * runner.
 *
 * Extracted out of src/hooks/useServerTimer.ts, which now just calls this
 * and handles the re-render tick — no behavior change for callers.
 *
 * This is purely a *display* calculation; actual answer-window enforcement
 * is the server's job (see submit_answer's response_ms clamping in
 * supabase/migrations/0011_answer_submission.sql) and does not depend on
 * this function at all.
 */
export function computeRemainingSeconds(
  startedAtIso: string | null,
  durationSeconds: number,
  nowMs: number = Date.now()
): number {
  if (!startedAtIso) return durationSeconds;

  const startedAt = new Date(startedAtIso).getTime();
  const elapsed = (nowMs - startedAt) / 1000;
  return Math.max(0, Math.ceil(durationSeconds - elapsed));
}
