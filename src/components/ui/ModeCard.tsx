import type { LucideIcon } from "lucide-react";
import { Check } from "lucide-react";
import clsx from "clsx";

interface ModeCardProps {
  icon: LucideIcon;
  name: string;
  description: string;
  checked: boolean;
  onToggle: () => void;
}

/**
 * A single selectable "game mode" (question type) card — icon, name, short
 * description, and a clear checked/unchecked state, per the Game Setup
 * redesign's Step 2. Same visual language as the rest of the app's
 * selection controls (SelectPills/MultiSelectPills: mango-filled when
 * active, ink-2/border-ink-3 otherwise) but laid out as a row so the
 * description has room, instead of a pill.
 *
 * Every mode — Multiple Choice included — is a plain toggleable card like
 * this one; none is locked or forced on (0037_host_pause_resume.sql's
 * "MCQ optional" change). The host is responsible for keeping at least
 * one enabled — see CreateGame.tsx's Step 2 validation.
 */
export function ModeCard({
  icon: Icon,
  name,
  description,
  checked,
  onToggle,
}: ModeCardProps) {
  return (
    <button
      type="button"
      role="checkbox"
      aria-checked={checked}
      onClick={onToggle}
      className={clsx(
        "flex items-start gap-3 w-full text-left rounded-2xl border-2 p-4 transition-colors touch-manipulation",
        checked
          ? "bg-mango/10 border-mango"
          : "bg-ink-2 border-ink-3 hover:border-mango/50"
      )}
    >
      <span
        className={clsx(
          "flex-shrink-0 w-10 h-10 rounded-xl flex items-center justify-center",
          checked ? "bg-mango text-night" : "bg-ink-3 text-sampaguita/70"
        )}
      >
        <Icon className="w-5 h-5" aria-hidden="true" />
      </span>

      <span className="flex-1 min-w-0 flex flex-col gap-0.5">
        <span className="font-display font-semibold text-sm text-sampaguita">
          {name}
        </span>
        <span className="text-xs text-sampaguita/50">{description}</span>
      </span>

      <span
        className={clsx(
          "flex-shrink-0 w-6 h-6 rounded-full border-2 flex items-center justify-center mt-0.5",
          checked
            ? "bg-mango border-mango text-night"
            : "border-ink-3 text-transparent"
        )}
        aria-hidden="true"
      >
        <Check className="w-4 h-4" strokeWidth={3} />
      </span>
    </button>
  );
}
