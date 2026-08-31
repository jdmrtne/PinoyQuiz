import { Card } from "../ui/Card";
import { Button } from "../ui/Button";
import { QuestionImage } from "./QuestionImage";
import { StreakBadge } from "./StreakBadge";
import type { AnswerReveal, CurrentQuestion } from "../../lib/gameApi";

const OPTION_LETTERS = ["A", "B", "C", "D"] as const;

/**
 * Shown once the game moves QUESTION -> REVEAL. Re-renders the same prompt
 * the player just saw, then branches by question type:
 *   - multiple_choice/true_false: the choice grid, correct one highlighted
 *     in bagoong, this player's own wrong pick (if any) in sunset.
 *   - identification/fill_blank/unscramble/image: this player's typed
 *     answer next to the canonical correct_answer.
 *   - matching: the full term/definition board with right/wrong lines.
 */
export function RevealScreen({
  question,
  reveal,
  streak,
  isHost,
  isAutomatic,
  onContinue,
  advancing,
}: {
  question: CurrentQuestion;
  reveal: AnswerReveal;
  /** 🔥 Streak *after* this question's result was folded in (GameRoom
   * updates it in the same fetch that produced `reveal`, so by the time
   * this component renders the two are already in sync). */
  streak: number;
  isHost: boolean;
  isAutomatic: boolean;
  onContinue: () => void;
  advancing: boolean;
}) {
  const isTextType =
    reveal.questionType === "identification" ||
    reveal.questionType === "fill_blank" ||
    reveal.questionType === "unscramble" ||
    reveal.questionType === "image";
  const isTrueFalse = reveal.questionType === "true_false";
  const isMatching = reveal.questionType === "matching";
  const isSequence = reveal.questionType === "sequence";
  const noAnswer = isMatching
    ? reveal.yourPairing === null
    : isSequence
      ? reveal.yourSequence === null
      : isTextType
        ? reveal.yourTextAnswer === null
        : reveal.yourAnswerIndex === null;

  return (
    // Same top-clearance fix as QuestionScreen — see its comment — so the
    // Correct/Incorrect label here doesn't render under the fixed
    // pause/theme-toggle buttons either.
    <div
      className="min-h-dvh px-5 pb-8 flex flex-col items-center"
      style={{ paddingTop: "calc(env(safe-area-inset-top, 0px) + 4.5rem)" }}
    >
      <div className="w-full max-w-lg flex flex-col gap-6">
        {/* Back to a simple left/right split — see QuestionScreen's
            comment on why centering isn't needed anymore. */}
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

        <div className="flex justify-center">
          <StreakBadge streak={streak} justIncreased={reveal.wasCorrect} />
        </div>

        <Card className="p-6">
          <h1 className="text-xl sm:text-2xl font-bold leading-snug">
            {question.prompt}
          </h1>
        </Card>

        {reveal.questionType === "image" && reveal.imageUrl && (
          <QuestionImage src={reveal.imageUrl} />
        )}

        {isMatching ? (
          <MatchingReveal reveal={reveal} />
        ) : isSequence ? (
          <SequenceReveal reveal={reveal} />
        ) : isTextType ? (
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
                    ? "bg-bagoong text-night"
                    : isYours
                      ? "bg-sunset text-night"
                      : "bg-night text-mango"
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

/**
 * out_match_terms/out_match_definitions come back in canonical (unshuffled)
 * order from get_answer_reveal, so yourPairing[i] (a displayed-slot index
 * from when the question was live) can't be zipped directly against them
 * anymore — instead we just show, per term, whether it was ever paired and
 * whether the whole set was correct (Phase 2 grades all-or-nothing; see
 * that migration's comment on submit_matching_answer for why per-pair
 * detail isn't shown here).
 */
function MatchingReveal({ reveal }: { reveal: AnswerReveal }) {
  const terms = reveal.matchTerms ?? [];
  const definitions = reveal.matchDefinitions ?? [];
  const attempted = reveal.yourPairing !== null;

  return (
    <div className="flex flex-col gap-2">
      {terms.map((term, i) => (
        <div
          key={i}
          className={`rounded-xl border-2 px-4 py-3 text-sm font-semibold ${
            reveal.wasCorrect
              ? "border-bagoong bg-bagoong/10 text-sampaguita"
              : "border-ink-3 bg-ink-2 text-sampaguita/80"
          }`}
        >
          {term}
          <span className="block text-xs text-bagoong mt-0.5">
            → {definitions[i]}
          </span>
        </div>
      ))}
      {!attempted && (
        <p className="text-xs text-center text-sampaguita/40 mt-1">
          You didn't finish matching before time ran out.
        </p>
      )}
    </div>
  );
}

/**
 * out_sequence_items comes back in canonical (correct) order from
 * get_answer_reveal — just show the correct order in a numbered list,
 * same "canonical, not shuffled, reveal isn't a live quiz" choice as
 * MatchingReveal above.
 */
function SequenceReveal({ reveal }: { reveal: AnswerReveal }) {
  const items = reveal.sequenceItems ?? [];
  const attempted = reveal.yourSequence !== null;

  return (
    <div className="flex flex-col gap-2">
      {items.map((item, i) => (
        <div
          key={i}
          className={`flex items-center gap-3 rounded-xl border-2 px-4 py-3 text-sm font-semibold ${
            reveal.wasCorrect
              ? "border-bagoong bg-bagoong/10 text-sampaguita"
              : "border-ink-3 bg-ink-2 text-sampaguita/80"
          }`}
        >
          <span className="flex items-center justify-center w-7 h-7 rounded-full bg-bagoong text-night font-display font-bold flex-shrink-0">
            {i + 1}
          </span>
          {item}
        </div>
      ))}
      {!attempted && (
        <p className="text-xs text-center text-sampaguita/40 mt-1">
          You didn't finish arranging before time ran out.
        </p>
      )}
    </div>
  );
}
