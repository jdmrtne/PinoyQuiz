# Changelog

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

