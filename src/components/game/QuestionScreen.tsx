import { useEffect, useState } from "react";
import { Card } from "../ui/Card";
import { Button } from "../ui/Button";
import { useServerTimer } from "../../hooks/useServerTimer";
import type { CurrentQuestion } from "../../lib/gameApi";

const OPTION_LETTERS = ["A", "B", "C", "D"] as const;

export function QuestionScreen({
  question,
  answeredIndex,
  answeredText,
  onAnswer,
  onAnswerText,
  canChangeAnswer,
  isAutomatic,
}: {
  question: CurrentQuestion;
  /** Displayed slot this player already picked (choice-based types), or null if not answered yet. */
  answeredIndex: number | null;
  /** This player's already-submitted text (identification/fill_blank), or null if not answered yet. */
  answeredText: string | null;
  onAnswer: (index: number) => void;
  onAnswerText: (text: string) => void;
  /** true when games.answer_behavior === "CHANGE_UNTIL_TIMER_ENDS" — an
   * already-picked option (or already-typed answer) stays editable right
   * up until the timer runs out, instead of locking on first submission. */
  canChangeAnswer: boolean;
  /** true when games.game_mode === "AUTOMATIC" — only changes the footer
   * copy below ("waiting for the host" doesn't apply to an automatic game). */
  isAutomatic: boolean;
}) {
  const remaining = useServerTimer(
    question.questionStartedAt,
    question.timeLimitSeconds
  );
  const timeUp = remaining <= 0;
  const isTextType =
    question.questionType === "identification" || question.questionType === "fill_blank";
  const isTrueFalse = question.questionType === "true_false";

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

        {isTextType ? (
          <TextAnswerForm
            answeredText={answeredText}
            onSubmit={onAnswerText}
            canChangeAnswer={canChangeAnswer}
            timeUp={timeUp}
            placeholder={
              question.questionType === "fill_blank"
                ? "Type the missing word or phrase…"
                : "Type your answer…"
            }
          />
        ) : (
          <ChoiceGrid
            options={question.options}
            answeredIndex={answeredIndex}
            onAnswer={onAnswer}
            canChangeAnswer={canChangeAnswer}
            timeUp={timeUp}
            useLetters={!isTrueFalse}
          />
        )}

        <p className="text-xs text-center text-sampaguita/30">
          {footerCopy({
            hasAnswered: isTextType ? answeredText !== null : answeredIndex !== null,
            canChangeAnswer,
            timeUp,
            isAutomatic,
          })}
        </p>
      </div>
    </div>
  );
}

function footerCopy({
  hasAnswered,
  canChangeAnswer,
  timeUp,
  isAutomatic,
}: {
  hasAnswered: boolean;
  canChangeAnswer: boolean;
  timeUp: boolean;
  isAutomatic: boolean;
}) {
  if (hasAnswered && canChangeAnswer && !timeUp) {
    return "Answer submitted — you can still change it until time runs out.";
  }
  if (hasAnswered && !timeUp) {
    return isAutomatic
      ? "Answer locked in — the game will continue automatically."
      : "Answer locked in — waiting for the host to reveal the result.";
  }
  if (timeUp) {
    return isAutomatic
      ? "Time's up! The game will continue automatically."
      : "Time's up! Waiting for the host to reveal the result.";
  }
  return "Answer before time runs out.";
}

function ChoiceGrid({
  options,
  answeredIndex,
  onAnswer,
  canChangeAnswer,
  timeUp,
  useLetters,
}: {
  options: CurrentQuestion["options"];
  answeredIndex: number | null;
  onAnswer: (index: number) => void;
  canChangeAnswer: boolean;
  timeUp: boolean;
  /** false for true_false — renders two large TRUE/FALSE buttons instead of lettered A-D cards. */
  useLetters: boolean;
}) {
  const hasAnswered = answeredIndex !== null;
  const realOptions = options
    .map((opt, i) => ({ opt, i }))
    .filter((o): o is { opt: string; i: number } => o.opt !== null);

  return (
    <div
      className={
        useLetters
          ? "grid grid-cols-1 gap-3"
          : "grid grid-cols-1 sm:grid-cols-2 gap-3"
      }
    >
      {realOptions.map(({ opt, i }) => {
        const isPicked = answeredIndex === i;
        const disabled = timeUp || (hasAnswered && !canChangeAnswer);
        return (
          <button
            key={i}
            type="button"
            disabled={disabled}
            onClick={() => onAnswer(i)}
            aria-pressed={isPicked}
            className={`flex items-center gap-3 rounded-2xl border-2 px-5 py-4 min-h-[3.25rem] text-left text-lg font-semibold transition-colors touch-manipulation ${
              useLetters ? "" : "justify-center"
            } ${
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
            {useLetters && (
              <span
                className={`flex items-center justify-center w-8 h-8 rounded-full font-display font-bold flex-shrink-0 ${
                  isPicked ? "bg-mango text-ink" : "bg-ink text-mango"
                }`}
              >
                {OPTION_LETTERS[i]}
              </span>
            )}
            {opt}
          </button>
        );
      })}
    </div>
  );
}

function TextAnswerForm({
  answeredText,
  onSubmit,
  canChangeAnswer,
  timeUp,
  placeholder,
}: {
  answeredText: string | null;
  onSubmit: (text: string) => void;
  canChangeAnswer: boolean;
  timeUp: boolean;
  placeholder: string;
}) {
  const [draft, setDraft] = useState(answeredText ?? "");
  const hasAnswered = answeredText !== null;
  const locked = hasAnswered && !canChangeAnswer;
  const disabled = timeUp || locked;

  // A fresh question (new answeredText === null after the parent resets
  // it on question change) clears the draft too.
  useEffect(() => {
    setDraft(answeredText ?? "");
  }, [answeredText]);

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    const trimmed = draft.trim();
    if (!trimmed || disabled) return;
    onSubmit(trimmed);
  }

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-3">
      <input
        type="text"
        value={draft}
        onChange={(e) => setDraft(e.target.value)}
        disabled={disabled}
        placeholder={placeholder}
        autoComplete="off"
        autoCapitalize="off"
        autoCorrect="off"
        className={`w-full rounded-2xl border-2 px-5 py-4 text-lg font-semibold bg-ink-2 text-sampaguita placeholder:text-sampaguita/30 focus:outline-none focus:border-mango ${
          disabled ? "opacity-60 cursor-not-allowed border-ink-3" : "border-ink-3"
        }`}
      />
      <Button
        type="submit"
        size="lg"
        disabled={disabled || draft.trim().length === 0}
      >
        {hasAnswered ? (canChangeAnswer ? "Update answer" : "Submitted") : "Submit answer"}
      </Button>
    </form>
  );
}
