import { supabase, ensureAnonymousSession } from "./supabase";
import type {
  Database,
  GameCategorySetting,
  GameDifficultySetting,
  GameStatusRow,
  GameModeRow,
  AnswerBehaviorRow,
  QuestionCategoryRow,
  QuestionTypeRow,
} from "../types/database.types";
import type { AnswerReveal, LeaderboardEntry } from "../types/game";

type FunctionName = keyof Database["public"]["Functions"];

export class GameApiError extends Error {}

/**
 * Maps raw Postgres exception text (see 0007_room_functions.sql) to what we
 * show the user. Exported (Phase 11) purely so it has a direct unit test —
 * still only meant to be called from within this module.
 */
export function friendlyMessage(raw: string): string {
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
    // Added 0026_question_types_phase1.sql
    "This question needs a typed answer",
    "This question needs an option, not typed text",
    // Added 0028_question_types_phase2.sql
    "This question needs a different kind of answer",
    "You need to match every term before submitting",
    // Added 0030_question_types_phase3.sql
    "You need to place every item before submitting",
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
  /** Defaults to HOST_CONTROLLED server-side if omitted (0015 migration). */
  gameMode?: GameModeRow;
  /** Defaults to LOCK_ON_SELECTION server-side if omitted (0015 migration). */
  answerBehavior?: AnswerBehaviorRow;
  /**
   * Custom Mix (0022 migration). When set (non-empty), question selection
   * is restricted to just these categories instead of the single
   * `category` value — pass `category: "random"` alongside it, since
   * that's what the single-select fallback path would otherwise use.
   */
  categories?: QuestionCategoryRow[];
  /**
   * Phase 1 of the question-types work (0026 migration). Defaults to
   * false server-side, so omitting it keeps a game pure multiple_choice —
   * identical to pre-Phase-1 behavior. Set true to draw from true_false/
   * identification/fill_blank too.
   */
  includeNewQuestionTypes?: boolean;
  /**
   * Phase 3 of the question-types work (0030 migration) — explicit Mixed
   * Mode type selection. Takes precedence over includeNewQuestionTypes
   * when set (see resolve_enabled_question_types in that migration).
   */
  enabledQuestionTypes?: QuestionTypeRow[];
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
    p_game_mode: params.gameMode,
    p_answer_behavior: params.answerBehavior,
    p_categories: params.categories,
    p_include_new_question_types: params.includeNewQuestionTypes,
    p_enabled_question_types: params.enabledQuestionTypes,
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
  /** Custom Mix (0022 migration) — see categoryDisplayLabel in gameOptions.ts. */
  categories: QuestionCategoryRow[] | null;
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
    categories: row.categories,
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
  /** Added Phase 1 of the question-types work. */
  questionType: QuestionTypeRow;
  prompt: string;
  /**
   * Populated left-to-right; entries past this question type's real
   * option count are null. multiple_choice: all 4. true_false: only the
   * first 2 (rendered as TRUE/FALSE, not lettered choices — see
   * QuestionScreen.tsx). identification/fill_blank: all null — there's
   * no options grid, just a text input.
   */
  options: [string | null, string | null, string | null, string | null];
  /** image type only. */
  imageUrl: string | null;
  /** unscramble only — per-game shuffled letters. */
  scrambleLetters: string[] | null;
  /** matching only. */
  matchTerms: string[] | null;
  /** matching only, in shuffled displayed order. */
  matchDefinitions: string[] | null;
  /** sequence only, in shuffled displayed order. */
  sequenceItems: string[] | null;
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
    questionType: row.out_question_type,
    prompt: row.out_prompt,
    options: [row.out_option_1, row.out_option_2, row.out_option_3, row.out_option_4],
    imageUrl: row.out_image_url,
    scrambleLetters: row.out_scramble_letters,
    matchTerms: row.out_match_terms,
    matchDefinitions: row.out_match_definitions,
    sequenceItems: row.out_sequence_items,
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

/**
 * Selected option is the *displayed* slot, matching CurrentQuestion.options
 * order (0-3 for multiple_choice, 0-1 for true_false). Only valid for
 * choice-based question types — see submitTextAnswer for identification/
 * fill_blank.
 */
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

/**
 * identification/fill_blank counterpart to submitAnswer. Sends the
 * player's raw typed text — trimming/case-folding happens server-side in
 * submit_text_answer, so this is intentionally a thin passthrough.
 */
export async function submitTextAnswer(
  gameId: string,
  answerText: string
): Promise<SubmitAnswerResult> {
  const row = await callRpc("submit_text_answer", {
    p_game_id: gameId,
    p_answer_text: answerText,
  });
  return { isCorrect: row.out_is_correct, points: row.out_points };
}

/**
 * matching counterpart to submitAnswer. pairing[i] is the *displayed*
 * definition slot the player assigned to matchTerms[i] (matching
 * CurrentQuestion.matchTerms/matchDefinitions order) — grading happens
 * server-side in submit_matching_answer.
 */
export async function submitMatchingAnswer(
  gameId: string,
  pairing: number[]
): Promise<SubmitAnswerResult> {
  const row = await callRpc("submit_matching_answer", {
    p_game_id: gameId,
    p_pairing: pairing,
  });
  return { isCorrect: row.out_is_correct, points: row.out_points };
}

/**
 * sequence counterpart to submitAnswer. order[i] is the *displayed* item
 * slot the player placed at chronological position i (matching
 * CurrentQuestion.sequenceItems order) — grading happens server-side in
 * submit_sequence_answer.
 */
export async function submitSequenceAnswer(
  gameId: string,
  order: number[]
): Promise<SubmitAnswerResult> {
  const row = await callRpc("submit_sequence_answer", {
    p_game_id: gameId,
    p_order: order,
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
    questionType: row.out_question_type,
    correctOptionIndex: row.out_correct_option,
    correctOptionText: row.out_correct_text,
    correctAnswer: row.out_correct_answer,
    imageUrl: row.out_image_url,
    matchTerms: row.out_match_terms,
    matchDefinitions: row.out_match_definitions,
    yourPairing: row.out_your_pairing,
    sequenceItems: row.out_sequence_items,
    yourSequence: row.out_your_sequence,
    explanation: row.out_explanation ?? undefined,
    yourAnswerIndex: row.out_your_answer,
    yourTextAnswer: row.out_your_text_answer,
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

/**
 * Phase 8 — disconnect/reconnect handling. See
 * supabase/migrations/0013_disconnect_reconnect.sql for the mechanism and
 * why a heartbeat/staleness approach was chosen over Realtime Presence.
 */

/** Called periodically by every client to prove this player is still around. */
export async function heartbeat(gameId: string): Promise<void> {
  await callRpc("heartbeat", { p_game_id: gameId });
}

/**
 * Called periodically by every client (not just the host's) — sweeps this
 * game's roster and flips `connected=false` for anyone who's missed too
 * many heartbeats. The resulting change reaches every client through the
 * existing `players` Realtime subscription (Phase 4), same as any other
 * roster update.
 */
export async function markStalePlayers(gameId: string): Promise<void> {
  await callRpc("mark_stale_players", { p_game_id: gameId });
}

export interface ClaimHostResult {
  newHostPlayerId: string;
  newHostNickname: string;
}

/**
 * Takes over as host once the current host has gone stale. Server-side
 * picks the new host deterministically (earliest-joined connected player,
 * excluding the stale host) — the caller doesn't have to be, and usually
 * isn't, the player who ends up hosting. Rejected with a friendly message
 * if the current host isn't actually stale yet.
 */
export async function claimHost(gameId: string): Promise<ClaimHostResult> {
  const row = await callRpc("claim_host", { p_game_id: gameId });
  return {
    newHostPlayerId: row.out_new_host_player_id,
    newHostNickname: row.out_new_host_nickname,
  };
}

/**
 * Automatic mode (0015_automatic_mode_and_answer_behavior.sql). Any
 * participant calls this on a short poll interval whenever
 * games.game_mode === "AUTOMATIC" — see src/hooks/useAutoAdvance.ts. It's a
 * silent no-op unless the current phase's server-anchored timer has
 * actually elapsed, so calling it redundantly/concurrently from every
 * connected client is expected and harmless (the DB function row-locks and
 * re-checks before acting). This is what keeps an Automatic-mode game
 * moving even if the host's tab closes — every other client keeps polling
 * independently.
 */
export async function autoAdvanceGame(gameId: string): Promise<void> {
  await callRpc("auto_advance_game", { p_game_id: gameId });
}

/**
 * Rematch, in place (0016_play_again_and_no_repeat_questions.sql). Host-only,
 * only once the game has reached FINISHED. Resets the SAME games row/room
 * to WAITING with a fresh round and every score back to 0 — players table
 * is never touched, so nobody needs to rejoin or retype their nickname.
 * The status change reaches every client (host included) through the
 * existing Realtime subscription; see Results.tsx's navigate-back-to-
 * GameRoom effect.
 */
export async function playAgain(gameId: string): Promise<void> {
  await callRpc("play_again", { p_game_id: gameId });
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
