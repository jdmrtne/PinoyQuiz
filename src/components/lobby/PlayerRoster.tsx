import { Card } from "../ui/Card";
import clsx from "clsx";

export interface RosterPlayer {
  id: string;
  nickname: string;
  isHost: boolean;
  connected: boolean;
}

export function PlayerRoster({
  players,
  currentPlayerId,
  onRemove,
}: {
  players: RosterPlayer[];
  currentPlayerId: string | null;
  /** Pass only when the viewer is the host — enables the remove ("x") control. */
  onRemove?: (playerId: string) => void;
}) {
  return (
    <Card className="p-6">
      <p className="text-xs font-semibold uppercase tracking-wide text-sampaguita/50 mb-4">
        Players ({players.length})
      </p>
      {players.length === 0 ? (
        <p className="text-sm text-sampaguita/50">Waiting for players to join…</p>
      ) : (
        <ul className="flex flex-wrap gap-2.5">
          {players.map((p) => (
            <li
              key={p.id}
              className={clsx(
                "px-4 py-2 rounded-full text-sm font-semibold border-2 flex items-center gap-1.5",
                p.id === currentPlayerId
                  ? "bg-ube/20 border-ube text-sampaguita"
                  : "bg-ink border-ink-3 text-sampaguita/80",
                !p.connected && "opacity-40"
              )}
            >
              {p.isHost && <span aria-hidden="true">👑</span>}
              {p.nickname}
              {p.id === currentPlayerId && (
                <span className="text-sampaguita/50">(you)</span>
              )}
              {!p.connected && <span className="sr-only">(disconnected)</span>}
              {onRemove && !p.isHost && (
                <button
                  type="button"
                  onClick={() => onRemove(p.id)}
                  aria-label={`Remove ${p.nickname} from the room`}
                  className="ml-0.5 -mr-1.5 -my-2 rounded-full w-8 h-8 flex items-center justify-center text-sampaguita/50 hover:text-sunset hover:bg-sunset/10 transition-colors touch-manipulation"
                >
                  ×
                </button>
              )}
            </li>
          ))}
        </ul>
      )}
    </Card>
  );
}
