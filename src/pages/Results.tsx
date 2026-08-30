import { useEffect, useState } from "react";
import { useParams, useLocation, useNavigate, Link } from "react-router-dom";
import { Card } from "../components/ui/Card";
import { Button } from "../components/ui/Button";
import { Crown } from "lucide-react";
import { useGameRealtime } from "../hooks/useGameRealtime";
import { useCurrentUserId } from "../hooks/useCurrentUserId";
import { getAvatarById } from "../data/avatars";
import {
  getLeaderboard,
  playAgain,
  GameApiError,
  type LeaderboardEntry,
} from "../lib/gameApi";

const MEDAL_COLORS = ["text-mango", "text-sampaguita/70", "text-sunset/80"];
// How many top finishers get a big standing character + crown treatment
// below the standings card (see the "podium" block further down).
const PODIUM_SIZE = 3;

/**
 * Final results — routed to automatically from GameRoom once a game
 * reaches FINISHED (see the navigate() effect there). Reuses
 * useGameRealtime for the room lookup (same as GameRoom) and
 * get_leaderboard (Phase 7, 0012_leaderboard.sql) for final standings —
 * the same function the mid-game LeaderboardScreen uses, since the ranked
 * columns it returns are exactly what a final scoreboard needs too.
 */
export default function Results() {
  const { roomCode } = useParams();
  const location = useLocation();
  const navigate = useNavigate();
  const navState = location.state as { playerId?: string; isHost?: boolean } | null;

  const { state, game, players } = useGameRealtime(roomCode);
  // Same reasoning as GameRoom.tsx (Phase 8): re-derive identity from the
  // roster + this browser's persisted auth session rather than relying
  // only on router state, so "(you)" still highlights correctly after a
  // hard refresh of the results page.
  const userId = useCurrentUserId();
  const myPlayer = players.find((p) => p.user_id === userId) ?? null;
  const currentPlayerId = myPlayer?.id ?? navState?.playerId ?? null;
  const isHost = myPlayer?.is_host ?? navState?.isHost ?? false;
  const [entries, setEntries] = useState<LeaderboardEntry[] | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [startingRematch, setStartingRematch] = useState(false);

  useEffect(() => {
    if (!game || game.status !== "FINISHED") return;
    let cancelled = false;
    getLeaderboard(game.id)
      .then((rows) => {
        if (!cancelled) setEntries(rows);
      })
      .catch((err) => {
        if (!cancelled) {
          setLoadError(
            err instanceof GameApiError ? err.message : "Couldn't load final results."
          );
        }
      });
    return () => {
      cancelled = true;
    };
  }, [game?.status, game?.id]);

  // play_again (0016_play_again_and_no_repeat_questions.sql) resets THIS
  // SAME game row back to WAITING for a rematch in the same room. That
  // status change arrives here through the Realtime subscription above for
  // every player, not just whoever clicked the button — so this effect,
  // not the button's own click handler, is what actually sends everyone
  // back to the room's lobby, in sync with each other.
  useEffect(() => {
    if (!game || game.status === "FINISHED") return;
    navigate(`/game/${roomCode}`, {
      replace: true,
      state: { playerId: currentPlayerId, isHost },
    });
  }, [game?.status, roomCode, navigate, currentPlayerId, isHost]);

  async function handlePlayAgain() {
    if (!game) return;
    setLoadError(null);
    setStartingRematch(true);
    try {
      await playAgain(game.id);
      // No local navigation here — the effect above does it once the
      // status change reaches this client via Realtime, the same way
      // every other transition in this app propagates.
    } catch (err) {
      setStartingRematch(false);
      setLoadError(
        err instanceof GameApiError ? err.message : "Couldn't start a new round."
      );
    }
  }

  if (state.status === "loading") {
    return (
      <div className="min-h-dvh flex items-center justify-center">
        <p className="text-sampaguita/50">Loading results…</p>
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

  if (game.status !== "FINISHED") {
    return (
      <div className="min-h-dvh flex items-center justify-center px-5">
        <Card className="p-8 max-w-md text-center">
          <h1 className="text-xl font-bold mb-2">Game still in progress</h1>
          <p className="text-sampaguita/60 text-sm mb-6">
            This room hasn't finished yet — jump back in to keep playing.
          </p>
          <Link to={`/game/${roomCode}`} state={navState ?? undefined}>
            <Button>Back to game</Button>
          </Link>
        </Card>
      </div>
    );
  }

  return (
    <div className="min-h-dvh px-5 py-10 flex flex-col items-center">
      <div className="w-full max-w-lg flex flex-col gap-6">
        <div className="text-center">
          <h1 className="text-3xl font-bold mb-1">Final Results</h1>
          <p className="text-sampaguita/60 text-sm">
            {game.question_count} questions · thanks for playing!
          </p>
        </div>

        {loadError && (
          <p role="alert" className="text-sm text-sunset text-center">
            {loadError}
          </p>
        )}

        {!entries ? (
          <div className="flex items-center justify-center py-12">
            <p className="text-sampaguita/50">Loading final standings…</p>
          </div>
        ) : (
          <Card className="p-3 flex flex-col gap-2">
            {entries.map((entry) => {
              const isYou = entry.playerId === currentPlayerId;
              const medalColor = MEDAL_COLORS[entry.rank - 1];
              const avatar = getAvatarById(
                players.find((p) => p.id === entry.playerId)?.avatar_id
              );
              return (
                <div
                  key={entry.playerId}
                  className={`flex items-center gap-3 rounded-2xl px-4 py-3 ${
                    isYou
                      ? "bg-ube/15 border-2 border-ube"
                      : entry.rank === 1
                        ? "bg-mango/10 border-2 border-mango"
                        : "bg-ink border-2 border-ink-3"
                  }`}
                >
                  {/* Player's avatar with a small crown for the top 3 (gold/
                      silver/bronze, filled only for 1st) and a rank-number
                      badge — replaces the old plain trophy-in-a-circle
                      treatment now that every player has a chosen avatar
                      (0038_player_avatars.sql) to actually show here. */}
                  <span className="relative flex-shrink-0 w-9 h-9">
                    {avatar ? (
                      <img
                        src={avatar.icon}
                        alt=""
                        aria-hidden="true"
                        className="w-9 h-9 rounded-full object-cover border-2 border-ink-2"
                      />
                    ) : (
                      <span className="flex items-center justify-center w-9 h-9 rounded-full bg-ink-2 text-mango font-display font-bold text-lg">
                        {entry.nickname.charAt(0).toUpperCase()}
                      </span>
                    )}
                    {medalColor && (
                      <Crown
                        className={`absolute -top-2.5 left-1/2 -translate-x-1/2 w-3.5 h-3.5 -rotate-[10deg] ${medalColor}`}
                        aria-hidden="true"
                        fill={entry.rank === 1 ? "currentColor" : "none"}
                        strokeWidth={2}
                      />
                    )}
                    <span className="absolute -bottom-1 -right-1 flex items-center justify-center w-4.5 h-4.5 min-w-[1.125rem] rounded-full bg-ink-2 border-2 border-ink text-[10px] font-bold text-mango leading-none px-0.5">
                      {entry.rank}
                    </span>
                    <span className="sr-only">Rank {entry.rank}</span>
                  </span>
                  <span className="flex-1 font-semibold text-sampaguita truncate">
                    {entry.nickname}
                    {isYou && (
                      <span className="text-sampaguita/50 font-normal"> (you)</span>
                    )}
                  </span>
                  <span className="font-display font-bold text-xl text-mango tabular-nums">
                    {entry.score}
                  </span>
                </div>
              );
            })}
          </Card>
        )}

        {/* Big standing-character podium — top finishers (rank order,
            left to right), with a crown anchored right on top of the
            winner's head. Standing pose artwork has the character's head
            essentially touching the very top edge of its image (see
            AvatarPoseManager/GameAvatar's source PNGs), so anchoring the
            crown to the top of the image container — rather than floating
            further above it — is what actually lands it on the head
            instead of hovering beside/above it. */}
        {entries && entries.length > 0 && (
          <div className="flex items-end justify-center gap-6 sm:gap-10 flex-wrap">
            {entries.slice(0, PODIUM_SIZE).map((entry) => {
              const isYou = entry.playerId === currentPlayerId;
              const avatar = getAvatarById(
                players.find((p) => p.id === entry.playerId)?.avatar_id
              );
              if (!avatar) return null;
              return (
                <div
                  key={entry.playerId}
                  className="flex flex-col items-center gap-2"
                >
                  <div className="relative w-24 sm:w-28">
                    {entry.rank === 1 && (
                      <Crown
                        className="absolute -top-4 sm:-top-5 left-1/2 -translate-x-1/2 w-9 h-9 sm:w-10 sm:h-10 text-mango z-10"
                        aria-hidden="true"
                        fill="currentColor"
                        strokeWidth={1.5}
                        style={{
                          filter: "drop-shadow(0 3px 4px rgba(0,0,0,0.35))",
                        }}
                      />
                    )}
                    <img
                      src={avatar.poses.standing}
                      alt=""
                      aria-hidden="true"
                      className="w-full h-auto object-contain drop-shadow-[0_10px_16px_rgba(0,0,0,0.3)]"
                    />
                  </div>
                  <span
                    className={`text-sm font-semibold truncate max-w-[7rem] text-center ${
                      isYou ? "text-ube" : "text-sampaguita"
                    }`}
                  >
                    {entry.nickname}
                    {isYou && (
                      <span className="text-sampaguita/50 font-normal"> (you)</span>
                    )}
                  </span>
                </div>
              );
            })}
          </div>
        )}

        <div className="flex flex-col gap-3">
          {isHost ? (
            <Button
              size="lg"
              className="w-full"
              onClick={handlePlayAgain}
              disabled={startingRematch}
            >
              {startingRematch ? "Starting…" : "Play Again"}
            </Button>
          ) : (
            <Card className="p-4 text-center text-sm text-sampaguita/60">
              Waiting for the host to start a new round…
            </Card>
          )}
          <Link to="/create">
            <Button size="lg" variant="ghost" className="w-full">
              Create a Different Room
            </Button>
          </Link>
          <Link to="/">
            <Button size="lg" variant="ghost" className="w-full">
              Back Home
            </Button>
          </Link>
        </div>
      </div>
    </div>
  );
}
