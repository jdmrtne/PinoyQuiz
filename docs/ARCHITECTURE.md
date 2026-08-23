# Architecture

This document explains how Pinoy Quiz is built and how the pieces fit
together. It's written ahead of most of the backend work so that whoever
(or whichever Claude session) picks this up next has a clear target to
build against. Sections marked **(planned)** describe the intended design
but are not implemented yet — check `CHANGELOG.md` for exactly what exists
today.

## Phase roadmap

| Phase | Scope | Status |
|---|---|---|
| 1 | Project setup + UI foundation | ✅ Done |
| 2 | Database schema + Supabase config | ✅ Done |
| 3 | Create/join room system | ✅ Done |
| 4 | Multiplayer lobby + realtime sync | ✅ Done |
| 5 | Question system + game engine | ✅ Done |
| 6 | Answer submission + scoring | ✅ Done |
| 7 | Leaderboard + final results | ✅ Done |
| 8 | Disconnect/reconnect handling | ✅ Done |
| 9 | Security + anti-cheat hardening | ✅ Done |
| 10 | Mobile responsiveness + UI polish | ✅ Done |
| 11 | Testing + bug fixing | ✅ Done |
| 12 | Automatic Mode + Configurable Answer Behavior | ✅ Done |
| 13 | Play Again (rematch in same room) + no repeat questions | ✅ Done |
| 14 | Production deployment | ⬜ Not started |
| 15 | Expand question bank + categories | ✅ Done (out of order — see below) |

Work normally happens one phase at a time, in order. Phase 15 is the one
exception so far: it was explicitly requested and completed before Phase
14, ahead of its place in this table. Phase 14 (production deployment)
remains the next phase in sequence for whoever picks this up next. Do not
start a phase's code until the previous one is tested and documented.

## Frontend architecture

- **Vite + React + TypeScript**, strict-mode TS.
- **Routing** (`src/App.tsx`) — one route per page in the spec:
  `/`, `/create`, `/join`, `/join/:roomCode`, `/game/:roomCode`,
  `/results/:roomCode`. `/join/:roomCode` and `/join` render the same
  `JoinGame` page; the route param pre-fills the room code input once that
  page is built out.
- **Design system** — tokens live in `src/index.css` under `@theme`
  (Tailwind v4's CSS-based config). Palette, type, and the "jeepney
  stripes" signature motif are documented inline there. `src/components/ui`
  holds primitives (`Button`, `Card`) every later phase should reuse rather
  than re-styling from scratch.
- **Types** (`src/types/game.ts`) — the client-facing data contracts
  (`Game`, `Player`, `ClientQuestion`, `AnswerReveal`, `LeaderboardEntry`,
  `ScoringConfig`) are defined now so Phase 2's DB schema and Phase 5's
  game engine both target the same shapes. Note `ClientQuestion`
  deliberately has no field for the correct answer — that's the anti-cheat
  boundary made explicit in the type system.
- **State (planned)** — Zustand is installed for realtime game state
  (current question, timer, leaderboard) once Phase 4 wires up Supabase
  subscriptions. Local component state (form inputs, UI toggles) stays in
  React state; only synced multiplayer state goes in the store.

## Database architecture (Phase 2 — implemented)

Schema lives in `supabase/migrations/`, applied in numeric order:
`0001_extensions` → `0002_enums` → `0003_tables` → `0004_views` →
`0005_rls` → `0006_grants`.

Tables, as specified in the brief, with FKs/indexes/constraints added:

- `games` — one row per room. `room_code` unique + indexed, format-checked
  (`^[A-Z0-9]{6}$`). `status` is the state-machine enum (see below).
  Also carries the *live* play pointer (`current_question_index`,
  `current_question_id`, `question_started_at` as the server-authoritative
  timer anchor) and a per-game `scoring_config` JSONB column — scoring is
  data, not a hard-coded constant (spec 3, "configurable scoring system").
- `players` — belongs to a `game`, `references auth.users(id)`. Unique
  constraint on `(game_id, user_id)` (rejoining reuses the row — this is
  the reconnect mechanism for Phase 8) and a separate case-insensitive
  unique index on `(game_id, lower(nickname))` so the DB itself rejects
  duplicate nicknames, not just client-side validation.
- `questions` — the master bank, keyed by `category` + `difficulty` enums.
  `correct_option` and `explanation` never reach a browser — see Security
  model below.
- `game_questions` — join table pinning a randomized, de-duplicated
  (`unique(game_id, question_id)`) subset of `questions` to a `game`, in
  play order (`unique(game_id, question_order)`), plus a `shuffle_map`
  smallint[4] recording how that game's answer options were shuffled. This
  table is never directly readable by clients (see Security model) —
  exposing it would leak both the shuffle and the question order.
- `answers` — one row per (player, question) submission.
  `unique(game_id, player_id, question_id)` means "no double submission"
  is a database constraint, not just a check in application code — even a
  buggy or malicious client literally cannot insert a second row for a
  question it already answered.

Two views exist purely to narrow what's exposed to clients:
`questions_public` (all `questions` columns except `correct_option` and
`explanation`) and `leaderboard` (ranked, public player fields only, no
`user_id`).

## Create/join room system (Phase 3 — implemented)

Three `SECURITY DEFINER` functions in `supabase/migrations/0007_room_functions.sql`
are the only way `games`/`players` rows get created, matching the "the
functions are the server" model from Phase 2:

- **`create_game(...)`** — generates a 6-character room code (charset
  excludes visually ambiguous `0/O/1/I/L`), retrying up to 10 times on a
  collision, inserts the `games` row with `host_user_id = auth.uid()`, then
  inserts the host's own `players` row (`is_host = true`) in the same
  transaction. Returns `{game_id, room_code, player_id}`.
- **`lookup_game_by_room_code(code)`** — a deliberately narrow read for the
  pre-join screen. Returns only `{found, status, category, difficulty,
  question_count, time_limit_seconds}` — no `id`, no `host_user_id` — so
  someone probing room codes before joining can't harvest a full game row.
  This is *separate* from the `games_select_participant` RLS policy, which
  only lets you `SELECT` a game you're already in.
- **`join_game(code, nickname)`** — validates the game exists, rejects
  joining if `status <> 'WAITING'` ("this game has already started"),
  rejects a case-insensitively duplicate nickname, and caps rooms at 50
  players. **Reconnect is built in**: if the calling `auth.uid()` already
  has a `players` row in that game (same anonymous session, e.g. a page
  refresh), it flips `connected = true` and returns the existing player
  instead of erroring or duplicating — this is the data-layer half of
  Phase 8's disconnect handling; the presence/heartbeat half still needs
  building then.

Client side, `src/lib/gameApi.ts` wraps all three as typed functions
(`createGame`, `lookupGame`, `joinGame`) with a shared error mapper that
turns the Postgres exception text into the same friendly copy on every
call site. `CreateGame.tsx` and `JoinGame.tsx` are now fully functional
forms; `GameRoom.tsx` does a one-time fetch (via the RLS-gated
`supabase.from("games")`/`.from("players")` reads, not RPCs — this is
intentionally the first place the app reads directly rather than through
a function, since reads were always allowed by RLS) to show the invite
code, invite link, and current roster. It explicitly does **not** yet
subscribe to changes — a second browser joining won't appear without a
manual refresh until Phase 4 adds Realtime.

**Validated, not just written:** re-ran all 7 migrations (0001–0007)
against a fresh local Postgres, then exercised `create_game`/`join_game`/
`lookup_game_by_room_code` as the `authenticated` role for: normal create;
lookup of a real and a fake code; a normal join; a rejected duplicate
nickname; a second real player joining after that rejection; the *same*
player calling `join_game` again (confirmed it reconnects — same
`player_id`, `players` row count stays at 1, `out_reconnected = true`);
joining a nonexistent code; and joining a game whose status had been
flipped away from `WAITING` (confirmed rejected with "already started").

## Question system and game engine (Phase 5 — implemented)

**Question bank:** `supabase/seed/0001_sample_questions.sql` seeds 80
questions (10 per category × 8 categories, roughly 4 easy / 3 medium /
3 hard each). This is deliberately *not* the full 240 the spec calls
for — see the seed file's header comment. Every question was chosen for
facts I'm confident are accurate and unambiguous; padding to 240 by
including anything "probably right" would violate the spec's own
requirement that answers not be ambiguous. Expanding this to 240 is
tracked as Phase 14 and needs the same verification bar, not a rush to
hit a number.

**Practical consequence, discovered by testing (see below): with only
~3-4 questions per category+difficulty cell, `start_game` will
legitimately reject narrow settings** (e.g., a specific category at a
specific difficulty asking for 10 questions) with "not enough questions
available." Broader settings (a specific category with Mixed difficulty,
or Random category at any difficulty) have enough headroom. This is
surfaced to the host as a friendly error, not a crash — but it's a real
current limitation worth knowing about before demoing.

**Game engine**, in `supabase/migrations/0010_game_engine.sql`, covers the
state machine from `WAITING` through serving the first question:

- **`start_game(game_id)`** — host-only, requires `status = 'WAITING'`
  and at least one player (spec: "Do not allow the game to start if there
  are no players"). Builds this game's question set by querying
  `questions` with the game's category/difficulty settings (`'random'`/
  `'mixed'` mean "no filter"), ordering randomly, and capping at
  `question_count` — this is where de-duplication comes from implicitly
  (each `questions.id` can only be picked once per `ORDER BY random()
  LIMIT n` query). For each selected question, generates a random
  `shuffle_map` (a permutation of `[0,1,2,3]`) and inserts a
  `game_questions` row. Moves `games.status` to `COUNTDOWN`.
- **`begin_first_question(game_id)`** — host-only, requires
  `status = 'COUNTDOWN'`. Sets `current_question_index = 0`,
  `current_question_id`, and `question_started_at = now()` (the
  server-authoritative timer anchor scoring will use in Phase 6), and
  flips `status` to `QUESTION`.
- **`get_current_question(game_id)`** — any participant. Returns *only*
  the currently-live question, with option text already reordered
  according to that question's `shuffle_map`, and no correct-answer
  field anywhere in the response. Returns zero rows if the game isn't in
  `QUESTION` status — a client can't fetch ahead by guessing at
  `game_questions` rows, because it can't reach that table directly at
  all (no grant, no policy — Phase 2) and this function only ever looks
  at `games.current_question_id`.

**Client side:** `CountdownOverlay` plays a cosmetic 3-2-1 (the server
doesn't care how long it takes); the host's client calls
`begin_first_question` when it finishes, restricted to the host so an
impatient non-host can't cut it short for everyone. `useServerTimer`
computes remaining time from the server's `question_started_at` plus
`time_limit_seconds`, not from when the client happened to render, so a
slow-loading client still sees a correct (lower) number. `QuestionScreen`
renders the prompt and four shuffled options — **read-only** in this
phase; the buttons are present but disabled, since answer submission and
scoring are Phase 6 by design.

**Validated, not just written:** ran all 10 migrations plus the seed file
against a fresh local Postgres, confirmed exactly 80 rows landed with 10
per category (proving the seed SQL's apostrophe/quote escaping was
correct throughout), then walked the full flow as two simulated real
players: non-host blocked from starting; an intentionally-too-narrow
category+difficulty combination correctly rejected with "not enough
questions" (this is what surfaced the limitation described above); a
valid start succeeding; `get_current_question` correctly returning zero
rows before the first question begins; non-host blocked from calling
`begin_first_question`; the host successfully advancing to `QUESTION`;
a real participant fetching the shuffled question with no correct-answer
field visible; and an outsider — even one who somehow obtained a real
`game_id` — still rejected. **Found and fixed one real bug this pass:**
`v_gq.question_order + 1` in `get_current_question` promotes from
`smallint` to `integer` under Postgres's arithmetic rules, which didn't
match the function's declared `smallint` return column, causing a runtime
"structure of query does not match function result type" error on every
call. Fixed with an explicit `::smallint` cast; re-tested and confirmed.

`supabase/migrations/0008_realtime.sql` adds `games` and `players` to the
`supabase_realtime` publication Supabase provisions in every project.
Realtime enforces each table's existing RLS policies automatically — a
client only receives change events for rows it could already `SELECT`
(see `games_select_participant` / `players_select_same_game` in
`0005_rls.sql`), so no separate "realtime policy" was needed.

`src/hooks/useGameRealtime.ts` does the actual client-side work: an
initial one-shot fetch of the game + roster, then a `supabase.channel(...)
.on("postgres_changes", ...)` subscription filtered to that `game_id`,
covering `players` INSERT/UPDATE/DELETE (join, reconnect, host removal)
and `games` UPDATE (status changes once Phase 5 starts writing them).
`GameRoom.tsx` now renders straight from this hook instead of the
Phase 3 one-time fetch — a second browser joining the same room code
should appear in the first browser's roster without a refresh.

`remove_player(player_id)` (`0009_lobby_functions.sql`) rounds out the
lobby: a host-only `SECURITY DEFINER` function that deletes a player row,
which every remaining participant picks up as a `DELETE` event through
the same subscription. **Known gap:** because RLS re-evaluates against
the *current* table state, the removed player's own client stops being
considered a "participant" the instant their row is gone, so they may not
reliably receive the DELETE event describing their own removal. Their
screen simply won't update further rather than showing an explicit "you
were removed" message. A clean fix (e.g. a short-lived broadcast message
to that specific player, or a `kicked` flag surfaced through a narrower
channel) is deferred to Phase 8/9 rather than solved here.

**What I could and couldn't verify from this sandbox:** all of the SQL —
the publication statement, `remove_player`'s authorization logic (host vs.
non-host, self-removal, double-removal) — was run and tested against a
disposable local Postgres, same as every other migration in this project.
What I could *not* test is actual Realtime message delivery: Supabase's
Realtime service is a separate hosted component from Postgres itself
(it reads the logical replication stream and pushes over WebSockets), and
nothing in this sandbox can stand in for that hosted service. The
`postgres_changes` subscription code follows the documented supabase-js v2
API precisely, and the RLS/security model it depends on is the part that
actually was tested — but the live "does it arrive over the wire" behavior
needs to be checked against your real project (open two browser tabs,
join the same room, confirm the roster updates in both without a
refresh).

## Answer submission and scoring (Phase 6 — implemented)

`supabase/migrations/0011_answer_submission.sql` covers the rest of the
live-play state machine's per-question half: submitting an answer, scoring
it, and moving `QUESTION → REVEAL`.

- **`submit_answer(game_id, selected_option)`** — any participant, once per
  question (the DB's `answers_one_per_player_per_question` constraint
  backstops the friendly "already answered" check). `selected_option` is
  the *displayed* slot (0-3) the client rendered, not an original A-D
  index — the function maps it back through this game's
  `game_questions.shuffle_map` to find the question's real
  `correct_option`, so correctness-checking never has to (and never does)
  leak the shuffle back to the client. Timing is entirely
  server-authoritative: `response_time_ms` comes from
  `now() - games.question_started_at`, clamped to the time limit, never
  from anything the client reports about its own elapsed time. Scoring
  reads `games.scoring_config` (set per-game, see Phase 2) rather than a
  hard-coded formula: `basePoints + speedBonus` when correct, where
  `speedBonus` scales linearly from `maxSpeedBonus` at t=0 down to 0 at
  the time limit; `incorrectPoints` when wrong. Updates `players.score` in
  the same transaction as the `answers` insert.
- **`end_question(game_id)`** — host-only, requires `status = 'QUESTION'`.
  For every player in the game who has no `answers` row yet for the
  current question, inserts one with `selected_option = null` and
  `points = noAnswerPoints` (also from `scoring_config`) — so "didn't
  answer in time" is scored the same table-driven way as everything else,
  not a special-cased zero. Then flips `status` to `REVEAL`. This is
  triggered by the *host's client-side timer* reaching zero, matching the
  same "host controls pacing" pattern as `begin_first_question` in Phase
  5 — the server itself still doesn't independently enforce the clock,
  it only trusts whichever host client calls this once time is up.
- **`get_answer_reveal(game_id)`** — any participant, readable only while
  `status = 'REVEAL'`. Returns the correct option in *displayed-slot*
  terms (so the client can highlight the same option it rendered during
  `QUESTION`, not the original A-D order), the question's explanation if
  one exists, the caller's own answer/points/correctness, and a
  percent-correct figure computed by counting `is_correct` across all of
  that question's `answers` rows for the game. This keeps
  `answers_select_own` (Phase 2's RLS policy) intact — no player can read
  another player's individual answer row, only this aggregate the
  function computes on their behalf.

**Client side:** `QuestionScreen` now renders four *interactive* buttons
instead of Phase 5's disabled placeholders — tapping one locks in an
optimistic UI state immediately and calls `submitAnswer`; a failed
submission reverts the lock so the player can retry. `RevealScreen` (new)
shows the correct answer highlighted in bagoong (the design system's
success green), the player's own pick highlighted in sunset (the
incorrect/urgency red) if they missed it, points earned this question, the
percent of players who got it right, and the explanation when the
question has one. `GameRoom.tsx` gained an `answeredIndex` state (reset
whenever `question.questionId` changes, so a future second question in
Phase 7 clears it automatically) and a `reveal` state populated from
`getAnswerReveal` whenever `game.status` becomes `REVEAL`, plus the
host-only effect described above that calls `end_question` exactly once
per question when `useServerTimer` (Phase 5) reaches zero.

**Validated, not just written:** ran all 11 migrations against a fresh
local Postgres (same stubbed `auth.users`/`auth.uid()` setup as every
prior phase) and walked the full two-player flow: `submit_answer` before
`QUESTION` (rejected), a stranger blocked from `get_current_question`, a
fast correct answer scoring exactly `1000 + 500 = 1500` (default
`scoring_config`), a rejected double-submission, a rejected non-host
`end_question`, a successful `end_question` transition to `REVEAL`, both
players' `get_answer_reveal` rows matching their real submissions with a
correct `50%` `percentCorrect`, and confirming both `submit_answer` and
`get_current_question` correctly reject once in `REVEAL`. A second,
three-player scenario (one answers, two don't) confirmed `end_question`
correctly back-fills exactly two "no answer" rows and that calling it
twice is rejected the second time. `npm run build` passes with zero
errors after the frontend changes.



```
WAITING → COUNTDOWN → QUESTION → REVEAL → LEADERBOARD → (next QUESTION | FINISHED)
```

`games.status` holds the current state. Clients render based on `status`
plus the current question/timer data — they never decide when to
transition; that's a server-side responsibility (Phase 5/6), which is what
makes this "real" multiplayer rather than a simulated one where each
client just guesses at synchronization.

## Score calculation (implemented — Phase 6)

Scoring is table-driven via each game's `scoring_config` JSONB column
(shape matches the `ScoringConfig` type in `src/types/game.ts`), not
hard-coded constants scattered through the game engine — see
`submit_answer` and `end_question` in
`supabase/migrations/0011_answer_submission.sql`:

```
points = isCorrect
  ? basePoints + speedBonus(responseTimeMs, timeLimitMs, maxSpeedBonus)
  : (answered ? incorrectPoints : noAnswerPoints)
```

`speedBonus` scales linearly from `maxSpeedBonus` at t=0 down to 0 at the
time limit: `speedBonus = round(maxSpeedBonus * (1 - responseTimeMs /
timeLimitMs))`, clamped to `[0, maxSpeedBonus]`. Calculated entirely
server-side from `now() - games.question_started_at` — never from a
client-reported "how fast I was" value.

## Security model (Phase 2 foundation implemented; Phase 9 hardens further)

Every player, including the host, authenticates via **Supabase Anonymous
Auth** (`supabase.auth.signInAnonymously()`, wrapped as
`ensureAnonymousSession()` in `src/lib/supabase.ts`) before touching any
table. That's what makes `auth.uid()` available for every RLS check below
— there is no unauthenticated (`anon` role) access anywhere in this app.

**The core pattern:** RLS policies in `0005_rls.sql` grant `SELECT` only,
and `0006_grants.sql` explicitly revokes `INSERT`/`UPDATE`/`DELETE` on
every table for both `anon` and `authenticated`. There is currently no way
for a client — however its JS is modified — to write to `games`,
`players`, `questions`, `game_questions`, or `answers` at all. All writes
will happen inside `SECURITY DEFINER` Postgres functions (Phase 3 for
create/join, Phase 5/6 for the game engine and scoring), which run as the
function owner and therefore bypass RLS. **The functions are the server.**
This is what makes "the backend stays authoritative" literally true on a
Supabase-only stack with no separate application server.

Concretely, today:
- `service_role` key never ships to the frontend; only the publishable/anon
  key, which is safe specifically because of the revokes above.
- `questions.correct_option` and `.explanation` are not reachable through
  any grant a client has — not even a read. The only client-visible
  question data is the `questions_public` view.
- `game_questions.shuffle_map` (which display slot maps to which original
  option) is fully inaccessible to clients — no grant, no policy.
- `answers` rows are readable only by the player who submitted them
  (`answers_select_own` policy) — one player can never read another's
  answer, correct or not, at any phase. Aggregate reveal stats ("63%
  answered correctly") will be computed by a Phase 6 function, not by
  relaxing this policy.
- `players.score` cannot be updated directly by any client role — the only
  way a score changes is a future scoring function running as table owner.

**Validated, not just written:** these six migrations were run against a
disposable local Postgres (with `auth.users`/`auth.uid()` stubbed to match
Supabase) as part of Phase 2, followed by a scripted test as the
`authenticated` role simulating two real players and a stranger. That
testing caught a real bug — see `CHANGELOG.md` — before it could ever
reach a live project.

**Phase 9 update:** both items above are now done. The narrow
room-code-lookup function (`lookup_game_by_room_code`) actually shipped
back in Phase 3, returning only `{found, status, category, difficulty,
question_count, time_limit_seconds}` — no `id`, no `host_user_id`.
Submission-timing validation was already server-side as of Phase 6
(`response_time_ms` computed from `question_started_at`, never a
client-reported value). What Phase 9 actually added was rate limiting —
`enforce_rate_limit()` in `supabase/migrations/0014_security_hardening.sql`,
applied to every mutating function plus `lookup_game_by_room_code`
itself (closing the room-code enumeration/brute-force angle that
function's narrow return shape alone didn't address) — plus a `claim_host`
TOCTOU race fix. See `docs/MASTER_HANDOFF.md` and `CHANGELOG.md`'s Phase 9
entry for full detail.

## What's implemented today (Phase 1)

- Vite/React/TS/Tailwind v4 project, builds and type-checks cleanly.
- Router with all six required paths (five are placeholders).
- Design tokens + `Button`/`Card` primitives.
- Fully built `Home` page.
- `src/types/game.ts` domain contracts.
- Folder scaffolding for every future phase's code (empty but present, so
  Phase 2+ doesn't need to restructure).

## What's implemented today (Phase 2)

- Full schema (`supabase/migrations/0001`–`0006`): enums, five core
  tables with constraints/indexes, two client-safe views, RLS policies,
  and explicit grants/revokes.
- `is_game_participant()` SECURITY DEFINER helper function, needed to
  avoid an RLS self-recursion bug (see `CHANGELOG.md`).
- `src/lib/supabase.ts` — typed client + `ensureAnonymousSession()`
  helper (not yet called from the UI — that's Phase 3).
- `src/types/database.types.ts` — hand-written `Database` type matching
  the schema, to be replaced with `supabase gen types` output once the
  project is linked via the CLI.
- `.env.local` populated with the real project URL + publishable key
  (gitignored).
- All six migrations validated end-to-end against a local Postgres
  instance, including a full RLS/anti-cheat test suite (participant vs.
  stranger visibility, blocked direct writes to every table, hidden
  `correct_option`/`shuffle_map`, per-player answer isolation).

## What's implemented today (Phase 5)

- `supabase/seed/0001_sample_questions.sql` — 80 verified questions (10 per
  category).
- `supabase/migrations/0010_game_engine.sql` — `start_game`,
  `begin_first_question`, `get_current_question`.
- `src/lib/gameApi.ts` — `startGame`, `beginFirstQuestion`,
  `getCurrentQuestion` typed wrappers.
- `CountdownOverlay`, `QuestionScreen`, `useServerTimer` — new client
  components/hook.
- `GameRoom.tsx` now branches on `game.status`: `WAITING` shows the
  existing lobby (with a working "Start Game" button), `COUNTDOWN` shows
  the countdown, `QUESTION` fetches and displays the live question.

Next up: **Phase 6 — answer submission and scoring** (`submit_answer`
function, the configurable scoring formula from `games.scoring_config`,
enabling the answer buttons, and the `QUESTION → REVEAL` transition).

## What's implemented today (Phase 6)

- `supabase/migrations/0011_answer_submission.sql` — `submit_answer`,
  `end_question`, `get_answer_reveal`.
- `src/lib/gameApi.ts` — `submitAnswer`, `endQuestion`, `getAnswerReveal`
  typed wrappers; `getAnswerReveal` returns the `AnswerReveal` type
  originally defined in `src/types/game.ts` (Phase 1).
- `QuestionScreen` — answer buttons are now interactive (was read-only in
  Phase 5).
- `RevealScreen` — new component: correct-answer highlight, your result,
  points earned, percent-correct, explanation.
- `GameRoom.tsx` — `answeredIndex`/`reveal` state, `REVEAL` render branch,
  host-only auto-`end_question` effect keyed off `useServerTimer`.

Next up: **Phase 7 — leaderboard and final results** (`REVEAL →
LEADERBOARD` transition, advancing to the next question,
`LEADERBOARD → QUESTION` loop, detecting the last question and moving to
`FINISHED`, and the `Results.tsx` page which is still a placeholder).

## What's implemented today (Phase 7)

- `supabase/migrations/0012_leaderboard.sql` — `get_leaderboard`,
  `advance_to_leaderboard`, `advance_question`. Closes the full state
  machine cycle described above: `REVEAL → LEADERBOARD → (next
  QUESTION | FINISHED)`.
- `src/lib/gameApi.ts` — `advanceToLeaderboard`, `getLeaderboard`,
  `advanceQuestion` typed wrappers, reusing the `LeaderboardEntry` type
  from `src/types/game.ts` (Phase 1) rather than a new one.
- `LeaderboardScreen` — new component: ranked standings, per-player
  score delta from the question just played, host-only advance button.
- `RevealScreen` — host-only "See Leaderboard" button replaces the
  Phase 6 "waiting for Phase 7" placeholder text.
- `GameRoom.tsx` — `LEADERBOARD` render branch; a `FINISHED` effect
  routes every client to `/results/:roomCode` at the same time via the
  existing Realtime subscription.
- `Results.tsx` — implemented: final rankings via `get_leaderboard`,
  "Play Again"/"Back Home" CTAs. No longer a placeholder.

Next up: **Phase 8 — disconnect/reconnect handling** (a host closing
their tab mid-game currently leaves everyone else stuck with no way to
advance the state machine; Phase 7 didn't add any new resilience here).

## What's implemented today (Phase 8)

- `supabase/migrations/0013_disconnect_reconnect.sql` — `heartbeat`,
  `mark_stale_players`, `claim_host`. Detection is heartbeat/staleness-based
  (20s threshold) rather than Realtime Presence — see the migration's
  header comment for the full reasoning (short version: Presence can't be
  exercised from this sandbox at all, same limitation as the rest of
  Realtime since Phase 4; a heartbeat is a plain function call this
  sandbox *can* fully validate, and it reuses the already-tested `players`
  `postgres_changes` subscription to broadcast the result instead of
  needing a new Realtime feature).
- `src/lib/gameApi.ts` — `heartbeat`, `markStalePlayers`, `claimHost`
  typed wrappers.
- `src/hooks/useCurrentUserId.ts` (new) — also fixes a pre-existing gap:
  `GameRoom`/`Results` used to know "who am I" only from
  `location.state`, which doesn't survive a hard refresh or a directly-
  opened `/game/:roomCode` link. Now derived by matching this browser's
  persisted auth session against the already-fetched `players` roster.
- `src/hooks/useHeartbeat.ts` (new) — every 8s, sends this player's own
  heartbeat and opportunistically sweeps the roster for staleness. Runs
  on *every* client, not just the host's — necessary since the host is
  exactly the client that might be the one that's gone.
- `GameRoom.tsx` — identity now derived via `useCurrentUserId` + roster
  match (see above) rather than solely from router state; `useHeartbeat`
  wired in; a new `HostDisconnectedBanner` (shown to non-host players
  once the host's `connected` flag reads false) rendered above every
  in-progress phase screen, not just the lobby.
- `LeaderboardScreen` — optional "N of M connected" note, shown only when
  someone's actually missing.
- `Results.tsx` — same identity-derivation fix as `GameRoom.tsx`.

**Known limitation, documented rather than silently left in:** detection
has up to ~20s of lag (client A's heartbeat timer has to notice client
B's absence), and relies on *some* other connected client's own timer
running the sweep — if literally everyone disconnects simultaneously,
nothing brings the game back on its own (would need a server-side
scheduled job, e.g. `pg_cron`, deliberately not introduced this phase —
see CHANGELOG's Phase 8 entry for why).

## What's implemented today (Phase 9)

- `supabase/migrations/0014_security_hardening.sql` — `rate_limit_hits`
  table + `enforce_rate_limit()` helper (internal-only, not grantable to
  clients), applied to all 13 mutating/enumeration-sensitive functions.
  Limits are generous multiples of real client cadence, confirmed by a
  full end-to-end game playthrough not to interfere with legitimate play.
- `claim_host`'s TOCTOU race (host read as stale, then a concurrent
  `heartbeat()` from the real host lands before the write) fixed via
  `select ... for update` on the host row, verified with an actual
  two-session concurrency test.
- `submit_answer`'s existing server-side timing/scoring (Phase 6)
  re-confirmed to need no changes.
- `src/lib/gameApi.ts` — one new known-message entry in `friendlyMessage`
  for rate-limit rejections.

See `docs/MASTER_HANDOFF.md` and `CHANGELOG.md`'s Phase 9 entry for full
detail, including the specific per-function limits chosen and the testing
methodology.

## Phase 10 — mobile responsiveness + UI polish (done)

No prior phase had reviewed the app's small-viewport behavior as a
dedicated pass, so this phase started from a real review of every screen
against phone-width layout concerns rather than assuming "Tailwind makes
it fine." Two categories of real (not hypothetical) issues came out of
that review:

- **`min-h-screen` (`100vh`) on every full-page wrapper.** On mobile
  Safari/Chrome, `100vh` is measured against the *largest* possible
  viewport (address bar hidden), so content sized to `100vh` gets clipped
  or forces an awkward extra scroll the moment the address bar is
  showing — exactly the kind of thing that reads as "probably fine" on a
  desktop browser and isn't. Every one of these (`Home`, `CreateGame`,
  `JoinGame`, `GameRoom`'s lobby/loading/COUNTDOWN/QUESTION/REVEAL/
  LEADERBOARD branches, `Results`, `CountdownOverlay`, `QuestionScreen`,
  `RevealScreen`, `LeaderboardScreen`) now uses `min-h-dvh` (dynamic
  viewport height) instead, which tracks the browser chrome's actual
  current state.
- **Touch targets smaller than the ~44px baseline** most mobile guidance
  (Apple HIG, WCAG 2.5.5) converges on. The most consequential one:
  `PlayerRoster`'s host-only remove ("×") control was a 20px hit area.
  `QuestionScreen`'s answer buttons were already comfortably sized
  (`py-4`/`text-lg` ⇒ ~60px) but got an explicit `min-h-[3.25rem]` floor
  so a short one-word answer can't shrink the tap target, plus
  `touch-manipulation` so a tap registers immediately instead of waiting
  out the browser's default double-tap-zoom delay. `SelectPills` (used
  four times on `CreateGame` — category, difficulty, question count, time
  limit) got the same `touch-manipulation` treatment and a `min-h-[2.75rem]`
  floor. `touch-manipulation` was also added to the shared `Button`
  primitive itself, so every CTA in the app picks it up in one place.

Also addressed, extending the existing design-token system (Phase 1)
rather than introducing new ones:

- **iOS safe areas.** `index.html`'s viewport meta gained
  `viewport-fit=cover`, and `body` in `src/index.css` now pads itself with
  `env(safe-area-inset-*)` (each with an explicit `0px` fallback for
  devices without a notch/home-indicator) so content on a notched or
  gesture-nav phone doesn't sit under either.
- **`CountdownOverlay`'s fixed `p-12`/`text-8xl` sizing**, the single
  largest fixed-size element in the app with zero small-screen
  adjustment, now steps down to `p-8`/`text-6xl` below the `sm:`
  breakpoint, and its wrapper gained `px-5` so the card can never touch
  the screen edges on a narrow phone.

**What was reviewed and found to already be fine, not touched:**
`QuestionScreen`/`RevealScreen`'s answer-option layout (already
single-column, already wraps long option text normally), `Home`'s
hero/CTAs/step grid (already used `sm:` breakpoints throughout),
`LeaderboardScreen`/`Results`' player rows (already `truncate` long
nicknames), `TextField` (already `text-lg`, which avoids iOS Safari's
auto-zoom-on-focus for inputs under 16px).

**Explicit limitation, same shape as Phase 4's Realtime-wire-behavior
gap:** this sandbox has no headless browser or device emulator available
(no matching domain in the network allowlist to fetch one), so this pass
is real/careful CSS + pixel-math review and a clean `npm run build`, not
an actual rendered-viewport screenshot comparison. Documented here rather
than silently presented as fully device-tested — a real phone or
browser dev-tools device-mode pass is the needed manual check, the same
category of gap Phase 4/8's handoffs left for live Realtime wire
behavior.

Next up: **Phase 11 — testing + bug fixing**.

## Phase 11 — testing + bug fixing (done)

Two separate testing surfaces, because the actual game logic lives in two
places rather than one:

**Server-side (the real game engine) — `supabase/tests/run_scenarios.sql`.**
A repeatable scripted scenario runner, replacing "run SQL by hand" (every
prior phase's actual method). Truncates every app table at the top, so
it's safe to re-run identically after any future migration; uses a
`test_assert(condition, label)` helper that raises immediately on the
first failed assertion. 8 scenarios / 27 assertions, chosen to be
genuinely adversarial rather than re-confirming each phase's own already-
tested happy path: a full 2-player game through `FINISHED`, a solo
1-player game, an insufficient-questions rejection, the `QUESTION`/
`end_question` race (a late `submit_answer` arriving after the host has
already ended the question), rapid double-submission, the 20-character
nickname boundary, `heartbeat` rate-limit enforcement, and host disconnect
→ `claim_host` reassignment. Run against a disposable local Postgres per
`docs/MASTER_HANDOFF.md`'s existing setup instructions (nothing about that
setup changed this phase).

**Client-side pure logic — Vitest (`vitest.config.ts`, `npm run test`).**
No test runner existed before this phase. Scoped deliberately narrow:
`environment: "node"`, no jsdom/React Testing Library, because the only
genuinely pure client-side logic in this codebase (as opposed to thin
components rendering server-validated data) turned out to be the
countdown-remaining-time calculation. Extracted that out of
`useServerTimer` into `src/game-engine/timeRemaining.ts` — a pure
`computeRemainingSeconds(startedAtIso, durationSeconds, nowMs?)` function,
zero behavior change for the hook's callers — finally giving the Phase-1-
scaffolded `game-engine/` folder the "framework-agnostic, unit-testable
without a DB" content its original description described. Also exported
`gameApi.ts`'s previously-private `friendlyMessage` purely so it has a
direct test. 18 tests total across `src/game-engine/timeRemaining.test.ts`,
`src/lib/gameApi.test.ts`, and `src/data/gameOptions.test.ts` (the last one
guards against a category/difficulty option ever silently missing its
label — a real way this specific data-table pattern can break).

**Bug-hunt result: zero real bugs found.** Every scenario above passed on
the first run of `run_scenarios.sql`, confirming Phases 2–10's own
per-phase testing discipline had already covered these paths correctly —
this phase's value is a *repeatable* form of that confidence (re-runnable
after any future change, not dependent on a session's scrollback) plus
narrow real unit coverage on the one pocket of client-side pure logic that
existed.

Full test output, the exact `npm run lint`/`npm run build` verification
(and why the total oxlint error count moved from 110 to 112 without any
new `src/`-level errors — `vitest`'s own dependency tree now exists in
`node_modules` and accounts for the difference), and what was deliberately
left out of this phase's scope (component-render testing, concurrency
fuzzing) are in `CHANGELOG.md`'s Phase 11 entry.

Next up: **Phase 12 — Automatic Mode + Configurable Answer Behavior**.

## Phase 12 — Automatic Mode + Configurable Answer Behavior (done)

Two new independent per-game settings, chosen at `create_game` time
alongside category/difficulty/question count/time limit, both defaulted to
Phases 1–11's only prior behavior so nothing existing changes unless a
game explicitly opts in.

**Game Mode: `HOST_CONTROLLED` (unchanged) | `AUTOMATIC` (new).** The
interesting design question here wasn't the state machine itself — it's
the same `WAITING → COUNTDOWN → QUESTION → REVEAL → LEADERBOARD → (next
QUESTION | FINISHED)` machine Phase 5 built — it's *what drives the
transitions* when no host click is available to do it. This project has no
server-side scheduled-job infrastructure (no `pg_cron` extension, no
Supabase Edge Functions anywhere in this repo), so "the backend advances
the game on its own" can't mean a background process the way it might on
a stack that had one. Instead, Automatic mode reuses the exact pattern
Phase 8 already established for "the host might be the one who's gone"
(`mark_stale_players`/`claim_host`): a new `auto_advance_game(p_game_id)`
function that

- any participant can call, not just the host,
- is a pure no-op unless the current phase's server-anchored timestamp
  shows real elapsed time past that phase's fixed duration, and
- is safe to call redundantly and concurrently — it `select ... for
  update`s the `games` row before checking anything, the same TOCTOU fix
  Phase 9 applied to `claim_host`, so several clients' polling timers
  landing moments apart serialize against each other instead of racing.

`src/hooks/useAutoAdvance.ts` polls this every 1s from **every** connected
client whenever `game_mode === "AUTOMATIC"` — not just the host's. That's
what makes "host disconnecting during Automatic Mode doesn't stop the
game" true in practice: as long as *any* participant's tab is open, that
tab's polling keeps the game moving. A new nullable `games.phase_started_at`
column anchors COUNTDOWN/REVEAL/LEADERBOARD's fixed durations (3s/6s/5s
respectively — see the migration for why those specific numbers); QUESTION
keeps using the pre-existing `question_started_at` untouched, since that
was already server-anchored and already drove `submit_answer`'s
response-time scoring.

**Answer Behavior: `LOCK_ON_SELECTION` (unchanged) |
`CHANGE_UNTIL_TIMER_ENDS` (new).** `submit_answer` branches on this at the
top: `LOCK_ON_SELECTION` reproduces the exact pre-existing insert-and-
reject-a-second-attempt body; `CHANGE_UNTIL_TIMER_ENDS` upserts
(`on conflict (game_id, player_id, question_id) do update`) instead,
recomputing correctness/points from scratch on every call. `players.score`
is adjusted by the *delta* between the new submission's points and
whatever that same row previously scored — never by the full new amount
again — so switching A → C → B only ever contributes B's points to the
running total, not A + C + B. One small hardening ships alongside this,
applying to both behaviors: `submit_answer` now also rejects a submission
once real elapsed time has passed `time_limit_seconds`, even if `status`
technically hasn't flipped to `REVEAL` yet, closing the small window
between the clock actually running out and `end_question`/
`auto_advance_game` actually landing — a window that matters more once
changing-until-the-wire is the intended interaction rather than an edge
case.

**Backward compatibility**, checked by test rather than assumed: both
settings are `not null default` columns, `create_game`'s two new
parameters are both defaulted (its old 5-argument signature was explicitly
`drop function`-ed first, since Postgres treats a changed argument list as
a distinct overload rather than something `create or replace` can widen),
and every touched function keeps its exact prior behavior for a game that
didn't opt in — Scenario 10 confirms `auto_advance_game` never touches a
`HOST_CONTROLLED` game, Scenario 12 confirms `LOCK_ON_SELECTION` still
hard-rejects a changed answer.

**Testing**: rebuilt the same disposable local Postgres used since Phase
2, applied all 15 migrations clean, and added scenarios 9–13 (23
assertions, 59 total across the full suite) to `run_scenarios.sql` — a
complete Automatic-mode game driven start-to-finish by
`auto_advance_game` alone (backdating `phase_started_at`/
`question_started_at` instead of sleeping through real durations), the
no-op/no-double-advance safety properties, the `CHANGE_UNTIL_TIMER_ENDS`
scoring-delta correctness, the `LOCK_ON_SELECTION` regression check, and
the new elapsed-time cutoff. All pass on a clean re-run. `npm run build`
and `npm run test` (22/22) both clean; `npx oxlint src` shows 0 errors,
same pre-existing warning count as before this phase.

Full design rationale (in far more depth than is useful to duplicate here)
lives in `supabase/migrations/0015_automatic_mode_and_answer_behavior.sql`'s
header comment — read that before changing any of this. The complete
"validated by testing" list and what was deliberately left out (a true
scheduled-job backend, live Realtime-wire verification, component-render
tests) are in `CHANGELOG.md`'s Phase 12 entry.

Next up: **Phase 13 — Play Again (rematch in the same room) + no repeated
questions**.

## Phase 13 — Play Again + no repeated questions (done)

Bug report: "Play Again" just linked to `/create` — a brand-new room, new
code, everyone including the host had to rejoin and retype their nickname
— and a room's questions repeated within a handful of games because
`start_game`'s random draw had no memory of anything an earlier game in
that room had already used.

**The room-persistence half.** The natural instinct is "create a new
`games` row for the rematch" — but `room_code` has a global unique index
(Phase 2), so a genuinely new row can never carry the old room's code
forward anyway, and migrating every `players` row over to a new
`game_id` to fake it would be a much larger, riskier change than this bug
needs. Instead, `play_again(p_game_id)` resets the *same* `games` row back
to `WAITING` with an incremented `round_number`, and touches nothing on
`players` at all. Since `players.game_id` never changes, nicknames, host
status, and connection state simply carry over — there's no "rejoin"
step to build because nobody ever left. The existing `start_game` (no
new host action needed) is what actually kicks off the next round from
that same lobby, exactly like the first one.

**The repeat-avoidance half.** `games`, `game_questions`, and `answers`
each gained a `round_number` column (all `not null default 1`, so no
existing row's meaning changes). `start_game`'s question-selection query
now excludes every `question_id` already used anywhere in this `game_id`'s
history before falling back to allowing a repeat — and only then, once
that "never used in this room" pool is actually exhausted. A game's first
round has no history yet, so this changes nothing about round-1 behavior;
it only matters from round 2 onward.

Giving `game_questions`/`answers` a `round_number`-aware identity, rather
than just filtering `start_game`'s draw, mattered for a subtler reason:
once the same `question_id` can legitimately appear in two different
rounds of the same game, every function that reads or writes "the
answers for the current question" needed to stop assuming
`(game_id, question_id)` uniquely identifies one answer. `submit_answer`,
`end_question`, `get_answer_reveal`, and `get_leaderboard` (plus
`auto_advance_game`'s QUESTION branch, which duplicates `end_question`'s
logic per Phase 12's design) were all widened to filter/insert by
`round_number` too — otherwise a question repeating in round 3 would
collide with its own leftover `answers` row from round 1: a false
"already answered" rejection under Lock on Selection, the wrong upsert
target under Change Until Timer Ends, a wrong percent-correct in the
reveal, a wrong score delta on the leaderboard.

**A related client-side bug**, found while wiring up `Results.tsx`'s new
"Play Again" button rather than reported directly: two guards in
`GameRoom.tsx` — the "reset the answer UI for a fresh question" effect
and the `endQuestionCalledRef` "don't call `end_question` twice for the
same question" ref — were both keyed on `question.questionId`, which is
the underlying `questions.id`. That's fine as long as no two questions in
a game ever share an id, which was true before this phase and is no
longer true once a question can repeat across rounds. Both were switched
to `game.current_question_id` instead — the `game_questions` row id,
which is a fresh UUID every round regardless of whether the underlying
question repeats. The `endQuestionCalledRef` case was the serious one: a
`ref.current === value` comparison persists for the life of the
component, so a repeated question could permanently stop a
Host-Controlled game's `end_question` from ever firing again once it hit
a question whose id the ref had already seen, with no error or symptom
other than the game silently hanging in `QUESTION` forever.

**Testing**: re-ran the full pre-existing 59-assertion suite unmodified
first to confirm zero regressions, then added scenarios 14–16 (24
assertions, 83 total) — `play_again`'s permission/status gating and full
room-preserving reset, a deterministic 3-round repeat-avoidance proof
using the seed's exactly-4-question trivia/easy pool (round 2 completely
disjoint from round 1 while fresh questions remain, round 3 forced to
repeat only once the pool is exhausted, never erroring), and a forced
repeated-question scoring-correctness check. `npm run build` and
`npm run test` (22/22) both clean; `npx oxlint src` shows 0 errors.

Full design rationale (in more depth than is useful to duplicate here)
lives in `0016_play_again_and_no_repeat_questions.sql`'s header comment —
read that before changing any of this. The complete "validated by
testing" list and what was deliberately left out (cumulative scoring
across rounds, per-round settings editing, live Realtime-wire
verification) are in `CHANGELOG.md`'s Phase 13 entry.

Next up: **Phase 14 — production deployment**.

## Phase 15 — Expand question bank + categories (done, out of order)

Done ahead of Phase 14 at explicit request. Merged on top of Phase 12/13's
Automatic Mode, Play Again, and `0017`'s timing tune-up rather than the
branch it was originally developed against, hence the migration numbers
(`0018`/`0019`) not lining up with the "Phase 15" label.

**Design, in short:** 15 new values were added to both
`game_category_setting` (the game-creation setting enum) and
`question_category` (the per-question enum) in
`0018_expand_categories.sql`, as its own migration file separate from the
question inserts — Postgres won't let a transaction reference an enum
value it just added in the same transaction, and each migration file runs
as one transaction. `0019_new_categories_and_questions.sql` then adds 200
new questions (`INSERT ... SELECT ... WHERE NOT EXISTS`, idempotent),
split 150 across the 15 new categories and 50 as a top-up of the original
8. Of the 20 category names originally requested, 5 mapped onto an
existing enum value under a different label (e.g. "Philippine History" →
the existing `history`) rather than being duplicated.

**No game-engine changes were needed at all** — `create_game`,
`start_game`, and `auto_advance_game` all filter/accept by the enum
*type*, not an enumerated list of its values, so the 15 new categories
became selectable and playable — in both Host-Controlled and Automatic
mode — the instant `0018` committed. Verified directly: created a game
with the brand-new `music` category, joined a second player, started it,
and confirmed it reached `COUNTDOWN` with every assigned question
actually belonging to `music`.

On the frontend, `CATEGORY_LABELS` (the single source of truth
`CATEGORY_OPTIONS` is derived from) gained the 15 new labels, and a new
`CATEGORY_GROUPS` export clusters all 23 categories + Random into 5
labeled sections so `CreateGame`'s category picker doesn't become an
unscannable 24-pill wall. Phase 12's Game Mode / Answer Behavior sections
on that same screen are untouched.

**Testing**: re-ran the full pre-existing 88-assertion `run_scenarios.sql`
suite unmodified against the expanded (280-question) database — all 88
still pass. A separate Python validation pass over the 200 drafted
questions confirmed 0 structural errors, 0 duplicate prompts, and 0
overlap with the existing 80 seed questions. `npm run build` and
`npm run test` both clean; no new `oxlint` warnings or errors in any file
this phase touched.

The complete category-name mapping, the exact difficulty-distribution
numbers, and which specific trivia facts were verified via web search
before being written into the migration are in `CHANGELOG.md`'s Phase 15
entry — read that instead of re-deriving the same question bank from
scratch.

Next up (still): **Phase 14 — production deployment**.

## Phase 16 — Science/Medical + general-knowledge categories, Phase 17 — Custom category mix (done, out of order)

Three category-related changes landed on top of Phase 15, two of them
(general-knowledge expansion and the custom mix feature) developed in
parallel branches and reconciled here:

1. **`0020_science_medical_categories.sql` / `0021_science_medical_questions.sql`**
   — added `science` and `medical` (general, non-Philippines-scoped) plus
   100 questions across them.
2. **`0022_custom_category_mix.sql`** — a second, independent way to scope
   a game's questions: `games.categories question_category[]`, nullable
   and defaulting to null (old single-`category` behavior unchanged).
   When set, `start_game` filters `category = any(games.categories)`
   instead of the single-value comparison. Frontend: a Single/Custom Mix
   toggle on `CreateGame`, `MultiSelectPills` for the multi-select pills,
   and `categoryDisplayLabel()` so the lobby/pre-join screens show either
   the one category or a `Custom Mix (N)` summary.
3. **`0023_expand_general_categories.sql` / `0024_general_knowledge_questions.sql`**
   (renumbered from a parallel branch's `0020`/`0021`, since those numbers
   were already taken by #1 and #2 above) — 20 more general-knowledge
   categories (Mathematics, World History, Animals, Space & Astronomy,
   etc.), 9 of which get a distinctly-named sibling instead of reusing an
   existing Philippine-scoped enum value (`world_history` alongside
   `history`, and so on), plus 160 new questions. `CATEGORY_LABELS` now
   prefixes every Philippine-scoped category with "Philippine"/"Filipino"
   to disambiguate. `CATEGORY_GROUPS` (Phase 15) was replaced by
   `CATEGORY_SECTIONS` — two named sections, "General Knowledge" and
   "Philippines" — each still broken into small labeled clusters.
   `CUSTOM_MIX_GROUPS` (#2 above) now derives from `CATEGORY_SECTIONS`
   instead of the retired `CATEGORY_GROUPS`.

No game-engine changes were needed for either category expansion — same
reasoning as Phase 15: `create_game`/`start_game`/`auto_advance_game`
filter by enum type, not an enumerated value list. The three migrations
apply cleanly in sequence (`0020` → `0024`); `science`'s `add value if
not exists` in `0023` is a harmless no-op since it already exists from
`0020`. Verified: `npx tsc --noEmit`, `npx vitest run` (32/32), and
`npx vite build` all pass on the merged tree. Full category-label
mapping and migration rationale are in `CHANGELOG.md`'s Phase 16b and
Phase 17 entries.
