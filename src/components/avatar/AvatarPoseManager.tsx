import { useEffect, useState } from "react";
import { GameAvatar } from "./GameAvatar";
import type { AvatarPose } from "../../data/avatars";
import type { GameStatus } from "../../types/game";

interface AvatarPoseManagerProps {
  avatarId: string | null;
  status: GameStatus | null | undefined;
  /** `game.current_question_index` — which round is currently live (or was
   *  just completed, during REVEAL/LEADERBOARD). Drives ROUND_POSE_CYCLE
   *  below; ignored/unused during WAITING, since rounds haven't started
   *  yet. Treated as round 0 if omitted. */
  roundIndex?: number | null;
  side?: "left" | "right";
}

/** Once a round is underway, the character holds ONE pose through all of
 *  that round's phases (COUNTDOWN/QUESTION/REVEAL/LEADERBOARD) and only
 *  changes when the next round begins — rather than switching pose on
 *  every phase transition. Cycling through all 3 on `roundIndex % 3`
 *  guarantees a different pose than the round before (3 distinct poses,
 *  so it never repeats back-to-back). */
const ROUND_POSE_CYCLE: AvatarPose[] = ["standing", "sitting", "lying"];

/** Only the pre-game lobby is "idle" in the old sense — long, open-ended,
 *  and not yet part of any round — so it's the one phase that still
 *  drifts through all 3 poses on a slow loop for a bit of life. */
const IDLE_ROTATION: AvatarPose[] = ["standing", "sitting", "lying"];
const IDLE_INTERVAL_MS = 14_000;

export function AvatarPoseManager({
  avatarId,
  status,
  roundIndex,
  side = "left",
}: AvatarPoseManagerProps) {
  const isLobbyIdle = !status || status === "WAITING";
  const [idlePose, setIdlePose] = useState<AvatarPose>("standing");

  useEffect(() => {
    if (!isLobbyIdle) return;
    let i = 0;
    setIdlePose(IDLE_ROTATION[i]);
    const timer = window.setInterval(() => {
      i = (i + 1) % IDLE_ROTATION.length;
      setIdlePose(IDLE_ROTATION[i]);
    }, IDLE_INTERVAL_MS);
    return () => window.clearInterval(timer);
  }, [isLobbyIdle]);

  if (!avatarId) return null;

  let pose: AvatarPose;
  if (isLobbyIdle) {
    pose = idlePose;
  } else if (status === "FINISHED") {
    // Game truly over — settle rather than holding whatever the final
    // round's pose happened to be.
    pose = "sitting";
  } else {
    const round = roundIndex ?? 0;
    pose = ROUND_POSE_CYCLE[round % ROUND_POSE_CYCLE.length];
  }

  return <GameAvatar avatarId={avatarId} pose={pose} side={side} />;
}
