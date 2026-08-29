# Changelog

## Smart/Auto question timing + Game Setup redesign (0036) ✅

Two asks handled together: a per-game Timing Strategy so question time
doesn't have to be one flat number, and a Create Game screen restructured
into a clearer step flow. See
[docs/MASTER_HANDOFF.md](docs/MASTER_HANDOFF.md)'s "Smart/Auto question
timing + Game Setup redesign (0036)" section for the full writeup — kept
there rather than duplicated here since it's a continuation of the
question-types track documented in that file, not the Phase 1-17 roadmap
below.

**Completed:**
- `supabase/migrations/0036_smart_timing.sql` — `games.timing_strategy`
  (`'fixed' | 'smart'`, default `'fixed'`), a new reusable
  `calculate_question_time()` SQL function, and
  `game_questions.effective_time_limit_seconds` (computed once at
  `start_game`). `get_current_question`, all four `submit_*_answer`
  functions, and `auto_advance_game` were redefined to read that one
  column instead of each re-deriving the effective time limit inline.
  `create_game` gained `p_timing_strategy` (default `'fixed'`, so every
  existing caller keeps today's behavior); its old 10-param signature was
  dropped first (same reasoning as 0034) to avoid a second ambiguous
  overload.
- `src/game-engine/questionTiming.ts` — client-side pure-function mirror
  of the SQL calculation, for the Create Game Summary step's estimated
  duration preview (new `questionTiming.test.ts`, 17 tests).
- `src/pages/CreateGame.tsx` fully restructured into a 5-step flow
  (Categories → Game Modes → Questions → Timing → Summary) with a new
  `StepIndicator` and `ModeCard` (`src/components/ui/`). The old "Mixed
  Mode (Beta)" checkbox is gone — picking any optional question type now
  implicitly enables Mixed Mode.
- `src/data/gameOptions.ts` — `QUESTION_TYPE_LABELS/DESCRIPTIONS/ICONS`
  (all 8 types) and `TIMING_STRATEGY_LABELS/DESCRIPTIONS/OPTIONS`, plus
  matching data-integrity tests in `gameOptions.test.ts` (27 tests total,
  up from 20).
- Verified `npx tsc -b`, `npx vitest run` (56/56 passing), and
  `npx vite build` all pass. **The SQL migration has not been run against
  a live/disposable Postgres** (no DB access in the environment it was
  written in) — traced carefully against the 0030/0034 function bodies it
  extends, but treat it as unverified until run through
  `supabase db reset` + a real Smart Auto game.

## Phase 16b — General-knowledge category expansion (merged) ✅

Merged in from a branch developed in parallel with Phase 17 (custom
category mix), off the same Phase 16 base. Both branches added new
category-related work independently — this phase reconciles them so the
site has both.

**Completed:**
- Added 20 new general-knowledge categories to both `game_category_setting`
  and `question_category` enums in
  `supabase/migrations/0023_expand_general_categories.sql` (renumbered
  from the source branch's `0020` — `0020`–`0022` were already taken here
  by `science`/`medical` and the custom category mix feature): `science`
  (no-op, already existed), `mathematics`, `world_technology`,
  `computer_science`, `world_geography`, `world_history`,
  `world_literature`, `general_language`, `arts`, `world_music`,
  `world_movies_tv`, `world_sports`, `world_food`, `animals`,
  `general_nature`, `space_astronomy`, `human_body`, `business_economics`,
  `logic_reasoning`, `general_trivia`. `medical` (Phase 16 original) is
  untouched and kept as its own category, not folded into any of the 20.
- 9 of these 20 subjects share a plain-English name with an existing
  Philippine-scoped category (e.g. `history` = Philippine history only)
  — each got a distinctly-named sibling (`world_history`, etc.) instead
  of reusing the enum value, so questions never mix between the two.
- Added 160 new general-knowledge questions in
  `supabase/migrations/0024_general_knowledge_questions.sql` (renumbered
  from `0021`), 8 per new category. Checked against the existing 380
  questions (seed + Phases 14/15/16) for prompt overlap — none found.
- **Frontend, reconciled with Phase 17's Custom Mix feature:**
  - `src/data/gameOptions.ts` — `CATEGORY_LABELS` now prefixes every
    Philippine-scoped category with "Philippine"/"Filipino" (e.g. `history`
    → "Philippine History") so it's never confused with its
    general-knowledge sibling. `random` now reads "All Categories".
    `CATEGORY_GROUPS` was replaced by `CATEGORY_SECTIONS` — two named
    top-level sections ("General Knowledge" / "Philippines"), each broken
    into the same small labeled clusters as before. `medical` sits in
    General Knowledge → "Sciences & Tech" alongside `science`.
    `CUSTOM_MIX_GROUPS` (Phase 17) now derives from `CATEGORY_SECTIONS`
    instead of the retired `CATEGORY_GROUPS` — flattens both sections'
    groups into one list for the Custom Mix multi-select, since every
    group label across the two sections is unique. `categoryDisplayLabel`
    is unchanged.
  - `src/pages/CreateGame.tsx` — the Single/Custom Mix toggle (Phase 17)
    is unchanged and sits above the category pills. In Single mode, a
    standalone "All Categories" pill plus a General Knowledge/Philippines
    section toggle (Phase 16) now sit above the labeled group pills. In
    Custom Mix mode, `CUSTOM_MIX_GROUPS` renders as before, now covering
    all 44 real categories across 10 groups instead of 6.
  - `src/types/database.types.ts` — `GameCategorySetting` grew by the 19
    new values (`science` already existed).
- Verified `npx tsc --noEmit`, `npx vitest run` (32/32 passing), and
  `npx vite build` all pass on the merged tree.

## Phase 17 — Host-selectable custom category mix ✅

Adds a second way to scope which questions a game draws from, alongside
the existing single `category` setting: the host can now multi-select a
specific SET of categories on the Create Game screen and get a random draw
restricted to just that set — "random, but custom" per the request.

- **`supabase/migrations/0022_custom_category_mix.sql`** — new nullable
  `games.categories question_category[]` column. Null/empty (every
  pre-existing game, and any new game that doesn't use the feature) keeps
  the exact old behavior, filtered by the single `category` column.
  When set, it takes priority over `category` for actual question
  selection.
  - `create_game` gains a defaulted `p_categories` param (dropped +
    recreated — same "CREATE OR REPLACE can't widen a function's own
    argument list" situation 0015 hit).
  - `lookup_game_by_room_code` now also returns `categories` (dropped +
    recreated — its output column list changed).
  - `start_game`'s existing fresh/top-up two-pass draw (from 0016) now
    branches on a `v_use_custom_categories` flag: `category = any(games.
    categories)` when set, otherwise the original single-value-or-random
    filter, unchanged.
  - `play_again` needed no changes — it only resets the row to WAITING and
    bumps `round_number`; the next `start_game` call does the actual draw
    and already respects `categories`.
- **Frontend:**
  - `src/types/database.types.ts` — `categories` added to the `games` row
    type, `create_game` Args, and `lookup_game_by_room_code` Returns.
  - `src/data/gameOptions.ts` — `CUSTOM_MIX_GROUPS` (CATEGORY_GROUPS minus
    "random" — a custom mix is a set of real categories, "random" isn't a
    member of that set) and `categoryDisplayLabel(category, categories)`,
    which shows the single category's label normally, or `Custom Mix (N)`
    once more than one custom category is selected.
  - `src/components/ui/MultiSelectPills.tsx` — new checkbox-group sibling
    to the existing radio-group `SelectPills`.
  - `src/pages/CreateGame.tsx` — a Single/Custom Mix toggle above the
    category pills; Custom Mix swaps in `MultiSelectPills` per group and
    requires at least one category selected before submit. On submit,
    Custom Mix sends `category: "random"` (the single-select fallback
    value) plus the picked `categories` array.
  - `src/lib/gameApi.ts` — `CreateGameParams`/`RoomLookup` carry
    `categories` through to `create_game`/`lookup_game_by_room_code`.
  - `JoinGame.tsx` (pre-join info) and `GameRoom.tsx` (lobby header) both
    switched from a direct `CATEGORY_LABELS[...]` lookup to
    `categoryDisplayLabel(...)`.
- **Tests:** `gameOptions.test.ts` gained `CUSTOM_MIX_GROUPS` integrity
  tests (same drift checks as the existing `CATEGORY_GROUPS` ones, plus
  the "never contains random" invariant) and `categoryDisplayLabel`
  coverage for the null/single/multi cases.
- **Verification:** `npm run build` and `npx vitest run` both pass (30
  tests, up from 21); `npm run lint` reports the same pre-existing
  baseline, no new errors introduced by this phase's files.

## Phase 16 — Science + Medical categories, 100 new questions ✅

Same shape as Phase 15 (`0018`/`0019`), done out of sequence at explicit
request: `0020_science_medical_categories.sql` adds `science` and
`medical` to `game_category_setting`/`question_category` as their own
committed migration (enum values can't be used in the same transaction
that adds them), then `0021_science_medical_questions.sql` inserts 100
new questions guarded by a `WHERE NOT EXISTS` check on
`(category, prompt)`, same idempotency approach as `0019`.

**Unlike Phase 15, these categories are deliberately NOT
Philippines-scoped** — no existing category fit general science/medical
knowledge, so two new ones were added rather than folding into an
existing category.

- **Science (50 questions):** 10 each — Biology, Chemistry, Physics,
  Earth Science, Astronomy. Deliberately varied per subject (identification,
  cause/effect, function, comparison, basic calculation) rather than
  repeating the same fact reworded.
- **Medical (50 questions):** 10 each — Anatomy, Physiology,
  Microbiology, Pathology, Pharmacology. All objective, non-diagnostic,
  non-clinical facts — no patient scenarios, no personalized advice, no
  contested claims. Every question has exactly one well-established
  correct answer.
- **Difficulty (both categories combined):** 30 easy / 44 medium / 26
  hard, approximating the requested 30/45/25 split.
- **Duplicate check:** every new prompt was checked against the full
  existing bank (80-question seed + Phase 15's 200) before writing —
  none overlapped, since the existing bank is entirely Philippines-scoped
  (culture, geography, Filipino scientists/inventors, etc.) rather than
  general science/medical fact recall. All 100 new prompts are also
  unique against each other.

**Frontend (required — `CATEGORY_LABELS` is an exhaustive
`Record<GameCategorySetting, string>`, so a missing entry fails the
build):**
- `src/types/database.types.ts` — added `science` and `medical` to
  `GameCategorySetting`.
- `src/data/gameOptions.ts` — added labels for both to `CATEGORY_LABELS`
  and a new "Science & Medical" entry to `CATEGORY_GROUPS`.
- No other UI changes — same multiple-choice format, no new quiz modes.

**Verification (local Postgres, not the live Supabase project — see
below):** ran the full migration chain `0001`–`0021` plus the seed file
against a scratch database. Confirmed: 380 total questions (280
pre-existing + 100 new), `science` = 50, `medical` = 50, zero duplicate
`id`s, zero duplicate `(category, prompt)` pairs, zero rows with a null
`correct_option` or missing option text, zero rows with a blank
explanation. Re-ran `0021` a second time and confirmed it inserted 0
additional rows (idempotency holds). `npx tsc -b`: clean. `npx vitest
run`: 24/24 pass, including the `gameOptions.test.ts` integrity checks
that would fail if either category were missing a label or group entry.

**Not included in this phase (by design, per the request's scope):**
- No changes to scoring, timers, Automatic Mode pacing, or Play Again
  behavior.
- No new quiz formats (true/false, identification, etc.) — same
  multiple-choice system throughout.
- **Not pushed to the live Supabase project.** This sandbox has no
  network access to Supabase and no service-role credentials, so
  `0020`/`0021` were validated against a local Postgres replica running
  the identical schema rather than the real database. Run `supabase db
  push` (or apply the two files via the CLI/dashboard) against the real
  project to actually land this.

**Next phase:** Phase 14 — production deployment — is still the next
unstarted phase in the original sequence.

## Phase 1 — Project setup and UI foundation ✅

**Completed:**
- Scaffolded Vite + React 19 + TypeScript project.
- Installed and configured Tailwind CSS v4 (`@tailwindcss/postcss`),
  React Router, `@supabase/supabase-js`, Zustand, `clsx`.
- Designed a custom token system (`src/index.css`) — ink-navy base with
  mango/ube/sunset/bagoong accents and a "jeepney stripes" signature motif,
  deliberately avoiding the generic cream/terracotta and near-black/acid
  AI-design defaults. Type pairing: Space Grotesk (display) + Inter (body).
- Built shared UI primitives: `Button` (primary/secondary/ghost/danger,
  md/lg, large tap targets for mobile), `Card`.
- Implemented the full `Home` page per spec section 21 (hero, tagline,
  Create/Join CTAs, 4-step how-it-works, category preview).
- Added placeholder pages for `CreateGame`, `JoinGame`, `GameRoom`,
  `Results` and wired all six required routes in `App.tsx`, including
  `/join/:roomCode` for pre-filled invite links.
- Defined shared domain types (`src/types/game.ts`): `Game`, `Player`,
  `ClientQuestion` (no correct-answer field, by design), `AnswerReveal`,
  `LeaderboardEntry`, `ScoringConfig`.
- Created full folder scaffolding for every planned phase
  (`game-engine/`, `lib/`, `hooks/`, `data/`, `supabase/migrations`,
  `supabase/seed`, `tests/`) so later phases don't need restructuring.
- Added `.env.example` with placeholder-only Supabase values.
- Verified `npx tsc --noEmit` and `npm run build` both pass with zero
  errors.

**Not included in this phase (by design):**
- No Supabase project, schema, or client wiring.
- No real-time functionality.
- No question data or seed script.
- No game logic, scoring, or state machine implementation.
- No tests (nothing stateful exists yet to test).

**Next phase:** Phase 2 — database schema and Supabase configuration
(tables, RLS policies, migrations, Realtime setup on `games`/`players`).

## Phase 2 — Database schema and Supabase configuration ✅

**Completed:**
- Wrote six ordered SQL migrations in `supabase/migrations/`: extensions,
  enums (`game_status`, category/difficulty settings vs. per-question
  category/difficulty, `answer_option`), the five core tables (`games`,
  `players`, `questions`, `game_questions`, `answers`) with constraints and
  indexes, two client-safe views (`questions_public`, `leaderboard`), RLS
  policies, and explicit privilege grants/revokes.
- Designed the anti-cheat security model: every client authenticates via
  Supabase Anonymous Auth; RLS grants `SELECT` only; `INSERT`/`UPDATE`/
  `DELETE` are revoked outright for every table and role, so all writes
  must go through `SECURITY DEFINER` functions in later phases. Full
  reasoning documented in `docs/ARCHITECTURE.md` → Security model.
- Added `src/lib/supabase.ts` (typed client + `ensureAnonymousSession()`)
  and `src/types/database.types.ts` (hand-written `Database` type).
- Wrote your real Supabase project URL + publishable key into
  `.env.local` (gitignored) and documented the dashboard setup steps
  (enable Anonymous Sign-ins, run migrations in order) in `README.md`.

**Validated by testing, not just review:**
- Installed a disposable local Postgres in the sandbox, stubbed
  `auth.users`/`auth.uid()` to match Supabase's environment, and ran all
  six migrations end-to-end.
- **Found and fixed a real bug:** the original `players` RLS policy
  self-referenced the `players` table via a subquery, which Postgres
  rejects at query time with `infinite recursion detected in policy for
  relation "players"`. This would have completely broken the app the
  first time any query touched `games` or `players` on a live project.
  Fixed by moving the membership check into a `SECURITY DEFINER` helper
  function (`is_game_participant`), which is the standard pattern for
  self-referencing RLS and avoids the recursive policy evaluation
  entirely.
- Re-ran the full migration set from a clean database after the fix, then
  ran a scripted security test as the `authenticated` Postgres role with
  simulated JWTs for two real players and an outside "stranger":
  participants can see their game and roster; the stranger sees zero
  games; direct writes to `players.score` and `games.status` are both
  rejected with `permission denied`; `questions.correct_option` is
  unreadable directly and absent from `questions_public`;
  `game_questions` (which holds `shuffle_map`) is fully inaccessible; and
  a player who didn't answer a question sees 0 rows in `answers` while
  the player who did sees exactly 1 — their own.

**Not included in this phase (by design):**
- No `SECURITY DEFINER` functions yet (`create_game`, `join_game`,
  `submit_answer`, etc.) — the schema is write-locked until those land in
  Phase 3/5/6, which also means the app can't actually create or join a
  game yet.
- No question seed data — `questions` has zero rows.
- No Realtime subscriptions wired up yet.
- `ensureAnonymousSession()` exists but isn't called from any page yet.

**Next phase:** Phase 3 — create/join room system.

## Phase 3 — Create/join room system ✅

**Completed:**
- Added `supabase/migrations/0007_room_functions.sql`: `generate_room_code()`
  (internal helper, ambiguous-character-free charset), `create_game(...)`,
  `lookup_game_by_room_code(...)`, `join_game(...)` — all `SECURITY DEFINER`,
  all revoked from `PUBLIC` and granted only to `authenticated`.
- `join_game` includes duplicate-nickname rejection, a 50-player room cap,
  an "already started" rejection, and built-in reconnect (same `auth.uid()`
  rejoining updates their existing row instead of erroring/duplicating).
- `lookup_game_by_room_code` returns a narrow, non-sensitive shape for the
  pre-join screen, distinct from the full-row RLS policy used once you're
  actually a participant.
- `src/lib/gameApi.ts` — typed wrappers (`createGame`, `lookupGame`,
  `joinGame`) with shared friendly-error mapping.
- Built out `CreateGame.tsx` (full settings form) and `JoinGame.tsx` (room
  code + nickname, pre-filled/validated from invite links) for real.
- Built `GameRoom.tsx` as a one-time lobby snapshot (invite code/link with
  copy buttons, player roster) — explicitly not realtime yet; that's
  Phase 4. New components: `InviteBox`, `PlayerRoster`, `SelectPills`,
  `TextField`.
- Populated `src/data/gameOptions.ts` with category/difficulty labels and
  the question-count/time-limit choices used by the create form.

**Validated by testing:**
- Re-ran all 7 migrations against a fresh local Postgres (same stubbed
  `auth.users`/`auth.uid()` setup as Phase 2) and exercised every function
  as the `authenticated` role: create game → look up by real and fake room
  code → join → reject duplicate nickname → a different player joins with
  a unique nickname → the original player calls `join_game` again and
  reconnects (same `player_id`, no duplicate row, `out_reconnected = true`)
  → join a nonexistent code (rejected) → join a game whose status was
  flipped to `QUESTION` (rejected with "already started").
- **Found and fixed two real TypeScript bugs during the build check**, not
  just `tsc --noEmit`: the project's root `tsconfig.json` has `"files": []`
  and only `references`, so a bare `npx tsc --noEmit` silently compiles
  *nothing* and reports success — it was masking real errors. Running the
  actual `npm run build` (`tsc -b && vite build`) surfaced them:
  1. `src/types/database.types.ts` was missing the `Relationships` field
     supabase-js's generics expect on every table/view, and had no
     `Functions` map at all — so `.from(...)` queries silently resolved to
     `never` and `supabase.rpc(...)` calls couldn't typecheck their
     arguments. Fixed by adding `Relationships: []` throughout and a full
     `Functions` map for the three Phase 3 RPCs.
  2. `gameApi.ts`'s `callRpc` used a manually-supplied generic for the
     return type, which doesn't compose with a function-name-keyed generic
     (can't partially apply type arguments in TS). Refactored to derive
     the return type automatically from `Database["public"]["Functions"]`
     instead of asserting it by hand at each call site — safer, since a
     schema/type change now surfaces at every call site instead of only
     where someone remembered to update the manual annotation.
  From now on, `npm run build` (not a bare `tsc --noEmit`) is the real
  verification step for this project — noted in `README.md`.

**Not included in this phase (by design):**
- No Realtime — the lobby is a one-time fetch; a second browser joining
  won't appear without a manual refresh.
- No host controls beyond the disabled "Start Game" placeholder — kicking
  players, changing settings after creation, etc. are Phase 4/5.
- No question data — the settings form lets you pick a category, but
  there's still nothing in `questions` to serve.

**Next phase:** Phase 4 — multiplayer lobby and real-time synchronization.

## Phase 4 — Multiplayer lobby and real-time synchronization ✅

**Completed:**
- `supabase/migrations/0008_realtime.sql` — adds `games` and `players` to
  the `supabase_realtime` publication.
- `supabase/migrations/0009_lobby_functions.sql` — `remove_player(id)`,
  a host-only `SECURITY DEFINER` function (rejects non-hosts, rejects
  self-removal, handles a target that's already gone).
- `src/hooks/useGameRealtime.ts` — one-shot fetch + `postgres_changes`
  subscription on `players` (all events) and `games` (UPDATE), scoped to
  the specific `game_id` via Realtime's filter syntax.
- `GameRoom.tsx` rebuilt on the hook — no more manual fetch. Host sees a
  remove ("×") control per non-host player, wired to `removePlayer()` in
  `gameApi.ts`; success is picked up by every client through the DELETE
  event rather than a local state patch.

**Validated by testing — with an explicit boundary on what "tested" means
this phase:**
- Re-ran all 9 migrations against a fresh local Postgres (stubbing a
  `supabase_realtime` publication so `0008` could be validated too) and
  exercised `remove_player` as the `authenticated` role: a non-host
  removal attempt (rejected), a host attempting to remove themselves
  (rejected), a valid host removal (succeeded, player actually gone from
  the table), and removing an already-removed player (rejected with a
  clean message instead of a raw constraint error).
- **What was not, and could not be, tested from this sandbox:** actual
  Realtime message delivery. Supabase Realtime is a separate hosted
  service (reads the Postgres logical replication stream, pushes over
  WebSockets) — a local Postgres instance can validate the SQL and RLS
  underneath it, but not the live wire behavior. This is called out
  explicitly in `docs/ARCHITECTURE.md` rather than presented as
  fully verified; two real browser tabs against the live project is the
  needed manual check.
- **Found a real bug via the build, not review:** an edit meant to insert
  `removePlayer()` into `gameApi.ts` accidentally deleted the
  `export interface JoinGameResult {` declaration line, leaving its body
  as orphaned syntax. `npx tsc -b` failed immediately with a clear
  "Declaration or statement expected" error, caught before this shipped.
  Another point in favor of always running the real build command (see
  Phase 3's changelog entry) rather than trusting an edit was applied
  cleanly.

**Known limitation, documented rather than silently left in:** because
RLS re-evaluates against current table state, a removed player's own
client isn't guaranteed to receive the `DELETE` event describing their
own removal (they stop counting as a "participant" the instant the row
is gone). Their screen just stops updating rather than showing an
explicit "you were removed" message. A real fix needs a different
mechanism (e.g. a short-lived targeted broadcast) and is deferred to
Phase 8/9.

**Not included in this phase (by design):**
- "Start Game" is still a disabled placeholder — needs Phase 5's engine.
- No question data yet.
- The known reconnect-visibility gap above.

**Next phase:** Phase 5 — question system and game engine.

## Phase 5 — Question system and game engine ✅ (partial question bank)

**Completed:**
- `supabase/seed/0001_sample_questions.sql` — 80 verified Filipino trivia
  questions (10 per category × 8 categories). Explicitly documented as a
  partial subset of the spec's 240-question target, not a shortcut —
  every question here was chosen for facts I could verify confidently;
  the remaining ~160 are tracked as Phase 14 rather than rushed now.
- `supabase/migrations/0010_game_engine.sql` — `start_game` (builds a
  randomized, de-duplicated, per-game-shuffled question set and moves
  `WAITING → COUNTDOWN`), `begin_first_question` (host-triggered
  `COUNTDOWN → QUESTION`, sets the server-authoritative timer anchor),
  and `get_current_question` (participant-only, shuffled options, zero
  correct-answer leakage, returns nothing outside `QUESTION` status).
- Client: `CountdownOverlay`, `QuestionScreen` (read-only — answering is
  Phase 6), `useServerTimer` (computes remaining time from the server's
  timestamp, not client render time). `GameRoom.tsx` now branches on
  `games.status` to show the right screen.

**Validated by testing:**
- Ran all 10 migrations + the seed file against a fresh local Postgres;
  confirmed exactly 80 rows landed with the correct 10-per-category split
  (this also confirmed every apostrophe/quote in the seed SQL was escaped
  correctly — e.g. "Philippines'", "world's", nicknames like "Bata" —
  since a single mistake there would have broken the whole `INSERT`).
- Walked the complete engine flow as two simulated players: non-host
  blocked from starting a game; deliberately requesting more
  questions than exist for a narrow category+difficulty combination
  correctly rejected with a friendly "not enough questions" error (this
  is what surfaced the practical seed-data-size limitation noted in
  `docs/ARCHITECTURE.md`); a valid start succeeding; `get_current_question`
  correctly returning zero rows before the countdown finishes; a non-host
  blocked from calling `begin_first_question`; the host successfully
  advancing to `QUESTION`; a real participant fetching the question with
  options already shuffled per-game and no correct-answer field visible
  anywhere; and an outsider who somehow obtained a real `game_id` still
  rejected.
- **Found and fixed a real bug:** `get_current_question` computed
  `v_gq.question_order + 1` for its `out_order` column. Postgres promotes
  `smallint + integer literal` to `integer`, which didn't match the
  function's declared `smallint` return type — every single call failed
  at runtime with "structure of query does not match function result
  type," caught only by actually calling the function against real data,
  not by reading the SQL. Fixed with an explicit `::smallint` cast and
  re-verified.

**Not included in this phase (by design):**
- Answer buttons are visible but disabled — no `submit_answer` function,
  no scoring, no `QUESTION → REVEAL` transition yet (Phase 6).
- No leaderboard display or advancing to a second question yet (Phase 7).
- Question bank covers 80 of the eventual 240 questions.
- `begin_first_question` is host-triggered rather than fully automatic —
  acceptable for now since it's the same pattern as the rest of the app
  (host controls pacing), revisit only if it becomes a UX problem.

**Next phase:** Phase 6 — answer submission and scoring.

## Phase 6 — Answer submission and scoring ✅

**Completed:**
- `supabase/migrations/0011_answer_submission.sql` — three new
  `SECURITY DEFINER` functions:
  - `submit_answer(game_id, selected_option)` — the only way an `answers`
    row is ever created. Requires the game to be in `QUESTION` status,
    rejects a second submission for the same question (the DB's own
    `answers_one_per_player_per_question` constraint is the real backstop;
    this gives a friendly error first). Maps the player's *displayed*
    choice back through `game_questions.shuffle_map` to the question's
    real `correct_option` to determine correctness — the shuffle stays
    server-internal even at scoring time. Computes `response_time_ms` from
    `now() - games.question_started_at` (never a client-reported value),
    clamped to the time limit, and applies the configurable scoring
    formula from `games.scoring_config`: `basePoints + linear speed bonus`
    when correct, `incorrectPoints` when wrong. Updates `players.score` in
    the same transaction.
  - `end_question(game_id)` — host-only. Back-fills a zero-points "no
    answer" row (using `noAnswerPoints` from the same per-game
    `scoring_config`, not a hard-coded constant) for anyone who didn't
    submit in time, then flips `QUESTION → REVEAL`.
  - `get_answer_reveal(game_id)` — participant-only, readable only while
    `status = 'REVEAL'`. Returns the correct answer in *displayed-slot*
    terms (matching what the client actually rendered), the explanation if
    one exists, the caller's own submission/points/correctness, and a
    percent-correct stat computed server-side from all `answers` rows for
    that question — without ever exposing another player's individual
    answer, keeping `answers_select_own` (Phase 2) intact.
- Client: `QuestionScreen` rewritten to make the four answer buttons
  interactive (optimistic "locked in" UI, disabled once answered or once
  time is up) instead of the disabled placeholder from Phase 5. New
  `RevealScreen` component shows the correct answer highlighted in
  bagoong (success) with the player's own wrong pick highlighted in sunset
  if they missed it, points earned, percent-correct, and the optional
  explanation. `src/lib/gameApi.ts` gained `submitAnswer`, `endQuestion`,
  `getAnswerReveal` — the latter reuses the `AnswerReveal` domain type
  already defined in `src/types/game.ts` back in Phase 1 rather than a
  second bespoke shape.
- `GameRoom.tsx`: added `answeredIndex` (reset whenever the current
  question's id changes) and `reveal` state, a `REVEAL` render branch, and
  a host-only effect that calls `endQuestion` exactly once per question
  when the client-side `useServerTimer` reaches zero — the server itself
  still doesn't police the clock (matching the "host controls pacing"
  pattern from Phase 5's `begin_first_question`); this is purely what
  triggers the transition.

**Validated by testing:**
- Re-ran all 11 migrations against a fresh local Postgres (same stubbed
  `auth.users`/`auth.uid()` environment as every prior phase) and walked
  the complete flow as two simulated players plus a stranger:
  `submit_answer` before the game reaches `QUESTION` (rejected), a
  stranger blocked from `get_current_question`, a correct answer scoring
  `basePoints (1000) + full maxSpeedBonus (500) = 1500` when submitted
  immediately, a second submission attempt from the same player for the
  same question (rejected as "You already answered this question"), a
  non-host blocked from `end_question`, a valid `end_question` transition
  to `REVEAL`, both players' `get_answer_reveal` results matching their
  actual submissions and a correct 50% `percentCorrect`, and confirming
  `submit_answer`/`get_current_question` both correctly reject once the
  game is in `REVEAL`. A second scenario with three players (one host
  answers, two never submit) confirmed `end_question` back-fills exactly
  two "no answer" rows with `noAnswerPoints` and that calling
  `end_question` twice is rejected the second time.
- `npm run build` (the project's real verification step since Phase 3 —
  see that entry's `tsc -b` note) passes with zero errors after all
  frontend changes.

**Not included in this phase (by design):**
- No leaderboard screen and no `REVEAL → LEADERBOARD` transition — the
  game currently stops at `REVEAL` after the first question with no way
  to advance to a second one. That full "next question / finish game"
  cycle is Phase 7.
- `end_question` is still triggered by the host's local timer reaching
  zero rather than a server-side scheduled job — acceptable for now since
  it's the same client-triggered-transition pattern the app has used since
  Phase 5, revisit only if it becomes a reliability problem (e.g. host tab
  backgrounded/closed mid-question).

**Next phase:** Phase 7 — leaderboard and final results.

## Phase 7 — Leaderboard and final results ✅

**Completed:**
- `supabase/migrations/0012_leaderboard.sql` — three new `SECURITY
  DEFINER` functions, closing the state machine loop documented since
  Phase 1: `WAITING → COUNTDOWN → QUESTION → REVEAL → LEADERBOARD →
  (next QUESTION | FINISHED)`.
  - `get_leaderboard(game_id)` — any participant, any status. Ranked
    standings (`players.score` desc, `joined_at` asc — same ordering as
    the existing `leaderboard` view) plus each player's `score_delta`
    from the question just played. The delta has to be computed
    server-side rather than read directly from `answers`, for the same
    reason `get_answer_reveal`'s `percent_correct` is (Phase 6):
    `answers_select_own` only lets a player read their own submissions.
    Also used unmodified by the FINISHED/Results screen for final
    rankings.
  - `advance_to_leaderboard(game_id)` — host-only, `REVEAL →
    LEADERBOARD`. A pure status flip; `score_delta` is computed on read,
    not stored, so nothing else on the row needs to change.
  - `advance_question(game_id)` — host-only, `LEADERBOARD → QUESTION`
    (mirrors `begin_first_question`'s anchoring of
    `question_started_at`) if more questions remain, otherwise
    `LEADERBOARD → FINISHED` with `finished_at` stamped.
- `src/lib/gameApi.ts` — `advanceToLeaderboard`, `getLeaderboard`,
  `advanceQuestion` typed wrappers, reusing the `LeaderboardEntry`
  domain type from `src/types/game.ts` (Phase 1, already shaped for
  this) rather than a second bespoke type. New `friendlyMessage` error
  strings for the two new rejection cases.
- `src/types/database.types.ts` — `Functions` map entries for all three
  new RPCs.
- `LeaderboardScreen` (new, `src/components/game/`) — ranked player list
  with each player's score, rank, and this-question delta; host-only
  "Next Question" / "See Final Results" button (label depends on whether
  the leaderboard being shown was for the last question).
- `RevealScreen` — the "Phase 7" placeholder text is gone; host now sees
  a "See Leaderboard" button that calls `advance_to_leaderboard`,
  everyone else sees a waiting message.
- `GameRoom.tsx` — new `LEADERBOARD` render branch, a `leaderboard`
  fetch effect keyed on `current_question_index` (so a second/third trip
  through LEADERBOARD re-fetches instead of reusing a stale delta), and
  a `FINISHED` effect that `navigate()`s every client to
  `/results/:roomCode` at the same time (status arrives via the existing
  Realtime subscription for host and non-host alike).
- `Results.tsx` — no longer a placeholder. Fetches final standings via
  `get_leaderboard`, shows medal-style ranks, highlights "(you)", and
  offers "Play Again" (→ `/create`) and "Back Home" CTAs. Falls back to
  a "game still in progress" card with a link back to `/game/:roomCode`
  if visited before the game actually finishes.

**Validated by testing, not just review:** ran migrations `0001`–`0012`
end-to-end against a fresh disposable local Postgres (same stubbed
`auth.users`/`auth.uid()` setup as every prior phase), then two scripted
scenarios as two simulated players plus a stranger:
- A full three-question, two-player game through the entire
  `REVEAL → LEADERBOARD → QUESTION → … → FINISHED` cycle, confirming:
  a non-host is rejected from both `advance_to_leaderboard` and
  `advance_question`; calling `advance_to_leaderboard` a second time
  (already in `LEADERBOARD`, not `REVEAL`) is rejected; each
  `advance_question` call correctly increments
  `current_question_index` and re-anchors `question_started_at`; the
  third/last `advance_question` call flips the game to `FINISHED` and
  stamps `finished_at` instead of trying to serve a fourth question;
  calling `advance_question` again after `FINISHED` is rejected; a
  stranger is blocked from `get_leaderboard`; and both real players see
  identical, correct final rankings.
- A second, single-question game where the host's submission resolves
  the real (shuffled) correct answer server-side, confirming
  `score_delta` is exactly the points just earned for a correct answer
  and exactly `0` for a wrong one, and that a *single*-question game's
  first `advance_question` call goes straight to `FINISHED` rather than
  a (nonexistent) second question.
- `npm run build` (`tsc -b && vite build`) passes with zero errors.
  `npm run lint` reports the same 110 pre-existing errors as the
  unmodified Phase 6 baseline (verified by diffing against a fresh
  extract of the pre-Phase-7 project) — no new lint errors from this
  phase's changes.

**Not included in this phase (by design):**
- No disconnect/reconnect handling — a host who closes their tab
  mid-`LEADERBOARD` still leaves the game stuck there with no one able
  to advance it. That's Phase 8.
- No anti-cheat hardening beyond what Phase 2/6 already built (rate
  limiting on `advance_question`/`advance_to_leaderboard`, for
  instance) — that's Phase 9.
- No mobile-specific polish pass on the two new screens beyond reusing
  the existing responsive `Card`/`Button` primitives and design tokens —
  that's Phase 10.

**Next phase:** Phase 8 — disconnect/reconnect handling.

## Phase 8 — Disconnect/reconnect handling ✅

**Completed:**
- `supabase/migrations/0013_disconnect_reconnect.sql` — three new
  `SECURITY DEFINER` functions:
  - `heartbeat(game_id)` — any participant, called periodically by their
    own client. Updates their own `players.connected = true` and
    `last_seen_at = now()`.
  - `mark_stale_players(game_id)` — any participant (not just the host —
    the host might be the one who's gone). Sweeps the game's roster and
    flips `connected = false` for anyone whose `last_seen_at` is more
    than 20 seconds old. Idempotent, safe to call redundantly from every
    client's own timer.
  - `claim_host(game_id)` — any participant other than the current host.
    Rejects with "The host is still connected" unless the host row is
    both `connected = false` *and* stale by the same 20s threshold
    (re-checked server-side, not trusted from the caller's possibly-stale
    view). On success, deterministically reassigns hosting to the
    earliest-joined currently-`connected` player (excluding the outgoing
    host) — not necessarily the caller — and updates both that player's
    `players.is_host` and `games.host_user_id` in the same transaction.
  - **Mechanism choice, documented in the migration:** heartbeat +
    staleness sweep instead of Supabase Realtime Presence, even though
    `docs/ARCHITECTURE.md` flagged Presence as the more "natural" fit.
    Presence is, like the rest of Realtime, a separate hosted service this
    sandbox cannot exercise live-wire (see Phase 4's note) — a heartbeat
    is a plain function + `UPDATE`, fully testable against the same
    disposable local Postgres every other phase has used, and it
    broadcasts through the *already-validated* `players` `postgres_changes`
    subscription from Phase 4 rather than needing a new Realtime feature.
    Trade-off: up to ~20s detection lag instead of Presence's near-instant
    signal — acceptable against typical 5-120s question timers, but worth
    revisiting once this can be checked against a live project.
- `src/lib/gameApi.ts` — `heartbeat`, `markStalePlayers`, `claimHost`
  typed wrappers, plus new `friendlyMessage` strings for the rejection
  cases ("The host is still connected", "No other connected players are
  available to become host", etc.).
- `src/types/database.types.ts` — `Functions` map entries for all three
  new RPCs.
- `src/hooks/useCurrentUserId.ts` (new) — exposes the current browser's
  persisted Supabase Auth user id. **Fixes a real, pre-existing gap, not
  just new Phase 8 code:** `GameRoom.tsx`/`Results.tsx` previously derived
  "who am I in this game" (`currentPlayerId`/`isHost`) *only* from React
  Router's `location.state`, which is only populated when navigating in
  from `CreateGame`/`JoinGame` — a hard refresh or opening a saved/shared
  `/game/:roomCode` link directly left both `undefined`. Since
  `players.user_id` is already client-readable for any participant (RLS,
  Phase 2), matching it against the roster `useGameRealtime` already
  fetches re-derives the same information without any new server code.
  `location.state` is kept only as a same-render fallback for the brief
  window before the roster's first fetch resolves.
- `src/hooks/useHeartbeat.ts` (new) — sends `heartbeat()` +
  `markStalePlayers()` together every 8 seconds (chosen so a real drop is
  caught within ~2-3 missed beats, comfortably under the 20s server
  threshold and the 5s minimum question timer) for as long as this
  player's identity is known and the game hasn't reached `FINISHED`. Both
  calls are fire-and-forget on transient failure — the next tick retries.
- `GameRoom.tsx` — rewired `isHost`/`currentPlayerId` onto
  `useCurrentUserId` + the live roster (see above); wired in
  `useHeartbeat`; added `handleClaimHost`; added a `hostLooksStale` check
  (`hostPlayer.connected === false`, reusing the exact column
  `PlayerRoster` already dims on) that renders a new
  `HostDisconnectedBanner` above **every** in-progress phase screen (not
  just the lobby — a host can vanish mid-`COUNTDOWN`,
  mid-`QUESTION`/`REVEAL`/`LEADERBOARD` just as easily, and each of those
  has a host-only transition nothing else can trigger).
- `src/components/game/HostDisconnectedBanner.tsx` (new) — shown to every
  non-host player once the host looks stale; calls `claimHost`. Worded as
  "let someone take over" rather than "become host" since the clicker
  isn't guaranteed to be the one who ends up hosting (deterministic
  earliest-joined-connected-player selection happens server-side).
- `LeaderboardScreen` — new optional `connectedCount`/`totalCount` props
  render a small "N of M players connected" note under the header
  whenever someone's missing; omitted entirely when everyone's present.
  Chosen as the one extra indicator beyond `PlayerRoster`'s existing dim
  treatment (Phase 8 handoff item 4) because it's the natural
  between-questions pause point — `QuestionScreen` stays as-is since
  there's no good place to put a roster-wide status note without
  distracting from the countdown/answering flow.
- `Results.tsx` — same `useCurrentUserId` + roster-matching fix as
  `GameRoom.tsx`, so "(you)" still highlights correctly after a hard
  refresh of the final results page.

**Validated by testing, not just review:**
- Re-ran all 13 migrations (`0001`–`0013`) + the seed file end-to-end
  against a fresh disposable local Postgres (same stubbed
  `auth.users`/`auth.uid()` environment as every prior phase — this
  session also hit the exact `nodesource.sources` apt-403 pitfall the
  Phase 7 handoff warned about, moved out of
  `/etc/apt/sources.list.d/`, `apt-get update` succeeded).
- An 11-case scripted scenario as three simulated players plus a
  stranger, covering: a normal heartbeat updating `connected`/
  `last_seen_at`; a stranger rejected from both `heartbeat` and
  `mark_stale_players`; `claim_host` rejected while the host is still
  fresh; `mark_stale_players` correctly flipping a backdated host's
  `connected` to `false`; `claim_host` deterministically promoting the
  earliest-joined connected player (called *by* a different, later-joined
  player, confirming the caller isn't automatically the new host); the
  old host losing host-only privileges (`start_game` now rejected) and
  the new host gaining them immediately after; `claim_host` rejected once
  a game has reached `FINISHED`; `claim_host` rejected when no other
  connected candidate exists (host stale, only other player also
  disconnected); and a disconnected player's `connected` flag correctly
  flipping back to `true` on their next `heartbeat` call (the "silent
  rejoin on refresh" path — no `join_game` call required).
- A full end-to-end scenario distinct from the unit-style tests above:
  two players, host starts a 2-question game, gets the first question
  live, then goes silent mid-`QUESTION` (no more heartbeats). The
  surviving player's own heartbeat timer sweeps for staleness, sees the
  host is gone, calls `claim_host`, and — now host — single-handedly
  drives the rest of the game (`submit_answer` → `end_question` →
  `advance_to_leaderboard` → `advance_question` twice) all the way to
  `FINISHED` with correct final scores. The original host, reconnecting
  afterward via a fresh `heartbeat` call, can still read the final
  leaderboard as an ordinary (non-host) participant. **This is the
  concrete failure mode Phase 7's handoff described — "everyone else is
  stuck" — confirmed fixed, not just the individual functions in
  isolation.**
- A false-positive check: an actively-heartbeating host is never marked
  stale by `mark_stale_players`, confirmed by heartbeating immediately
  before the sweep and asserting `connected` stayed `true`.
- A `WAITING`-phase check: a host who vanishes *before ever starting the
  game* is still correctly detected as stale and replaced, and the new
  host can then successfully call `start_game` — confirming Phase 8
  isn't only wired up for mid-game drops.
- `npm run build` (`tsc -b && vite build`) passes with zero errors.
  `npm run lint` reports the same 110 pre-existing errors as a fresh,
  unmodified extract of the pre-Phase-8 project (verified by running
  lint against both side-by-side this session) — no new lint errors
  from this phase's changes.

**Not included in this phase (by design):**
- Detection still has a real (~20s worst-case) lag rather than the
  near-instant signal Realtime Presence could offer — see the mechanism
  discussion above. Not revisited this phase since it can't be validated
  from this sandbox either way.
- No automated background sweeping independent of a live client —
  `mark_stale_players` only runs when *some* connected client's own
  heartbeat timer calls it. If every single participant's tab closes at
  once, nobody's left to notice or to become host — an inherent limit of
  a client-driven design without a server-side scheduled job (e.g.
  `pg_cron`), which was deliberately not introduced given it's unusable
  from this sandbox's testing setup and adds hosted-infra dependency
  beyond what Phase 8 needs to solve the "stuck because the host left but
  others are still around" case from Phase 7's handoff.
- No UI test for the actual browser `beforeunload`/tab-close event —
  reconnection relies entirely on the *absence* of further heartbeats
  being noticed by others, not on any explicit "I'm leaving" signal from
  the departing client. Simpler and more robust (works for crashes and
  lost network too, not just clean tab closes) but means detection is
  never faster than the 20s threshold even for a clean close.
- `QuestionScreen` was deliberately left without its own connection
  indicator (see `LeaderboardScreen` note above) — revisit only if
  playtesting shows it's actually needed mid-question.
- No anti-cheat hardening beyond what already exists (Phase 9) and no
  mobile-specific polish pass on `HostDisconnectedBanner`/the leaderboard
  connection note beyond reusing existing `Card`/`Button` primitives and
  design tokens (Phase 10).

**Next phase:** Phase 9 — security and anti-cheat hardening.

## Phase 9 — Security and anti-cheat hardening ✅

**Scope, per `docs/MASTER_HANDOFF.md`'s Phase 9 section and
`docs/ARCHITECTURE.md`'s Security model:** rate limiting on every
mutating function (the concrete gap the handoff called out, and the
"Still to come (Phase 9)" item ARCHITECTURE.md's Security model section
named for `lookup_game_by_room_code` specifically), a closer look at
`claim_host` for any subtler race than "healthy host can't be forced
out," and a check of what else `submit_answer`'s server-side timing
already closes. Deliberately did **not** touch the question bank (Phase
14) or start Phase 10's mobile polish.

**What was actually a gap vs. what wasn't (the determination the handoff
asked for, not assumed):**
- **Rate limiting was a real gap.** Every function's own correctness
  checks (right phase, right caller, uniqueness constraints) were never
  in question — those already stop a bad client from corrupting *another*
  player's game state. What was missing was anything stopping a client
  from calling a function it's otherwise allowed to call as fast as a
  tight loop can issue requests: hammering `heartbeat`/`mark_stale_players`
  far faster than the real 8s client interval, or spamming
  `lookup_game_by_room_code` to brute-force room codes — exactly the
  "Still to come" item ARCHITECTURE.md's Security model section had
  flagged against that function since Phase 3 and never actually
  implemented. This is a resource-protection/enumeration-resistance gap,
  not a data-integrity hole, but real enough to close.
- **`claim_host`'s race was real, just not the one already guarded
  against.** The existing "host must actually be stale" check (added in
  Phase 8) already stops a healthy host from being forced out by someone
  else's inaction. What it didn't stop: a genuine TOCTOU race where
  `claim_host` reads the host row as stale, then — before its own
  `update` lands — the real host's own `heartbeat` call updates
  `last_seen_at` concurrently. Two racing transactions could each read
  "stale" before either writes, and the host gets demoted a moment after
  proving they're still connected. Confirmed by direct testing (see
  below), not just code review.
- **`submit_answer`'s timing anti-cheat needed no further work.**
  Re-confirmed by reading the Phase 6 implementation directly:
  `response_time_ms` is already computed entirely server-side from
  `now() - games.question_started_at`, never from any client-supplied
  value, and correctness is computed by mapping the player's selected
  *displayed* slot back through `game_questions.shuffle_map` to the real
  answer — a client can't claim a faster response or a different answer
  than it actually submitted. Nothing to add here; Phase 9 only added the
  same rate limit every other mutating function got, as defense in
  depth against submission-spam, not because the scoring math itself was
  exploitable.

**What was built (`supabase/migrations/0014_security_hardening.sql`):**
- `rate_limit_hits` table — one row per `(user_id, action)`, sliding
  window (`window_start`, `call_count`). RLS enabled with zero policies
  plus an explicit `revoke all ... from anon, authenticated`, matching
  every other table's defense-in-depth pattern from 0005/0006 — the only
  intended access path is the SECURITY DEFINER function below anyway,
  which bypasses RLS as table owner regardless.
- `enforce_rate_limit(p_action, p_max_calls, p_window_seconds)` —
  internal helper, single upsert (increments in place, or resets to a
  fresh window if the old one expired), raises once the count exceeds the
  limit. Deliberately **not** granted `EXECUTE` to `authenticated` — same
  revoked-from-public-but-called-internally pattern
  `generate_room_code()` already established in
  `0007_room_functions.sql`, confirmed with `has_function_privilege()`
  during testing (see below) that neither `anon` nor `authenticated` can
  call it directly.
- Every mutating function got a `perform enforce_rate_limit(...)` call
  right after its existing "must be signed in" check, each `create or
  replace`d with its original body from its own migration otherwise
  unchanged (grants aren't touched since signatures didn't change):
  `create_game` (10/60s), `lookup_game_by_room_code` (20/60s — the
  enumeration-resistance one specifically), `join_game` (15/60s),
  `remove_player` (30/60s), `start_game` (10/30s), `begin_first_question`
  (10/10s), `submit_answer` (15/10s), `end_question` (10/10s),
  `advance_to_leaderboard` (10/10s), `advance_question` (10/10s),
  `heartbeat` (20/30s), `mark_stale_players` (20/30s), `claim_host`
  (8/30s). Every limit is a generous multiple of that action's real
  client cadence (`useHeartbeat.ts`'s 8s interval; everything else in
  `GameRoom.tsx` is event-driven off Realtime, not polled — see
  `docs/MASTER_HANDOFF.md`'s "How to test your work" section reasoning
  reused here) so no legitimate client can ever hit one.
  `lookup_game_by_room_code` also lost its `stable` qualifier — it's no
  longer side-effect-free now that it calls a function that writes, and
  Postgres would reject a volatile-underneath function still marked
  `stable`.
- `claim_host` — same rate limit as above, plus the actual race fix:
  the host row is now read with `select ... for update` instead of a
  plain `select ... into`, so a concurrent `heartbeat()` UPDATE against
  that same row (issued by the real host reconnecting at the same
  instant) serializes against this transaction instead of racing it —
  whichever commits first is what the other sees.
- `src/lib/gameApi.ts` — added `"You are doing that too fast"` to
  `friendlyMessage`'s known-message list so a rate-limited call surfaces
  a clean UI message instead of falling through to the generic
  "Something went wrong" fallback. No other frontend changes — every
  rate limit is set far enough above real usage that normal play was
  confirmed unaffected (see testing below), so no UI-visible retry/backoff
  logic was needed for this phase.

**Validated by testing, not just review** (fresh disposable local
Postgres, same stubbed `auth.users`/`auth.uid()` environment as every
prior phase — hit the same `nodesource.sources` apt-403 pitfall the
handoff warned about again this session, same fix):
- Ran all 14 migrations (`0001`–`0014`) + the seed file end-to-end twice
  against two independent fresh databases (once while iterating, once
  again from a completely clean database as a final check) — zero errors
  either time.
- A 7-case scripted scenario: 25 rapid-fire `heartbeat` calls correctly
  rejected once the 20/30s budget is exceeded; 10 calls at realistic
  volume all succeed; 25 rapid `lookup_game_by_room_code` calls correctly
  rejected (the enumeration-resistance case); a call succeeds again once
  its window is manually rolled back over 60s (confirms the reset branch,
  not just the reject branch); one user's spam doesn't block a different
  user's legitimate call (confirms the per-`user_id` keying, not a global
  counter); a single `submit_answer` call during normal play succeeds
  under its new limit; `claim_host` still correctly promotes the
  earliest-joined connected player after the rate-limit and `for update`
  changes.
- A separate full 3-question, 2-player game played end-to-end through
  every mutating function (`create_game` → `join_game` → `start_game` →
  `begin_first_question` → per-question `heartbeat`/`mark_stale_players`/
  `submit_answer`/`end_question`/`advance_to_leaderboard`/
  `get_leaderboard`/`advance_question` ×3) reached `FINISHED` with
  correct scores and never once tripped a rate limit — confirms the
  chosen limits don't interfere with legitimate play, not just that they
  block abuse.
- Directly confirmed `enforce_rate_limit` isn't callable by either
  client role: `has_function_privilege('authenticated', ...)` and
  `has_function_privilege('anon', ...)` both return `false`.
- **The `claim_host` race fix specifically:** rather than trust the "for
  update serializes concurrent access" reasoning by inspection alone, ran
  an actual two-session concurrency test — session A opens an explicit
  transaction, takes `select ... for update` on the host's player row,
  and holds it via `pg_sleep(3)` before committing; session B, started
  ~0.7s later, issues a plain `update players set last_seen_at = now()
  where id = <that row>` (the same statement shape `heartbeat()` runs)
  against the *same row*. Session B's `UPDATE` measured ~2.36s to
  complete — it genuinely blocked until session A's transaction
  committed, rather than running immediately, confirming the lock (and
  therefore the fix) actually serializes concurrent `claim_host`/
  `heartbeat` access on the host row rather than just looking correct on
  paper.
- `npm run build` (`tsc -b && vite build`) passes with zero errors.
  `npm run lint` reports the same 110 pre-existing errors as the
  documented baseline — this phase's only `.ts` change is the one-line
  `friendlyMessage` addition in `gameApi.ts`, no new lint errors.

**Not included in this phase (by design):**
- No rate limiting on pure `stable` read functions other than
  `lookup_game_by_room_code` (`get_current_question`, `get_answer_reveal`,
  `get_leaderboard`) — these are event-driven off Realtime state changes
  in the current UI (confirmed by reading `GameRoom.tsx`: each is called
  from a `useEffect` keyed on `game.status`/`game.current_question_id`,
  never polled), so they don't carry the same brute-force/enumeration
  concern `lookup_game_by_room_code` does as the one function reachable
  *before* a player has joined a game at all. Revisit if a future phase
  adds any client-side polling of these.
- No CAPTCHA, IP-based limiting, or anything below the `auth.uid()` layer
  — out of scope for a Supabase-only stack without a separate application
  server, and the anonymous-auth session itself is already the identity
  boundary every other security decision in this app (Phase 2 onward) is
  built on.
- Rate-limit windows are fixed constants baked into each `perform
  enforce_rate_limit(...)` call rather than pulled from a config table —
  matches this project's existing `games.scoring_config`-is-configurable
  vs. `STALE_SECONDS`-is-a-constant split (Phase 8 made the latter choice
  for the same reason: nothing in this app's spec calls for these to be
  tunable per-game, so a table would be unused flexibility).
- `rate_limit_hits` rows are never pruned — bounded by
  `(real users) × (13 actions)`, not by call volume, since it's an
  upsert-in-place counter, not an append-only log, so no cleanup job was
  needed to keep it from growing unboundedly.

**Next phase:** Phase 10 — mobile responsiveness + UI polish.

## Phase 10 — Mobile responsiveness + UI polish ✅

**Scope, per `docs/MASTER_HANDOFF.md`'s Phase 10 section:** a real pass on
small-viewport layout (not just "it uses Tailwind so it's probably
fine"), tap target sizes on the answer-option buttons specifically, text
wrapping on long nicknames/prompts, and how the countdown/timer UI
behaves on narrow screens — extending `src/index.css`'s existing design
tokens rather than introducing new ones or falling back to generic
Tailwind defaults.

**What was actually a gap vs. what wasn't (reviewed screen by screen,
not assumed):**
- **`min-h-screen` (`100vh`) was a real gap.** Every full-page wrapper in
  the app (17 usages across 9 files) used it. On mobile Safari/Chrome,
  `100vh` is pinned to the viewport height with the address bar hidden,
  so a `min-h-screen` element can be taller than what's actually visible
  once the chrome is showing — the exact "cut off behind mobile browser
  chrome" failure mode the handoff called out for the countdown/timer UI
  specifically, except it applied to every screen in the app, not just
  those two.
- **Touch targets were a real, measurable gap in one place:**
  `PlayerRoster`'s host-only remove ("×") control was `w-5 h-5` — a 20px
  hit area, well under the ~44px baseline (Apple HIG, WCAG 2.5.5) this
  kind of tappable icon-only control should meet. `QuestionScreen`'s
  answer buttons (the "screen under the most real-world mobile pressure"
  per the handoff) were, on inspection, already comfortably sized —
  `px-5 py-4` with `text-lg` works out to roughly 60px tall — so this
  wasn't the gap the handoff worried it might be; it got a `min-h-[3.25rem]`
  floor anyway as insurance against a short one-word option shrinking
  that height, plus `touch-manipulation`.
- **Text wrapping on long nicknames/prompts needed no changes.**
  `LeaderboardScreen` and `Results` already `truncate` long nicknames;
  question prompts and answer option text already wrap normally inside
  block-level elements with no fixed width. Reviewed, confirmed fine, not
  touched.
- **`TextField` needed no changes.** Already `text-lg` (18px), which
  avoids iOS Safari's well-known auto-zoom-on-focus behavior for inputs
  under 16px — this was already correct from Phase 1, not a Phase 10 gap.

**What was built:**
- All 17 `min-h-screen` usages (`Home`, `CreateGame`, `JoinGame`,
  `GameRoom`'s six status branches, `Results`' four branches,
  `CountdownOverlay`, `QuestionScreen`, `RevealScreen`,
  `LeaderboardScreen`) switched to `min-h-dvh` (dynamic viewport height),
  which tracks the browser chrome's actual current state instead of the
  largest-possible-viewport assumption `100vh` makes.
- `index.html` — `viewport-fit=cover` added to the viewport meta tag.
- `src/index.css` — `body` now pads itself with
  `env(safe-area-inset-{top,bottom,left,right}, 0px)` (explicit `0px`
  fallback for non-notched devices) so content clears the notch/
  home-indicator area on iOS. Only takes effect paired with the
  `viewport-fit=cover` change above — without it, `env(safe-area-inset-*)`
  always reads 0.
- `src/components/ui/Button.tsx` — added `touch-manipulation` to the
  shared base classes, so every CTA in the app (both `CreateGame`/
  `JoinGame` submit buttons and every host-only advance/start button)
  picks up faster tap response in one place rather than needing it added
  per call site.
- `src/components/game/QuestionScreen.tsx` — answer buttons gained
  `min-h-[3.25rem]` (52px floor) and `touch-manipulation`.
- `src/components/ui/SelectPills.tsx` — the four option-pill groups on
  `CreateGame` (category, difficulty, question count, time limit) gained
  `min-h-[2.75rem]` (44px floor, matching the WCAG baseline exactly) and
  `touch-manipulation`.
- `src/components/lobby/PlayerRoster.tsx` — the remove-player control
  grew from `w-5 h-5` (20px) to `w-8 h-8` (32px) using negative margins so
  the larger hit area doesn't push the roster pill itself taller; pill
  gap increased from `gap-2` to `gap-2.5` so the larger hit areas don't
  overlap a neighboring pill's own control.
- `src/components/game/CountdownOverlay.tsx` — the one fixed-size element
  in the app with no responsive adjustment (`p-12`/`text-8xl` regardless
  of viewport) now steps down to `p-8`/`text-6xl` below the `sm:`
  breakpoint, and its wrapper gained `px-5` so the card has a guaranteed
  safety margin from the screen edges on narrow phones.

**Validated by testing:**
- `npm run build` (`tsc -b && vite build`) passes with zero errors.
  Manually confirmed the new utilities actually compiled into the CSS
  bundle rather than silently no-op'ing (Tailwind v4 has to recognize an
  arbitrary-value/dynamic-viewport utility to emit it) — `grep`'d
  `dist/assets/*.css` for `min-height:100dvh`, `.touch-manipulation{...}`,
  and all four `env(safe-area-inset-*)` calls; all present.
- `npm run lint` (oxlint) reports exactly the same 110 pre-existing
  errors as every prior phase's documented baseline — confirmed this
  phase's changes added zero new lint errors.
- Diffed the full working tree against a fresh, unmodified extract of the
  pre-Phase-10 project: exactly the 9 files intentionally touched
  differ, confirming no incidental changes elsewhere.
- Reviewed every touched screen's layout by direct pixel math against a
  320px-wide baseline (the narrowest common real device width) rather
  than by eye — e.g. confirmed `CountdownOverlay`'s "Go!" text at the new
  `text-6xl` fits comfortably inside a 320px viewport minus its `px-5`
  safety margin and `p-8` card padding, and that `PlayerRoster`'s
  enlarged 32px remove control's negative-margin hit area doesn't
  overlap into a neighboring pill given the new `gap-2.5` spacing.

**Not included in this phase, and why:**
- **No actual rendered-viewport screenshot/device-emulator comparison.**
  This sandbox has no headless browser or device emulator available — no
  domain that would serve one is in the network allowlist (`web_search`/
  `web_fetch` and the package registries only). This is the same shape of
  limitation Phase 4's handoff documented for live Supabase Realtime wire
  behavior: validated as thoroughly as this sandbox allows (build
  correctness, compiled-CSS inspection, and manual pixel-math review
  against real device widths), explicitly not presented as a substitute
  for an actual phone or browser dev-tools device-mode pass. That manual
  check is the next real-world validation step, same as Phase 4/8 left
  Realtime's live wire behavior for a real Supabase project.
- **`HostDisconnectedBanner` and the leaderboard "N of M connected"
  note** (both named in the Phase 10 handoff as deferred-by-name from
  Phase 8) already render using the same `Card`/`Button`/`min-h-dvh`
  primitives every other screen was just brought in line with, and
  needed no component-specific changes beyond that.
- **No new design tokens.** Every change above reuses `src/index.css`'s
  existing token system (colors, radii, fonts) — nothing new was added to
  `@theme`, per the handoff's explicit instruction not to introduce new
  tokens or fall back to generic Tailwind defaults.
- Did not touch the question bank (Phase 14) or start Phase 11
  (testing + bug fixing).

**Next phase:** Phase 11 — testing + bug fixing.

## Phase 11 — Testing + bug fixing ✅

**Decision made first, per the Phase 10 handoff's instruction not to
default to whatever's first to hand:** this project needed two distinct
kinds of testing, not one, because the actual logic lives in two places —
almost all of it server-side in the Postgres `SECURITY DEFINER` functions,
plus a small amount of genuinely pure client-side logic. Re-checked
`src/game-engine/`'s Phase 1 description ("framework-agnostic logic that
can be unit tested without a DB") against what actually exists today: no
pure game logic lived there — scoring, correctness, and timing are all
computed in SQL (`submit_answer` in `0011_answer_submission.sql`) and
deliberately never duplicated client-side (anti-cheat: the client is never
trusted with timing). The one thing left that *was* pure, framework-agnostic
display logic was the countdown-remaining-time calculation buried inside
`useServerTimer`. So:

1. **Server-side logic (the real game engine): a repeatable scripted
   scenario runner**, not a one-off manual session. Added
   `supabase/tests/run_scenarios.sql` — replaces "run scripted SQL
   scenarios by hand" (every phase's actual method through Phase 10) with
   a single idempotent script (truncates all app tables + `auth.users` at
   the top, so re-running it is always safe and comparable) containing 8
   scenarios / 27 assertions via a small `test_assert(condition, label)`
   helper that raises loudly on the first failure. Re-run twice back to
   back in this session to confirm the truncate-based idempotency actually
   holds, not just assumed.
2. **Client-side pure logic: introduced Vitest** (`vitest.config.ts`, `npm
   run test`) — no test runner existed in `package.json` before this
   phase. Deliberately `environment: "node"`, no jsdom/React Testing
   Library: nothing in this codebase's *pure* logic needs a DOM, and
   component-render testing was out of scope for what this phase actually
   needed (see "Not included," below). Extracted the countdown math out of
   `useServerTimer` into `src/game-engine/timeRemaining.ts` (`useServerTimer`
   now just calls it and owns the re-render tick — zero behavior change),
   finally giving that Phase-1-scaffolded-but-empty folder something to
   hold. Also exported `friendlyMessage` from `gameApi.ts` (was
   module-private) purely so it has a direct test. Three new test files,
   18 tests total: `src/game-engine/timeRemaining.test.ts` (boundary/
   rounding/clamping behavior, plus the exact slow-loading-client
   regression case documented in `useServerTimer`'s own comments),
   `src/lib/gameApi.test.ts` (every known error string round-trips
   unmodified; unrecognized text falls back to the generic message),
   `src/data/gameOptions.test.ts` (every category/difficulty option has
   exactly one label, `random`/`mixed` — the two values `start_game`
   treats as "no filter" — are always present, question-count/time-limit
   option lists are non-empty and ascending).

**Bug-hunt pass (adversarial, not "confirm this new code works" — the
distinction the Phase 10 handoff drew).** Every scenario below was
specifically chosen to probe an edge the "confirm this phase's own new
code works" testing style of Phases 2–10 wouldn't have exercised on its
own:

- **1-player (solo) game.** `start_game`'s player-count check is `< 1`,
  not `< 2` — a solo game creates, starts, and reaches `QUESTION`
  correctly. No bug; confirms the existing check was already written for
  this case, not merely happening to allow it.
- **The `QUESTION`/`end_question` race.** A player's `submit_answer` that
  arrives after the host has already called `end_question` (game already
  flipped to `REVEAL`) is rejected with the friendly
  "no longer accepting answers" message, and `end_question` had already
  back-filled a zero-point "no answer" row for that player — so a
  legitimately-late submission is rejected cleanly, not silently scored,
  and the player isn't left as an unrecorded gap in that question's
  answers. No bug.
- **Rapid double-submission** (same player, same question, two
  `submit_answer` calls back to back — a faster loop than Phase 9's rate
  limit alone would need to catch, since this is the business-rule
  "already answered" check underneath it). Second call rejected with the
  friendly message; exactly one `answers` row exists afterward, not two.
  No bug.
- **Nickname length boundary.** Exactly 20 characters (the client
  `TextField`'s `maxLength`) is accepted; 21 is rejected server-side with
  the friendly message rather than silently truncated. No bug — but this
  is worth having caught in a repeatable test rather than continuing to
  rely on the client's `maxLength` alone never being bypassed.
- **Insufficient questions for a narrow filter combination** (seed data
  has only 2 `history`/`hard` questions; requested 5) — rejected with the
  friendly "Not enough questions available" message, and the game stays in
  `WAITING` rather than partially mutating state before failing. No bug.
- **Rate limiting still active** (re-verified `heartbeat`'s 20-calls/30s
  limit specifically, as a regression check against everything else this
  phase touched, not because a break was expected). No bug.
- **Host disconnect → `claim_host` reassignment**, exercised once more as
  a straightforward regression check. No bug.

**Net result: zero real bugs found.** Phases 2–10's own per-phase testing
discipline had genuinely already covered these paths correctly; what this
phase added is a *repeatable, re-runnable* form of that same confidence
instead of one that only existed in a session's scrollback, plus real
(if narrow) unit coverage on the client's one pocket of pure logic.

**Validated by testing:**
- `supabase/tests/run_scenarios.sql` run twice consecutively against a
  fresh local Postgres (same one-time setup as every prior SQL-touching
  phase — see `docs/MASTER_HANDOFF.md`'s "How to test your work"): 27/27
  assertions pass both times.
- `npm run test` (Vitest): 18/18 pass.
- `npm run build` (`tsc -b && vite build`): zero errors.
- `npm run lint` (oxlint): 112 total errors, but confirmed by filename
  that all 112 are inside `node_modules` (mostly `typescript`,
  `react-dom`, `react-router`'s own bundled output) — zero errors in
  `src/`. The 2-error increase over the previously-documented 110
  baseline is `vitest` and its transitive dependencies now existing in
  `node_modules` at all, not anything in this project's own code; the
  right number to track going forward is "errors under `src/`," which is
  0, same as every prior phase.
- `grep`'d the compiled `dist/assets/*.css` for `min-height:100dvh` (a
  Phase 10 marker) post-build as a quick sanity check that this phase's
  changes didn't disturb anything from Phase 10 — still present.

**Also removed:** the empty `tests/` folder scaffolded in Phase 1. Its
originally-intended role is now filled by two things instead: Vitest test
files live co-located next to the source they test (`src/**/*.test.ts`,
Vitest's own convention), and the SQL scenario runner lives in
`supabase/tests/` (next to the migrations it exercises, not the frontend
`src/` tree). An empty top-level folder with nothing pointing to it would
just be confusing for the next session.

**Not included in this phase, and why:**
- **No component-level rendering tests** (React Testing Library, jsdom,
  etc.). This codebase's UI components are thin renderers over data that's
  already validated server-side (correctness, scoring, phase transitions)
  — the case for testing them would be catching JSX/markup mistakes, which
  `tsc -b` and the Phase 10 visual-review pass already cover for this
  project's size. Revisit if the component layer grows real conditional
  logic of its own worth unit-isolating.
- **No load/concurrency testing** (e.g. many simulated concurrent
  `submit_answer` calls racing against each other for the same question).
  `0014_security_hardening.sql`'s `claim_host` fix already required
  reasoning about one specific real race (documented there); a broader
  concurrency-fuzzing pass is a reasonable thing for a future phase but
  wasn't part of what this handoff's Phase 11 notes asked for.
- Did not touch the question bank (Phase 14) or start Phase 12
  (production deployment).

**Next phase:** Phase 12 — production deployment.

## Phase 12 — Automatic Mode & Configurable Answer Behavior ✅

**Completed:**
- `supabase/migrations/0015_automatic_mode_and_answer_behavior.sql` — two
  new independent, orthogonal per-game settings chosen at `create_game`
  time, both defaulting to Phases 1–11's only prior behavior:
  - **Game Mode**: `HOST_CONTROLLED` (unchanged) | `AUTOMATIC` (new). In
    Automatic mode the host still creates the room, configures it, waits
    for players, and clicks Start Game — after that, nothing further is
    required from the host. A new `auto_advance_game(p_game_id)` function,
    callable by **any** participant (not host-restricted), drives every
    remaining transition (`COUNTDOWN → QUESTION → REVEAL → LEADERBOARD →
    next QUESTION | FINISHED`) once the relevant phase's real elapsed
    server time has actually passed. Because every connected client polls
    it independently (`src/hooks/useAutoAdvance.ts`, 1s interval), the game
    keeps advancing even if the host disconnects mid-game — this project
    has no server-side cron/Edge Function infrastructure, so "any
    participant can trigger it, gated on real elapsed time, safe to call
    redundantly" is the honest version of "the backend continues it" that
    this stack can actually deliver; see the migration's header comment
    for the full reasoning.
  - **Answer Behavior**: `LOCK_ON_SELECTION` (unchanged — first tap wins,
    a second `submit_answer` call is rejected) | `CHANGE_UNTIL_TIMER_ENDS`
    (new — `submit_answer` upserts the same row instead of insert-only, so
    a player can keep changing their pick; only the latest selection is
    ever stored or scored, and `players.score` is adjusted by the *delta*
    between the new and previous points so switching answers never
    double-counts).
  - A new `games.phase_started_at` column anchors COUNTDOWN/REVEAL/
    LEADERBOARD timing for Automatic mode (QUESTION keeps using the
    pre-existing `question_started_at`, untouched).
  - Small deliberate hardening, flagged rather than silent: `submit_answer`
    now also rejects a submission once real elapsed time has passed
    `time_limit_seconds`, even if `status` hasn't flipped to `REVEAL` yet
    — closes a small timing window that matters more once
    change-until-the-wire is an intended interaction rather than an edge
    case. Applies to both answer behaviors; strictly tighter than before,
    never looser.
  - `create_game`'s old 5-argument signature was explicitly dropped (not
    just `create or replace`d) before creating the new 7-argument one,
    since Postgres treats a changed argument-type list as a distinct
    overload rather than a replacement — leaving the old 5-arg signature
    callable alongside the new one would have been a silent footgun.
- **Frontend**: `src/hooks/useAutoAdvance.ts` (new, mirrors
  `useHeartbeat.ts`'s "every client, not just host" polling shape);
  `CreateGame.tsx` gained Game Mode and Answer Behavior pill selectors with
  short descriptions (`src/data/gameOptions.ts`); `GameRoom.tsx`'s
  host-only manual transition handlers
  (`handleCountdownComplete`/the QUESTION-timeout effect/
  `handleContinueToLeaderboard`/`handleAdvanceQuestion`) are now no-ops in
  Automatic mode, deferring entirely to `auto_advance_game`;
  `QuestionScreen.tsx` allows re-selecting an answer under
  `CHANGE_UNTIL_TIMER_ENDS` (only `timeUp` disables the buttons, not
  `hasAnswered`) with an updated helper line telling the player they can
  still change their pick; `RevealScreen.tsx`/`LeaderboardScreen.tsx` swap
  the host's manual button for an "Advancing automatically…" message in
  Automatic mode, for every player including the host.
- `database.types.ts` — added `game_mode`/`answer_behavior` enums,
  `games.game_mode`/`answer_behavior`/`phase_started_at` columns,
  `create_game`'s two new Args, and the `auto_advance_game` function
  signature.

**Validated by testing, not just review:**
- Rebuilt the same disposable local Postgres instance used in Phase
  2/6/7/8/9/11 from scratch, applied all 15 migrations in order (0001
  through this phase's 0015) plus the seed data — clean, no errors.
- Extended `supabase/tests/run_scenarios.sql` with 5 new scenarios (9–13,
  23 new assertions — 59 total across all 13 scenarios now, all passing on
  a clean re-run):
  - **Scenario 9**: a full 2-question `AUTOMATIC` game driven start-to-
    finish by `auto_advance_game` alone (never calling
    `begin_first_question`/`end_question`/`advance_to_leaderboard`/
    `advance_question`), backdating `phase_started_at`/`question_started_at`
    instead of sleeping through each real duration — confirms it's a
    no-op before each phase's time is up, correctly records a no-answer
    row for a player who never submitted, and reaches `FINISHED` with
    `finished_at` stamped.
  - **Scenario 10**: `auto_advance_game` is a harmless no-op on a
    `HOST_CONTROLLED` game no matter how much time has passed, and a
    redundant call immediately after a real transition doesn't
    double-advance — the two safety properties the "any client can call
    this, possibly at almost the same moment" design depends on.
  - **Scenario 11**: `CHANGE_UNTIL_TIMER_ENDS` — wrong → wrong → correct in
    one question; only one `answers` row ever exists (upsert, not insert),
    only the final pick is stored/scored, and the player's final score
    equals exactly that one answer's points (never a sum across the three
    picks).
  - **Scenario 12**: `LOCK_ON_SELECTION` (the default) still hard-rejects
    a second `submit_answer` call with the pre-existing friendly message —
    confirms Scenario 11's upsert path didn't loosen the default.
  - **Scenario 13**: the new real-elapsed-time cutoff actually fires —
    backdating `question_started_at` past the time limit while `status` is
    still `QUESTION` (simulating the gap before `end_question`/
    `auto_advance_game` lands) gets a late `submit_answer` call rejected.
- `npm run build` (`tsc -b && vite build`): zero errors.
- `npm run test` (vitest): 22/22 passing, up from 18 — added 4 new
  `gameOptions.test.ts` cases (label/description table integrity for the
  two new option sets, same shape as the existing category/difficulty
  checks) on top of the 18 carried over unchanged from Phase 11.
- `npx oxlint src`: 0 errors (10 pre-existing `exhaustive-deps` warnings,
  same as before this phase — none introduced by these changes).

**Backward compatibility, explicitly checked:** `game_mode` and
`answer_behavior` are `not null default` columns and `create_game`'s two
new parameters are both defaulted, so every pre-Phase-12 game row and every
call from an un-upgraded client lands on exactly
`HOST_CONTROLLED`/`LOCK_ON_SELECTION` — Phases 1–11's only behavior, with
no migration of existing data required. No existing question, room,
player, or answer data was touched; every changed function
(`create_game`, `start_game`, `submit_answer`, `end_question`,
`advance_to_leaderboard`) kept its pre-existing behavior for games that
didn't opt into the new settings, verified directly by Scenarios 10 and
12 above rather than left as an assumption.

**Not included in this phase, and why:**
- **No true server-side scheduled job** (pg_cron, Supabase Edge Function
  cron trigger) driving Automatic mode — this stack has neither, and
  standing one up is a hosting-platform/infrastructure decision that
  belongs with Phase 13 (production deployment), not a schema migration.
  The any-client-polls-`auto_advance_game` design is the pragmatic
  equivalent given what's actually available; see this phase's migration
  header comment for the full tradeoff reasoning.
- **Realtime wire behavior for the new columns** wasn't (and can't be,
  from this sandbox) exercised against a live Supabase project, same
  standing limitation as every earlier phase's Realtime work — the
  `postgres_changes` subscription already covers `games` UPDATE events
  generically (`select("*")`), so the new columns ride along automatically
  with no subscription changes needed, but the live wire behavior itself
  is unverified here.
- **No component-rendering tests** for the new `QuestionScreen`/
  `RevealScreen`/`LeaderboardScreen` branches — same reasoning as Phase
  11's entry (this codebase's UI is a thin renderer over server-validated
  state; `tsc -b` plus the SQL-level correctness tests cover this
  project's size).
- Did not touch the question bank (Phase 14) or start Phase 13 (production
  deployment).

**Next phase:** Phase 13 — production deployment.

## Phase 13 — Play Again (rematch in the same room) + no repeated questions ✅

Bug report: "Play Again" just linked to `/create` — a brand-new room, new
code, everyone (including the host) had to rejoin and retype their
nickname — and questions repeated within just a few games because
`start_game`'s random draw had no memory of what any earlier game had
already used.

**Completed:**
- `supabase/migrations/0016_play_again_and_no_repeat_questions.sql`:
  - New `play_again(p_game_id)` function. Host-only, only once
    `status = 'FINISHED'`. Resets the **same** `games` row — same `id`,
    same `room_code` — back to `WAITING` with a new `round_number` and
    every player's score zeroed. `players` rows are never touched, so
    nicknames, host status, and connection state all carry over exactly
    as they were — no rejoin, no new invite link, nothing for anyone to
    retype. The existing `start_game` (unchanged host action) is what
    kicks off the next round from that same lobby.
  - New `games.round_number`, `game_questions.round_number`,
    `answers.round_number` columns (all `not null default 1`, so every
    existing row reads as round 1 — no migration of existing data
    needed). `game_questions`'s and `answers`' uniqueness constraints
    were widened to include `round_number`, so the exact same question
    can legitimately reappear in a later round without colliding with its
    own leftover row from an earlier one.
  - `start_game` now prefers questions **never used before anywhere in
    this room's history** (any earlier round of the same `game_id`),
    only falling back to allowing a repeat once that "never used" pool is
    actually exhausted — never errors either way. A brand-new game has no
    history yet, so round 1 behaves exactly as before this migration.
  - Every function that reads or writes "the current question's" answers
    (`submit_answer`, `end_question`, `get_answer_reveal`,
    `get_leaderboard`, and `auto_advance_game`'s QUESTION branch) is now
    `round_number`-scoped — without that, a question repeating in round 3
    would collide with its own round-1 answer row: wrong "already
    answered" rejection under Lock on Selection, wrong upsert target
    under Change Until Timer Ends, wrong percent-correct in the reveal,
    wrong score delta on the leaderboard. None of the round-1 behavior
    for any of these functions changed — they're scoped to
    `round_number = 1` where they used to have no round concept at all.
- **Frontend**: `gameApi.ts` gained `playAgain()`. `Results.tsx`'s "Play
  Again" button now calls it (host-only — non-hosts see a "waiting for
  the host" card instead, same pattern as the mid-game Reveal/Leaderboard
  screens) instead of linking to `/create`; a new effect mirrors
  `GameRoom.tsx`'s existing FINISHED → `/results` effect in reverse —
  once `play_again` flips `status` back to `WAITING`, every subscribed
  client (host included) is routed back to `/game/:roomCode`
  automatically via the same Realtime path every other transition in
  this app already uses, not a local-only navigation tied to whoever
  clicked the button. A **separate, smaller bug** surfaced while wiring
  this up and is fixed alongside it: `GameRoom.tsx`'s
  "has this question already been answered / already had `end_question`
  called for it" guards were keyed on `question.questionId` (the
  underlying `questions.id`), which — now that a question can legitimately
  repeat across rounds — could collide with a stale value left over from
  an earlier round and either skip resetting the answer UI or (worse)
  permanently prevent `end_question` from ever firing for a
  Host-Controlled game whose repeated question matched one already seen
  by that ref. Both are now keyed on `game.current_question_id` (the
  `game_questions` row id), which is fresh every round even when the
  underlying question repeats.
- `database.types.ts` — added `round_number` to `games`/`game_questions`/
  `answers`, and the `play_again` function signature.

**Validated by testing, not just review:**
- Rebuilt the same disposable local Postgres used since Phase 2 from
  scratch, applied all 16 migrations clean, re-ran the full existing
  59-assertion suite unmodified first to confirm zero regressions before
  adding anything.
- Added 3 new scenarios (14–16, 24 new assertions, 83 total across the
  full suite, all passing on a clean re-run):
  - **Scenario 14**: `play_again` end-to-end — rejected before `FINISHED`
    and for a non-host caller; once called, the room_code is unchanged,
    status is back to `WAITING`, `round_number` incremented,
    `finished_at` cleared, both players' nicknames and the host's
    `is_host` flag are untouched, both scores are back to 0, no players
    rows were added or removed, and `start_game` works again immediately
    for round 2 in the same room.
  - **Scenario 15**: using the seed's exactly-4-question trivia/easy pool
    with `question_count = 2` — round 1 draws 2, round 2 (exactly 2 fresh
    remaining) is proven **completely disjoint** from round 1, and round 3
    (pool now fully exhausted across rounds 1+2) is proven to fall back to
    a repeat **without erroring**.
  - **Scenario 16**: a question forced to repeat across rounds doesn't
    corrupt scoring — answering it again in a later round isn't blocked
    by its round-1 answer row, and both rounds' answer rows exist
    independently (round-scoped), not merged or overwritten.
- `npm run build` (`tsc -b && vite build`): zero errors.
- `npm run test` (vitest): 22/22 passing, unchanged from Phase 12 — this
  phase's changes are SQL/routing-level, with no new pure-function surface
  that warranted new Vitest cases.
- `npx oxlint src`: 0 errors (one additional pre-existing-pattern
  `exhaustive-deps` warning from the new Results.tsx effect, deliberately
  narrower like every other transition effect in this codebase — 11 total,
  none newly problematic).

**Backward compatibility, explicitly checked:** `round_number` is
`not null default 1` on all three tables, so every pre-Phase-13 row reads
as round 1 with no data migration required, and `start_game`'s "exclude
previously-used questions" clause is a no-op for any `game_id` with no
`game_questions` history yet — i.e. every game that has never been
replayed, new or already in flight — confirmed by Scenario 15's round-1
behavior matching pre-migration behavior exactly.

**Not included in this phase, and why:**
- **No cumulative/"best of N rounds" scoring** — `play_again` resets
  `players.score` to 0 for a clean new scoreboard each round, which is
  what "Play Again" implies without further specification. A running
  total across rounds would need its own aggregate leaderboard function
  and UI, and wasn't part of the reported bug.
- **No per-round settings editing** (category/difficulty/question count/
  time limit/game mode/answer behavior all carry over unchanged into the
  next round) — there's no "edit settings while WAITING" UI at all yet,
  for the first round or a rematch; out of scope for this fix.
- **Live Realtime-wire verification** of the new WAITING↔FINISHED round
  trip wasn't (and can't be, from this sandbox) exercised against a live
  Supabase project — same standing limitation noted in every earlier
  phase's Realtime work.

**Next phase:** Phase 14 — production deployment.

## Automatic mode timing tune-up (0017) ✅

Reported directly: Automatic mode felt slow. Cause: `auto_advance_game`'s
fixed `REVEAL_SECONDS`/`LEADERBOARD_SECONDS` constants (set in Phase 12)
were 6s and 5s — 11 seconds of pure dead time per question on top of
however long the question itself took, before any poll lag on top of
that.

**Completed:**
- `supabase/migrations/0017_faster_automatic_mode_timing.sql`: retuned
  `REVEAL_SECONDS` 6→3 and `LEADERBOARD_SECONDS` 5→2.
  `COUNTDOWN_SECONDS` (3) is unchanged — it's a cosmetic "3, 2, 1, Go" the
  player is meant to watch, not dead time, and it has to keep matching
  `CountdownOverlay`'s default. Net: ~11s of forced waiting per question
  drops to ~5s.
- `src/hooks/useAutoAdvance.ts`: poll interval 1000ms → 500ms, so the
  extra lag between a phase's timer actually elapsing and some client's
  next poll picking it up is also cut in half — comfortably inside
  `auto_advance_game`'s existing rate limit (3 calls/s average allowed;
  500ms is 2/s).

**Validated by testing:** re-ran the full 83-assertion suite unmodified
first (zero regressions — Scenario 9's backdating uses 10s offsets, well
clear of either new threshold), then added Scenario 17 (5 assertions, 88
total) locking in both new durations at their exact edges — a poll just
under 3s/2s must still no-op, a poll just over must transition — so a
future change can't silently regress this back toward "too slow" without
a test failing. `npm run build`, `npm run test` (22/22), and
`npx oxlint src` (0 errors) all clean.

## Phase 15 — Expand question bank + categories ✅

Done out of sequence, ahead of Phase 14 (production deployment), at
explicit request — merged on top of Phase 12/13's Automatic Mode, Play
Again, and timing tune-up work rather than the branch it was originally
built against, so migration numbers below reflect the merged position
(0018/0019, not their original 0015/0016).

**Completed:**
- Added 15 new categories to both `game_category_setting` and
  `question_category` enums in
  `supabase/migrations/0018_expand_categories.sql`: `politics_government`,
  `provinces_cities`, `languages`, `literature`, `music`, `movies_tv`,
  `celebrities`, `festivals`, `mythology_folklore`, `nature_wildlife`,
  `landmarks`, `innovations`, `economy_business`, `technology`,
  `religion_traditions`.
- Of the 20 categories originally requested, 5 already existed under a
  different (already Philippines-scoped) name and were **not**
  duplicated — new questions for those went to the existing enum value
  instead:
  - "Philippine History" → existing `history`
  - "Filipino Food & Cuisine" → existing `food`
  - "Filipino Sports" → existing `sports`
  - "Filipino Slang & Expressions" → existing `slang`
  - "General Philippines Trivia" → existing `trivia`
- Added 200 new questions in
  `supabase/migrations/0019_new_categories_and_questions.sql`: 10 each
  across the 15 new categories (150 total), plus a 50-question top-up
  spread across the 8 original categories (history +6, geography +6,
  culture +6, food +7, entertainment +6, sports +6, trivia +6, slang +7).
  Difficulty split: 78 easy / 85 medium / 37 hard (target was ~35/45/20;
  landed close to it, slightly heavier on medium/lighter on hard than the
  recommendation, which the spec treated as a guideline rather than a
  hard requirement).
- Every new row: exactly 4 unique choices, exactly 1 correct answer, and
  an explanation. Inserted via `INSERT ... SELECT ... WHERE NOT EXISTS`
  guards keyed on `(category, prompt)`, so the migration is safe to
  re-run.
- Did **not** modify, delete, or duplicate any of the 80 questions in
  `supabase/seed/0001_sample_questions.sql`, and did **not** touch any
  of Phase 12/13's Automatic Mode, Play Again, or timing-tuning work —
  this phase is additive only.
- Fact-checked the riskiest/least-certain claims via web search before
  writing them into the migration rather than trusting memory alone
  (e.g. the composer of "Bayan Ko", Brillante Mendoza's 2009 Cannes Best
  Director win for *Kinatay*, *Insiang* being the first Filipino film
  shown at Cannes, Eugenio Torre's 1974 Grandmaster title, Roberto del
  Rosario's karaoke-machine patent). Where a popular claim is genuinely
  contested (e.g. exactly who "invented karaoke", or the precise extent
  of Eduardo San Juan's NASA lunar-rover contribution), questions were
  worded to reflect what's *popularly credited* rather than asserting a
  disputed fact outright.

**Validated by testing, not just review:**
- A Python validation pass over all 200 drafted questions confirmed: 0
  structural errors (choice count/uniqueness, valid difficulty, valid
  correct-answer letter, non-empty explanation), 0 duplicate prompts
  among the new questions, and 0 prompt overlap with the existing 80
  seed questions.
- Applied every migration `0001` through `0019` plus the seed file, in
  order, against a disposable local Postgres — all applied cleanly with
  `ON_ERROR_STOP=1`, including on top of Phase 12/13's `game_mode`/
  `answer_behavior`/`round_number` schema changes and `0017`'s timing
  retune.
- Confirmed `select count(*) from questions` = 280 (80 existing + 200
  new), with all 23 categories represented at every difficulty level.
- Re-ran `supabase/tests/run_scenarios.sql` (now 17 scenarios / 88
  assertions, after Phase 12/13/timing-tuneup's additions) against the
  expanded database — **all 88 assertions still pass**, confirming this
  phase's additions don't interfere with Automatic Mode, Play Again, or
  the no-repeat-question logic.
- Ran a new ad hoc end-to-end check: called `create_game` with the
  brand-new `music` category, joined a second player, started it, and
  confirmed both that it reached `COUNTDOWN` and that every assigned
  question actually belonged to `music`. No changes were needed to
  `create_game`/`start_game`/`auto_advance_game` — they filter/accept by
  the enum type itself, not an enumerated list of values, so new
  categories are automatically playable in both Host-Controlled and
  Automatic mode the moment `0018` lands.

**Frontend:**
- `src/types/database.types.ts` — added the 15 new values to
  `GameCategorySetting`, alongside (not replacing) Phase 12's
  `GameModeRow`/`AnswerBehaviorRow` additions.
- `src/data/gameOptions.ts` — added labels for the 15 new categories to
  `CATEGORY_LABELS` (still the single source of truth `CATEGORY_OPTIONS`
  derives from), and a new `CATEGORY_GROUPS` export clustering all 23
  categories + Random into 5 labeled sections. Phase 12's
  `GAME_MODE_*`/`ANSWER_BEHAVIOR_*` exports are untouched.
- `src/pages/CreateGame.tsx` — the "Category" section now renders
  `CATEGORY_GROUPS` as multiple labeled `SelectPills` groups instead of
  one flat 24-pill list; same component, same visual style. The Game
  Mode and Answer Behavior sections added in Phase 12 are unchanged.
- `src/data/gameOptions.test.ts` — added two tests asserting
  `CATEGORY_GROUPS` stays in sync with `CATEGORY_OPTIONS` (every option
  present exactly once, no unknowns) and that every group has a label
  and at least one option, alongside Phase 12's existing game-mode/
  answer-behavior integrity tests.
- `npx tsc -b && vite build`: clean, zero errors. `npm run test`: 22/22
  pass (all pre-existing, unchanged — this phase added no new pure-logic
  surface needing a Vitest case beyond the 2 already listed above).
  `npx oxlint src`: no new errors or warnings introduced by any file this
  phase touched.

**Not included in this phase (by design, per the request's scope):**
- No redesign of the category selector's visual style — grouping only.
- No changes to scoring, timers, Automatic Mode pacing, or Play Again
  behavior.
- No production deployment work (still Phase 14, next in sequence).

**Next phase:** Phase 14 — production deployment.

