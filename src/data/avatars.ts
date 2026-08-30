// Avatar character registry.
//
// Each avatar is ONE character with 3 consistent full-body poses (never
// mixed across characters — see poses below) plus a circular `icon` used
// in the selector grid. Assets live in `public/avatars/<id>/*.png`
// (transparent-background chibi PNGs), so they're referenced here as
// plain root-relative paths Vite serves as-is — no import/bundling needed.
//
// To add a new avatar later: drop a new `public/avatars/avatar-NN/` folder
// with icon.png/standing.png/sitting.png/lying.png, then add one entry
// below. Nothing else in the avatar system needs to change — GameAvatar,
// AvatarSelector, and AvatarPoseManager all just iterate/read from this
// list.

export type AvatarPose = "standing" | "sitting" | "lying";

export interface Avatar {
  id: string;
  name: string;
  /** Rough dominant color from the character's outfit — used for a subtle
   *  accent ring/glow in the selector; purely decorative. */
  accent: string;
  icon: string;
  poses: Record<AvatarPose, string>;
}

function poseSet(id: string): Record<AvatarPose, string> {
  return {
    standing: `/avatars/${id}/standing.png`,
    sitting: `/avatars/${id}/sitting.png`,
    lying: `/avatars/${id}/lying.png`,
  };
}

export const AVATARS: Avatar[] = [
  { id: "avatar-01", name: "Momi", accent: "#d46b9a", icon: "/avatars/avatar-01/icon.png", poses: poseSet("avatar-01") },
  { id: "avatar-02", name: "Dulce", accent: "#c77b8f", icon: "/avatars/avatar-02/icon.png", poses: poseSet("avatar-02") },
  { id: "avatar-03", name: "Rico", accent: "#b23a3a", icon: "/avatars/avatar-03/icon.png", poses: poseSet("avatar-03") },
  { id: "avatar-04", name: "Liza", accent: "#7a5ca3", icon: "/avatars/avatar-04/icon.png", poses: poseSet("avatar-04") },
  { id: "avatar-05", name: "Jomar", accent: "#d97b29", icon: "/avatars/avatar-05/icon.png", poses: poseSet("avatar-05") },
  { id: "avatar-06", name: "Kyle", accent: "#2f6fb0", icon: "/avatars/avatar-06/icon.png", poses: poseSet("avatar-06") },
  { id: "avatar-07", name: "Zeke", accent: "#8a2f2f", icon: "/avatars/avatar-07/icon.png", poses: poseSet("avatar-07") },
  { id: "avatar-08", name: "Neo", accent: "#2f8fae", icon: "/avatars/avatar-08/icon.png", poses: poseSet("avatar-08") },
];

export const DEFAULT_AVATAR_ID = AVATARS[0].id;

export function getAvatarById(id: string | null | undefined): Avatar | null {
  if (!id) return null;
  return AVATARS.find((a) => a.id === id) ?? null;
}
