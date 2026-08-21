import { describe, expect, it } from "vitest";
import {
  CATEGORY_LABELS,
  CATEGORY_OPTIONS,
  DIFFICULTY_LABELS,
  DIFFICULTY_OPTIONS,
  QUESTION_COUNT_OPTIONS,
  TIME_LIMIT_OPTIONS,
  GAME_MODE_LABELS,
  GAME_MODE_DESCRIPTIONS,
  GAME_MODE_OPTIONS,
  ANSWER_BEHAVIOR_LABELS,
  ANSWER_BEHAVIOR_DESCRIPTIONS,
  ANSWER_BEHAVIOR_OPTIONS,
} from "./gameOptions";

// These option lists back the CreateGame settings pills (SelectPills) and
// feed straight into create_game's p_category/p_difficulty/p_question_count/
// p_time_limit_seconds args (see gameApi.ts). A label silently missing for
// an option value would render "undefined" in the UI; this catches that at
// build/test time instead of by eyeballing every pill.
describe("gameOptions data integrity", () => {
  it("has a label for every category option, and no orphaned labels", () => {
    expect(new Set(CATEGORY_OPTIONS)).toEqual(
      new Set(Object.keys(CATEGORY_LABELS))
    );
  });

  it("has a label for every difficulty option, and no orphaned labels", () => {
    expect(new Set(DIFFICULTY_OPTIONS)).toEqual(
      new Set(Object.keys(DIFFICULTY_LABELS))
    );
  });

  it("always includes 'random' as a category option (the no-filter case start_game relies on)", () => {
    expect(CATEGORY_OPTIONS).toContain("random");
  });

  it("always includes 'mixed' as a difficulty option (the no-filter case start_game relies on)", () => {
    expect(DIFFICULTY_OPTIONS).toContain("mixed");
  });

  it("has no blank or duplicate category labels", () => {
    const labels = Object.values(CATEGORY_LABELS);
    expect(labels.every((l) => l.trim().length > 0)).toBe(true);
    expect(new Set(labels).size).toBe(labels.length);
  });

  it("question count and time limit options are non-empty, positive, and ascending", () => {
    for (const options of [QUESTION_COUNT_OPTIONS, TIME_LIMIT_OPTIONS]) {
      expect(options.length).toBeGreaterThan(0);
      expect(options.every((n) => n > 0)).toBe(true);
      expect(options).toEqual([...options].sort((a, b) => a - b));
    }
  });

  // 0015_automatic_mode_and_answer_behavior.sql — same integrity shape as
  // category/difficulty above: every option needs a label AND a short
  // description (the CreateGame screen shows both), with no orphans.
  it("has a label and description for every game mode option, and no orphans", () => {
    expect(new Set(GAME_MODE_OPTIONS)).toEqual(
      new Set(Object.keys(GAME_MODE_LABELS))
    );
    expect(new Set(GAME_MODE_OPTIONS)).toEqual(
      new Set(Object.keys(GAME_MODE_DESCRIPTIONS))
    );
  });

  it("always includes HOST_CONTROLLED as a game mode option (the pre-existing default)", () => {
    expect(GAME_MODE_OPTIONS).toContain("HOST_CONTROLLED");
  });

  it("has a label and description for every answer behavior option, and no orphans", () => {
    expect(new Set(ANSWER_BEHAVIOR_OPTIONS)).toEqual(
      new Set(Object.keys(ANSWER_BEHAVIOR_LABELS))
    );
    expect(new Set(ANSWER_BEHAVIOR_OPTIONS)).toEqual(
      new Set(Object.keys(ANSWER_BEHAVIOR_DESCRIPTIONS))
    );
  });

  it("always includes LOCK_ON_SELECTION as an answer behavior option (the pre-existing default)", () => {
    expect(ANSWER_BEHAVIOR_OPTIONS).toContain("LOCK_ON_SELECTION");
  });
});
