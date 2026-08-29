import {
  CheckCircle2,
  ToggleLeft,
  Type,
  TextCursorInput,
  Shuffle,
  Link2,
  Image as ImageIcon,
  ListOrdered,
  type LucideIcon,
} from "lucide-react";
import type {
  GameCategorySetting,
  GameDifficultySetting,
  GameModeRow,
  AnswerBehaviorRow,
  QuestionCategoryRow,
  QuestionTypeRow,
  TimingStrategyRow,
} from "../types/database.types";

export const CATEGORY_LABELS: Record<GameCategorySetting, string> = {
  random: "All Categories",
  // Philippine-scoped categories. Several share a name with a Phase 16
  // general-knowledge category below (History, Geography, Music, etc.)
  // but contain only Philippine-focused questions — labeled with a
  // "Philippine"/"Filipino" prefix so the two are never confused in the
  // picker. This is a label-only change; the underlying enum values and
  // stored questions are untouched (see 0020's migration header).
  history: "Philippine History",
  geography: "Philippine Geography",
  culture: "Filipino Culture",
  food: "Filipino Food",
  entertainment: "Philippine Entertainment",
  sports: "Philippine Sports",
  trivia: "Philippine Trivia",
  slang: "Filipino Slang",
  // Added Phase 15 (supabase/migrations/0018_expand_categories.sql).
  politics_government: "Philippine Politics & Government",
  provinces_cities: "Philippine Provinces & Cities",
  languages: "Philippine Languages",
  literature: "Philippine Literature",
  music: "Philippine Music",
  movies_tv: "Philippine Movies & TV",
  celebrities: "Philippine Celebrities",
  festivals: "Philippine Festivals",
  mythology_folklore: "Philippine Mythology & Folklore",
  nature_wildlife: "Philippine Nature & Wildlife",
  landmarks: "Philippine Landmarks",
  innovations: "Philippine Inventions & Innovations",
  economy_business: "Philippine Economy & Business",
  technology: "Filipino Technology",
  religion_traditions: "Philippine Religion & Traditions",
  // Added Phase 16 (supabase/migrations/0020_science_medical_categories.sql
  // + 0023_expand_general_categories.sql) — general-knowledge subjects,
  // deliberately NOT Philippines-scoped.
  science: "Science",
  medical: "Medical",
  mathematics: "Mathematics",
  world_technology: "Technology",
  computer_science: "Computer Science",
  world_geography: "Geography",
  world_history: "History",
  world_literature: "Literature",
  general_language: "Language",
  arts: "Arts",
  world_music: "Music",
  world_movies_tv: "Movies & TV",
  world_sports: "Sports",
  world_food: "Food & Cooking",
  animals: "Animals",
  general_nature: "Nature & Environment",
  space_astronomy: "Space & Astronomy",
  human_body: "Human Body",
  business_economics: "Business & Economics",
  logic_reasoning: "Logic & Reasoning",
  general_trivia: "General Trivia",
};

export const CATEGORY_OPTIONS = Object.keys(
  CATEGORY_LABELS
) as GameCategorySetting[];

// "All Categories" (the pre-existing `random` setting) is rendered as its
// own standalone pick above both sections below, not inside either one —
// see CreateGame.tsx.
export const ALL_CATEGORIES_OPTION: GameCategorySetting = "random";

type CategoryGroup = { label: string; options: GameCategorySetting[] };
type CategorySection = { label: string; groups: CategoryGroup[] };

// Phase 16 grew the category count from 24 (23 + Random) to 45. CreateGame
// renders two named sections — "General Knowledge" and "Philippines" —
// each broken into small labeled clusters, so the picker stays scannable
// instead of becoming one wall of pills. Same SelectPills component and
// visual style throughout; only the section/group structure differs.
export const CATEGORY_SECTIONS: CategorySection[] = [
  {
    label: "General Knowledge",
    groups: [
      {
        label: "Sciences & Tech",
        options: ["science", "medical", "mathematics", "world_technology", "computer_science"],
      },
      {
        label: "World Knowledge",
        options: ["world_geography", "world_history", "world_literature", "general_language"],
      },
      {
        label: "Culture & Media",
        options: ["arts", "world_music", "world_movies_tv", "world_sports"],
      },
      {
        label: "Life & Nature",
        options: ["world_food", "animals", "general_nature", "space_astronomy"],
      },
      {
        label: "Body, Business & Mind",
        options: ["human_body", "business_economics", "logic_reasoning", "general_trivia"],
      },
    ],
  },
  {
    label: "Philippines",
    groups: [
      { label: "General", options: ["trivia", "history", "geography"] },
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
    ],
  },
];

// 0022's Custom Mix picker multi-selects real categories only (no "random"
// pill; zero selected just isn't a valid custom mix, distinct from picking
// "Random"/"All Categories" in single-select mode). Flattens both
// CATEGORY_SECTIONS sections into one list of groups — every group label
// across the two sections is unique (see gameOptions.test.ts), so this is
// safe to render as a single flat list in the Custom Mix UI.
export const CUSTOM_MIX_GROUPS: { label: string; options: QuestionCategoryRow[] }[] =
  CATEGORY_SECTIONS.flatMap((section) => section.groups)
    .map((group) => ({
      label: group.label,
      options: group.options.filter(
        (opt): opt is QuestionCategoryRow => opt !== "random"
      ),
    }))
    .filter((group) => group.options.length > 0);

/**
 * What the lobby/pre-join screens show for a game's category setting.
 * Custom Mix (0022) takes priority over the single `category` value when
 * present — see games.categories' column comment in
 * 0022_custom_category_mix.sql. Matches CATEGORY_LABELS's fallback shape:
 * one category reads as just its label, several read as a short "Custom
 * Mix (N)" summary rather than spelling all of them out inline.
 */
export function categoryDisplayLabel(
  category: GameCategorySetting,
  categories: QuestionCategoryRow[] | null | undefined
): string {
  if (categories && categories.length > 0) {
    if (categories.length === 1) {
      return CATEGORY_LABELS[categories[0]];
    }
    return `Custom Mix (${categories.length})`;
  }
  return CATEGORY_LABELS[category];
}

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

// Added Question-Types Phase 3 (0030_question_types_phase3.sql), expanded
// in the Game Setup redesign to cover every type (including
// multiple_choice) with an icon + short description for the Step 2 "Game
// Modes" picker (ModeCard). Every type here — multiple_choice included —
// is a plain toggleable card; the host must enable at least one (see
// CreateGame.tsx's Step 2 validation) but none is locked or forced on.
export const QUESTION_TYPE_LABELS: Record<QuestionTypeRow, string> = {
  multiple_choice: "Multiple Choice",
  true_false: "True / False",
  identification: "Identification",
  fill_blank: "Fill in the Blank",
  unscramble: "Unscramble",
  matching: "Matching",
  image: "Image ID",
  sequence: "Sequence",
};

export const QUESTION_TYPE_DESCRIPTIONS: Record<QuestionTypeRow, string> = {
  multiple_choice: "Choose the correct answer from four options.",
  true_false: "Decide whether the statement is true or false.",
  identification: "Type the answer from memory — no options shown.",
  fill_blank: "Type the missing word or phrase.",
  unscramble: "Unscramble the shuffled letters to spell the answer.",
  matching: "Pair up terms with their matching definitions.",
  image: "Identify what's shown in the picture.",
  sequence: "Put the items in the correct order.",
};

export const QUESTION_TYPE_ICONS: Record<QuestionTypeRow, LucideIcon> = {
  multiple_choice: CheckCircle2,
  true_false: ToggleLeft,
  identification: Type,
  fill_blank: TextCursorInput,
  unscramble: Shuffle,
  matching: Link2,
  image: ImageIcon,
  sequence: ListOrdered,
};

export const QUESTION_TYPE_OPTIONS: QuestionTypeRow[] = Object.keys(
  QUESTION_TYPE_LABELS
) as QuestionTypeRow[];

// Added 0036_smart_timing.sql.
export const TIMING_STRATEGY_LABELS: Record<TimingStrategyRow, string> = {
  fixed: "Fixed Time",
  smart: "Smart / Auto Time",
};

export const TIMING_STRATEGY_DESCRIPTIONS: Record<TimingStrategyRow, string> = {
  fixed: "Every question gets the same number of seconds.",
  smart:
    "The time per question is calculated automatically from its type and complexity — short questions run faster, complex ones get more time.",
};

export const TIMING_STRATEGY_OPTIONS: TimingStrategyRow[] = ["fixed", "smart"];
