import { Pause } from "lucide-react";
import { Card } from "../ui/Card";
import { Button } from "../ui/Button";

/**
 * Host pause/resume (0037_host_pause_resume.sql). Rendered in place of
 * whichever phase screen (QuestionScreen/RevealScreen/LeaderboardScreen)
 * is currently active — the underlying game_id/current_question_id/
 * round_number etc. are untouched in the database while paused (see the
 * migration's header), this is purely what's shown on screen, and it
 * appears identically for a player who joins or reconnects mid-pause as
 * for one who was already there when the host paused (both just render
 * off the same `games.is_paused` column, synced the same way as any other
 * status change — see useGameRealtime.ts).
 */
export function PauseOverlay({
  isHost,
  onResume,
  resuming,
}: {
  isHost: boolean;
  onResume: () => void;
  resuming: boolean;
}) {
  return (
    <div className="min-h-dvh flex items-center justify-center px-5">
      <Card className="p-8 sm:p-12 max-w-md w-full flex flex-col items-center gap-4 text-center">
        <span className="w-16 h-16 rounded-2xl bg-mango/15 text-mango flex items-center justify-center">
          <Pause className="w-8 h-8" strokeWidth={2.5} aria-hidden="true" />
        </span>
        <div>
          <h1 className="text-2xl font-bold mb-1">Game Paused</h1>
          <p className="text-sampaguita/60 text-sm">
            {isHost
              ? "You've paused the game. Your question, timer, and progress are all held exactly where they were — resume whenever you're ready."
              : "The host has temporarily paused the game. Sit tight — your question and progress are safe, and you'll be able to answer again as soon as play resumes."}
          </p>
        </div>
        {isHost && (
          <Button size="lg" onClick={onResume} disabled={resuming} className="w-full">
            {resuming ? "Resuming…" : "Resume Game"}
          </Button>
        )}
      </Card>
    </div>
  );
}
