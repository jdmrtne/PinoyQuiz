import clsx from "clsx";
import { Check } from "lucide-react";
import { AVATARS } from "../../data/avatars";

interface AvatarSelectorProps {
  value: string | null;
  onChange: (id: string) => void;
  /** Optional — shown above the grid. Pass null to omit entirely. */
  label?: string | null;
}

/**
 * Lets a player pick ONE character before playing. Pure selection UI —
 * doesn't know about game/player state, so it drops into the existing
 * Join/Create forms as just another field.
 */
export function AvatarSelector({
  value,
  onChange,
  label = "Choose your character",
}: AvatarSelectorProps) {
  const selectedAvatar = AVATARS.find((a) => a.id === value) ?? null;

  return (
    <div className="flex flex-col gap-3">
      {label && (
        <span className="text-sm font-semibold text-sampaguita/80">{label}</span>
      )}
      <div className="grid grid-cols-5 gap-2.5 sm:grid-cols-6">
        {AVATARS.map((avatar) => {
          const selected = avatar.id === value;
          return (
            <button
              key={avatar.id}
              type="button"
              onClick={() => onChange(avatar.id)}
              aria-pressed={selected}
              aria-label={`Select ${avatar.name}`}
              title={avatar.name}
              className={clsx(
                "relative aspect-square rounded-full border-2 transition-all duration-150 overflow-hidden bg-ink-3/40",
                "focus-visible:outline-3 focus-visible:outline-mango focus-visible:outline-offset-2",
                selected
                  ? "border-mango scale-[1.08]"
                  : "border-ink-3 hover:border-mango/50 hover:scale-105"
              )}
              style={
                selected
                  ? { boxShadow: `0 0 0 3px var(--color-mango)` }
                  : undefined
              }
            >
              <img
                src={avatar.icon}
                alt=""
                aria-hidden="true"
                className="w-full h-full object-cover"
                loading="lazy"
              />
              {selected && (
                <span className="absolute -top-0.5 -right-0.5 bg-mango text-night rounded-full p-[3px] shadow shadow-black/30">
                  <Check className="w-2.5 h-2.5" strokeWidth={3.5} aria-hidden="true" />
                </span>
              )}
            </button>
          );
        })}
      </div>
      <p className="text-xs text-sampaguita/50 min-h-[1em]">
        {selectedAvatar ? (
          <>
            Playing as{" "}
            <span className="font-semibold text-mango">{selectedAvatar.name}</span>
          </>
        ) : (
          "Pick a character to bring into the game."
        )}
      </p>
    </div>
  );
}
