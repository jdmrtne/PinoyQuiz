import { useEffect, useState } from "react";
import { useParams, useLocation, Link } from "react-router-dom";
import { Card } from "../components/ui/Card";
import { Button } from "../components/ui/Button";
import { useGameRealtime } from "../hooks/useGameRealtime";
import {
  getLeaderboard,
  GameApiError,
  type LeaderboardEntry,
} from "../lib/gameApi";

const MEDALS = ["🥇", "🥈", "🥉"];

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
  const navState = location.state as { playerId?: string; isHost?: boolean } | null;
  const currentPlayerId = navState?.playerId ?? null;

  const { state, game } = useGameRealtime(roomCode);
  const [entries, setEntries] = useState<LeaderboardEntry[] | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);

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

  if (state.status === "loading") {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <p className="text-sampaguita/50">Loading results…</p>
      </div>
    );
  }

  if (state.status === "error" || !game) {
    return (
      <div className="min-h-screen flex items-center justify-center px-5">
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
      <div className="min-h-screen flex items-center justify-center px-5">
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
    <div className="min-h-screen px-5 py-10 flex flex-col items-center">
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
              const medal = MEDALS[entry.rank - 1];
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
                  <span className="flex items-center justify-center w-9 h-9 rounded-full font-display font-bold flex-shrink-0 bg-ink-2 text-mango text-lg">
                    {medal ?? entry.rank}
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

        <div className="flex flex-col gap-3">
          <Link to="/create">
            <Button size="lg" className="w-full">
              Play Again
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
