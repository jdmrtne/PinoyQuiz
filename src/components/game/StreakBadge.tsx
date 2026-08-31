/**
 * 🔥 Streak counter. Purely a display of GameRoom's `streak` state — all
 * the increment/reset logic (correct -> +1, wrong/no-answer/new game -> 0)
 * lives there; this component just renders the number and, optionally,
 * plays a subtle bounce + flame-flicker animation.
 *
 * `justIncreased` should only be passed as true from the one place the
 * bump actually happens — RevealScreen, gated on `reveal.wasCorrect`
 * (see GameRoom's REVEAL-fetch effect, which increments `streak` under
 * that exact condition). QuestionScreen renders the same badge statically
 * (no animation) since it's just carrying the value forward, not the
 * moment it changed.
 */
export function StreakBadge({
  streak,
  justIncreased = false,
}: {
  streak: number;
  justIncreased?: boolean;
}) {
  return (
    <span
      className="inline-flex items-center gap-1.5 font-display text-sm font-bold text-mango"
      aria-label={`Streak: ${streak}`}
    >
      <span
        aria-hidden="true"
        className={`inline-block leading-none ${
          justIncreased ? "animate-streak-flame" : ""
        }`}
      >
        🔥
      </span>
      <span
        className={`tabular-nums inline-block text-mango ${
          justIncreased ? "animate-streak-bounce" : ""
        }`}
        aria-live="polite"
      >
        Streak: {streak}
      </span>
    </span>
  );
}
