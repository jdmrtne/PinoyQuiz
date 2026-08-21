import { Card } from "../ui/Card";
import { Button } from "../ui/Button";
import type { LeaderboardEntry } from "../../lib/gameApi";

/**
 * Shown once the game moves REVEAL -> LEADERBOARD. Ranked standings for
 * the whole game, plus each player's score change from the question just
 * played (`scoreDelta`, 0 for anyone who answered wrong or not at all).
 * Only the host can advance — either to the next question or, if this was
 * the last one, to the FINISHED/Results screen — matching the same
 * "host controls pacing via a client-triggered function call" pattern as
 * end_question/begin_first_question.
 */
export function LeaderboardScreen({
  entries,
  currentPlayerId,
  isHost,
  isAutomatic,
  isLastQuestion,
  onAdvance,
  advancing,
  connectedCount,
  totalCount,
}: {
  entries: LeaderboardEntry[];
  currentPlayerId: string | null;
  isHost: boolean;
  isAutomatic: boolean;
  isLastQuestion: boolean;
  onAdvance: () => void;
  advancing: boolean;
  /**
   * Phase 8: shown as a small "N of M connected" note under the header
   * when someone's missing, so players understand why a rejoined
   * teammate momentarily looked greyed out — or why the game is stuck if
   * the host is one of the missing ones (see HostDisconnectedBanner,
   * rendered separately above this screen). Both counts come from the
   * same `players.connected` column PlayerRoster already dims on.
   */
  connectedCount?: number;
  totalCount?: number;
}) {
  const showConnectionNote =
    connectedCount !== undefined && totalCount !== undefined && connectedCount < totalCount;

  return (
    <div className="min-h-dvh px-5 py-8 flex flex-col items-center">
      <div className="w-full max-w-lg flex flex-col gap-6">
        <div className="text-center">
          <h1 className="text-3xl font-bold mb-1">Leaderboard</h1>
          <p className="text-sampaguita/60 text-sm">
            Standings after this question
          </p>
          {showConnectionNote && (
            <p className="text-xs text-sampaguita/40 mt-1">
              {connectedCount} of {totalCount} players connected
            </p>
          )}
        </div>

        <Card className="p-3 flex flex-col gap-2">
          {entries.map((entry) => {
            const isYou = entry.playerId === currentPlayerId;
            return (
              <div
                key={entry.playerId}
                className={`flex items-center gap-3 rounded-2xl px-4 py-3 ${
                  isYou ? "bg-ube/15 border-2 border-ube" : "bg-ink border-2 border-ink-3"
                }`}
              >
                <span className="flex items-center justify-center w-9 h-9 rounded-full font-display font-bold flex-shrink-0 bg-ink-2 text-mango">
                  {entry.rank}
                </span>
                <span className="flex-1 font-semibold text-sampaguita truncate">
                  {entry.nickname}
                  {isYou && (
                    <span className="text-sampaguita/50 font-normal"> (you)</span>
                  )}
                </span>
                {entry.scoreDelta > 0 && (
                  <span className="text-xs font-bold text-bagoong">
                    +{entry.scoreDelta}
                  </span>
                )}
                <span className="font-display font-bold text-lg text-mango tabular-nums">
                  {entry.score}
                </span>
              </div>
            );
          })}
        </Card>

        {isAutomatic ? (
          <Card className="p-4 text-center text-sm text-sampaguita/60">
            {isLastQuestion ? "Finishing up…" : "Advancing automatically…"}
          </Card>
        ) : isHost ? (
          <Button size="lg" onClick={onAdvance} disabled={advancing}>
            {advancing
              ? "Loading…"
              : isLastQuestion
                ? "See Final Results"
                : "Next Question"}
          </Button>
        ) : (
          <Card className="p-4 text-center text-sm text-sampaguita/60">
            Waiting for the host to continue…
          </Card>
        )}
      </div>
    </div>
  );
}
