import { useMemo, useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { ArrowLeft, ArrowRight, Clock, Sparkles } from "lucide-react";
import { Button } from "../components/ui/Button";
import { Card } from "../components/ui/Card";
import { TextField } from "../components/ui/TextField";
import { SelectPills } from "../components/ui/SelectPills";
import { MultiSelectPills } from "../components/ui/MultiSelectPills";
import { ModeCard } from "../components/ui/ModeCard";
import { StepIndicator } from "../components/ui/StepIndicator";
import {
  CATEGORY_SECTIONS,
  ALL_CATEGORIES_OPTION,
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
  QUESTION_TYPE_LABELS,
  QUESTION_TYPE_DESCRIPTIONS,
  QUESTION_TYPE_ICONS,
  OPTIONAL_QUESTION_TYPE_OPTIONS,
  TIMING_STRATEGY_LABELS,
  TIMING_STRATEGY_DESCRIPTIONS,
  TIMING_STRATEGY_OPTIONS,
} from "../data/gameOptions";
import { TYPICAL_SECONDS, averageTypicalSeconds } from "../game-engine/questionTiming";
import { createGame, GameApiError } from "../lib/gameApi";
import type {
  GameCategorySetting,
  GameDifficultySetting,
  GameModeRow,
  AnswerBehaviorRow,
  QuestionCategoryRow,
  QuestionTypeRow,
  TimingStrategyRow,
} from "../types/database.types";

type CategoryMode = "single" | "custom";

const CATEGORY_MODE_LABELS: Record<CategoryMode, string> = {
  single: "Single",
  custom: "Custom Mix",
};

// Rough phase-duration assumptions used only for the Summary step's
// estimated-game-length preview (Automatic mode's real constants —
// see auto_advance_game in supabase/migrations/0036_smart_timing.sql —
// double as a reasonable stand-in for Host-Controlled pacing too, since
// a host clicking through reveal/leaderboard at a similar clip is the
// common case). This never affects real game timing — it's a preview
// only.
const COUNTDOWN_SECONDS = 3;
const REVEAL_SECONDS = 3;
const LEADERBOARD_SECONDS = 2;

const STEPS = ["Categories", "Game Modes", "Questions", "Timing", "Summary"];

export default function CreateGame() {
  const navigate = useNavigate();
  const [step, setStep] = useState(0);

  const [nickname, setNickname] = useState("");
  const [category, setCategory] = useState<GameCategorySetting>("random");
  // Custom Mix (0022): host picks a specific set of categories instead of
  // one fixed category (or "random" across all of them). The two modes are
  // mutually exclusive — only whichever is active at submit time is sent.
  const [categoryMode, setCategoryMode] = useState<CategoryMode>("single");
  const [customCategories, setCustomCategories] = useState<QuestionCategoryRow[]>([]);
  // Phase 16: in Single mode, the 44 real categories are grouped into two
  // named sections (General Knowledge / Philippines) — this toggles which
  // section's groups are shown below the standalone "All Categories" pill.
  const CATEGORY_SECTION_LABELS = CATEGORY_SECTIONS.map((s) => s.label);
  const [categorySection, setCategorySection] = useState(CATEGORY_SECTION_LABELS[0]);

  // Game Modes (question types). multiple_choice is always on — its
  // ModeCard renders locked+checked; a host enables any others by
  // checking their card. Real Mixed Mode (enabledQuestionTypes) is only
  // sent to create_game when at least one extra type is selected — an
  // empty selection is identical to "just Multiple Choice", which is
  // also create_game's own default when this param is omitted.
  const [extraQuestionTypes, setExtraQuestionTypes] = useState<
    Exclude<QuestionTypeRow, "multiple_choice">[]
  >([]);

  const [difficulty, setDifficulty] = useState<GameDifficultySetting>("mixed");
  const [questionCount, setQuestionCount] = useState(10);
  const [gameMode, setGameMode] = useState<GameModeRow>("HOST_CONTROLLED");
  const [answerBehavior, setAnswerBehavior] = useState<AnswerBehaviorRow>(
    "LOCK_ON_SELECTION"
  );

  // Smart timing (0036): Fixed keeps the pre-existing flat time_limit_seconds
  // behavior (and is the default here, matching the server default), Smart
  // Auto derives each question's time from its own content at start_game.
  const [timingStrategy, setTimingStrategy] = useState<TimingStrategyRow>("fixed");
  const [timeLimit, setTimeLimit] = useState(15);

  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  const enabledTypes = useMemo<QuestionTypeRow[]>(
    () => ["multiple_choice", ...extraQuestionTypes],
    [extraQuestionTypes]
  );

  function toggleType(type: Exclude<QuestionTypeRow, "multiple_choice">) {
    setExtraQuestionTypes((prev) =>
      prev.includes(type) ? prev.filter((t) => t !== type) : [...prev, type]
    );
  }

  const categorySummary = useMemo(() => {
    if (categoryMode === "custom") {
      if (customCategories.length === 0) return "No categories selected yet";
      const labels = customCategories.map((c) => CATEGORY_LABELS[c]);
      return labels.length <= 3
        ? labels.join(", ")
        : `${labels.slice(0, 3).join(", ")} +${labels.length - 3} more`;
    }
    return CATEGORY_LABELS[category];
  }, [categoryMode, customCategories, category]);

  const modesSummary = useMemo(
    () => enabledTypes.map((t) => QUESTION_TYPE_LABELS[t]).join(", "),
    [enabledTypes]
  );

  // Preview only — see questionTiming.ts's header comment for why this
  // can't reflect the real questions (they aren't chosen/exposed until
  // start_game).
  const estimatedAvgSeconds =
    timingStrategy === "smart" ? averageTypicalSeconds(enabledTypes) : timeLimit;
  const estimatedTotalSeconds =
    COUNTDOWN_SECONDS +
    questionCount * (estimatedAvgSeconds + REVEAL_SECONDS + LEADERBOARD_SECONDS);
  const estimatedMinutes = Math.max(1, Math.round(estimatedTotalSeconds / 60));

  function validateStep(i: number): string | null {
    if (i === 0) {
      if (nickname.trim().length < 1) return "Enter a nickname first.";
      if (categoryMode === "custom" && customCategories.length < 1) {
        return "Pick at least one category for your custom mix.";
      }
    }
    return null;
  }

  function goNext() {
    const err = validateStep(step);
    if (err) {
      setError(err);
      return;
    }
    setError(null);
    setStep((s) => Math.min(STEPS.length - 1, s + 1));
  }

  function goBack() {
    setError(null);
    setStep((s) => Math.max(0, s - 1));
  }

  async function handleSubmit() {
    setError(null);
    const stepErr = validateStep(0);
    if (stepErr) {
      setError(stepErr);
      setStep(0);
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
        // Real Mixed Mode: multiple_choice is always included (there's no
        // card to remove it), so it's prepended via enabledTypes rather
        // than making the picker redundantly offer to turn off the one
        // type every game has always had. Only sent when the host turned
        // on at least one extra type — an empty selection is identical to
        // omitting this param.
        enabledQuestionTypes: extraQuestionTypes.length > 0 ? enabledTypes : undefined,
        timingStrategy,
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
        <Link
          to="/"
          className="inline-flex items-center gap-1.5 text-sm text-sampaguita/50 hover:text-mango"
        >
          <ArrowLeft className="w-4 h-4" aria-hidden="true" />
          Back
        </Link>

        <h1 className="text-3xl font-bold mt-3 mb-1">Game Setup</h1>
        <p className="text-sampaguita/60 mb-5 text-sm">
          Configure your room, then invite your friends with the code.
        </p>

        <StepIndicator
          steps={STEPS}
          current={step}
          onStepClick={(i) => {
            setError(null);
            setStep(i);
          }}
        />

        <Card className="p-6 mt-5 flex flex-col gap-6">
          {/* Step 1 — Categories (+ nickname, which has to live somewhere
              before Create Room and fits naturally as "who's hosting"). */}
          {step === 0 && (
            <>
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
                  Categories
                </span>
                <SelectPills
                  options={["single", "custom"] as CategoryMode[]}
                  value={categoryMode}
                  onChange={setCategoryMode}
                  labels={CATEGORY_MODE_LABELS}
                />

                {categoryMode === "single" ? (
                  <>
                    <SelectPills
                      options={[ALL_CATEGORIES_OPTION]}
                      value={category}
                      onChange={setCategory}
                      labels={CATEGORY_LABELS}
                    />
                    <SelectPills
                      options={CATEGORY_SECTION_LABELS}
                      value={categorySection}
                      onChange={setCategorySection}
                    />
                    {CATEGORY_SECTIONS.find((s) => s.label === categorySection)?.groups.map(
                      (group) => (
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
                      )
                    )}
                  </>
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
            </>
          )}

          {/* Step 2 — Game Modes: which question types are in play. */}
          {step === 1 && (
            <div className="flex flex-col gap-3">
              <div>
                <span className="text-sm font-semibold text-sampaguita/80">
                  Game Modes
                </span>
                <p className="text-xs text-sampaguita/50 mt-0.5">
                  Multiple Choice is always included. Turn on any others to
                  mix them into the same game.
                </p>
              </div>
              <ModeCard
                icon={QUESTION_TYPE_ICONS.multiple_choice}
                name={QUESTION_TYPE_LABELS.multiple_choice}
                description={QUESTION_TYPE_DESCRIPTIONS.multiple_choice}
                checked
                locked
                onToggle={() => {}}
              />
              {OPTIONAL_QUESTION_TYPE_OPTIONS.map((type) => (
                <ModeCard
                  key={type}
                  icon={QUESTION_TYPE_ICONS[type]}
                  name={QUESTION_TYPE_LABELS[type]}
                  description={QUESTION_TYPE_DESCRIPTIONS[type]}
                  checked={extraQuestionTypes.includes(type)}
                  onToggle={() => toggleType(type)}
                />
              ))}
            </div>
          )}

          {/* Step 3 — Questions: how many, difficulty, and game flow. */}
          {step === 2 && (
            <>
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
                  Number of Questions
                </span>
                <SelectPills
                  options={QUESTION_COUNT_OPTIONS}
                  value={questionCount}
                  onChange={setQuestionCount}
                />
              </div>

              <div className="flex flex-col gap-2">
                <span className="text-sm font-semibold text-sampaguita/80">
                  Game Flow
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
            </>
          )}

          {/* Step 4 — Timing: Fixed vs Smart Auto. */}
          {step === 3 && (
            <div className="flex flex-col gap-4">
              <div>
                <span className="text-sm font-semibold text-sampaguita/80">
                  Timing Strategy
                </span>
                <p className="text-xs text-sampaguita/50 mt-0.5">
                  How much time each question gets.
                </p>
              </div>

              <div className="flex flex-col gap-3">
                {TIMING_STRATEGY_OPTIONS.map((strategy) => {
                  const active = timingStrategy === strategy;
                  return (
                    <button
                      key={strategy}
                      type="button"
                      role="radio"
                      aria-checked={active}
                      onClick={() => setTimingStrategy(strategy)}
                      className={`flex items-start gap-3 w-full text-left rounded-2xl border-2 p-4 transition-colors touch-manipulation ${
                        active
                          ? "bg-mango/10 border-mango"
                          : "bg-ink-2 border-ink-3 hover:border-mango/50"
                      }`}
                    >
                      <span
                        className={`flex-shrink-0 w-10 h-10 rounded-xl flex items-center justify-center ${
                          active ? "bg-mango text-ink" : "bg-ink-3 text-sampaguita/70"
                        }`}
                      >
                        {strategy === "smart" ? (
                          <Sparkles className="w-5 h-5" aria-hidden="true" />
                        ) : (
                          <Clock className="w-5 h-5" aria-hidden="true" />
                        )}
                      </span>
                      <span className="flex-1 flex flex-col gap-0.5">
                        <span className="font-display font-semibold text-sm text-sampaguita">
                          {TIMING_STRATEGY_LABELS[strategy]}
                        </span>
                        <span className="text-xs text-sampaguita/50">
                          {TIMING_STRATEGY_DESCRIPTIONS[strategy]}
                        </span>
                      </span>
                    </button>
                  );
                })}
              </div>

              {timingStrategy === "fixed" ? (
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
              ) : (
                <div className="rounded-2xl border-2 border-ink-3 bg-ink p-4 flex flex-col gap-2">
                  <span className="text-xs font-semibold uppercase tracking-wide text-sampaguita/40">
                    Estimated time by mode
                  </span>
                  {enabledTypes.map((type) => (
                    <div
                      key={type}
                      className="flex items-center justify-between text-sm text-sampaguita/70"
                    >
                      <span>{QUESTION_TYPE_LABELS[type]}</span>
                      <span className="font-display font-semibold text-mango">
                        ~{TYPICAL_SECONDS[type]}s
                      </span>
                    </div>
                  ))}
                  <p className="text-xs text-sampaguita/40 mt-1">
                    Actual per-question time is calculated from each
                    question's real length and complexity once the game
                    starts — these are typical estimates for the modes
                    you've enabled.
                  </p>
                </div>
              )}
            </div>
          )}

          {/* Step 5 — Summary. */}
          {step === 4 && (
            <div className="flex flex-col gap-4">
              <span className="text-sm font-semibold text-sampaguita/80">
                Game Summary
              </span>

              <dl className="flex flex-col gap-3 text-sm">
                <div className="flex flex-col gap-0.5">
                  <dt className="text-xs uppercase tracking-wide text-sampaguita/40">
                    Categories
                  </dt>
                  <dd className="text-sampaguita">{categorySummary}</dd>
                </div>
                <div className="flex flex-col gap-0.5">
                  <dt className="text-xs uppercase tracking-wide text-sampaguita/40">
                    Modes
                  </dt>
                  <dd className="text-sampaguita">{modesSummary}</dd>
                </div>
                <div className="flex flex-col gap-0.5">
                  <dt className="text-xs uppercase tracking-wide text-sampaguita/40">
                    Questions
                  </dt>
                  <dd className="text-sampaguita">
                    {questionCount} · {DIFFICULTY_LABELS[difficulty]}
                  </dd>
                </div>
                <div className="flex flex-col gap-0.5">
                  <dt className="text-xs uppercase tracking-wide text-sampaguita/40">
                    Timing
                  </dt>
                  <dd className="text-sampaguita">
                    {timingStrategy === "smart"
                      ? "Smart Auto Timing"
                      : `Fixed — ${timeLimit}s per question`}
                  </dd>
                </div>
                <div className="flex flex-col gap-0.5">
                  <dt className="text-xs uppercase tracking-wide text-sampaguita/40">
                    Game Flow
                  </dt>
                  <dd className="text-sampaguita">
                    {GAME_MODE_LABELS[gameMode]} · {ANSWER_BEHAVIOR_LABELS[answerBehavior]}
                  </dd>
                </div>
                <div className="flex flex-col gap-0.5">
                  <dt className="text-xs uppercase tracking-wide text-sampaguita/40">
                    Estimated Game Duration
                  </dt>
                  <dd className="text-sampaguita">~{estimatedMinutes} min</dd>
                </div>
              </dl>
            </div>
          )}

          {error && (
            <p role="alert" className="text-sm text-sunset -mt-2">
              {error}
            </p>
          )}

          <div className="flex gap-3">
            {step > 0 && (
              <Button type="button" variant="ghost" onClick={goBack} className="flex-1">
                <span className="inline-flex items-center gap-1.5 justify-center w-full">
                  <ArrowLeft className="w-4 h-4" aria-hidden="true" />
                  Back
                </span>
              </Button>
            )}
            {step < STEPS.length - 1 ? (
              <Button type="button" size="lg" onClick={goNext} className="flex-1">
                <span className="inline-flex items-center gap-1.5 justify-center w-full">
                  Next
                  <ArrowRight className="w-4 h-4" aria-hidden="true" />
                </span>
              </Button>
            ) : (
              <Button
                type="button"
                size="lg"
                onClick={handleSubmit}
                disabled={submitting}
                className="flex-1"
              >
                {submitting ? "Creating room…" : "Start Game"}
              </Button>
            )}
          </div>
        </Card>
      </div>
    </div>
  );
}
