import { supabase, ensureAnonymousSession } from "./supabase";
import type {
  Database,
  GameCategorySetting,
  GameDifficultySetting,
  GameStatusRow,
} from "../types/database.types";
import type { AnswerReveal, LeaderboardEntry } from "../types/game";

type FunctionName = keyof Database["public"]["Functions"];

export class GameApiError extends Error {}

/** Maps raw Postgres exception text (see 0007_room_functions.sql) to what we show the user. */
function friendlyMessage(raw: string): string {
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
  ];
  const match = known.find((m) => raw.includes(m));
  return match ? raw : "Something went wrong. Please try again.";
}

type RpcReturnRow<Fn extends FunctionName> =
  Database["public"]["Functions"][Fn]["Returns"] extends (infer Row)[]
    ? Row
    : Database["public"]["Functions"][Fn]["Returns"];

async function callRpc<Fn extends FunctionName>(
  fn: Fn,
  args: Database["public"]["Functions"][Fn]["Args"]
): Promise<RpcReturnRow<Fn>> {
  await ensureAnonymousSession();
  const { data, error } = await supabase.rpc(fn, args);
  if (error) {
    throw new GameApiError(friendlyMessage(error.message));
  }
  // Supabase RPCs that `return table (...)` come back as an array of rows.
  const row = Array.isArray(data) ? data[0] : data;
  return row as RpcReturnRow<Fn>;
}

export interface CreateGameParams {
  category: GameCategorySetting;
  difficulty: GameDifficultySetting;
  questionCount: number;
  timeLimitSeconds: number;
  hostNickname: string;
}

export interface CreateGameResult {
  gameId: string;
  roomCode: string;
  playerId: string;
}

export async function createGame(
  params: CreateGameParams
): Promise<CreateGameResult> {
  const row = await callRpc("create_game", {
    p_category: params.category,
    p_difficulty: params.difficulty,
    p_question_count: params.questionCount,
    p_time_limit_seconds: params.timeLimitSeconds,
    p_host_nickname: params.hostNickname,
  });
  return {
    gameId: row.out_game_id,
    roomCode: row.out_room_code,
    playerId: row.out_player_id,
  };
}

export interface RoomLookup {
  found: boolean;
  status: GameStatusRow | null;
  category: GameCategorySetting | null;
  difficulty: GameDifficultySetting | null;
  questionCount: number | null;
  timeLimitSeconds: number | null;
}

export async function lookupGame(roomCode: string): Promise<RoomLookup> {
  const row = await callRpc("lookup_game_by_room_code", {
    p_room_code: roomCode,
  });
  return {
    found: row.found,
    status: row.status,
    category: row.category,
    difficulty: row.difficulty,
    questionCount: row.question_count,
    timeLimitSeconds: row.time_limit_seconds,
  };
}

export async function removePlayer(playerId: string): Promise<void> {
  await callRpc("remove_player", { p_player_id: playerId });
}

export async function startGame(gameId: string): Promise<void> {
  await callRpc("start_game", { p_game_id: gameId });
}

export async function beginFirstQuestion(gameId: string): Promise<void> {
  await callRpc("begin_first_question", { p_game_id: gameId });
}

export interface CurrentQuestion {
  questionId: string;
  prompt: string;
  options: [string, string, string, string];
  order: number;
  total: number;
  timeLimitSeconds: number;
  questionStartedAt: string;
}

/** Returns null if the game isn't currently in the QUESTION phase. */
export async function getCurrentQuestion(
  gameId: string
): Promise<CurrentQuestion | null> {
  await ensureAnonymousSession();
  const { data, error } = await supabase.rpc("get_current_question", {
    p_game_id: gameId,
  });
  if (error) throw new GameApiError(friendlyMessage(error.message));
  const row = data?.[0];
  if (!row) return null;
  return {
    questionId: row.out_question_id,
    prompt: row.out_prompt,
    options: [row.out_option_1, row.out_option_2, row.out_option_3, row.out_option_4],
    order: row.out_order,
    total: row.out_total,
    timeLimitSeconds: row.out_time_limit_seconds,
    questionStartedAt: row.out_question_started_at,
  };
}

export interface SubmitAnswerResult {
  isCorrect: boolean;
  points: number;
}

/** Selected option is the *displayed* slot (0-3), matching CurrentQuestion.options order. */
export async function submitAnswer(
  gameId: string,
  selectedOption: number
): Promise<SubmitAnswerResult> {
  const row = await callRpc("submit_answer", {
    p_game_id: gameId,
    p_selected_option: selectedOption,
  });
  return { isCorrect: row.out_is_correct, points: row.out_points };
}

/** Host-only. Flips QUESTION -> REVEAL, filling in "no answer" rows for anyone who didn't submit in time. */
export async function endQuestion(gameId: string): Promise<void> {
  await callRpc("end_question", { p_game_id: gameId });
}

/**
 * Reuses the domain-level AnswerReveal contract defined in src/types/game.ts
 * (Phase 1) rather than a second bespoke shape — `correctOptionIndex` is the
 * *displayed* slot (0-3), matching what QuestionScreen rendered from
 * CurrentQuestion.options, so highlighting "the option you saw" just works.
 */
export type { AnswerReveal };

/** Returns null if the game isn't currently in the REVEAL phase. */
export async function getAnswerReveal(
  gameId: string
): Promise<AnswerReveal | null> {
  await ensureAnonymousSession();
  const { data, error } = await supabase.rpc("get_answer_reveal", {
    p_game_id: gameId,
  });
  if (error) throw new GameApiError(friendlyMessage(error.message));
  const row = data?.[0];
  if (!row) return null;
  return {
    questionId: row.out_question_id,
    correctOptionIndex: row.out_correct_option,
    correctOptionText: row.out_correct_text,
    explanation: row.out_explanation ?? undefined,
    yourAnswerIndex: row.out_your_answer,
    yourPointsEarned: row.out_your_points,
    wasCorrect: row.out_was_correct,
    percentCorrect: row.out_percent_correct,
  };
}

/** Host-only. Flips REVEAL -> LEADERBOARD. */
export async function advanceToLeaderboard(gameId: string): Promise<void> {
  await callRpc("advance_to_leaderboard", { p_game_id: gameId });
}

export type { LeaderboardEntry };

/**
 * Ranked standings plus each player's score change from the question just
 * played. Any participant can call this while the game is on the
 * LEADERBOARD screen (or later, at FINISHED, for the final results page —
 * see get_leaderboard's comment in 0012_leaderboard.sql).
 */
export async function getLeaderboard(gameId: string): Promise<LeaderboardEntry[]> {
  await ensureAnonymousSession();
  const { data, error } = await supabase.rpc("get_leaderboard", {
    p_game_id: gameId,
  });
  if (error) throw new GameApiError(friendlyMessage(error.message));
  return (data ?? []).map((row) => ({
    playerId: row.out_player_id,
    nickname: row.out_nickname,
    score: row.out_score,
    rank: row.out_rank,
    scoreDelta: row.out_score_delta,
  }));
}

/**
 * Host-only. Advances LEADERBOARD -> next QUESTION, or -> FINISHED if the
 * leaderboard just shown was for the last question.
 */
export async function advanceQuestion(gameId: string): Promise<void> {
  await callRpc("advance_question", { p_game_id: gameId });
}

export interface JoinGameResult {
  gameId: string;
  playerId: string;
  status: GameStatusRow;
  isHost: boolean;
  reconnected: boolean;
}

export async function joinGame(
  roomCode: string,
  nickname: string
): Promise<JoinGameResult> {
  const row = await callRpc("join_game", {
    p_room_code: roomCode,
    p_nickname: nickname,
  });
  return {
    gameId: row.out_game_id,
    playerId: row.out_player_id,
    status: row.out_status,
    isHost: row.out_is_host,
    reconnected: row.out_reconnected,
  };
}
