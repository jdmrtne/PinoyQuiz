import { describe, expect, it } from "vitest";
import { computeRemainingSeconds } from "./timeRemaining";

describe("computeRemainingSeconds", () => {
  it("returns the full duration when no start time is set yet", () => {
    expect(computeRemainingSeconds(null, 20)).toBe(20);
  });

  it("returns the full duration at the exact start instant", () => {
    const start = "2026-01-01T00:00:00.000Z";
    const now = new Date(start).getTime();
    expect(computeRemainingSeconds(start, 20, now)).toBe(20);
  });

  it("counts down as elapsed time increases", () => {
    const start = "2026-01-01T00:00:00.000Z";
    const now = new Date(start).getTime() + 7_000; // 7s elapsed
    expect(computeRemainingSeconds(start, 20, now)).toBe(13);
  });

  it("rounds a partial second up, so the display never shows 0 early", () => {
    const start = "2026-01-01T00:00:00.000Z";
    const now = new Date(start).getTime() + 12_400; // 12.4s elapsed
    expect(computeRemainingSeconds(start, 20, now)).toBe(8);
  });

  it("clamps at 0 once the duration has fully elapsed", () => {
    const start = "2026-01-01T00:00:00.000Z";
    const now = new Date(start).getTime() + 20_000;
    expect(computeRemainingSeconds(start, 20, now)).toBe(0);
  });

  it("clamps at 0 rather than going negative for a very late render", () => {
    const start = "2026-01-01T00:00:00.000Z";
    const now = new Date(start).getTime() + 999_000;
    expect(computeRemainingSeconds(start, 20, now)).toBe(0);
  });

  it("handles a slow-loading client correctly — first render already reflects real elapsed time", () => {
    // Regression case documented in useServerTimer.ts: the client only
    // learns startedAtIso well after the server actually started the
    // question, so the very first computation must already show reduced
    // time, not a fresh full countdown.
    const start = "2026-01-01T00:00:00.000Z";
    const clientLoadedAt = new Date(start).getTime() + 5_000;
    expect(computeRemainingSeconds(start, 20, clientLoadedAt)).toBe(15);
  });
});
