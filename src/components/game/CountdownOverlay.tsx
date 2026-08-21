import { useEffect, useState } from "react";
import { Card } from "../ui/Card";

/**
 * Purely cosmetic — the server doesn't care how long this takes. The host's
 * client calls beginFirstQuestion() when this finishes; everyone else just
 * watches until the real games.status flips to QUESTION over Realtime.
 */
export function CountdownOverlay({
  seconds = 3,
  onComplete,
}: {
  seconds?: number;
  onComplete?: () => void;
}) {
  const [count, setCount] = useState(seconds);

  useEffect(() => {
    if (count <= 0) {
      onComplete?.();
      return;
    }
    const timer = setTimeout(() => setCount((c) => c - 1), 1000);
    return () => clearTimeout(timer);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [count]);

  return (
    <div className="min-h-dvh flex items-center justify-center px-5">
      <Card className="p-8 sm:p-12 flex flex-col items-center gap-3">
        <p className="text-sm uppercase tracking-wide text-sampaguita/50">
          Get ready
        </p>
        <span
          key={count}
          className="font-display text-6xl sm:text-8xl font-bold text-mango animate-[pulse_1s_ease-in-out]"
          aria-live="polite"
        >
          {count > 0 ? count : "Go!"}
        </span>
      </Card>
    </div>
  );
}
