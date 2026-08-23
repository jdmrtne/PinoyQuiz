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
  // Added Phase 14 (supabase/migrations/0018_expand_categories.sql).
  politics_government: "Politics & Government",
  provinces_cities: "Provinces & Cities",
  languages: "Languages",
  literature: "Literature",
  music: "Music",
  movies_tv: "Movies & TV",
  celebrities: "Celebrities",
  festivals: "Festivals",
  mythology_folklore: "Mythology & Folklore",
  nature_wildlife: "Nature & Wildlife",
  landmarks: "Landmarks",
  innovations: "Inventions & Innovations",
  economy_business: "Economy & Business",
  technology: "Filipino Technology",
  religion_traditions: "Religion & Traditions",
  // Added Phase 16 (supabase/migrations/0020_science_medical_categories.sql).
  science: "Science",
  medical: "Medical",
};

export const CATEGORY_OPTIONS = Object.keys(
  CATEGORY_LABELS
) as GameCategorySetting[];

// CreateGame renders CATEGORY_OPTIONS as a flat SelectPills group (see
// src/pages/CreateGame.tsx). With 23 real categories + "Random", a flat
// grid is still scannable on desktop, but Phase 14 grouped it into
// labeled clusters for mobile — see CATEGORY_GROUPS below and its use in
// CreateGame.tsx's "Category" section.
export const CATEGORY_GROUPS: { label: string; options: GameCategorySetting[] }[] = [
  { label: "General", options: ["random", "trivia", "history", "geography"] },
  {
    label: "Culture & Life",
    options: [
      "culture",
      "food",
      "religion_traditions",
      "festivals",
      "mythology_folklore",
      "languages",
      "slang",
    ],
  },
  {
    label: "Arts & Entertainment",
    options: ["entertainment", "movies_tv", "music", "literature", "celebrities"],
  },
  {
    label: "Places & Society",
    options: [
      "provinces_cities",
      "landmarks",
      "nature_wildlife",
      "politics_government",
      "economy_business",
    ],
  },
  { label: "Sports & Innovation", options: ["sports", "innovations", "technology"] },
  { label: "Science & Medical", options: ["science", "medical"] },
];

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
