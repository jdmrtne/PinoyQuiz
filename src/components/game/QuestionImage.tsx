import { useState } from "react";
import { ImageOff } from "lucide-react";
import { Card } from "../ui/Card";

interface QuestionImageProps {
  src: string;
}

/**
 * Renders an "image" question's picture (QuestionScreen and RevealScreen
 * both had their own bare <img>, each silently collapsing to the
 * browser's tiny broken-image icon on a failed load — no min-height, so
 * the whole Card shrank to a one-line pill around the alt text). This
 * gives the image a stable footprint either way: a skeleton while it
 * loads, and a clear "Image failed to load" state instead of the default
 * broken-icon look if the URL 404s, times out, or is blocked (seed data
 * hotlinks Wikimedia Commons images — see supabase/seed/0003 — so a
 * flaky network or an ad/tracker blocker can legitimately cause this
 * even when the stored image_url itself is fine).
 *
 * Uses the theme-variable tokens (bg-ink-2/ink-3, text-sampaguita/40) so
 * the skeleton and fallback state track light/dark mode automatically —
 * no hardcoded colors.
 */
export function QuestionImage({ src }: QuestionImageProps) {
  const [status, setStatus] = useState<"loading" | "loaded" | "error">("loading");

  return (
    <Card className="p-2 overflow-hidden">
      <div className="relative w-full h-56 sm:h-72 rounded-xl overflow-hidden bg-ink-2">
        {status !== "error" && (
          <img
            src={src}
            alt="Identify this"
            onLoad={() => setStatus("loaded")}
            onError={() => setStatus("error")}
            className={`w-full h-full object-cover transition-opacity ${
              status === "loaded" ? "opacity-100" : "opacity-0"
            }`}
          />
        )}
        {status === "loading" && (
          <div className="absolute inset-0 animate-pulse bg-ink-3" aria-hidden="true" />
        )}
        {status === "error" && (
          <div className="absolute inset-0 flex flex-col items-center justify-center gap-2 text-sampaguita/40">
            <ImageOff className="w-8 h-8" aria-hidden="true" />
            <span className="text-xs">Image failed to load</span>
          </div>
        )}
      </div>
    </Card>
  );
}
