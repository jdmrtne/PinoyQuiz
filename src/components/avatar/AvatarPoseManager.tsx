import { useEffect, useState } from "react";
import { GameAvatar } from "./GameAvatar";
import type { AvatarPose } from "../../data/avatars";
import type { GameStatus } from "../../types/game";

interface AvatarPoseManagerProps {
  avatarId: string | null;
  status: GameStatus | null | undefined;
  side?: "left" | "right";
}

/** Default pose for each game phase — standing while actively playing,
 *  settling into a more relaxed pose the longer the player is just
 *  watching/waiting. */
const BASE_POSE: Partial<Record<GameStatus, AvatarPose>> = {
  WAITING: "standing",
  COUNTDOWN: "standing",
  QUESTION: "standing",
  REVEAL: "sitting",
  LEADERBOARD: "lying",
  FINISHED: "sitting",
};

/** Phases long/idle enough to let the character drift through all 3
 *  poses on a slow loop, purely for a bit of life — the lobby (could be
 *  minutes waiting for friends) and the leaderboard (a pause between
 *  questions). Never QUESTION — the character should look "active"
 *  the whole time a question is live. */
const IDLE_PHASES = new Set<GameStatus>(["WAITING", "LEADERBOARD"]);
const IDLE_ROTATION: AvatarPose[] = ["standing", "sitting", "lying"];
const IDLE_INTERVAL_MS = 14_000;

export function AvatarPoseManager({ avatarId, status, side = "left" }: AvatarPoseManagerProps) {
  const basePose: AvatarPose = (status && BASE_POSE[status]) || "standing";
  const isIdlePhase = !!status && IDLE_PHASES.has(status);
  const [idlePose, setIdlePose] = useState<AvatarPose>(basePose);

  useEffect(() => {
    if (!isIdlePhase) {
      setIdlePose(basePose);
      return;
    }
    let i = IDLE_ROTATION.indexOf(basePose);
    if (i < 0) i = 0;
    setIdlePose(IDLE_ROTATION[i]);
    const timer = window.setInterval(() => {
      i = (i + 1) % IDLE_ROTATION.length;
      setIdlePose(IDLE_ROTATION[i]);
    }, IDLE_INTERVAL_MS);
    return () => window.clearInterval(timer);
    // Re-sync whenever the phase changes (e.g. a fresh LEADERBOARD screen
    // after each question should start from the "just sat down" pose).
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [status, isIdlePhase]);

  if (!avatarId) return null;
  const pose = isIdlePhase ? idlePose : basePose;
  return <GameAvatar avatarId={avatarId} pose={pose} side={side} />;
}
