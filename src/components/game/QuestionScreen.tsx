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
  answeredPairing,
  answeredSequence,
  onAnswer,
  onAnswerText,
  onAnswerPairing,
  onAnswerSequence,
  canChangeAnswer,
  isAutomatic,
}: {
  question: CurrentQuestion;
  /** Displayed slot this player already picked (choice-based types), or null if not answered yet. */
  answeredIndex: number | null;
  /** This player's already-submitted text (identification/fill_blank/unscramble/image), or null if not answered yet. */
  answeredText: string | null;
  /** This player's already-submitted pairing (matching), or null if not answered yet. */
  answeredPairing: number[] | null;
  /** This player's already-submitted arrangement (sequence), or null if not answered yet. */
  answeredSequence: number[] | null;
  onAnswer: (index: number) => void;
  onAnswerText: (text: string) => void;
  onAnswerPairing: (pairing: number[]) => void;
  onAnswerSequence: (order: number[]) => void;
  /** true when games.answer_behavior === "CHANGE_UNTIL_TIMER_ENDS" — an
   * already-picked/typed/matched answer stays editable right up until the
   * timer runs out, instead of locking on first submission. */
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
    question.questionType === "identification" ||
    question.questionType === "fill_blank" ||
    question.questionType === "unscramble" ||
    question.questionType === "image";
  const isTrueFalse = question.questionType === "true_false";
  const isMatching = question.questionType === "matching";
  const isSequence = question.questionType === "sequence";

  const hasAnswered = isMatching
    ? answeredPairing !== null
    : isSequence
      ? answeredSequence !== null
      : isTextType
        ? answeredText !== null
        : answeredIndex !== null;

  return (
    // Extra top clearance (beyond the plain py-8 used elsewhere) so this
    // row — specifically the timer, right-aligned near the edge — clears
    // the fixed pause button/theme toggle circles in the top corners
    // instead of rendering underneath them, matching how far down those
    // buttons themselves sit (safe-area-inset-top + 0.75rem top offset +
    // their own 2.75rem height), plus a small gap.
    <div
      className="min-h-dvh px-5 pb-8 flex flex-col items-center"
      style={{ paddingTop: "calc(env(safe-area-inset-top, 0px) + 4.5rem)" }}
    >
      <div className="w-full max-w-lg flex flex-col gap-6">
        {/* "Question X / Total" is centered (not left-aligned) so it sits
            clear of the fixed pause button (top-left) and theme toggle
            (top-right) corners at every viewport width, instead of
            landing directly under one of them. Absolutely centering it
            here (rather than switching the row to justify-center) keeps
            the timer honestly right-aligned regardless of how wide the
            centered text is. */}
        <div className="relative flex items-center justify-end min-h-8">
          <span className="absolute left-1/2 -translate-x-1/2 text-sm font-semibold text-sampaguita/60">
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

        {question.questionType === "image" && question.imageUrl && (
          <QuestionImage src={question.imageUrl} />
        )}

        {question.questionType === "unscramble" && question.scrambleLetters && (
          <ScrambleTiles letters={question.scrambleLetters} />
        )}

        {isMatching ? (
          <MatchingBoard
            terms={question.matchTerms ?? []}
            definitions={question.matchDefinitions ?? []}
            answeredPairing={answeredPairing}
            onSubmit={onAnswerPairing}
            canChangeAnswer={canChangeAnswer}
            timeUp={timeUp}
          />
        ) : isSequence ? (
          <SequenceBoard
            items={question.sequenceItems ?? []}
            answeredSequence={answeredSequence}
            onSubmit={onAnswerSequence}
            canChangeAnswer={canChangeAnswer}
            timeUp={timeUp}
          />
        ) : isTextType ? (
          <TextAnswerForm
            answeredText={answeredText}
            onSubmit={onAnswerText}
            canChangeAnswer={canChangeAnswer}
            timeUp={timeUp}
            placeholder={
              question.questionType === "fill_blank"
                ? "Type the missing word or phrase…"
                : question.questionType === "unscramble"
                  ? "Type the unscrambled word…"
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
          {footerCopy({ hasAnswered, canChangeAnswer, timeUp, isAutomatic })}
        </p>
      </div>
    </div>
  );
}

/**
 * Renders the prompt image for "image" type questions. Falls back to a
 * plain message instead of a broken-image icon if the URL 404s / times
 * out — hotlinked source images (e.g. Wikimedia thumbnails) occasionally
 * get renamed or removed upstream, and we don't want that to block the
 * player from at least reading the question and guessing.
 */
function QuestionImage({ src }: { src: string }) {
  const [failed, setFailed] = useState(false);

  if (failed) {
    return (
      <Card className="p-6 text-center text-sm text-sampaguita/50">
        Couldn't load the image for this question — go ahead and answer
        based on the prompt above.
      </Card>
    );
  }

  return (
    <Card className="p-2 overflow-hidden">
      <img
        src={src}
        alt="Identify this"
        className="w-full max-h-72 object-cover rounded-xl"
        onError={() => setFailed(true)}
      />
    </Card>
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
                  isPicked ? "bg-mango text-night" : "bg-night text-mango"
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

/**
 * Purely decorative letter tiles — unscramble is graded through the same
 * typed-text submission as identification/fill_blank (TextAnswerForm,
 * rendered right below this by the parent), so these tiles don't carry
 * any answer state themselves. They exist to make "unscramble" visually
 * distinct from "type the answer to this question" per the brief ("add a
 * visual interaction that makes this feel different from normal
 * identification").
 */
function ScrambleTiles({ letters }: { letters: string[] }) {
  return (
    <div className="flex flex-wrap justify-center gap-2" aria-hidden="true">
      {letters.map((ch, i) => (
        <span
          key={i}
          className="flex items-center justify-center w-11 h-11 rounded-xl bg-ube text-cloud font-display font-bold text-xl uppercase shadow-[0_4px_0_0_var(--color-ube-dim)]"
        >
          {ch}
        </span>
      ))}
    </div>
  );
}

/**
 * Tap a term, then tap a definition to pair them; tap either half of an
 * existing pair to undo it. Submits automatically once every term has a
 * definition — matching doesn't have a natural "one tap = one answer"
 * moment like the other types, so auto-submit-on-complete is the least
 * surprising behavior (mirrors the brief's "make this interactive rather
 * than simply asking another multiple-choice question").
 */
function MatchingBoard({
  terms,
  definitions,
  answeredPairing,
  onSubmit,
  canChangeAnswer,
  timeUp,
}: {
  terms: string[];
  definitions: string[];
  answeredPairing: number[] | null;
  onSubmit: (pairing: number[]) => void;
  canChangeAnswer: boolean;
  timeUp: boolean;
}) {
  const hasAnswered = answeredPairing !== null;
  const locked = (hasAnswered && !canChangeAnswer) || timeUp;

  // pairing[i] = displayed definition slot assigned to terms[i], or -1 if unpaired.
  const [pairing, setPairing] = useState<number[]>(
    () => answeredPairing ?? terms.map(() => -1)
  );
  const [selectedTerm, setSelectedTerm] = useState<number | null>(null);

  useEffect(() => {
    setPairing(answeredPairing ?? terms.map(() => -1));
    setSelectedTerm(null);
    // terms.length is stable per-question; re-keying on the question
    // itself happens via the parent unmounting/remounting on question change.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [answeredPairing]);

  const usedDefSlots = new Set(pairing.filter((d) => d >= 0));

  function pickTerm(termIndex: number) {
    if (locked) return;
    setSelectedTerm((cur) => (cur === termIndex ? null : termIndex));
  }

  function pickDefinition(defSlot: number) {
    if (locked || selectedTerm === null) return;
    const next = [...pairing];
    // Unpair anything already using this definition slot.
    for (let i = 0; i < next.length; i++) {
      if (next[i] === defSlot) next[i] = -1;
    }
    next[selectedTerm] = defSlot;
    setPairing(next);
    setSelectedTerm(null);
    if (next.every((d) => d >= 0)) {
      onSubmit(next);
    }
  }

  function unpair(termIndex: number) {
    if (locked) return;
    const next = [...pairing];
    next[termIndex] = -1;
    setPairing(next);
  }

  return (
    <div className="flex flex-col gap-4">
      <div className="grid grid-cols-2 gap-3">
        <div className="flex flex-col gap-2">
          {terms.map((term, i) => {
            const paired = pairing[i] >= 0;
            const isSelected = selectedTerm === i;
            return (
              <button
                key={i}
                type="button"
                disabled={locked}
                onClick={() => (paired ? unpair(i) : pickTerm(i))}
                className={`rounded-xl border-2 px-3 py-3 text-sm font-semibold text-left transition-colors ${
                  isSelected
                    ? "border-mango bg-mango/10 text-sampaguita"
                    : paired
                      ? "border-bagoong bg-bagoong/10 text-sampaguita"
                      : "border-ink-3 bg-ink-2 text-sampaguita/90"
                } ${locked ? "opacity-70 cursor-default" : "cursor-pointer hover:border-mango/60"}`}
              >
                {term}
                {paired && (
                  <span className="block text-xs text-bagoong mt-0.5">
                    → {definitions[pairing[i]]}
                  </span>
                )}
              </button>
            );
          })}
        </div>
        <div className="flex flex-col gap-2">
          {definitions.map((def, i) => {
            const used = usedDefSlots.has(i);
            return (
              <button
                key={i}
                type="button"
                disabled={locked || used}
                onClick={() => pickDefinition(i)}
                className={`rounded-xl border-2 px-3 py-3 text-sm font-semibold text-left transition-colors ${
                  used
                    ? "border-ink-3 bg-ink text-sampaguita/30"
                    : selectedTerm !== null
                      ? "border-mango/60 bg-ink-2 text-sampaguita/90 cursor-pointer hover:border-mango"
                      : "border-ink-3 bg-ink-2 text-sampaguita/60"
                }`}
              >
                {def}
              </button>
            );
          })}
        </div>
      </div>
      <p className="text-xs text-center text-sampaguita/40">
        {selectedTerm !== null
          ? "Now tap the matching definition on the right."
          : "Tap a term, then tap its definition."}
      </p>
    </div>
  );
}

/**
 * Tap items in the order you believe is correct (e.g. earliest event
 * first). Tap a placed item's number badge to pull it back out and
 * re-place it. Submits automatically once every item has been placed —
 * same auto-submit-on-complete reasoning as MatchingBoard above.
 */
function SequenceBoard({
  items,
  answeredSequence,
  onSubmit,
  canChangeAnswer,
  timeUp,
}: {
  items: string[];
  answeredSequence: number[] | null;
  onSubmit: (order: number[]) => void;
  canChangeAnswer: boolean;
  timeUp: boolean;
}) {
  const hasAnswered = answeredSequence !== null;
  const locked = (hasAnswered && !canChangeAnswer) || timeUp;

  // order = displayed item slots, in the sequence chosen so far.
  const [order, setOrder] = useState<number[]>(() => answeredSequence ?? []);

  useEffect(() => {
    setOrder(answeredSequence ?? []);
  }, [answeredSequence]);

  const placedSet = new Set(order);

  function place(slot: number) {
    if (locked || placedSet.has(slot)) return;
    const next = [...order, slot];
    setOrder(next);
    if (next.length === items.length) {
      onSubmit(next);
    }
  }

  function removeAt(position: number) {
    if (locked) return;
    setOrder(order.filter((_, i) => i !== position));
  }

  return (
    <div className="flex flex-col gap-4">
      {order.length > 0 && (
        <div className="flex flex-col gap-2">
          {order.map((slot, position) => (
            <button
              key={position}
              type="button"
              disabled={locked}
              onClick={() => removeAt(position)}
              className={`flex items-center gap-3 rounded-xl border-2 border-bagoong bg-bagoong/10 px-3 py-3 text-left text-sm font-semibold text-sampaguita ${
                locked ? "cursor-default" : "cursor-pointer"
              }`}
            >
              <span className="flex items-center justify-center w-7 h-7 rounded-full bg-bagoong text-night font-display font-bold flex-shrink-0">
                {position + 1}
              </span>
              {items[slot]}
            </button>
          ))}
        </div>
      )}
      {!locked && order.length < items.length && (
        <div className="flex flex-wrap gap-2">
          {items.map((item, slot) =>
            placedSet.has(slot) ? null : (
              <button
                key={slot}
                type="button"
                onClick={() => place(slot)}
                className="rounded-xl border-2 border-ink-3 bg-ink-2 px-4 py-3 text-sm font-semibold text-sampaguita/90 cursor-pointer hover:border-mango/60"
              >
                {item}
              </button>
            )
          )}
        </div>
      )}
      <p className="text-xs text-center text-sampaguita/40">
        {order.length === 0
          ? "Tap items in order — earliest/first to latest/last."
          : "Tap a placed item to move it back and re-place it."}
      </p>
    </div>
  );
}
