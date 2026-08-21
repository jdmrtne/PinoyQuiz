import { Card } from "../ui/Card";
import { useServerTimer } from "../../hooks/useServerTimer";
import type { CurrentQuestion } from "../../lib/gameApi";

const OPTION_LETTERS = ["A", "B", "C", "D"] as const;

export function QuestionScreen({
  question,
  answeredIndex,
  onAnswer,
}: {
  question: CurrentQuestion;
  /** Displayed slot (0-3) this player already picked, or null if not answered yet. */
  answeredIndex: number | null;
  onAnswer: (index: number) => void;
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
            const disabled = hasAnswered || timeUp;
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
          {hasAnswered
            ? "Answer locked in — waiting for the host to reveal the result."
            : timeUp
              ? "Time's up! Waiting for the host to reveal the result."
              : "Tap an answer before time runs out."}
        </p>
      </div>
    </div>
  );
}
