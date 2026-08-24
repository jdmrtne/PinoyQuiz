// Core domain types for Pinoy Quiz.
// These mirror the Supabase schema planned in docs/ARCHITECTURE.md (Phase 2).
// Kept here ahead of the DB work so client code has a stable contract to build against.

export type GameStatus =
  | "WAITING"
  | "COUNTDOWN"
  | "QUESTION"
  | "REVEAL"
  | "LEADERBOARD"
  | "FINISHED";

export type Category =
  | "history"
  | "geography"
  | "culture"
  | "food"
  | "entertainment"
  | "sports"
  | "trivia"
  | "slang"
  | "random";

export type Difficulty = "easy" | "medium" | "hard" | "mixed";

/**
 * Added Phase 1 of the question-types work (0026_question_types_phase1.sql).
 * More values (unscramble, matching, image, sequence, scenario) arrive in
 * later phases of the question-types work (tracked separately from the
 * numbered Phase 1-15 roadmap in docs/MASTER_HANDOFF.md — see that doc's
 * "Question types" section once added, or the 0026/0028 migration headers).
 */
export type QuestionType =
  | "multiple_choice"
  | "true_false"
  | "identification"
  | "fill_blank"
  | "unscramble"
  | "matching"
  | "image"
  | "sequence";

/** Added alongside 0015_automatic_mode_and_answer_behavior.sql. */
export type GameMode = "HOST_CONTROLLED" | "AUTOMATIC";
export type AnswerBehavior = "LOCK_ON_SELECTION" | "CHANGE_UNTIL_TIMER_ENDS";

export interface GameSettings {
  category: Category;
  difficulty: Difficulty;
  questionCount: number;
  timeLimitSeconds: number;
  gameMode: GameMode;
  answerBehavior: AnswerBehavior;
  /** Added Phase 1 of the question-types work — opt in to true_false/identification/fill_blank alongside multiple_choice. */
  includeNewQuestionTypes?: boolean;
  /** Added Phase 3 of the question-types work — explicit Mixed Mode type selection; takes precedence over includeNewQuestionTypes when set. */
  enabledQuestionTypes?: QuestionType[];
}

export interface Game {
  id: string;
  roomCode: string;
  hostId: string;
  status: GameStatus;
  settings: GameSettings;
  currentQuestionIndex: number;
  createdAt: string;
  startedAt: string | null;
  finishedAt: string | null;
}

export interface Player {
  id: string;
  gameId: string;
  nickname: string;
  score: number;
  isHost: boolean;
  connected: boolean;
  joinedAt: string;
}

/**
 * Client-safe question shape — NEVER includes which option is correct.
 * The correct answer only ever exists server-side until the REVEAL phase.
 */
export interface ClientQuestion {
  id: string;
  category: Exclude<Category, "random">;
  difficulty: Difficulty;
  questionType: QuestionType;
  prompt: string;
  /** Populated left-to-right; entries past this type's real option count are null (see CurrentQuestion in gameApi.ts). */
  options: [string | null, string | null, string | null, string | null];
  /** image type only. */
  imageUrl: string | null;
  /** unscramble only — per-game shuffled letters. */
  scrambleLetters: string[] | null;
  /** matching only. */
  matchTerms: string[] | null;
  /** matching only, in shuffled displayed order. */
  matchDefinitions: string[] | null;
  /** sequence only, in shuffled displayed order. */
  sequenceItems: string[] | null;
  order: number;
  totalQuestions: number;
}

export interface AnswerReveal {
  questionId: string;
  questionType: QuestionType;
  /** Choice-based types (multiple_choice/true_false) only — null for other types. */
  correctOptionIndex: number | null;
  correctOptionText: string | null;
  /** Text-answer types (identification/fill_blank/unscramble/image) only — the canonical accepted answer. */
  correctAnswer: string | null;
  /** image type only. */
  imageUrl: string | null;
  /** matching only, canonical (unshuffled) order. */
  matchTerms: string[] | null;
  matchDefinitions: string[] | null;
  /** matching only — this player's submitted pairing. */
  yourPairing: number[] | null;
  /** sequence only, canonical (unshuffled) order. */
  sequenceItems: string[] | null;
  /** sequence only — this player's submitted arrangement. */
  yourSequence: number[] | null;
  explanation?: string;
  yourAnswerIndex: number | null;
  /** This player's typed submission — text-answer types only. */
  yourTextAnswer: string | null;
  yourPointsEarned: number;
  wasCorrect: boolean;
  percentCorrect: number;
}

export interface LeaderboardEntry {
  playerId: string;
  nickname: string;
  score: number;
  rank: number;
  scoreDelta: number;
}

/** Configurable scoring — never hard-coded into game logic (see game-engine/scoring.ts). */
export interface ScoringConfig {
  basePoints: number;
  maxSpeedBonus: number;
  incorrectPoints: number;
  noAnswerPoints: number;
}
