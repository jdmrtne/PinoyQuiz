import { Card } from "../ui/Card";
import { Button } from "../ui/Button";
import type { AnswerReveal, CurrentQuestion } from "../../lib/gameApi";

const OPTION_LETTERS = ["A", "B", "C", "D"] as const;

/**
 * Shown once the game moves QUESTION -> REVEAL. Re-renders the same prompt
 * the player just saw, then either the choice grid (multiple_choice/
 * true_false — highlighting the correct one in bagoong and this player's
 * own wrong pick in sunset, matching the *displayed* slot order) or the
 * typed-answer comparison (identification/fill_blank — showing the
 * canonical correct_answer alongside whatever this player typed).
 */
export function RevealScreen({
  question,
  reveal,
  isHost,
  isAutomatic,
  onContinue,
  advancing,
}: {
  question: CurrentQuestion;
  reveal: AnswerReveal;
  isHost: boolean;
  isAutomatic: boolean;
  onContinue: () => void;
  advancing: boolean;
}) {
  const isTextType =
    reveal.questionType === "identification" || reveal.questionType === "fill_blank";
  const isTrueFalse = reveal.questionType === "true_false";
  const noAnswer = isTextType
    ? reveal.yourTextAnswer === null
    : reveal.yourAnswerIndex === null;

  return (
    <div className="min-h-dvh px-5 py-8 flex flex-col items-center">
      <div className="w-full max-w-lg flex flex-col gap-6">
        <div className="flex items-center justify-between">
          <span className="text-sm font-semibold text-sampaguita/60">
            Question {question.order} / {question.total}
          </span>
          <span
            className={`font-display text-lg font-bold ${
              reveal.wasCorrect ? "text-bagoong" : "text-sunset"
            }`}
          >
            {noAnswer
              ? "No answer"
              : reveal.wasCorrect
                ? "Correct!"
                : "Incorrect"}
          </span>
        </div>

        <Card className="p-6">
          <h1 className="text-xl sm:text-2xl font-bold leading-snug">
            {question.prompt}
          </h1>
        </Card>

        {isTextType ? (
          <TextReveal reveal={reveal} noAnswer={noAnswer} />
        ) : (
          <ChoiceReveal
            options={question.options}
            reveal={reveal}
            useLetters={!isTrueFalse}
          />
        )}

        <Card className="p-5 flex items-center justify-between">
          <div>
            <p className="text-xs uppercase tracking-wide text-sampaguita/50">
              Points earned
            </p>
            <p className="font-display text-3xl font-bold text-mango">
              +{reveal.yourPointsEarned}
            </p>
          </div>
          <div className="text-right">
            <p className="text-xs uppercase tracking-wide text-sampaguita/50">
              Answered correctly
            </p>
            <p className="font-display text-3xl font-bold">
              {reveal.percentCorrect}%
            </p>
          </div>
        </Card>

        {reveal.explanation && (
          <Card className="p-5">
            <p className="text-xs uppercase tracking-wide text-sampaguita/50 mb-1">
              Did you know?
            </p>
            <p className="text-sm text-sampaguita/80">{reveal.explanation}</p>
          </Card>
        )}

        {isAutomatic ? (
          <p className="text-xs text-center text-sampaguita/30">
            Advancing automatically…
          </p>
        ) : isHost ? (
          <Button size="lg" onClick={onContinue} disabled={advancing}>
            {advancing ? "Loading…" : "See Leaderboard"}
          </Button>
        ) : (
          <p className="text-xs text-center text-sampaguita/30">
            Waiting for the host to continue…
          </p>
        )}
      </div>
    </div>
  );
}

function ChoiceReveal({
  options,
  reveal,
  useLetters,
}: {
  options: CurrentQuestion["options"];
  reveal: AnswerReveal;
  useLetters: boolean;
}) {
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
        const isCorrect = i === reveal.correctOptionIndex;
        const isYours = i === reveal.yourAnswerIndex;
        const style = isCorrect
          ? "border-bagoong bg-bagoong/10 text-sampaguita"
          : isYours
            ? "border-sunset bg-sunset/10 text-sampaguita"
            : "border-ink-3 bg-ink-2 text-sampaguita/60";
        return (
          <div
            key={i}
            className={`flex items-center gap-3 rounded-2xl border-2 px-5 py-4 text-left text-lg font-semibold ${style}`}
          >
            {useLetters && (
              <span
                className={`flex items-center justify-center w-8 h-8 rounded-full font-display font-bold flex-shrink-0 ${
                  isCorrect
                    ? "bg-bagoong text-ink"
                    : isYours
                      ? "bg-sunset text-ink"
                      : "bg-ink text-mango"
                }`}
              >
                {OPTION_LETTERS[i]}
              </span>
            )}
            <span className="flex-1">{opt}</span>
            {isCorrect && (
              <span className="text-xs font-bold uppercase tracking-wide text-bagoong">
                Correct
              </span>
            )}
            {!isCorrect && isYours && (
              <span className="text-xs font-bold uppercase tracking-wide text-sunset">
                Your pick
              </span>
            )}
          </div>
        );
      })}
    </div>
  );
}

function TextReveal({
  reveal,
  noAnswer,
}: {
  reveal: AnswerReveal;
  noAnswer: boolean;
}) {
  return (
    <div className="flex flex-col gap-3">
      {!noAnswer && (
        <div
          className={`rounded-2xl border-2 px-5 py-4 text-lg font-semibold ${
            reveal.wasCorrect
              ? "border-bagoong bg-bagoong/10 text-sampaguita"
              : "border-sunset bg-sunset/10 text-sampaguita"
          }`}
        >
          <p className="text-xs uppercase tracking-wide opacity-60 mb-1">
            Your answer
          </p>
          {reveal.yourTextAnswer}
        </div>
      )}
      {!reveal.wasCorrect && (
        <div className="rounded-2xl border-2 border-bagoong bg-bagoong/10 px-5 py-4 text-lg font-semibold text-sampaguita">
          <p className="text-xs uppercase tracking-wide opacity-60 mb-1">
            Correct answer
          </p>
          {reveal.correctAnswer}
        </div>
      )}
    </div>
  );
}
