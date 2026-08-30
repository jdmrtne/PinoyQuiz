import { Card } from "../ui/Card";
import { Button } from "../ui/Button";
import { Crown } from "lucide-react";
import { getAvatarById } from "../../data/avatars";
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
// See Results.tsx for why these are literal hex values rather than a
// theme class — 2nd/3rd place need to actually read as silver/bronze
// regardless of light/dark theme, not fade into the card.
const MEDAL_HEX = ["#FFB100", "#C0C0C0", "#CD7F32"];

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
  playerAvatars,
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
  /** playerId -> avatarId (0038_player_avatars.sql). Missing/unknown
   *  entries just fall back to a plain initial circle, same as the
   *  Results screen's standings card. */
  playerAvatars?: Record<string, string | undefined>;
}) {
  const showConnectionNote =
    connectedCount !== undefined && totalCount !== undefined && connectedCount < totalCount;

  return (
    // Same top-clearance fix as QuestionScreen/RevealScreen — see their
    // comments — so this screen's content also clears the fixed
    // pause/theme-toggle buttons, even though "Leaderboard" itself is
    // centered and less likely to sit directly under either.
    <div
      className="min-h-dvh px-5 pb-8 flex flex-col items-center"
      style={{ paddingTop: "calc(env(safe-area-inset-top, 0px) + 4.5rem)" }}
    >
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
            const medalHex = MEDAL_HEX[entry.rank - 1];
            const avatar = getAvatarById(playerAvatars?.[entry.playerId]);
            return (
              <div
                key={entry.playerId}
                className={`flex items-center gap-3 rounded-2xl px-4 py-3 ${
                  isYou ? "bg-ube/15 border-2 border-ube" : "bg-ink border-2 border-ink-3"
                }`}
              >
                <span className="relative flex-shrink-0 w-9 h-9">
                  {avatar ? (
                    <img
                      src={avatar.icon}
                      alt=""
                      aria-hidden="true"
                      className="w-9 h-9 rounded-full object-cover border-2 border-ink-2"
                    />
                  ) : (
                    <span className="flex items-center justify-center w-9 h-9 rounded-full bg-ink-2 text-mango font-display font-bold">
                      {entry.nickname.charAt(0).toUpperCase()}
                    </span>
                  )}
                  {medalHex && (
                    <Crown
                      className="absolute -top-2.5 left-1/2 -translate-x-1/2 w-4 h-4 -rotate-[10deg]"
                      aria-hidden="true"
                      fill={medalHex}
                      stroke={medalHex}
                      strokeWidth={1}
                      style={{ filter: "drop-shadow(0 1px 1px rgba(0,0,0,0.35))" }}
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
