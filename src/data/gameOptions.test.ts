import { describe, expect, it } from "vitest";
import {
  CATEGORY_GROUPS,
  CATEGORY_LABELS,
  CATEGORY_OPTIONS,
  CUSTOM_MIX_GROUPS,
  categoryDisplayLabel,
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

  // Phase 14: CreateGame renders CATEGORY_GROUPS instead of a flat
  // CATEGORY_OPTIONS list once the category count grew past 8. These tests
  // catch the two ways that grouping can silently drift from the source of
  // truth (CATEGORY_LABELS): a new category added to CATEGORY_LABELS but
  // forgotten in CATEGORY_GROUPS (invisible in the UI), or a stray/renamed
  // option left in a group after a label is removed (crashes the pill's
  // label lookup at render time).
  it("CATEGORY_GROUPS contains every category option exactly once, with no unknown options", () => {
    const grouped = CATEGORY_GROUPS.flatMap((g) => g.options);
    expect(new Set(grouped)).toEqual(new Set(CATEGORY_OPTIONS));
    expect(grouped.length).toBe(CATEGORY_OPTIONS.length);
  });

  it("every CATEGORY_GROUPS entry has a non-blank label and at least one option", () => {
    for (const group of CATEGORY_GROUPS) {
      expect(group.label.trim().length).toBeGreaterThan(0);
      expect(group.options.length).toBeGreaterThan(0);
    }
  });

  // 0022_custom_category_mix.sql — CUSTOM_MIX_GROUPS is CATEGORY_GROUPS
  // with "random" stripped out (a custom mix is a set of real categories;
  // "random" isn't a pickable member of that set, it's the single-select
  // mode's own separate option). These tests catch the same two drift
  // failure modes as the CATEGORY_GROUPS tests above, plus the "random"
  // exclusion itself.
  describe("CUSTOM_MIX_GROUPS", () => {
    it("contains every real category option exactly once, excluding random", () => {
      const grouped = CUSTOM_MIX_GROUPS.flatMap((g) => g.options);
      const realCategories = CATEGORY_OPTIONS.filter((c) => c !== "random");
      expect(new Set(grouped)).toEqual(new Set(realCategories));
      expect(grouped.length).toBe(realCategories.length);
    });

    it("never includes random in any group", () => {
      for (const group of CUSTOM_MIX_GROUPS) {
        expect(group.options).not.toContain("random");
      }
    });

    it("every group has a non-blank label and at least one option", () => {
      for (const group of CUSTOM_MIX_GROUPS) {
        expect(group.label.trim().length).toBeGreaterThan(0);
        expect(group.options.length).toBeGreaterThan(0);
      }
    });
  });

  describe("categoryDisplayLabel", () => {
    it("falls back to the single category's label when categories is null/undefined/empty", () => {
      expect(categoryDisplayLabel("history", null)).toBe(CATEGORY_LABELS.history);
      expect(categoryDisplayLabel("random", undefined)).toBe(CATEGORY_LABELS.random);
      expect(categoryDisplayLabel("science", [])).toBe(CATEGORY_LABELS.science);
    });

    it("shows the single category's own label when exactly one custom category is set", () => {
      // Even though the game's `category` column is 'random' in this case
      // (see 0022's header comment), the display should read as the one
      // actual category picked, not "Random".
      expect(categoryDisplayLabel("random", ["medical"])).toBe(
        CATEGORY_LABELS.medical
      );
    });

    it("shows a 'Custom Mix (N)' summary when multiple custom categories are set", () => {
      expect(categoryDisplayLabel("random", ["science", "medical"])).toBe(
        "Custom Mix (2)"
      );
      expect(
        categoryDisplayLabel("random", ["science", "medical", "history"])
      ).toBe("Custom Mix (3)");
    });
  });
});
