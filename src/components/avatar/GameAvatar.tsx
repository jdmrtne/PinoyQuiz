import clsx from "clsx";
import { getAvatarById, type AvatarPose } from "../../data/avatars";

interface GameAvatarProps {
  avatarId: string;
  pose: AvatarPose;
  /** Which edge to anchor to on wide screens (`lg`+) — alternates each
   *  round, see AvatarPoseManager/GameRoom. Ignored below `lg`: phones
   *  and tablets don't have spare width to move the character around
   *  in, so there it always sits tucked into the same bottom-right
   *  corner instead. */
  side?: "left" | "right";
}

/**
 * Purely decorative, `fixed`-positioned character — deliberately taken
 * OUT of normal document flow so it can never push, shrink, or overlap
 * the actual quiz layout (which stays centered with its own max-width,
 * exactly as it was before this component existed).
 *
 * On wide screens (`lg`+) it's anchored to the left/right edge of the
 * viewport, in the blank margin that already exists outside the
 * centered `max-w-lg` quiz column, and can sit on either edge (`side`)
 * since there's room to spare. Below `lg` the quiz column runs edge to
 * edge with no such margin, so rather than hiding the character
 * entirely (the original v1 choice) it shrinks down into a small
 * bottom-right corner badge — clear of the pause/theme-toggle circles
 * already living in the top corners (see PauseButton.tsx), and small
 * enough to stay out of the way of the actual question/answers
 * underneath. `pointer-events-none` the whole way down means it never
 * blocks a tap even where it visually grazes a card's edge.
 */
export function GameAvatar({ avatarId, pose, side = "left" }: GameAvatarProps) {
  const avatar = getAvatarById(avatarId);
  if (!avatar) return null;
  const src = avatar.poses[pose];

  return (
    <div
      aria-hidden="true"
      className={clsx(
        "fixed z-10 pointer-events-none select-none",
        // Mobile/tablet (below lg): small fixed badge, bottom-right,
        // regardless of `side` — there's no spare width to switch sides in.
        // Both width AND height are fixed here (not just width) so that
        // landscape poses (e.g. "lying", which is wider than it is tall)
        // get scaled up to fill the same visual footprint as the portrait
        // poses ("standing"/"sitting") instead of shrinking to a sliver —
        // object-contain on the <img> below then fits each pose's own
        // aspect ratio inside this fixed box.
        "bottom-2 right-2 w-[clamp(64px,20vw,96px)] h-[clamp(64px,20vw,96px)]",
        // lg+: back to the original full-size, edge-anchored character,
        // free to sit on either side. Same fixed width+height box.
        "lg:bottom-0 lg:w-[clamp(130px,12vw,220px)] lg:h-[clamp(130px,12vw,220px)]",
        side === "left" && "lg:left-2 lg:right-auto xl:left-6 2xl:left-12",
        side === "right" && "xl:right-6 2xl:right-12"
      )}
      style={{
        paddingBottom: "env(safe-area-inset-bottom, 0px)",
        paddingRight: "env(safe-area-inset-right, 0px)",
      }}
    >
      {/* `key={pose}` forces a fresh element on pose change so the fade-in
          keyframe (defined in index.css) replays each time. */}
      <img
        key={pose}
        src={src}
        alt=""
        className="w-full h-full object-contain drop-shadow-[0_12px_20px_rgba(0,0,0,0.35)]"
        style={{ animation: "avatarFadeIn 0.45s ease" }}
      />
    </div>
  );
}
