import { useCallback, useState } from "react";
import { AVATARS, DEFAULT_AVATAR_ID } from "../data/avatars";

const STORAGE_KEY = "pinoyquiz.avatarId";

/**
 * Avatar selection is intentionally NOT stored server-side. Adding a
 * column to `players` would mean a Supabase migration this environment
 * can't deploy/verify against the live project, and the game's actual
 * multiplayer state (roster, scores, questions) doesn't need it — the
 * avatar is a personal, cosmetic, per-device choice, so `localStorage`
 * keeps it "associated with that player" across a refresh or a new game
 * on the same browser without touching any existing backend contract.
 */
function readStored(): string | null {
  try {
    const v = localStorage.getItem(STORAGE_KEY);
    if (v && AVATARS.some((a) => a.id === v)) return v;
  } catch {
    // localStorage unavailable (private browsing, blocked storage, etc.) —
    // fall through to no persisted selection.
  }
  return null;
}

export function useAvatarSelection() {
  const [avatarId, setAvatarIdState] = useState<string | null>(() => readStored());

  const setAvatarId = useCallback((id: string) => {
    setAvatarIdState(id);
    try {
      localStorage.setItem(STORAGE_KEY, id);
    } catch {
      // Ignore — selection still works for this session via React state.
    }
  }, []);

  return { avatarId, setAvatarId, defaultAvatarId: DEFAULT_AVATAR_ID };
}
