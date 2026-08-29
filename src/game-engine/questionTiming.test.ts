import { describe, expect, it } from "vitest";
import {
  calculateQuestionTime,
  averageTypicalSeconds,
  TYPICAL_SECONDS,
  MIN_SECONDS,
  MAX_SECONDS,
} from "./questionTiming";

describe("calculateQuestionTime", () => {
  it("gives true_false the shortest base time for a short prompt", () => {
    expect(calculateQuestionTime({ questionType: "true_false", promptWordCount: 8 })).toBe(10);
  });

  it("gives multiple_choice its normal base time for a short prompt and short options", () => {
    expect(
      calculateQuestionTime({
        questionType: "multiple_choice",
        promptWordCount: 8,
        optionCharCount: 30,
      })
    ).toBe(15);
  });

  it("adds time for a long prompt", () => {
    const short = calculateQuestionTime({ questionType: "identification", promptWordCount: 10 });
    const long = calculateQuestionTime({ questionType: "identification", promptWordCount: 40 });
    expect(long).toBeGreaterThan(short);
  });

  it("caps the prompt-length bonus so a very long prompt doesn't run away", () => {
    const veryLong = calculateQuestionTime({
      questionType: "identification",
      promptWordCount: 500,
    });
    expect(veryLong).toBeLessThanOrEqual(MAX_SECONDS);
  });

  it("adds time for long multiple_choice options but not for a short-option question", () => {
    const shortOptions = calculateQuestionTime({
      questionType: "multiple_choice",
      promptWordCount: 8,
      optionCharCount: 40,
    });
    const longOptions = calculateQuestionTime({
      questionType: "multiple_choice",
      promptWordCount: 8,
      optionCharCount: 160,
    });
    expect(longOptions).toBeGreaterThan(shortOptions);
  });

  it("ignores optionCharCount for question types that don't have options", () => {
    const withoutOptionCount = calculateQuestionTime({
      questionType: "identification",
      promptWordCount: 8,
    });
    const withOptionCount = calculateQuestionTime({
      questionType: "identification",
      promptWordCount: 8,
      optionCharCount: 500,
    });
    expect(withoutOptionCount).toBe(withOptionCount);
  });

  it("gives a matching question with many pairs more time than one with few", () => {
    const fewPairs = calculateQuestionTime({
      questionType: "matching",
      promptWordCount: 6,
      matchPairCount: 2,
    });
    const manyPairs = calculateQuestionTime({
      questionType: "matching",
      promptWordCount: 6,
      matchPairCount: 6,
    });
    expect(manyPairs).toBeGreaterThan(fewPairs);
  });

  it("gives a sequence question with many items more time than one with few", () => {
    const fewItems = calculateQuestionTime({
      questionType: "sequence",
      promptWordCount: 6,
      sequenceItemCount: 3,
    });
    const manyItems = calculateQuestionTime({
      questionType: "sequence",
      promptWordCount: 6,
      sequenceItemCount: 8,
    });
    expect(manyItems).toBeGreaterThan(fewItems);
  });

  it("never returns below the sensible minimum", () => {
    expect(
      calculateQuestionTime({ questionType: "true_false", promptWordCount: 0 })
    ).toBeGreaterThanOrEqual(MIN_SECONDS);
  });

  it("never returns above the sensible maximum, even for an extreme matching question", () => {
    expect(
      calculateQuestionTime({
        questionType: "matching",
        promptWordCount: 200,
        matchPairCount: 6,
      })
    ).toBeLessThanOrEqual(MAX_SECONDS);
  });

  it("rounds to the nearest 5 seconds", () => {
    const result = calculateQuestionTime({ questionType: "multiple_choice", promptWordCount: 15 });
    expect(result % 5).toBe(0);
  });

  it("is deterministic — same input always gives the same output", () => {
    const input = {
      questionType: "matching" as const,
      promptWordCount: 14,
      matchPairCount: 5,
    };
    expect(calculateQuestionTime(input)).toBe(calculateQuestionTime(input));
  });
});

describe("TYPICAL_SECONDS", () => {
  it("has an entry for every question type, each within the sensible bounds", () => {
    const types = Object.keys(TYPICAL_SECONDS) as (keyof typeof TYPICAL_SECONDS)[];
    expect(types.length).toBe(8);
    for (const t of types) {
      expect(TYPICAL_SECONDS[t]).toBeGreaterThanOrEqual(MIN_SECONDS);
      expect(TYPICAL_SECONDS[t]).toBeLessThanOrEqual(MAX_SECONDS);
    }
  });

  it("gives matching a longer typical time than true_false, reflecting real complexity", () => {
    expect(TYPICAL_SECONDS.matching).toBeGreaterThan(TYPICAL_SECONDS.true_false);
  });
});

describe("averageTypicalSeconds", () => {
  it("returns the multiple_choice typical time when no types are given", () => {
    expect(averageTypicalSeconds([])).toBe(TYPICAL_SECONDS.multiple_choice);
  });

  it("returns a single type's typical time unchanged", () => {
    expect(averageTypicalSeconds(["matching"])).toBe(TYPICAL_SECONDS.matching);
  });

  it("equal-weights every enabled type", () => {
    const avg = averageTypicalSeconds(["true_false", "matching"]);
    expect(avg).toBe((TYPICAL_SECONDS.true_false + TYPICAL_SECONDS.matching) / 2);
  });
});
