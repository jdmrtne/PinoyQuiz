import { Pause } from "lucide-react";
import clsx from "clsx";

/**
 * Host-only pause control (0037_host_pause_resume.sql). Fixed to a corner
 * rather than inline in each phase screen — QuestionScreen/RevealScreen/
 * LeaderboardScreen stay untouched, and the control reads the same in
 * every phase it's offered in (QUESTION/REVEAL/LEADERBOARD; see GameRoom.tsx
 * for why COUNTDOWN/WAITING/FINISHED don't get one). Only ever rendered
 * for the host — see GameRoom.tsx's `isHost` gate — so there's nothing
 * else guarding visibility here, but the label stays explicit ("Pause
 * game") rather than an icon-only button, since a floating control that
 * only one participant in the room can see/use benefits from being
 * unambiguous about what it does and who it's for.
 */
export function PauseButton({
  onPause,
  pausing,
}: {
  onPause: () => void;
  pausing: boolean;
}) {
  return (
    <button
      type="button"
      onClick={onPause}
      disabled={pausing}
      aria-label="Pause game (host only)"
      className={clsx(
        "fixed top-4 right-4 z-40 inline-flex items-center gap-1.5",
        "rounded-full border-2 border-ink-3 bg-ink-2/90 backdrop-blur-sm",
        "px-3.5 py-2 text-xs font-display font-semibold text-sampaguita/80",
        "shadow-lg shadow-black/20 transition-colors touch-manipulation",
        "hover:border-mango/60 hover:text-sampaguita",
        "disabled:opacity-50 disabled:cursor-not-allowed"
      )}
    >
      <Pause className="w-3.5 h-3.5" aria-hidden="true" />
      {pausing ? "Pausing…" : "Pause"}
    </button>
  );
}
