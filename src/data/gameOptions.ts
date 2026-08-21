import type {
  GameCategorySetting,
  GameDifficultySetting,
  GameModeRow,
  AnswerBehaviorRow,
} from "../types/database.types";

export const CATEGORY_LABELS: Record<GameCategorySetting, string> = {
  random: "Random",
  history: "Philippine History",
  geography: "Geography",
  culture: "Filipino Culture",
  food: "Filipino Food",
  entertainment: "Entertainment",
  sports: "Philippine Sports",
  trivia: "Trivia",
  slang: "Slang & Language",
};

export const CATEGORY_OPTIONS = Object.keys(
  CATEGORY_LABELS
) as GameCategorySetting[];

export const DIFFICULTY_LABELS: Record<GameDifficultySetting, string> = {
  mixed: "Mixed",
  easy: "Easy",
  medium: "Medium",
  hard: "Hard",
};

export const DIFFICULTY_OPTIONS = Object.keys(
  DIFFICULTY_LABELS
) as GameDifficultySetting[];

export const QUESTION_COUNT_OPTIONS = [5, 10, 15, 20];
export const TIME_LIMIT_OPTIONS = [10, 15, 20, 30];

// Added for 0015_automatic_mode_and_answer_behavior.sql.
export const GAME_MODE_LABELS: Record<GameModeRow, string> = {
  HOST_CONTROLLED: "Host-Controlled",
  AUTOMATIC: "Automatic",
};

export const GAME_MODE_DESCRIPTIONS: Record<GameModeRow, string> = {
  HOST_CONTROLLED:
    "The host advances each question, reveal, and leaderboard manually.",
  AUTOMATIC:
    "Once started, the game runs itself — no clicking required from the host.",
};

export const GAME_MODE_OPTIONS: GameModeRow[] = ["HOST_CONTROLLED", "AUTOMATIC"];

export const ANSWER_BEHAVIOR_LABELS: Record<AnswerBehaviorRow, string> = {
  LOCK_ON_SELECTION: "Lock on Selection",
  CHANGE_UNTIL_TIMER_ENDS: "Change Until Timer Ends",
};

export const ANSWER_BEHAVIOR_DESCRIPTIONS: Record<AnswerBehaviorRow, string> = {
  LOCK_ON_SELECTION:
    "Your first tap is final — the answer locks in immediately.",
  CHANGE_UNTIL_TIMER_ENDS:
    "Change your mind as many times as you want. Only your last pick counts.",
};

export const ANSWER_BEHAVIOR_OPTIONS: AnswerBehaviorRow[] = [
  "LOCK_ON_SELECTION",
  "CHANGE_UNTIL_TIMER_ENDS",
];
