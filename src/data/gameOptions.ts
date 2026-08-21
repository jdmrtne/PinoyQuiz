import type {
  GameCategorySetting,
  GameDifficultySetting,
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
