import { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { Button } from "../components/ui/Button";
import { Card } from "../components/ui/Card";
import { TextField } from "../components/ui/TextField";
import { SelectPills } from "../components/ui/SelectPills";
import { MultiSelectPills } from "../components/ui/MultiSelectPills";
import {
  CATEGORY_GROUPS,
  CATEGORY_LABELS,
  CUSTOM_MIX_GROUPS,
  DIFFICULTY_LABELS,
  DIFFICULTY_OPTIONS,
  QUESTION_COUNT_OPTIONS,
  TIME_LIMIT_OPTIONS,
  GAME_MODE_LABELS,
  GAME_MODE_DESCRIPTIONS,
  GAME_MODE_OPTIONS,
  ANSWER_BEHAVIOR_LABELS,
  ANSWER_BEHAVIOR_DESCRIPTIONS,
  ANSWER_BEHAVIOR_OPTIONS,
} from "../data/gameOptions";
import { createGame, GameApiError } from "../lib/gameApi";
import type {
  GameCategorySetting,
  GameDifficultySetting,
  GameModeRow,
  AnswerBehaviorRow,
  QuestionCategoryRow,
} from "../types/database.types";

type CategoryMode = "single" | "custom";

const CATEGORY_MODE_LABELS: Record<CategoryMode, string> = {
  single: "Single",
  custom: "Custom Mix",
};

export default function CreateGame() {
  const navigate = useNavigate();
  const [nickname, setNickname] = useState("");
  const [category, setCategory] = useState<GameCategorySetting>("random");
  // Custom Mix (0022): host picks a specific set of categories instead of
  // one fixed category (or "random" across all of them). The two modes are
  // mutually exclusive — only whichever is active at submit time is sent.
  const [categoryMode, setCategoryMode] = useState<CategoryMode>("single");
  const [customCategories, setCustomCategories] = useState<QuestionCategoryRow[]>([]);
  const [difficulty, setDifficulty] = useState<GameDifficultySetting>("mixed");
  const [questionCount, setQuestionCount] = useState(10);
  const [timeLimit, setTimeLimit] = useState(15);
  const [gameMode, setGameMode] = useState<GameModeRow>("HOST_CONTROLLED");
  const [answerBehavior, setAnswerBehavior] = useState<AnswerBehaviorRow>(
    "LOCK_ON_SELECTION"
  );
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);

    if (nickname.trim().length < 1) {
      setError("Enter a nickname first.");
      return;
    }

    if (categoryMode === "custom" && customCategories.length < 1) {
      setError("Pick at least one category for your custom mix.");
      return;
    }

    setSubmitting(true);
    try {
      const result = await createGame({
        category: categoryMode === "custom" ? "random" : category,
        categories: categoryMode === "custom" ? customCategories : undefined,
        difficulty,
        questionCount,
        timeLimitSeconds: timeLimit,
        hostNickname: nickname.trim(),
        gameMode,
        answerBehavior,
      });
      navigate(`/game/${result.roomCode}`, {
        state: { playerId: result.playerId, isHost: true },
      });
    } catch (err) {
      setError(
        err instanceof GameApiError ? err.message : "Couldn't create the game. Please try again."
      );
      setSubmitting(false);
    }
  }

  return (
    <div className="min-h-dvh px-5 py-10 flex flex-col items-center">
      <div className="w-full max-w-lg">
        <Link to="/" className="text-sm text-sampaguita/50 hover:text-mango">
          ← Back
        </Link>

        <h1 className="text-3xl font-bold mt-3 mb-1">Create Game</h1>
        <p className="text-sampaguita/60 mb-6 text-sm">
          Set up your room, then invite your friends with the code.
        </p>

        <form onSubmit={handleSubmit}>
          <Card className="p-6 flex flex-col gap-6">
            <TextField
              label="Your nickname"
              placeholder="e.g. Juan"
              maxLength={20}
              value={nickname}
              onChange={(e) => setNickname(e.target.value)}
              autoFocus
            />

            <div className="flex flex-col gap-4">
              <span className="text-sm font-semibold text-sampaguita/80">
                Category
              </span>
              {/* 0022: Single (existing behavior — one fixed category, or
                  "random" across all of them) vs Custom Mix (host picks a
                  specific subset; the draw is random within just that
                  subset — "random, but custom"). */}
              <SelectPills
                options={["single", "custom"] as CategoryMode[]}
                value={categoryMode}
                onChange={setCategoryMode}
                labels={CATEGORY_MODE_LABELS}
              />

              {categoryMode === "single" ? (
                /* Phase 14: 23 categories + Random is too many for one flat
                   pill group on a small screen, so they're clustered into
                   labeled sections (CATEGORY_GROUPS in data/gameOptions.ts)
                   while reusing the same SelectPills component/visual style
                   per group. */
                CATEGORY_GROUPS.map((group) => (
                  <div key={group.label} className="flex flex-col gap-2">
                    <span className="text-xs font-semibold uppercase tracking-wide text-sampaguita/40">
                      {group.label}
                    </span>
                    <SelectPills
                      options={group.options}
                      value={category}
                      onChange={setCategory}
                      labels={CATEGORY_LABELS}
                    />
                  </div>
                ))
              ) : (
                <>
                  <p className="text-xs text-sampaguita/50 -mt-1">
                    Pick as many as you like — questions are drawn randomly
                    from just this set.
                  </p>
                  {CUSTOM_MIX_GROUPS.map((group) => (
                    <div key={group.label} className="flex flex-col gap-2">
                      <span className="text-xs font-semibold uppercase tracking-wide text-sampaguita/40">
                        {group.label}
                      </span>
                      <MultiSelectPills
                        options={group.options}
                        value={customCategories}
                        onChange={setCustomCategories}
                        labels={CATEGORY_LABELS}
                      />
                    </div>
                  ))}
                </>
              )}
            </div>

            <div className="flex flex-col gap-2">
              <span className="text-sm font-semibold text-sampaguita/80">
                Difficulty
              </span>
              <SelectPills
                options={DIFFICULTY_OPTIONS}
                value={difficulty}
                onChange={setDifficulty}
                labels={DIFFICULTY_LABELS}
              />
            </div>

            <div className="flex flex-col gap-2">
              <span className="text-sm font-semibold text-sampaguita/80">
                Questions
              </span>
              <SelectPills
                options={QUESTION_COUNT_OPTIONS}
                value={questionCount}
                onChange={setQuestionCount}
              />
            </div>

            <div className="flex flex-col gap-2">
              <span className="text-sm font-semibold text-sampaguita/80">
                Time per question
              </span>
              <SelectPills
                options={TIME_LIMIT_OPTIONS}
                value={timeLimit}
                onChange={setTimeLimit}
                suffix="s"
              />
            </div>

            <div className="flex flex-col gap-2">
              <span className="text-sm font-semibold text-sampaguita/80">
                Game Mode
              </span>
              <SelectPills
                options={GAME_MODE_OPTIONS}
                value={gameMode}
                onChange={setGameMode}
                labels={GAME_MODE_LABELS}
              />
              <p className="text-xs text-sampaguita/50">
                {GAME_MODE_DESCRIPTIONS[gameMode]}
              </p>
            </div>

            <div className="flex flex-col gap-2">
              <span className="text-sm font-semibold text-sampaguita/80">
                Answer Behavior
              </span>
              <SelectPills
                options={ANSWER_BEHAVIOR_OPTIONS}
                value={answerBehavior}
                onChange={setAnswerBehavior}
                labels={ANSWER_BEHAVIOR_LABELS}
              />
              <p className="text-xs text-sampaguita/50">
                {ANSWER_BEHAVIOR_DESCRIPTIONS[answerBehavior]}
              </p>
            </div>

            {error && (
              <p role="alert" className="text-sm text-sunset -mt-2">
                {error}
              </p>
            )}

            <Button type="submit" size="lg" disabled={submitting}>
              {submitting ? "Creating room…" : "Create Room"}
            </Button>
          </Card>
        </form>
      </div>
    </div>
  );
}
