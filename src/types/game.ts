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
  prompt: string;
  options: [string, string, string, string];
  order: number;
  totalQuestions: number;
}

export interface AnswerReveal {
  questionId: string;
  correctOptionIndex: number;
  correctOptionText: string;
  explanation?: string;
  yourAnswerIndex: number | null;
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
