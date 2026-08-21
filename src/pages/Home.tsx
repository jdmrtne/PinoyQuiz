import { Link } from "react-router-dom";
import { Button } from "../components/ui/Button";
import { Card } from "../components/ui/Card";

const steps = [
  { n: "1", label: "Create or join a room" },
  { n: "2", label: "Invite your friends" },
  { n: "3", label: "Answer the questions" },
  { n: "4", label: "Get the highest score" },
];

const categories = [
  "Philippine History",
  "Geography",
  "Filipino Culture",
  "Filipino Food",
  "Entertainment",
  "Sports",
  "Trivia",
  "Slang & Language",
];

export default function Home() {
  return (
    <div className="min-h-dvh flex flex-col">
      <div className="h-2 jeepney-stripes" aria-hidden="true" />

      <main className="flex-1 flex flex-col items-center px-5 pt-14 pb-10 max-w-3xl mx-auto w-full text-center">
        <span className="inline-block rounded-full border border-ink-3 bg-ink-2 px-4 py-1.5 text-xs font-semibold tracking-wide text-mango uppercase">
          Live multiplayer • Free to play
        </span>

        <h1 className="mt-6 text-5xl sm:text-6xl font-bold leading-[1.05]">
          PINOY <span className="text-gradient-mango">QUIZ</span>
        </h1>

        <p className="mt-4 text-xl sm:text-2xl font-display text-sampaguita/90">
          How well do you know the Philippines?
        </p>
        <p className="mt-3 text-base text-sampaguita/60 max-w-md">
          Challenge your friends. Answer fast. Climb the leaderboard —
          real-time, right from your phone.
        </p>

        <div className="mt-9 flex flex-col sm:flex-row gap-4 w-full sm:w-auto">
          <Link to="/create" className="w-full sm:w-auto">
            <Button variant="primary" size="lg" className="w-full">
              Create Game
            </Button>
          </Link>
          <Link to="/join" className="w-full sm:w-auto">
            <Button variant="secondary" size="lg" className="w-full">
              Join Game
            </Button>
          </Link>
        </div>

        {/* How it works — a real sequence, so numbering carries meaning */}
        <div className="mt-16 grid grid-cols-2 sm:grid-cols-4 gap-3 w-full">
          {steps.map((s) => (
            <Card key={s.n} className="p-4 flex flex-col items-center gap-2">
              <span className="font-display text-2xl font-bold text-mango">
                {s.n}
              </span>
              <span className="text-xs text-sampaguita/70 leading-snug">
                {s.label}
              </span>
            </Card>
          ))}
        </div>

        {/* Category preview */}
        <div className="mt-14 w-full text-left">
          <h2 className="text-sm font-semibold uppercase tracking-wide text-sampaguita/50 mb-3 text-center">
            Categories
          </h2>
          <div className="flex flex-wrap gap-2 justify-center">
            {categories.map((c) => (
              <span
                key={c}
                className="rounded-full border border-ink-3 bg-ink-2 px-3.5 py-1.5 text-sm text-sampaguita/80"
              >
                {c}
              </span>
            ))}
          </div>
        </div>
      </main>

      <footer className="text-center text-xs text-sampaguita/40 pb-6">
        Made for barkada game night 🇵🇭
      </footer>
    </div>
  );
}
