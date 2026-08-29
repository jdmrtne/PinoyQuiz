import type { LucideIcon } from "lucide-react";
import { Check, Lock } from "lucide-react";
import clsx from "clsx";

interface ModeCardProps {
  icon: LucideIcon;
  name: string;
  description: string;
  checked: boolean;
  /** Locked cards (multiple_choice) show a Lock badge and can't be toggled off. */
  locked?: boolean;
  onToggle: () => void;
}

/**
 * A single selectable "game mode" (question type) card — icon, name, short
 * description, and a clear checked/unchecked state, per the Game Setup
 * redesign's Step 2. Same visual language as the rest of the app's
 * selection controls (SelectPills/MultiSelectPills: mango-filled when
 * active, ink-2/border-ink-3 otherwise) but laid out as a row so the
 * description has room, instead of a pill.
 */
export function ModeCard({
  icon: Icon,
  name,
  description,
  checked,
  locked,
  onToggle,
}: ModeCardProps) {
  return (
    <button
      type="button"
      role="checkbox"
      aria-checked={checked}
      disabled={locked}
      onClick={onToggle}
      className={clsx(
        "flex items-start gap-3 w-full text-left rounded-2xl border-2 p-4 transition-colors touch-manipulation",
        checked
          ? "bg-mango/10 border-mango"
          : "bg-ink-2 border-ink-3 hover:border-mango/50",
        locked && "cursor-default"
      )}
    >
      <span
        className={clsx(
          "flex-shrink-0 w-10 h-10 rounded-xl flex items-center justify-center",
          checked ? "bg-mango text-ink" : "bg-ink-3 text-sampaguita/70"
        )}
      >
        <Icon className="w-5 h-5" aria-hidden="true" />
      </span>

      <span className="flex-1 min-w-0 flex flex-col gap-0.5">
        <span className="flex items-center gap-2">
          <span className="font-display font-semibold text-sm text-sampaguita">
            {name}
          </span>
          {locked && (
            <span className="inline-flex items-center gap-1 text-[10px] uppercase tracking-wide font-semibold text-sampaguita/40">
              <Lock className="w-3 h-3" aria-hidden="true" />
              Always on
            </span>
          )}
        </span>
        <span className="text-xs text-sampaguita/50">{description}</span>
      </span>

      <span
        className={clsx(
          "flex-shrink-0 w-6 h-6 rounded-full border-2 flex items-center justify-center mt-0.5",
          checked
            ? "bg-mango border-mango text-ink"
            : "border-ink-3 text-transparent"
        )}
        aria-hidden="true"
      >
        <Check className="w-4 h-4" strokeWidth={3} />
      </span>
    </button>
  );
}
