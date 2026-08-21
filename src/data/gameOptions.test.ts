import { describe, expect, it } from "vitest";
import {
  CATEGORY_LABELS,
  CATEGORY_OPTIONS,
  DIFFICULTY_LABELS,
  DIFFICULTY_OPTIONS,
  QUESTION_COUNT_OPTIONS,
  TIME_LIMIT_OPTIONS,
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
});
