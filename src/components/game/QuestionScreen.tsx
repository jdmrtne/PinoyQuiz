import { Card } from "../ui/Card";
import { useServerTimer } from "../../hooks/useServerTimer";
import type { CurrentQuestion } from "../../lib/gameApi";

const OPTION_LETTERS = ["A", "B", "C", "D"] as const;

export function QuestionScreen({
  question,
  answeredIndex,
  onAnswer,
  canChangeAnswer,
  isAutomatic,
}: {
  question: CurrentQuestion;
  /** Displayed slot (0-3) this player already picked, or null if not answered yet. */
  answeredIndex: number | null;
  onAnswer: (index: number) => void;
  /** true when games.answer_behavior === "CHANGE_UNTIL_TIMER_ENDS" — an
   * already-picked option stays tappable (to switch to a different one)
   * right up until the timer runs out, instead of locking on first tap. */
  canChangeAnswer: boolean;
  /** true when games.game_mode === "AUTOMATIC" — only changes the footer
   * copy below ("waiting for the host" doesn't apply to an automatic game). */
  isAutomatic: boolean;
}) {
  const remaining = useServerTimer(
    question.questionStartedAt,
    question.timeLimitSeconds
  );
  const hasAnswered = answeredIndex !== null;
  const timeUp = remaining <= 0;

  return (
    <div className="min-h-dvh px-5 py-8 flex flex-col items-center">
      <div className="w-full max-w-lg flex flex-col gap-6">
        <div className="flex items-center justify-between">
          <span className="text-sm font-semibold text-sampaguita/60">
            Question {question.order} / {question.total}
          </span>
          <span
            className="font-display text-2xl font-bold text-mango tabular-nums"
            aria-live="polite"
            aria-label={`${remaining} seconds remaining`}
          >
            {remaining}
          </span>
        </div>

        <Card className="p-6">
          <h1 className="text-xl sm:text-2xl font-bold leading-snug">
            {question.prompt}
          </h1>
        </Card>

        <div className="grid grid-cols-1 gap-3">
          {question.options.map((opt, i) => {
            const isPicked = answeredIndex === i;
            // Under CHANGE_UNTIL_TIMER_ENDS, an already-answered question
            // stays interactive (so a different option can still be
            // picked) right up until the timer actually runs out — only
            // `timeUp` disables it. Under LOCK_ON_SELECTION, the very first
            // pick disables everything, same as before this feature.
            const disabled = timeUp || (hasAnswered && !canChangeAnswer);
            return (
              <button
                key={i}
                type="button"
                disabled={disabled}
                onClick={() => onAnswer(i)}
                aria-pressed={isPicked}
                className={`flex items-center gap-3 rounded-2xl border-2 px-5 py-4 min-h-[3.25rem] text-left text-lg font-semibold transition-colors touch-manipulation ${
                  isPicked
                    ? "border-mango bg-mango/10 text-sampaguita"
                    : "border-ink-3 bg-ink-2 text-sampaguita/90"
                } ${
                  disabled && !isPicked
                    ? "opacity-50 cursor-not-allowed"
                    : disabled
                      ? "cursor-default"
                      : "cursor-pointer hover:border-mango/60 active:scale-[0.99]"
                }`}
              >
                <span
                  className={`flex items-center justify-center w-8 h-8 rounded-full font-display font-bold flex-shrink-0 ${
                    isPicked ? "bg-mango text-ink" : "bg-ink text-mango"
                  }`}
                >
                  {OPTION_LETTERS[i]}
                </span>
                {opt}
              </button>
            );
          })}
        </div>

        <p className="text-xs text-center text-sampaguita/30">
          {hasAnswered && canChangeAnswer && !timeUp
            ? "Answer selected — you can still change it until time runs out."
            : hasAnswered && !timeUp
              ? isAutomatic
                ? "Answer locked in — the game will continue automatically."
                : "Answer locked in — waiting for the host to reveal the result."
              : timeUp
                ? isAutomatic
                  ? "Time's up! The game will continue automatically."
                  : "Time's up! Waiting for the host to reveal the result."
                : "Tap an answer before time runs out."}
        </p>
      </div>
    </div>
  );
}
