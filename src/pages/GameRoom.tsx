import { useEffect, useRef, useState } from "react";
import { useParams, useLocation, useNavigate, Link } from "react-router-dom";
import { Card } from "../components/ui/Card";
import { Button } from "../components/ui/Button";
import { InviteBox } from "../components/lobby/InviteBox";
import { PlayerRoster } from "../components/lobby/PlayerRoster";
import { CountdownOverlay } from "../components/game/CountdownOverlay";
import { QuestionScreen } from "../components/game/QuestionScreen";
import { RevealScreen } from "../components/game/RevealScreen";
import { LeaderboardScreen } from "../components/game/LeaderboardScreen";
import { HostDisconnectedBanner } from "../components/game/HostDisconnectedBanner";
import { categoryDisplayLabel, DIFFICULTY_LABELS, GAME_MODE_LABELS, ANSWER_BEHAVIOR_LABELS } from "../data/gameOptions";
import { useGameRealtime } from "../hooks/useGameRealtime";
import { useServerTimer } from "../hooks/useServerTimer";
import { useCurrentUserId } from "../hooks/useCurrentUserId";
import { useHeartbeat } from "../hooks/useHeartbeat";
import { useAutoAdvance } from "../hooks/useAutoAdvance";
import {
  removePlayer,
  startGame,
  beginFirstQuestion,
  getCurrentQuestion,
  submitAnswer,
  submitTextAnswer,
  endQuestion,
  getAnswerReveal,
  advanceToLeaderboard,
  getLeaderboard,
  advanceQuestion,
  claimHost,
  GameApiError,
  type CurrentQuestion,
  type AnswerReveal,
  type LeaderboardEntry,
} from "../lib/gameApi";

export default function GameRoom() {
  const { roomCode } = useParams();
  const location = useLocation();
  const navigate = useNavigate();
  const navState = location.state as { playerId?: string; isHost?: boolean } | null;
  const { state, game, players } = useGameRealtime(roomCode);
  const [actionError, setActionError] = useState<string | null>(null);
  const [starting, setStarting] = useState(false);
  const [question, setQuestion] = useState<CurrentQuestion | null>(null);
  const [answeredIndex, setAnsweredIndex] = useState<number | null>(null);
  const [answeredText, setAnsweredText] = useState<string | null>(null);
  const [reveal, setReveal] = useState<AnswerReveal | null>(null);
  const [leaderboard, setLeaderboard] = useState<LeaderboardEntry[] | null>(null);
  const [advancing, setAdvancing] = useState(false);
  const [claimingHost, setClaimingHost] = useState(false);
  const endQuestionCalledRef = useRef<string | null>(null);

  // Phase 8: "who am I in this game" no longer relies solely on
  // location.state — that's only present when you *navigated* here from
  // CreateGame/JoinGame, and is gone after a hard refresh or opening a
  // saved/shared /game/:roomCode link directly. Once the roster has
  // loaded, find our own row by matching this browser's persisted auth
  // session (see useCurrentUserId) against players[].user_id — RLS already
  // exposes that column to any fellow participant (Phase 2). navState is
  // kept only as a fallback for the brief window before the roster's
  // first fetch resolves, so there's no flash of "not host" for a host
  // who just created the game.
  const userId = useCurrentUserId();
  const myPlayer = players.find((p) => p.user_id === userId) ?? null;
  const isHost = myPlayer?.is_host ?? navState?.isHost ?? false;
  const currentPlayerId = myPlayer?.id ?? navState?.playerId ?? null;

  // Keep this player's connected/last_seen_at fresh, and opportunistically
  // sweep the roster for anyone who's gone stale — see useHeartbeat.ts and
  // 0013_disconnect_reconnect.sql. Runs for any known player in any
  // pre-FINISHED phase (including the WAITING lobby — a host can vanish
  // before ever starting the game too).
  useHeartbeat(
    game?.id ?? null,
    currentPlayerId,
    !!game && game.status !== "FINISHED"
  );

  // Automatic mode: every connected client polls auto_advance_game while
  // the game is in a timed phase — see useAutoAdvance.ts. A no-op entirely
  // for Host-Controlled games (gated on game.game_mode inside the hook).
  const isAutomatic = game?.game_mode === "AUTOMATIC";
  useAutoAdvance(
    game?.id ?? null,
    currentPlayerId,
    game?.game_mode ?? null,
    game?.status ?? null
  );

  // The live host row (if any) — used both to show "N connected" context
  // and to decide whether to offer a "Become host" control to everyone
  // else. `connected` here is the same Realtime-synced column
  // PlayerRoster already dims on, so this reuses a signal that's already
  // proven reliable rather than inventing a second one.
  const hostPlayer = players.find((p) => p.is_host) ?? null;
  const hostLooksStale = !!hostPlayer && !hostPlayer.connected && hostPlayer.id !== currentPlayerId;
  const connectedCount = players.filter((p) => p.connected).length;

  // Fetch the live question whenever the game enters QUESTION state (or the
  // current question changes — i.e. advancing to a future question in
  // Phase 7 will re-trigger this the same way).
  useEffect(() => {
    // REVEAL still needs the question (RevealScreen renders it alongside the
    // reveal payload below), so only clear `question` once we've left both
    // phases entirely — clearing it on REVEAL too would leave RevealScreen
    // permanently stuck behind the "Loading results…" branch, since that
    // branch waits on `question` as well as `reveal`.
    if (!game || (game.status !== "QUESTION" && game.status !== "REVEAL")) {
      setQuestion(null);
      return;
    }
    // Already-loaded question carries over into REVEAL as-is; only QUESTION
    // triggers a (re)fetch.
    if (game.status !== "QUESTION") return;
    let cancelled = false;
    getCurrentQuestion(game.id)
      .then((q) => {
        if (!cancelled) setQuestion(q);
      })
      .catch(() => {
        if (!cancelled) setQuestion(null);
      });
    return () => {
      cancelled = true;
    };
  }, [game?.status, game?.current_question_id, game?.id]);

  // A fresh question means a fresh answer. Keyed on game.current_question_id
  // (the game_questions row id — unique per round even when the underlying
  // question_id repeats across rounds, see 0016_play_again_and_no_repeat_
  // questions.sql) rather than question.questionId (the underlying
  // questions.id, which CAN repeat once a room has played more than one
  // round) — using the latter would fail to reset answeredIndex on the
  // rare occasion a repeated question lands right after itself.
  useEffect(() => {
    setAnsweredIndex(null);
    setAnsweredText(null);
  }, [game?.current_question_id]);

  // Fetch the reveal payload whenever the game enters REVEAL state.
  useEffect(() => {
    if (!game || game.status !== "REVEAL") {
      setReveal(null);
      return;
    }
    let cancelled = false;
    getAnswerReveal(game.id)
      .then((r) => {
        if (!cancelled) setReveal(r);
      })
      .catch(() => {
        if (!cancelled) setReveal(null);
      });
    return () => {
      cancelled = true;
    };
  }, [game?.status, game?.current_question_id, game?.id]);

  // Fetch standings whenever the game enters LEADERBOARD state. Re-keyed on
  // current_question_index too, so a second/third trip through LEADERBOARD
  // (after the next question's reveal) re-fetches rather than showing the
  // previous question's scoreDelta.
  useEffect(() => {
    if (!game || game.status !== "LEADERBOARD") {
      setLeaderboard(null);
      return;
    }
    let cancelled = false;
    getLeaderboard(game.id)
      .then((rows) => {
        if (!cancelled) setLeaderboard(rows);
      })
      .catch(() => {
        if (!cancelled) setLeaderboard(null);
      });
    return () => {
      cancelled = true;
    };
  }, [game?.status, game?.current_question_index, game?.id]);

  // Once the game finishes, every client routes to the final results page —
  // status arrives via Realtime for everyone, so this fires for the host
  // and every other player at the same time.
  useEffect(() => {
    if (!game || game.status !== "FINISHED" || !roomCode) return;
    navigate(`/results/${roomCode}`, {
      replace: true,
      state: { playerId: currentPlayerId, isHost },
    });
  }, [game?.status, roomCode, navigate, currentPlayerId, isHost]);

  // Host-only, and only for Host-Controlled games: once the display timer
  // hits zero, end the question for everyone. This is purely a
  // client-triggered transition (the server doesn't police the clock
  // itself — see 0011_answer_submission.sql) so only the host's client does
  // it, guarded so it fires once per question even though this timer
  // re-renders every 250ms. Automatic-mode games skip this entirely —
  // auto_advance_game (polled by every client, not just the host — see
  // useAutoAdvance) is what ends the question there instead, so this host
  // client doesn't race its own end_question call against that.
  //
  // The guard compares against game.current_question_id (the game_questions
  // row id), not question.questionId (the underlying questions.id) — a
  // room that's played more than one round (0016_play_again_and_no_repeat_
  // questions.sql) can legitimately serve the same question again in a
  // later round, and current_question_id is guaranteed unique per round
  // even then, where questionId is not.
  const remaining = useServerTimer(
    question?.questionStartedAt ?? null,
    question?.timeLimitSeconds ?? 0
  );
  useEffect(() => {
    if (isAutomatic) return;
    if (!isHost || !game || game.status !== "QUESTION" || !question) return;
    if (remaining > 0) return;
    if (endQuestionCalledRef.current === game.current_question_id) return;
    endQuestionCalledRef.current = game.current_question_id;
    endQuestion(game.id).catch((err) => {
      // Reset the guard so a transient failure can be retried on the next tick.
      endQuestionCalledRef.current = null;
      setActionError(
        err instanceof GameApiError ? err.message : "Couldn't end the question."
      );
    });
  }, [isAutomatic, isHost, game, question, remaining]);

  async function handleStart() {
    if (!game) return;
    setActionError(null);
    setStarting(true);
    try {
      await startGame(game.id);
      // status -> COUNTDOWN arrives via Realtime for every client, including
      // this one — no local state mutation needed.
    } catch (err) {
      setActionError(
        err instanceof GameApiError ? err.message : "Couldn't start the game."
      );
      setStarting(false);
    }
  }

  async function handleCountdownComplete() {
    // Automatic mode: auto_advance_game (polled by every client) moves
    // COUNTDOWN -> QUESTION on its own once COUNTDOWN_SECONDS elapses — see
    // 0015_automatic_mode_and_answer_behavior.sql. The countdown animation
    // still plays for everyone (cosmetic, via CountdownOverlay), it just
    // isn't what triggers the real transition here.
    if (isAutomatic) return;
    if (!game || !isHost) return;
    try {
      await beginFirstQuestion(game.id);
    } catch (err) {
      setActionError(
        err instanceof GameApiError ? err.message : "Couldn't begin the question."
      );
    }
  }

  async function handleAnswer(index: number) {
    if (!game) return;
    const canChangeAnswer = game.answer_behavior === "CHANGE_UNTIL_TIMER_ENDS";
    if (!canChangeAnswer && answeredIndex !== null) return;
    if (answeredIndex === index) return; // re-tapping the same pick is a no-op
    setActionError(null);
    const previous = answeredIndex;
    setAnsweredIndex(index); // optimistic — locks/updates the UI immediately
    try {
      await submitAnswer(game.id, index);
    } catch (err) {
      setAnsweredIndex(previous); // revert to whatever was actually locked in
      setActionError(
        err instanceof GameApiError ? err.message : "Couldn't submit your answer."
      );
    }
  }

  async function handleAnswerText(text: string) {
    if (!game) return;
    const canChangeAnswer = game.answer_behavior === "CHANGE_UNTIL_TIMER_ENDS";
    if (!canChangeAnswer && answeredText !== null) return;
    if (answeredText === text) return; // resubmitting the same text is a no-op
    setActionError(null);
    const previous = answeredText;
    setAnsweredText(text); // optimistic — locks/updates the UI immediately
    try {
      await submitTextAnswer(game.id, text);
    } catch (err) {
      setAnsweredText(previous); // revert to whatever was actually locked in
      setActionError(
        err instanceof GameApiError ? err.message : "Couldn't submit your answer."
      );
    }
  }

  async function handleRemove(playerId: string) {
    setActionError(null);
    try {
      await removePlayer(playerId);
    } catch (err) {
      setActionError(
        err instanceof GameApiError ? err.message : "Couldn't remove that player."
      );
    }
  }

  async function handleContinueToLeaderboard() {
    if (isAutomatic) return;
    if (!game || !isHost) return;
    setActionError(null);
    setAdvancing(true);
    try {
      await advanceToLeaderboard(game.id);
      // status -> LEADERBOARD arrives via Realtime for everyone.
    } catch (err) {
      setActionError(
        err instanceof GameApiError ? err.message : "Couldn't show the leaderboard."
      );
    } finally {
      setAdvancing(false);
    }
  }

  async function handleClaimHost() {
    if (!game) return;
    setActionError(null);
    setClaimingHost(true);
    try {
      await claimHost(game.id);
      // is_host flips on both the old and new host's players rows, and
      // games.host_user_id updates too — all three arrive via the
      // existing Realtime subscriptions, so every client's `isHost`
      // re-derives itself automatically (see myPlayer above).
    } catch (err) {
      setActionError(
        err instanceof GameApiError ? err.message : "Couldn't take over as host."
      );
    } finally {
      setClaimingHost(false);
    }
  }

  async function handleAdvanceQuestion() {
    if (isAutomatic) return;
    if (!game || !isHost) return;
    setActionError(null);
    setAdvancing(true);
    try {
      await advanceQuestion(game.id);
      // status -> QUESTION or FINISHED arrives via Realtime for everyone.
    } catch (err) {
      setActionError(
        err instanceof GameApiError ? err.message : "Couldn't advance the game."
      );
    } finally {
      setAdvancing(false);
    }
  }

  if (state.status === "loading") {
    return (
      <div className="min-h-dvh flex items-center justify-center">
        <p className="text-sampaguita/50">Loading room…</p>
      </div>
    );
  }

  if (state.status === "error" || !game) {
    return (
      <div className="min-h-dvh flex items-center justify-center px-5">
        <Card className="p-8 max-w-md text-center">
          <h1 className="text-xl font-bold mb-2">Room not found</h1>
          <p className="text-sampaguita/60 text-sm mb-6">
            {state.status === "error" ? state.message : "Something went wrong."}
          </p>
          <Link to="/join">
            <Button variant="secondary">Try another code</Button>
          </Link>
        </Card>
      </div>
    );
  }

  // Phase 8: offered to any non-host player once the host's own
  // `connected` flag reads false (see hostLooksStale above). Shown above
  // whichever phase screen is currently rendering, rather than only in the
  // lobby — a stuck host can happen at any point in the state machine
  // (mid-COUNTDOWN with no one able to call begin_first_question,
  // mid-LEADERBOARD with no one able to advance, etc.), not just WAITING.
  const disconnectBanner =
    hostLooksStale && !isHost ? (
      <HostDisconnectedBanner onClaim={handleClaimHost} claiming={claimingHost} />
    ) : null;

  if (game.status === "COUNTDOWN") {
    return (
      <>
        {disconnectBanner}
        <CountdownOverlay onComplete={handleCountdownComplete} />
      </>
    );
  }

  if (game.status === "QUESTION") {
    if (!question) {
      return (
        <div className="min-h-dvh flex items-center justify-center">
          <p className="text-sampaguita/50">Loading question…</p>
        </div>
      );
    }
    return (
      <>
        {disconnectBanner}
        <QuestionScreen
          question={question}
          answeredIndex={answeredIndex}
          answeredText={answeredText}
          onAnswer={handleAnswer}
          onAnswerText={handleAnswerText}
          canChangeAnswer={game.answer_behavior === "CHANGE_UNTIL_TIMER_ENDS"}
          isAutomatic={isAutomatic}
        />
      </>
    );
  }

  if (game.status === "REVEAL") {
    if (!question || !reveal) {
      return (
        <div className="min-h-dvh flex items-center justify-center">
          <p className="text-sampaguita/50">Loading results…</p>
        </div>
      );
    }
    return (
      <>
        {disconnectBanner}
        <RevealScreen
          question={question}
          reveal={reveal}
          isHost={isHost}
          isAutomatic={isAutomatic}
          onContinue={handleContinueToLeaderboard}
          advancing={advancing}
        />
      </>
    );
  }

  if (game.status === "LEADERBOARD") {
    if (!leaderboard) {
      return (
        <div className="min-h-dvh flex items-center justify-center">
          <p className="text-sampaguita/50">Loading leaderboard…</p>
        </div>
      );
    }
    const isLastQuestion = game.current_question_index + 1 >= game.question_count;
    return (
      <>
        {disconnectBanner}
        <LeaderboardScreen
          entries={leaderboard}
          currentPlayerId={currentPlayerId}
          isHost={isHost}
          isAutomatic={isAutomatic}
          isLastQuestion={isLastQuestion}
          onAdvance={handleAdvanceQuestion}
          advancing={advancing}
          connectedCount={connectedCount}
          totalCount={players.length}
        />
      </>
    );
  }

  // WAITING (and any other not-yet-built status) falls back to the lobby.
  const rosterPlayers = players.map((p) => ({
    id: p.id,
    nickname: p.nickname,
    isHost: p.is_host,
    connected: p.connected,
  }));

  return (
    <div className="min-h-dvh px-5 py-10 flex flex-col items-center">
      <div className="w-full max-w-lg flex flex-col gap-5">
        {disconnectBanner}
        <div>
          <h1 className="text-3xl font-bold mb-1">Lobby</h1>
          <p className="text-sampaguita/60 text-sm">
            {categoryDisplayLabel(game.category, game.categories)} · {DIFFICULTY_LABELS[game.difficulty]} ·{" "}
            {game.question_count} questions · {game.time_limit_seconds}s per question
          </p>
          <p className="text-sampaguita/40 text-xs mt-1">
            {GAME_MODE_LABELS[game.game_mode]} · {ANSWER_BEHAVIOR_LABELS[game.answer_behavior]}
          </p>
        </div>

        <InviteBox roomCode={roomCode!} />

        <PlayerRoster
          players={rosterPlayers}
          currentPlayerId={currentPlayerId}
          onRemove={isHost ? handleRemove : undefined}
        />
        {actionError && (
          <p role="alert" className="text-sm text-sunset -mt-2">
            {actionError}
          </p>
        )}

        {isHost ? (
          <Button size="lg" onClick={handleStart} disabled={starting}>
            {starting ? "Starting…" : "Start Game"}
          </Button>
        ) : (
          <Card className="p-4 text-center text-sm text-sampaguita/60">
            Waiting for the host to start the game…
          </Card>
        )}

        <p className="text-xs text-center text-sampaguita/30">
          Players joining, leaving, or reconnecting update live here via
          Supabase Realtime — no refresh needed.
        </p>
      </div>
    </div>
  );
}
