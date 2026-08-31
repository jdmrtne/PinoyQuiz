import { useEffect, useState } from "react";
import { Card } from "../ui/Card";
import { Button } from "../ui/Button";
import { StreakBadge } from "./StreakBadge";
import { useServerTimer } from "../../hooks/useServerTimer";
import type { CurrentQuestion } from "../../lib/gameApi";

const OPTION_LETTERS = ["A", "B", "C", "D"] as const;

export function QuestionScreen({
  question,
  answeredIndex,
  answeredText,
  answeredPairing,
  answeredSequence,
  streak,
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
  /** 🔥 Current correct-answer streak, carried forward from GameRoom — see StreakBadge.tsx. */
  streak: number;
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
  const isScramble = question.questionType === "unscramble";

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
        {/* Back to a simple left/right split now that the extra top
            padding above keeps this row clear of the fixed pause/theme
            buttons — no need to center the label anymore, and
            left+right reads more balanced than both being center/right. */}
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

        <div className="flex justify-center">
          <StreakBadge streak={streak} />
        </div>

        <Card className="p-6">
          <h1 className="text-xl sm:text-2xl font-bold leading-snug">
            {question.prompt}
          </h1>
        </Card>

        {question.questionType === "image" && question.imageUrl && (
          <QuestionImage src={question.imageUrl} />
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
        ) : isScramble ? (
          <UnscrambleBoard
            // Remounts fresh on every new question (order is unique per
            // round, questionId can repeat across a "Play Again" rematch —
            // see GameRoom's comment on current_question_id) so the tile
            // pool always starts fully shuffled and the answer area empty,
            // rather than needing an effect to detect the letter set
            // changing underneath it.
            key={`${question.order}-${question.questionId}`}
            letters={question.scrambleLetters ?? []}
            answeredText={answeredText}
            onSubmit={onAnswerText}
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

/** A single scrambled letter, carrying its own id so two tiles with the
 * same letter (e.g. the two "A"s in MANILA) still drag/drop and reorder
 * independently instead of being indistinguishable by value alone. */
interface LetterTile {
  id: string;
  letter: string;
}

type ScrambleZone = "pool" | "answer";

function shuffleTiles(letters: string[]): LetterTile[] {
  const tiles = letters.map((letter, i) => ({
    id: `t${i}-${Math.random().toString(36).slice(2, 9)}`,
    letter,
  }));
  // Fisher-Yates — re-shuffled fresh every time this runs (component
  // mount, i.e. every new question — see the `key` on UnscrambleBoard's
  // call site in the parent).
  for (let i = tiles.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [tiles[i], tiles[j]] = [tiles[j], tiles[i]];
  }
  return tiles;
}

/** Pointer (mouse + touch + pen, unified) drag state for the tile
 * currently being dragged, if any. */
interface DragState {
  id: string;
  letter: string;
  fromZone: ScrambleZone;
  pointerId: number;
  x: number;
  y: number;
  offsetX: number;
  offsetY: number;
  width: number;
  height: number;
}

/**
 * Unscramble, drag & drop: the scrambled word starts as loose letter
 * tiles in the pool below; the player drags tiles up into the answer
 * strip to spell out a word, in any order, and can drag tiles back out
 * or reorder them within the strip before submitting. Submission still
 * goes through the exact same onAnswerText -> submitTextAnswer path (and
 * therefore the exact same server-side grading) as identification/
 * fill_blank — this component only changes how the text gets assembled.
 *
 * Built on raw Pointer Events rather than HTML5 drag-and-drop because
 * native HTML5 DnD doesn't fire reliably on touch devices; Pointer
 * Events unify mouse/touch/pen behind one API and, combined with
 * setPointerCapture, keep routing move/up events to the tile that
 * started the drag even once the finger/cursor has moved elsewhere.
 */
function UnscrambleBoard({
  letters,
  answeredText,
  onSubmit,
  canChangeAnswer,
  timeUp,
}: {
  letters: string[];
  answeredText: string | null;
  onSubmit: (text: string) => void;
  canChangeAnswer: boolean;
  timeUp: boolean;
}) {
  const hasAnswered = answeredText !== null;
  const locked = (hasAnswered && !canChangeAnswer) || timeUp;

  const [pool, setPool] = useState<LetterTile[]>(() => shuffleTiles(letters));
  const [answer, setAnswer] = useState<LetterTile[]>([]);
  const [dragging, setDragging] = useState<DragState | null>(null);
  const [overZone, setOverZone] = useState<ScrambleZone | null>(null);

  function moveTile(
    id: string,
    fromZone: ScrambleZone,
    toZone: ScrambleZone,
    targetSlotId: string | null,
    dropBeforeSlot: boolean
  ) {
    const fromList = fromZone === "answer" ? answer : pool;
    const tile = fromList.find((t) => t.id === id);
    if (!tile) return;
    const setFrom = fromZone === "answer" ? setAnswer : setPool;
    const setTo = toZone === "answer" ? setAnswer : setPool;
    const remainingFrom = fromList.filter((t) => t.id !== id);
    // Base the insertion index off the target list with the dragged tile
    // already removed (remainingFrom when reordering in place, the
    // target's current contents otherwise) — indexing against a list
    // that still includes the tile being moved is the classic off-by-one
    // trap for in-place reordering.
    const targetList =
      toZone === fromZone ? remainingFrom : toZone === "answer" ? answer : pool;
    let insertIndex = targetList.length;
    if (targetSlotId) {
      const slotIndex = targetList.findIndex((t) => t.id === targetSlotId);
      if (slotIndex >= 0) insertIndex = dropBeforeSlot ? slotIndex : slotIndex + 1;
    }
    const nextTarget = [...targetList];
    nextTarget.splice(insertIndex, 0, tile);

    if (fromZone === toZone) {
      setFrom(nextTarget);
    } else {
      setFrom(remainingFrom);
      setTo(nextTarget);
    }
  }

  function handlePointerDown(
    e: React.PointerEvent<HTMLButtonElement>,
    tile: LetterTile,
    zone: ScrambleZone
  ) {
    if (locked) return;
    e.preventDefault();
    const rect = e.currentTarget.getBoundingClientRect();
    e.currentTarget.setPointerCapture(e.pointerId);
    setDragging({
      id: tile.id,
      letter: tile.letter,
      fromZone: zone,
      pointerId: e.pointerId,
      x: e.clientX,
      y: e.clientY,
      offsetX: e.clientX - rect.left,
      offsetY: e.clientY - rect.top,
      width: rect.width,
      height: rect.height,
    });
  }

  function handlePointerMove(e: React.PointerEvent<HTMLButtonElement>) {
    if (!dragging || e.pointerId !== dragging.pointerId) return;
    setDragging((d) => (d ? { ...d, x: e.clientX, y: e.clientY } : d));
    const el = document.elementFromPoint(e.clientX, e.clientY);
    const zoneEl = el?.closest("[data-dropzone]") as HTMLElement | null;
    setOverZone((zoneEl?.dataset.dropzone as ScrambleZone | undefined) ?? null);
  }

  function finishDrag(e: React.PointerEvent<HTMLButtonElement>) {
    if (!dragging || e.pointerId !== dragging.pointerId) return;
    const el = document.elementFromPoint(e.clientX, e.clientY);
    const zoneEl = el?.closest("[data-dropzone]") as HTMLElement | null;
    const toZone =
      (zoneEl?.dataset.dropzone as ScrambleZone | undefined) ?? dragging.fromZone;
    const slotEl = el?.closest("[data-tile-slot]") as HTMLElement | null;
    let targetSlotId: string | null = null;
    let dropBeforeSlot = true;
    if (slotEl && slotEl.dataset.tileSlot !== dragging.id) {
      targetSlotId = slotEl.dataset.tileSlot ?? null;
      const rect = slotEl.getBoundingClientRect();
      dropBeforeSlot = e.clientX < rect.left + rect.width / 2;
    }
    moveTile(dragging.id, dragging.fromZone, toZone, targetSlotId, dropBeforeSlot);
    setDragging(null);
    setOverZone(null);
  }

  function cancelDrag() {
    // Pointer capture lost / gesture cancelled (e.g. a browser gesture
    // took over mid-touch) — snap back to wherever the tile already was,
    // nothing to persist.
    setDragging(null);
    setOverZone(null);
  }

  function handleSubmit() {
    if (locked || answer.length === 0) return;
    onSubmit(answer.map((t) => t.letter).join(""));
  }

  const tileHandlers = {
    onPointerDown: handlePointerDown,
    onPointerMove: handlePointerMove,
    onPointerUp: finishDrag,
    onPointerCancel: cancelDrag,
  };

  return (
    <div className="flex flex-col gap-4">
      <div
        data-dropzone="answer"
        className={`min-h-16 flex flex-wrap content-start items-center gap-2 rounded-2xl border-2 border-dashed p-3 transition-colors ${
          overZone === "answer"
            ? "border-mango bg-mango/10"
            : "border-ink-3 bg-ink-2/50"
        }`}
      >
        {answer.length === 0 && (
          <span className="px-2 text-sm text-sampaguita/30">
            Drag letters here to spell out your answer…
          </span>
        )}
        {answer.map((tile) => (
          <ScrambleTile
            key={tile.id}
            tile={tile}
            zone="answer"
            isDragging={dragging?.id === tile.id}
            locked={locked}
            {...tileHandlers}
          />
        ))}
      </div>

      <div
        data-dropzone="pool"
        className={`flex min-h-16 flex-wrap justify-center items-center gap-2 rounded-2xl p-2 transition-colors ${
          overZone === "pool" ? "bg-mango/10" : ""
        }`}
      >
        {pool.map((tile) => (
          <ScrambleTile
            key={tile.id}
            tile={tile}
            zone="pool"
            isDragging={dragging?.id === tile.id}
            locked={locked}
            {...tileHandlers}
          />
        ))}
      </div>

      <Button
        type="button"
        size="lg"
        onClick={handleSubmit}
        disabled={locked || answer.length === 0}
      >
        {hasAnswered ? (canChangeAnswer ? "Update answer" : "Submitted") : "Submit answer"}
      </Button>

      {dragging && (
        <div
          className="pointer-events-none fixed z-50 flex items-center justify-center rounded-xl bg-ube text-cloud font-display font-bold text-xl uppercase shadow-[0_4px_0_0_var(--color-ube-dim)]"
          style={{
            left: dragging.x - dragging.offsetX,
            top: dragging.y - dragging.offsetY,
            width: dragging.width,
            height: dragging.height,
          }}
          aria-hidden="true"
        >
          {dragging.letter}
        </div>
      )}
    </div>
  );
}

function ScrambleTile({
  tile,
  zone,
  isDragging,
  locked,
  onPointerDown,
  onPointerMove,
  onPointerUp,
  onPointerCancel,
}: {
  tile: LetterTile;
  zone: ScrambleZone;
  isDragging: boolean;
  locked: boolean;
  onPointerDown: (
    e: React.PointerEvent<HTMLButtonElement>,
    tile: LetterTile,
    zone: ScrambleZone
  ) => void;
  onPointerMove: (e: React.PointerEvent<HTMLButtonElement>) => void;
  onPointerUp: (e: React.PointerEvent<HTMLButtonElement>) => void;
  onPointerCancel: (e: React.PointerEvent<HTMLButtonElement>) => void;
}) {
  return (
    <button
      type="button"
      data-tile-slot={tile.id}
      disabled={locked}
      onPointerDown={(e) => onPointerDown(e, tile, zone)}
      onPointerMove={onPointerMove}
      onPointerUp={onPointerUp}
      onPointerCancel={onPointerCancel}
      aria-label={`Letter ${tile.letter}`}
      className={`flex touch-none select-none items-center justify-center w-11 h-11 rounded-xl font-display font-bold text-xl uppercase shadow-[0_4px_0_0_var(--color-ube-dim)] transition-opacity ${
        isDragging ? "opacity-0" : "bg-ube text-cloud opacity-100"
      } ${locked ? "cursor-default" : "cursor-grab active:cursor-grabbing"}`}
    >
      {tile.letter}
    </button>
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
