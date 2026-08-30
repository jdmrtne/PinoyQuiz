import { Pause } from "lucide-react";

/**
 * Host-only pause control (0037_host_pause_resume.sql). A circular icon
 * button fixed to the top-left corner, mirroring ThemeToggle.tsx's own
 * fixed top-right circle (same size, same safe-area handling, same
 * vertical offset) — putting it on the opposite corner instead of
 * crowding the same corner as the theme toggle, which previously caused
 * the two to visually collide/overlap.
 *
 * Icon-only (no visible label) to match the theme toggle's minimal style
 * and avoid cluttering the gameplay screen; `aria-label`/`title` still
 * make its purpose and host-only nature clear on hover/to screen readers.
 * Only ever rendered for the host — see GameRoom.tsx's `isHost` gate.
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
      title="Pause game (host only)"
      className="fixed z-40 flex items-center justify-center w-11 h-11 rounded-full bg-ink-2 text-sampaguita border-2 border-ink-3 hover:border-mango/60 transition-all duration-150 active:scale-[0.95] touch-manipulation focus-visible:outline-3 focus-visible:outline-mango disabled:opacity-50 disabled:cursor-not-allowed"
      style={{
        top: "calc(env(safe-area-inset-top, 0px) + 0.75rem)",
        left: "calc(env(safe-area-inset-left, 0px) + 0.75rem)",
      }}
    >
      <Pause className="w-5 h-5" strokeWidth={2.25} aria-hidden="true" />
    </button>
  );
}
