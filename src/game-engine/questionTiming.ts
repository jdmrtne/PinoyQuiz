/**
 * Client-side mirror of the SQL `calculate_question_time()` function
 * added in supabase/migrations/0036_smart_timing.sql. The server is
 * always the source of truth — this never decides a real game's actual
 * per-question time (that happens once, server-side, at start_game) — it
 * exists purely so the Create Game screen can show the host a realistic
 * "Smart Auto" estimate *before* a game exists, when the real questions
 * haven't been selected yet (and can't be — see 0036's header comment on
 * why question content isn't exposed to the client pre-game).
 *
 * Framework-agnostic pure functions, same spirit as timeRemaining.ts.
 *
 * Algorithm (keep in sync with 0036's calculate_question_time — same
 * comment there):
 *   base (by question type)
 *   + prompt length   — 0.6s per word past the first 12, capped at +15s
 *   + option length    — multiple_choice/true_false only: 1s per 20 chars
 *                        of combined option text past 80, capped at +10s
 *   + matching pairs   — 4s per pair past the first 2
 *   + sequence items   — 4s per item past the first 3
 * ...rounded to the nearest 5 seconds, clamped to [MIN_SECONDS, MAX_SECONDS].
 */
import type { QuestionTypeRow } from "../types/database.types";

export const MIN_SECONDS = 10;
export const MAX_SECONDS = 60;

const BASE_SECONDS: Record<QuestionTypeRow, number> = {
  true_false: 10,
  multiple_choice: 15,
  identification: 15,
  fill_blank: 15,
  image: 15,
  unscramble: 18,
  matching: 20,
  sequence: 20,
};

export interface QuestionTimingInput {
  questionType: QuestionTypeRow;
  /** Word count of the prompt text. */
  promptWordCount: number;
  /** Combined character length of the answer options — multiple_choice/true_false only. */
  optionCharCount?: number;
  /** Number of term/definition pairs — matching only. */
  matchPairCount?: number;
  /** Number of items to order — sequence only. */
  sequenceItemCount?: number;
}

/** The exact per-question calculation, given real question content. */
export function calculateQuestionTime(input: QuestionTimingInput): number {
  let seconds = BASE_SECONDS[input.questionType];

  const extraWords = Math.max(0, input.promptWordCount - 12);
  seconds += Math.min(15, extraWords * 0.6);

  if (
    (input.questionType === "multiple_choice" || input.questionType === "true_false") &&
    input.optionCharCount &&
    input.optionCharCount > 80
  ) {
    seconds += Math.min(10, Math.floor((input.optionCharCount - 80) / 20));
  }

  if (input.matchPairCount) {
    seconds += Math.max(0, input.matchPairCount - 2) * 4;
  }

  if (input.sequenceItemCount) {
    seconds += Math.max(0, input.sequenceItemCount - 3) * 4;
  }

  const rounded = Math.round(seconds / 5) * 5;
  return Math.min(MAX_SECONDS, Math.max(MIN_SECONDS, rounded));
}

/**
 * Typical-case estimate per question type, used for the Create Game
 * summary preview (before any real question is known — see this file's
 * header). Each value is calculateQuestionTime() run against a
 * representative average-length question of that type, so the preview
 * stays consistent with what a real Smart Auto game will actually do on
 * an unremarkable question, without needing the real question bank.
 */
export const TYPICAL_SECONDS: Record<QuestionTypeRow, number> = {
  true_false: calculateQuestionTime({ questionType: "true_false", promptWordCount: 10 }),
  multiple_choice: calculateQuestionTime({
    questionType: "multiple_choice",
    promptWordCount: 12,
    optionCharCount: 60,
  }),
  identification: calculateQuestionTime({ questionType: "identification", promptWordCount: 10 }),
  fill_blank: calculateQuestionTime({ questionType: "fill_blank", promptWordCount: 10 }),
  image: calculateQuestionTime({ questionType: "image", promptWordCount: 8 }),
  unscramble: calculateQuestionTime({ questionType: "unscramble", promptWordCount: 8 }),
  matching: calculateQuestionTime({ questionType: "matching", promptWordCount: 6, matchPairCount: 4 }),
  sequence: calculateQuestionTime({ questionType: "sequence", promptWordCount: 6, sequenceItemCount: 5 }),
};

/**
 * Estimated average seconds/question for a set of enabled types, used by
 * the Create Game summary to project a total game duration under Smart
 * Auto. Equal-weighted across the enabled types — matches how start_game
 * actually draws questions (0031's balanced per-type allocation splits
 * question_count evenly across enabled types), so this estimate tracks
 * the real draw instead of assuming a multiple_choice-heavy mix.
 */
export function averageTypicalSeconds(enabledTypes: QuestionTypeRow[]): number {
  if (enabledTypes.length === 0) return TYPICAL_SECONDS.multiple_choice;
  const total = enabledTypes.reduce((sum, t) => sum + TYPICAL_SECONDS[t], 0);
  return total / enabledTypes.length;
}
