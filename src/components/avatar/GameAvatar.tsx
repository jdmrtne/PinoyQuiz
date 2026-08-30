import clsx from "clsx";
import { getAvatarById, type AvatarPose } from "../../data/avatars";

interface GameAvatarProps {
  avatarId: string;
  pose: AvatarPose;
  side?: "left" | "right";
}

/**
 * Purely decorative, `fixed`-positioned character — deliberately taken
 * OUT of normal document flow so it can never push, shrink, or overlap
 * the actual quiz layout (which stays centered with its own max-width,
 * exactly as it was before this component existed).
 *
 * Anchored to the left/right edge of the viewport, in the blank margin
 * that already exists outside the centered `max-w-lg` quiz column on
 * wide screens. Hidden below the `lg` breakpoint entirely — on tablet
 * and mobile there usually isn't enough spare width to show a
 * full-body character without crowding the question/answers/timer, so
 * per the brief it's just not shown there rather than shrunk to the
 * point of being illegible.
 */
export function GameAvatar({ avatarId, pose, side = "left" }: GameAvatarProps) {
  const avatar = getAvatarById(avatarId);
  if (!avatar) return null;
  const src = avatar.poses[pose];

  return (
    <div
      aria-hidden="true"
      className={clsx(
        "hidden lg:block fixed bottom-0 z-10 pointer-events-none select-none",
        side === "left"
          ? "left-2 xl:left-6 2xl:left-12"
          : "right-2 xl:right-6 2xl:right-12"
      )}
      style={{ width: "clamp(130px, 12vw, 220px)" }}
    >
      {/* `key={pose}` forces a fresh element on pose change so the fade-in
          keyframe (defined in index.css) replays each time. */}
      <img
        key={pose}
        src={src}
        alt=""
        className="w-full h-auto object-contain drop-shadow-[0_12px_20px_rgba(0,0,0,0.35)]"
        style={{ animation: "avatarFadeIn 0.45s ease" }}
      />
    </div>
  );
}
