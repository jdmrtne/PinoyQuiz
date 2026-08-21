import { describe, expect, it } from "vitest";
import { friendlyMessage } from "./gameApi";

describe("friendlyMessage", () => {
  it("passes through a known error verbatim", () => {
    expect(friendlyMessage("This room is full")).toBe("This room is full");
  });

  it("passes through a known error even wrapped in Postgres's raw exception noise", () => {
    // Real supabase-js error.message shape includes context Postgres adds
    // around the RAISE EXCEPTION text, not just the bare string.
    const raw =
      'That nickname is already taken in this room, code: 22023, details: ...';
    expect(friendlyMessage(raw)).toBe(raw);
  });

  it("falls back to a generic message for anything unrecognized", () => {
    expect(friendlyMessage("relation \"players\" does not exist")).toBe(
      "Something went wrong. Please try again."
    );
  });

  it("falls back to a generic message for an empty string", () => {
    expect(friendlyMessage("")).toBe("Something went wrong. Please try again.");
  });

  it("recognizes every known-message substring without throwing", () => {
    const known = [
      "You must be signed in",
      "Nickname must be between 1 and 20 characters",
      "That room code doesn't exist",
      "This game has already started",
      "That nickname is already taken in this room",
      "This room is full",
      "Could not allocate a room code",
      "Only the host can remove players",
      "You can't remove yourself",
      "That player has already left the room",
      "You need at least one player to start",
      "Not enough questions available",
      "This game is not ready to begin",
      "No questions were prepared for this game",
      "You are not part of this game",
      "Only the host can do that",
      "That is not a valid answer option",
      "This question is no longer accepting answers",
      "You already answered this question",
      "This game is not in the question phase",
      "This game is not in the reveal phase",
      "This game is not on the leaderboard screen",
      "The host is still connected",
      "You are already the host",
      "No other connected players are available to become host",
      "This game has already finished",
      "This game has no host on record",
      "You are doing that too fast",
    ];
    for (const message of known) {
      expect(friendlyMessage(message)).toBe(message);
    }
  });
});
