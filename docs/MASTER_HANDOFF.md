# Master Handoff

Read this first. It's the single "where are we, what's next" doc for
whichever Claude session picks this project up next. For the full
technical design and per-phase implementation detail, see
[docs/ARCHITECTURE.md](ARCHITECTURE.md); for a chronological log of every
change and how it was tested, see [../CHANGELOG.md](../CHANGELOG.md).

## Current state: Phase 13 complete ✅, plus Phases 15–17 done out of order ✅

**Phases 1–13 are done and validated.** Everything from Phase 12 (below)
still holds, plus — new that phase — "Play Again" is a real rematch in the
same room instead of a link to a brand-new one, and repeated games in the
same room no longer draw the same questions until the available pool is
actually exhausted.

**Phases 15, 16, and 17 have also been completed**, out of their normal
place in the sequence, at explicit request — see "What Phase 15 actually
built" and "What Phases 16/17 actually built" below. Phase 16 itself
landed in two parts developed in parallel and then merged: `science`/
`medical` plus 20 more general-knowledge categories (44 real categories +
"All Categories" total). **Phase 14 (production deployment) is still the
next unstarted phase** and remains next in sequence for whoever picks
this up.

Phase 13 (Play Again + no repeat questions) added:

1. **`play_again(p_game_id)`** — host-only, only once `status = 'FINISHED'`.
   Resets the SAME `games` row (same `id`, same `room_code`) back to
   `WAITING` with a new `round_number` and every score zeroed.
   `players` rows are never touched — nicknames, host status, connection
   state all carry over automatically, so nobody rejoins or retypes
   anything. `start_game` (unchanged) is what the host clicks to actually
   kick off the next round from that same lobby.
2. **Repeat avoidance** — `games`/`game_questions`/`answers` all gained a
   `round_number` column (all `not null default 1`, so nothing existing
   changes). `start_game` now prefers questions never used anywhere in
   this room's history before falling back to a repeat, which only
   happens once that pool is actually exhausted — never an error either
   way. Every function that touches "the current question's" answers
   (`submit_answer`, `end_question`, `get_answer_reveal`,
   `get_leaderboard`, `auto_advance_game`) is now `round_number`-scoped,
   or a repeated question in round 3 would collide with its own leftover
   answer row from round 1.
3. A related client-side bug fixed alongside it: two guards in
   `GameRoom.tsx` were keyed on the underlying `questions.id`, which can
   now legitimately repeat across rounds — switched to
   `game.current_question_id` (the `game_questions` row id, fresh every
   round) so a repeated question can't silently break the "already
   answered" UI reset or (worse, for Host-Controlled games) permanently
   block `end_question` from ever firing again.

Full design rationale is in `0016_play_again_and_no_repeat_questions.sql`'s
header comment — read it before touching this again. See CHANGELOG's
Phase 13 entry for the full "validated by testing" list.

## Previous state: Phase 12 complete ✅

**Phases 1–12 are done and validated.** The game supports the entire core
loop, survives players (including the host) dropping mid-game, every
mutating server function is rate-limited against tight-loop abuse, every
screen uses mobile-correct viewport sizing with real touch targets on the
controls that need them, there's real automated test coverage (SQL
scenarios + Vitest), and — new this phase — a host can now choose
**Automatic** game pacing (no manual Next Question/End Question clicks
needed) and **Change Until Timer Ends** answer behavior (players can
switch their pick right up until time runs out), independently of each
other, without breaking anything from Phases 1–11.

Phase 12 (Automatic Mode & Configurable Answer Behavior) added:

1. **`game_mode` setting** (`HOST_CONTROLLED` | `AUTOMATIC`, chosen at
   `create_game` time, defaults to `HOST_CONTROLLED`). In Automatic mode
   the host still creates the room, configures it, waits for players, and
   clicks Start Game — everything after that (`COUNTDOWN → QUESTION →
   REVEAL → LEADERBOARD → next QUESTION | FINISHED`) runs on its own. The
   mechanism: a new `auto_advance_game(p_game_id)` SQL function, callable
   by **any** participant, gated on real server-elapsed time
   (`games.phase_started_at` for COUNTDOWN/REVEAL/LEADERBOARD, the
   pre-existing `question_started_at` for QUESTION) and row-locked
   (`for update`) so concurrent calls from multiple clients' polling
   timers can't double-advance. `src/hooks/useAutoAdvance.ts` polls it
   every 1s from **every** connected client (not just the host's) — that's
   what lets the game keep running even if the host disconnects, since
   this stack has no server-side cron/Edge Functions to fall back on. Full
   design rationale is in the migration's own header comment — it's long
   on purpose; read it before touching this again.
2. **`answer_behavior` setting** (`LOCK_ON_SELECTION` |
   `CHANGE_UNTIL_TIMER_ENDS`, defaults to `LOCK_ON_SELECTION`, the
   pre-existing behavior). Under `CHANGE_UNTIL_TIMER_ENDS`, `submit_answer`
   upserts instead of insert-only-and-reject; only the latest pick is ever
   stored, and `players.score` is adjusted by the delta between the new
   and previous points so switching answers never double-counts.
3. A small, deliberate hardening flagged in both the migration and
   CHANGELOG rather than left silent: `submit_answer` now also rejects a
   submission once real elapsed time has passed the time limit, even if
   `status` technically hasn't flipped to `REVEAL` yet — applies to both
   answer behaviors, strictly tighter than before.

**Everything from Phases 1–11, unchanged this phase:** the core state
machine, scoring formula, heartbeat/staleness disconnect handling,
`claim_host` reassignment, and rate-limiting are all still exactly as
documented below — this phase only added two new settings and the
Automatic-mode advancement path alongside them. Every changed SQL function
(`create_game`, `start_game`, `submit_answer`, `end_question`,
`advance_to_leaderboard`) keeps its pre-existing behavior for any game
that doesn't opt into the new settings — verified directly by the new
test scenarios, not just assumed. See CHANGELOG's Phase 12 entry for the
full "validated by testing" list.

## Previous state: Phase 11 complete ✅

**Phases 1–11 are done and validated.** The game supports the entire core
loop, survives players (including the host) dropping mid-game, every
mutating server function is rate-limited against tight-loop abuse, every
screen uses mobile-correct viewport sizing with real touch targets on the
controls that need them, and — new this phase — the project finally has
real automated, repeatable test coverage instead of relying entirely on
by-hand SQL sessions and eyeballing.

Phase 11 (testing + bug fixing) added:

1. **`supabase/tests/run_scenarios.sql`** — a repeatable scripted scenario
   runner for the server-side game engine (truncates all app tables at the
   top, so re-running it after any future migration is always safe and
   comparable). 8 scenarios / 27 assertions covering the real edge cases
   that had never been adversarially tested before: a solo 1-player game,
   the `QUESTION`/`end_question` race, rapid double-submission, the
   20-character nickname boundary, an insufficient-questions rejection,
   `heartbeat` rate-limit enforcement, and host disconnect →`claim_host`
   reassignment, plus a full 2-player happy-path game through `FINISHED`.
   **Run twice in this session — 27/27 pass both times. Zero real bugs
   found**; every edge case was already handled correctly by Phases 2–10's
   own functions.
2. **Vitest** (`npm run test`, `vitest.config.ts`) — this project's first
   client-side test runner. Scoped to the one pocket of genuinely pure,
   framework-agnostic logic that exists client-side: the countdown-
   remaining-time math, extracted out of `useServerTimer` into
   `src/game-engine/timeRemaining.ts` (zero behavior change — the hook now
   just calls it and owns the re-render tick). 18 tests total across that
   file plus `src/lib/gameApi.test.ts` (the RPC error-message friendliness
   mapping) and `src/data/gameOptions.test.ts` (category/difficulty label
   table integrity). No jsdom/component-rendering tests — deliberately out
   of scope; see CHANGELOG's Phase 11 entry for why.

**Everything from Phase 8/9/10, unchanged this phase:** no SQL logic
changed (the scenario runner only *reads* existing behavior — it added no
migration), no `gameApi.ts` behavior changed (only `friendlyMessage`
became exported, same implementation), no game-state-machine changes, no
CSS/markup changes.

Phase 10 (mobile responsiveness + UI polish) closed two concrete gaps
found by reviewing every screen against small-viewport behavior, rather
than assuming Tailwind made it fine by default:

1. **`min-h-screen` (`100vh`) on all 17 full-page wrappers**, switched to
   `min-h-dvh`. `100vh` on mobile Safari/Chrome is pinned to the
   largest-possible viewport (address bar hidden), so content sized to it
   can be taller than what's actually visible once the chrome is showing
   — `min-h-dvh` tracks the browser's actual current state instead.
2. **A real touch-target gap**: `PlayerRoster`'s host-only remove ("×")
   control was a 20px hit area, well under the ~44px baseline most mobile
   guidance converges on. Grew to 32px. `QuestionScreen`'s answer buttons
   (the screen under the most real-world mobile pressure — a
   Kahoot-style "everyone answers on their phone" game) were already
   comfortably sized on inspection, but got an explicit height floor and
   `touch-manipulation` as insurance and for faster tap response;
   `SelectPills` (4 groups on `CreateGame`) and the shared `Button`
   primitive got the same treatment.

Also added, extending the existing token system rather than introducing
new ones: iOS safe-area padding (`viewport-fit=cover` + `env(safe-area-
inset-*)` on `body`), and a responsive step-down on `CountdownOverlay`'s
previously-fixed `p-12`/`text-8xl` sizing for narrow phones.

**Explicit limitation, same shape as Phase 4/8's Realtime-wire-behavior
gap:** this sandbox has no headless browser or device emulator available
(no matching domain in the network allowlist), so this pass is real CSS
review + pixel-math against a 320px baseline + a clean `npm run build`
and compiled-CSS inspection — not an actual rendered-viewport screenshot
comparison. A real phone or browser dev-tools device-mode pass is the
needed manual check before calling mobile layout fully verified.

**Everything from Phase 8/9, unchanged this phase:**

```
WAITING → COUNTDOWN → QUESTION → REVEAL → LEADERBOARD → (next QUESTION | FINISHED)
```

Heartbeat/staleness-based disconnect handling (`src/hooks/useHeartbeat.ts`,
every 8s), deterministic host reassignment via `claim_host`, and
rate-limiting on all 13 mutating/enumeration-sensitive functions are all
still in place and untouched — see CHANGELOG's Phase 8/9 entries or
ARCHITECTURE.md for the full detail if you need it. Phase 10 was a
CSS/markup-only pass; no SQL, no `gameApi.ts` changes, no state-machine
changes.

## Phase roadmap (see ARCHITECTURE.md for full detail)

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
| 14 | Production deployment | ⬜ **Next task** |
| 15 | Expand question bank + categories | ✅ Done (out of order — see below) |
| 16 | Science/Medical + general-knowledge categories | ✅ Done (out of order — see below) |
| 17 | Host-selectable custom category mix | ✅ Done (out of order — see below) |

## What Phase 15 actually built (so you don't re-derive it)

- `supabase/migrations/0018_expand_categories.sql` — adds 15 new values
  to both `game_category_setting` and `question_category` (`ALTER TYPE
  ... ADD VALUE IF NOT EXISTS`, idempotent). Its own migration, not
  combined with the question inserts, because Postgres won't let a
  newly-added enum value be referenced by the same transaction that added
  it, and Supabase applies each migration file as one transaction.
- `supabase/migrations/0019_new_categories_and_questions.sql` — 200 new
  questions (10 each × 15 new categories, + a 50-question top-up of the
  original 8). Every row uses `INSERT ... SELECT ... WHERE NOT EXISTS`
  keyed on `(category, prompt)`, so it's safe to re-run. None of the
  existing 80 seed questions were touched, and neither migration touches
  `game_mode`/`answer_behavior`/`round_number` or anything else from
  Phase 12/13.
- `src/types/database.types.ts` — 15 new `GameCategorySetting` values,
  added alongside (not replacing) Phase 12's `GameModeRow`/
  `AnswerBehaviorRow`.
- `src/data/gameOptions.ts` — labels for the 15 new categories in
  `CATEGORY_LABELS` (still the only source of truth; `CATEGORY_OPTIONS`
  is still derived from it, nothing hard-coded elsewhere), plus a new
  `CATEGORY_GROUPS` export clustering all 23 categories + Random into 5
  labeled sections for the picker UI. Phase 12's `GAME_MODE_*`/
  `ANSWER_BEHAVIOR_*` exports are unchanged.
- `src/pages/CreateGame.tsx` — the "Category" section renders
  `CATEGORY_GROUPS` as multiple labeled `SelectPills` groups instead of
  one flat 24-pill list. Same component, same visual style. The Game
  Mode / Answer Behavior sections added in Phase 12 are untouched.
- `src/data/gameOptions.test.ts` — two new tests asserting
  `CATEGORY_GROUPS` stays in sync with `CATEGORY_OPTIONS` (every option
  present exactly once, no unknowns) and that every group has a label and
  at least one option, alongside Phase 12's existing game-mode/answer-
  behavior integrity tests.
- **No changes were needed to `create_game`/`start_game`/
  `auto_advance_game`/any other game engine function.** They filter/
  accept by the enum type, not an enumerated list of its values, so new
  categories become selectable and playable automatically — in both
  Host-Controlled and Automatic mode — the moment `0018` lands. Verified
  directly: created a game with the brand-new `music` category, joined a
  second player, started it, and confirmed both that it reached
  `COUNTDOWN` and that every assigned question actually belonged to
  `music`.
- Re-ran `supabase/tests/run_scenarios.sql` against the expanded
  database (280 rows total) — all pre-existing assertions still pass,
  including Phase 12/13's Automatic Mode, Play Again, and no-repeat-
  question scenarios.

## What Phases 16/17 actually built (so you don't re-derive it)

Three migrations landed on top of Phase 15, two of them from a branch
developed in parallel with Phase 17 and reconciled afterward:

- `supabase/migrations/0020_science_medical_categories.sql` /
  `0021_science_medical_questions.sql` — adds `science` and `medical`
  (general, non-Philippines-scoped) plus 100 new questions across them.
- `supabase/migrations/0022_custom_category_mix.sql` — new nullable
  `games.categories question_category[]` column. Null/empty (every
  pre-Phase-17 game) keeps the old single-`category` behavior; when set,
  it takes priority for question selection. `create_game` gained a
  defaulted `p_categories` param, `lookup_game_by_room_code` now returns
  `categories` too, and `start_game`'s fresh/top-up draw branches on
  whether a custom set is present. Frontend: a Single/Custom Mix toggle
  on `CreateGame`, the new `MultiSelectPills` component, and
  `categoryDisplayLabel()` for the lobby/pre-join "Custom Mix (N)"
  display.
- `supabase/migrations/0023_expand_general_categories.sql` /
  `0024_general_knowledge_questions.sql` — renumbered from a parallel
  branch's `0020`/`0021` (those numbers were already taken by the two
  migrations above), adds 20 more general-knowledge categories
  (Mathematics, World History, Animals, Space & Astronomy, etc.) plus 160
  new questions. 9 of the 20 share a plain-English name with an existing
  Philippine category and got a distinctly-named sibling instead
  (`world_history` alongside `history`) so questions never mix.
  `CATEGORY_LABELS` now prefixes every Philippine-scoped category with
  "Philippine"/"Filipino" to disambiguate. `CATEGORY_GROUPS` was replaced
  by `CATEGORY_SECTIONS` — "General Knowledge" and "Philippines" — and
  Phase 17's `CUSTOM_MIX_GROUPS` now derives from `CATEGORY_SECTIONS`
  instead. Total: 44 real categories + "All Categories", up from 24.

No game-engine changes were needed for either category expansion, same
reasoning as Phase 15. `science`'s `ADD VALUE IF NOT EXISTS` in `0023` is
a harmless no-op (already added by `0020`). Verified on the merged tree:
`npx tsc --noEmit`, `npx vitest run` (32/32 passing), and `npx vite
build` all pass. Full rationale is in `CHANGELOG.md`'s Phase 16b and
Phase 17 entries, and `ARCHITECTURE.md`'s matching section.

Full reasoning — including which 5 of the 20 requested category names
were mapped onto existing enum values instead of duplicated, the exact
difficulty-distribution numbers, and which specific facts were verified
via web search before being written into the migration — is in
`CHANGELOG.md`'s Phase 15 entry.

## What Phase 13 actually built (so you don't re-derive it)

- `supabase/migrations/0016_play_again_and_no_repeat_questions.sql` — new
  `round_number` column on `games`/`game_questions`/`answers` (all
  defaulted to 1 for backward compatibility), widened uniqueness
  constraints on `game_questions`/`answers` to include it, the new
  `play_again` function, `start_game`'s repeat-avoiding question draw, and
  `round_number`-scoping added to `submit_answer`/`end_question`/
  `get_answer_reveal`/`get_leaderboard`/`auto_advance_game`. **Read this
  migration's header comment before changing any of this** — it explains
  why the fix is "reset the same room" rather than "create a new room",
  and exactly which functions needed round-scoping and why.
- `supabase/tests/run_scenarios.sql` — scenarios 14–16 (24 new assertions,
  83 total). Same re-run command as before.
- `src/lib/gameApi.ts` — new `playAgain()`.
- `src/pages/Results.tsx` — "Play Again" now calls `playAgain()`
  (host-only) instead of linking to `/create`; new effect mirrors
  `GameRoom.tsx`'s FINISHED → `/results` effect in reverse.
- `src/pages/GameRoom.tsx` — two guards (`answeredIndex` reset,
  `endQuestionCalledRef`) switched from keying on `question.questionId` to
  `game.current_question_id`, since the former can now collide across
  rounds when a question repeats — read the migration header comment and
  CHANGELOG's Phase 13 entry for exactly what broke and why.
- `src/types/database.types.ts` — `round_number` added to the three
  tables, `play_again` function signature.

Full reasoning for every design decision is in the migration's header
comment and CHANGELOG's Phase 13 entry — read those instead of
re-deriving the same tradeoffs from scratch.

## What Phase 12 actually built (so you don't re-derive it)

- `supabase/migrations/0015_automatic_mode_and_answer_behavior.sql` — new
  `game_mode`/`answer_behavior` enums, `games.game_mode`/`answer_behavior`/
  `phase_started_at` columns (all defaulted for backward compatibility),
  `create_game` extended (old 5-arg signature explicitly dropped first),
  `submit_answer`/`start_game`/`end_question`/`advance_to_leaderboard`
  updated in place, and the new `auto_advance_game` function. **Read this
  migration's header comment before changing any of this** — it explains
  why Automatic mode works the way it does given this stack has no
  server-side cron/Edge Functions, rather than assuming a background job
  exists somewhere.
- `supabase/tests/run_scenarios.sql` — scenarios 9–13 (23 new assertions,
  59 total). Re-run the same way as before:
  `psql -d pinoyquiz_test -v ON_ERROR_STOP=1 -f supabase/tests/run_scenarios.sql`
  against a fresh disposable Postgres (see "How to test your work" below).
- `src/hooks/useAutoAdvance.ts` — new, every-client polling hook, same
  shape as `useHeartbeat.ts`.
- `src/data/gameOptions.ts` (+ `.test.ts`) — `GAME_MODE_*`/
  `ANSWER_BEHAVIOR_*` label/description/option tables.
- `src/pages/CreateGame.tsx` — two new `SelectPills` groups with
  description text.
- `src/pages/GameRoom.tsx` — `isAutomatic` derived from `game.game_mode`;
  every host-only manual-transition handler now short-circuits when
  Automatic; `handleAnswer` rewritten to support re-picking under
  `CHANGE_UNTIL_TIMER_ENDS`.
- `src/components/game/QuestionScreen.tsx` — `canChangeAnswer`/
  `isAutomatic` props control button disabling and helper copy.
- `src/components/game/RevealScreen.tsx`,
  `src/components/game/LeaderboardScreen.tsx` — new `isAutomatic` prop,
  shows "Advancing automatically…" instead of a host button/wait message.
- `src/types/database.types.ts`, `src/types/game.ts` — new enums/columns/
  function signature.

Full reasoning for every design decision (why polling instead of a real
scheduled job, why the elapsed-time hardening in `submit_answer`, why the
old `create_game` signature was dropped rather than just replaced) is in
the migration's header comment and CHANGELOG's Phase 12 entry — read those
instead of re-deriving the same tradeoffs from scratch.

## What Phase 11 actually built (so you don't re-derive it)

- `supabase/tests/run_scenarios.sql` — run it against a disposable local
  Postgres exactly as described in "How to test your work" below, then
  `psql -d pinoyquiz_test -v ON_ERROR_STOP=1 -f supabase/tests/run_scenarios.sql`.
  Safe to re-run anytime; it truncates `answers`, `game_questions`,
  `players`, `games`, `rate_limit_hits`, and `auth.users` itself as its
  first statement.
- `vitest.config.ts`, `npm run test` script in `package.json`.
- `src/game-engine/timeRemaining.ts` (+ `.test.ts`) — the countdown math,
  extracted out of `src/hooks/useServerTimer.ts`, which now just imports
  and calls it.
- `src/lib/gameApi.ts` — `friendlyMessage` changed from module-private to
  exported. No implementation change.
- `src/lib/gameApi.test.ts`, `src/data/gameOptions.test.ts` — new test
  files, no corresponding source changes (`gameOptions.ts` untouched).

Full reasoning for what was and wasn't in scope, and the complete bug-hunt
scenario list with results, is in `CHANGELOG.md`'s Phase 11 entry — read
that instead of re-deriving the same test plan from scratch.

## What Phase 10 actually built (so you don't re-derive it)

- All 17 `min-h-screen` → `min-h-dvh` across `Home`, `CreateGame`,
  `JoinGame`, every `GameRoom` status branch, every `Results` branch,
  `CountdownOverlay`, `QuestionScreen`, `RevealScreen`,
  `LeaderboardScreen`.
- `index.html` — `viewport-fit=cover` on the viewport meta tag.
- `src/index.css` — `body` pads itself with
  `env(safe-area-inset-{top,bottom,left,right}, 0px)`.
- `src/components/ui/Button.tsx` — `touch-manipulation` added to the
  shared base classes (every CTA app-wide picks this up automatically).
- `src/components/game/QuestionScreen.tsx` — answer buttons gained
  `min-h-[3.25rem]` + `touch-manipulation`.
- `src/components/ui/SelectPills.tsx` — pills gained `min-h-[2.75rem]`
  (exactly the WCAG 44px baseline) + `touch-manipulation`.
- `src/components/lobby/PlayerRoster.tsx` — remove control 20px → 32px
  via negative-margin hit-area expansion; pill gap `gap-2` → `gap-2.5` so
  the larger hit areas don't overlap a neighboring pill.
- `src/components/game/CountdownOverlay.tsx` — `p-12`/`text-8xl` →
  responsive `p-8 sm:p-12` / `text-6xl sm:text-8xl`; wrapper gained
  `px-5`.

Full reasoning, what was reviewed and found already-fine (answer option
layout, `Home`'s existing `sm:` breakpoints, leaderboard/results
`truncate`, `TextField`'s already-16px+-safe font size), and the exact
testing methodology are in `CHANGELOG.md`'s Phase 10 entry and
`ARCHITECTURE.md`'s new Phase 10 section — read those instead of
re-auditing the same screens from scratch.

## What earlier phases built (condensed — see CHANGELOG.md for full detail)

- **Phase 8** (`supabase/migrations/0013_disconnect_reconnect.sql`):
  `heartbeat`, `mark_stale_players`, `claim_host` — heartbeat/staleness
  disconnect detection with deterministic host reassignment.
  `useCurrentUserId.ts` (identity re-derived from the roster, not just
  router state) and `useHeartbeat.ts` (8s interval) are the client side
  of this.
- **Phase 9** (`supabase/migrations/0014_security_hardening.sql`):
  `enforce_rate_limit()` called from all 13 mutating/enumeration-
  sensitive functions, plus a `select ... for update` fix for a genuine
  TOCTOU race in `claim_host`.

Don't re-read these in full unless you're actually touching that code —
this handoff doc's job is to tell you what already exists, not to make
you re-derive it.

## Next task: Phase 14 — production deployment

`docs/ARCHITECTURE.md`'s roadmap table names this next; as of this
session it has no Phase-14-specific detail beyond that roadmap line
(the same situation every prior phase's handoff flagged for the phase
after it, before that section got filled in) — search it yourself for
"Phase 14" to confirm before assuming this list is complete.

Concrete things a real "production deployment" phase for this stack
likely involves, not yet decided or built — treat this as a starting
checklist to validate/expand, not a finished plan:

1. **Where it's actually hosted.** This is a Vite + React SPA with a
   Supabase backend — a standard target for Vercel/Netlify/Cloudflare
   Pages. No hosting decision has been made yet in this repo; confirm the
   intended platform before assuming one, and check whether a project
   already exists there or needs creating.
2. **Environment variables in the hosting platform**, not just
   `.env.local` — `VITE_SUPABASE_URL` / `VITE_SUPABASE_ANON_KEY` need to
   be set in whatever CI/deploy environment builds this, sourced from a
   real (not local-test) Supabase project.
3. **Every migration in `supabase/migrations/` (0001–0019) and the seed
   file need to actually be applied against that real Supabase project**
   — every session's testing so far has been against a disposable local
   Postgres, never against a real hosted Supabase instance. That's a
   genuine, still-open gap, not something any prior phase closed.
4. **Realtime, specifically** — `0008_realtime.sql` adds tables to the
   `supabase_realtime` publication; confirm Realtime is actually enabled
   for those tables in the real project's dashboard, not just at the SQL
   level (this is the same category of "can't verify from this sandbox"
   gap Phase 4/8's handoffs already flagged for live wire behavior).
5. A production build sanity check (`npm run build`, verify `dist/`
   output) is necessary but not sufficient — this app uses client-side
   routing (`react-router-dom`), which needs an explicit SPA rewrite rule
   on most static hosts (e.g. Vercel's `vercel.json` rewrites, Netlify's
   `_redirects`), or deep links like `/game/:roomCode` will 404 on a hard
   refresh. Confirm whichever host is chosen has this configured.

Phase 15 (question bank + categories) is now done — see "What Phase 15
actually built" above. It's no longer something to defer or avoid
touching; any older note saying otherwise is obsolete.

## How to test your work (do this — don't just review the SQL)

**Since Phase 11:** once the environment below is set up and every
migration + seed file applied, run
`psql -d pinoyquiz_test -v ON_ERROR_STOP=1 -f supabase/tests/run_scenarios.sql`
instead of writing new ad hoc `do $$ ... $$` blocks by hand for anything
that script's 8 scenarios already cover. If your change affects behavior
outside those scenarios, add a new scenario to that file (following its
existing `test_assert(condition, label)` pattern) rather than testing it
once in a throwaway session — that's the whole point of Phase 11 having
made this repeatable.

Every SQL-touching phase so far has been validated against a
**disposable local Postgres**, not just read over. Reproduce that setup:

```bash
# Postgres 16 was installed via apt in this sandbox; a fresh sandbox needs:
# (the nodesource.sources apt list needs moving out of
# /etc/apt/sources.list.d/ first if `apt-get update` 403s on it — that's
# an unrelated broken repo in this sandbox image, not a project issue —
# hit repeatedly across sessions, not just once)
apt-get update -qq && apt-get install -y -qq postgresql postgresql-contrib
service postgresql start
su postgres -c "createdb pinoyquiz_test"
```

Then stub the Supabase auth environment (a real Supabase project provides
`auth.uid()`/`auth.users` automatically; local Postgres doesn't):

```sql
create schema if not exists auth;
create table if not exists auth.users (id uuid primary key default gen_random_uuid());
create or replace function auth.uid() returns uuid
language sql stable as $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid
$$;
do $$ begin
  if not exists (select from pg_roles where rolname = 'anon') then create role anon nologin; end if;
  if not exists (select from pg_roles where rolname = 'authenticated') then create role authenticated nologin; end if;
end $$;
grant usage on schema public, auth to anon, authenticated;
```

Also needs a stub `supabase_realtime` publication before running
`0008_realtime.sql`: `create publication supabase_realtime;`.

Then run every migration file in `supabase/migrations/` **in numeric
order** (`0001` through the newest — currently `0016`), then the seed
file in `supabase/seed/`, then simulate real users with a `do $$ ... $$`
block: `insert into auth.users default values returning id into
v_some_var;`, switch "who's calling" between statements with
`perform set_config('request.jwt.claim.sub', v_uid::text, false);`, and
call the RPCs directly (they're `SECURITY DEFINER`, so a superuser
session can call them regardless of the `authenticated`-only grants — the
grants matter for the real Supabase project, not this local harness).

**Known pitfall (still applies):** if you put a `set_config(...)` call
*inside* a `begin ... exception when others ... end;` block to test a
rejection, and that block's statement raises (which it should, to prove
the rejection works), Postgres rolls back that subtransaction — including
the `set_config` call itself, even though `is_local = false`. Always call
`set_config` to switch "current user" as its own statement **before** the
`begin` block you're testing, not inside it, or the next test will
silently run as the wrong user.

**Function argument types matter when testing in raw SQL:** several
functions take `smallint` parameters (`submit_answer`'s
`p_selected_option`, `create_game`'s `p_question_count`/
`p_time_limit_seconds`) — an untyped integer literal like `submit_answer(v_game_id, 0)`
will fail to resolve against the function signature; write
`submit_answer(v_game_id, 0::smallint)`. Bit this project repeatedly
across sessions — worth remembering.

**Simulating a stale player in tests (Phase 8):** to test
staleness-dependent behavior (`mark_stale_players`, `claim_host`)
without actually waiting 20+ seconds, just backdate the row directly:
`update players set last_seen_at = now() - interval '25 seconds' where
user_id = v_some_uid;` before calling the function under test.

**After the SQL is validated (or for any frontend-only change, like
Phase 10's):** run `npm run build` (not a bare `tsc --noEmit` — see
Phase 3's CHANGELOG entry for why that's misleading on this project's
tsconfig) and fix everything it reports before calling the phase done.
`npm run lint` (oxlint) currently reports 110 pre-existing errors and a
large, growing number of warnings unrelated to this project's own code —
reconfirmed again this session (Phase 10) by diffing the error count
against the documented baseline; still exactly 110. Don't chase those
down as part of an unrelated phase; just confirm your changes don't add
*new* errors to that count.

**For a CSS/markup-only phase like Phase 10:** there's an extra check
worth doing beyond the build — grep the compiled output in `dist/` for
the specific classes/values you added (e.g. `grep -o
"min-height:100dvh" dist/assets/*.css`) to confirm Tailwind actually
recognized and emitted them, rather than trusting that an arbitrary-value
or newer utility class compiled correctly just because the build didn't
error. A typo'd utility class doesn't fail the build — it just silently
produces no CSS.

## Things to *not* redo

- Don't re-run the Phase 15 question-bank expansion — it's done (280
  questions across 23 categories; see "What Phase 15 actually built"
  above and CHANGELOG.md's Phase 15 entry). If more categories or
  questions are wanted later, extend `CATEGORY_LABELS`/`CATEGORY_GROUPS`
  and add a new numbered migration in the same `NOT EXISTS`-guarded
  pattern as `0019` rather than editing `0018`/`0019` in place.
- Don't rebuild Realtime, RLS, the create/join functions, the
  WAITING→COUNTDOWN→QUESTION→REVEAL→LEADERBOARD→(QUESTION|FINISHED)
  transitions, the heartbeat/staleness/host-transfer mechanics from
  Phase 8, the rate-limiting/`claim_host` race fix from Phase 9, or the
  mobile viewport/touch-target work from Phase 10 — all implemented and
  tested. Reuse `useGameRealtime`, `useHeartbeat`, `useCurrentUserId`,
  `enforce_rate_limit`, the existing `gameApi.ts` patterns, the existing
  design tokens (`src/index.css`), and `min-h-dvh`/`touch-manipulation`
  (not `min-h-screen`/bare buttons) for any new screen or component.
- Don't re-litigate the rate limit numbers chosen in
  `0014_security_hardening.sql` without a concrete reason — they were
  deliberately set as generous multiples of real client cadence and
  confirmed not to interfere with a full end-to-end game playthrough
  (re-confirmed again in Phase 11's scenario 7). If a future phase
  changes any client polling/call pattern (e.g. adds polling to a
  currently event-driven fetch), revisit the relevant limit then, not
  preemptively.
- Don't re-run the Phase 11 bug-hunt from scratch expecting to find
  something — it didn't, on a deliberately adversarial pass across 8
  scenarios. If a future phase changes behavior in `submit_answer`,
  `end_question`, `start_game`, or any other function
  `run_scenarios.sql` exercises, extend that script with a new scenario
  for the changed behavior rather than distrusting the whole file and
  starting over.
- Don't introduce jsdom/React Testing Library for component-render
  tests without a concrete reason — Phase 11 deliberately scoped Vitest
  to pure-logic-only (`environment: "node"`) because there was no pure
  component logic worth isolating yet; see CHANGELOG's Phase 11 entry
  for the reasoning if that calculus changes.
- Phase 15 (question bank expansion) is now done, out of its normal
  place in the sequence, at explicit request. Phase 14 (production
  deployment) is once again the immediate next task — don't skip ahead
  to some other later phase without a similarly explicit reason.

## Question types (separate track from the Phase 1-15 roadmap above)

Started by explicit request, not part of the original spec the numbered
phases above were built against — tracked with its own "Question-Types
Phase N" numbering so it doesn't collide with the real Phase 1-15
history. Migrations: `0026_question_types_phase1.sql`,
`0027_question_types_phase2_enum.sql`, `0028_question_types_phase2.sql`,
`0029_question_types_phase3_enum.sql`, `0030_question_types_phase3.sql`.
Seeds: `supabase/seed/0002_phase1_question_types_sample.sql`,
`supabase/seed/0003_phase2_question_types_sample.sql`,
`supabase/seed/0004_phase3_question_types_sample.sql`.

**Question-Types Phase 1 — done.** True/False, Identification,
Fill-in-the-Blank alongside the original Multiple Choice. `questions`
gained `question_type` (defaults `multiple_choice` — every pre-existing
row needed zero changes), `correct_answer`, `acceptable_answers`.
`option_a-d`/`correct_option` went nullable (still required for
multiple_choice/true_false via check constraints, not a NOT NULL). New
`submit_text_answer` RPC grades identification/fill_blank by normalized
(trim, collapse whitespace, case-fold) string comparison against
`correct_answer` or any of `acceptable_answers`. `games` gained
`include_new_question_types` (default `false`) — a host opts in via a
checkbox on Create Game; nothing about an existing/未-updated caller
changes by default.

**Question-Types Phase 2 — done.** Unscramble, Matching, Image ID.
Unscramble and Image both grade through the *same* `submit_text_answer`
from Phase 1 (Image is really "Identification with a picture"; Unscramble
is "type the word" with a per-game shuffled-letters display) — no new
grading function needed for either. `questions` gained `image_url` and
the aligned-by-index pair `match_terms`/`match_definitions`.
`game_questions` gained `unscramble_letters` (generated once at
`start_game`, stable for the question's duration — same idea as
`shuffle_map`) and `match_shuffle` (same convention as `shuffle_map`,
applied to `match_definitions`). New `submit_matching_answer` RPC grades
all-or-nothing (every term paired to its correct definition) — per-pair
partial credit would be a reasonable later extension but wasn't added
now per the brief's "don't add fields/behavior that isn't needed yet."

**Question-Types Phase 3 — done.** Sequence/Arrange, per-question
configurable timers, and real Mixed Mode. Sequence grades through a new
`submit_sequence_answer`, structurally identical to Phase 2's
`submit_matching_answer` (server shuffles a display order once at
`start_game` into `game_questions.sequence_shuffle`, player proposes a
displayed-slot arrangement, grading decodes it back against the shuffle)
— all-or-nothing, same reasoning as Matching. `questions` gained
`time_limit_override` (nullable, 5-120s; null means "use this game's
`time_limit_seconds`", the same as every question before this migration)
and `sequence_items`. Every answer-submission function
(`submit_answer`/`submit_text_answer`/`submit_matching_answer`/
`submit_sequence_answer`) and `auto_advance_game` were updated to use
the effective per-question limit instead of the flat game-level one —
`auto_advance_game` was the one place still reading
`games.time_limit_seconds` directly, since `get_current_question`
already returned per-question data and the HOST_CONTROLLED client
already read `out_time_limit_seconds` from there. `games` gained
`enabled_question_types` (nullable array) as the real Mixed Mode
selector; a new `resolve_enabled_question_types()` SQL function is the
single place the fallback chain lives (explicit array → old
`include_new_question_types` boolean → `multiple_choice` only), so
`include_new_question_types` keeps working unchanged for any caller that
never sends the new param. CreateGame.tsx's old blunt "Include new
question types (Beta)" checkbox was replaced with a proper picker
(toggle + a pill per type, Multiple Choice always implicitly included).

**Not done yet, in priority order per the original brief:** Streaks,
Difficulty-driven config (question selection/timer/points varying by
difficulty — `question_difficulty` already exists and is already a
selection filter, but nothing yet *derives* a timer or point value from
it), the remaining named game modes (Speed Challenge/Brain
Challenge/Survival/Daily Challenge — a host can approximate Speed
Challenge today by combining a short `time_limit_seconds` with per-
question `time_limit_override`s, but there's no dedicated mode UI/preset
for any of the four), and an admin/question-authoring UI (every question
across all three phases was seeded via SQL — there is still no in-app
way to create one).

**Rules for continuing this track**, same spirit as the "Don't relitigate
past decisions" section above:
- Redefine functions from their *latest* version, not whatever an older
  migration file shows — trace forward from 0030, the same way 0030 was
  built by tracing 0028 forward (which itself traced 0022/0016, rather
  than 0010/0011's originals). Regressing custom-category-mix, Play
  Again/no-repeat-questions, rate limiting, or per-question timers while
  adding a question type is the most likely way to quietly break
  something that already worked.
- New question_type enum values need their own migration/transaction
  before anything can use them (`0027` exists solely for this reason) —
  Postgres rejects referencing a new enum value in the same transaction
  that added it.
- Keep the "existing multiple_choice behavior is the zero-config default"
  property intact: any new selection/scoring/mode logic should require an
  explicit opt-in (a new column defaulting to the old behavior, a new
  checkbox defaulting off) rather than changing what a caller who does
  nothing differently gets.

## Smart/Auto question timing + Game Setup redesign (0036)

Two asks handled together, since the second was mostly the frontend
surface for the first: (1) a per-game Timing Strategy so timing doesn't
have to be one flat number for every question, and (2) redesigning the
Create Game screen's mode/category/timing pickers into a clearer step
flow (Categories → Game Modes → Questions → Timing → Summary).

**Timing Strategy** (`games.timing_strategy`, `'fixed' | 'smart'`,
default `'fixed'`) sits alongside the existing `time_limit_seconds`.
Fixed is the pre-existing behavior unchanged. Smart derives each
question's time from a new reusable `calculate_question_time()` SQL
function — base seconds by `question_type`, plus additive bumps for
prompt length, option length (multiple_choice/true_false), matching pair
count, and sequence item count, rounded to the nearest 5s and clamped to
[10, 60]. It's computed ONCE per question, at `start_game`, and stored on
`game_questions.effective_time_limit_seconds` — not recomputed on every
read. That meant redefining `get_current_question` and all four
`submit_*_answer` functions plus `auto_advance_game` to read that one
column instead of each re-deriving
`coalesce(v_q.time_limit_override, v_game.time_limit_seconds)` inline —
six call sites collapsed to one computation, same pattern as the
shuffle_map/match_shuffle/sequence_shuffle values already being generated
once at `start_game` and read stably afterward.
`questions.time_limit_override` (content-author-set, from Phase 3) is
untouched and still wins over both Fixed and Smart Auto.

**Deliberately not built**: the third strategy the original brief
mentioned as an optional "advanced" mode — a host manually overriding an
individual question's time before the game starts. Questions aren't
queryable by the client pre-game (the host plays too, so exposing prompts
would leak answers same as it would to anyone else — see the anti-cheat
design), so a real per-question override UI needs its own
question-preview surface that doesn't exist yet. Same category of gap as
the admin/question-authoring UI already noted above — flagged here
instead of half-built.

**Frontend** (`src/pages/CreateGame.tsx` fully restructured):
- `src/game-engine/questionTiming.ts` — pure-function mirror of the SQL
  calculation, used only for the pre-game Summary preview (before real
  questions are known, so it shows typical-case estimates per type, not
  the exact numbers a real Smart Auto game will land on).
- `src/components/ui/ModeCard.tsx` — icon + name + description +
  checked-state row, used for the Game Modes step. `multiple_choice`
  renders locked/checked (it's always on; there's no pill to turn it
  off) — same "always included" property `CreateGame.tsx` already had,
  just made visible instead of implicit.
- `src/components/ui/StepIndicator.tsx` — numbered step nav, tappable to
  jump back to a completed step.
- Existing settings (category picker, difficulty, question count, Game
  Flow/Answer Behavior) are unchanged in substance, just redistributed
  across the new steps instead of one long scrolling form. The old
  "Mixed Mode (Beta)" on/off checkbox is gone — selecting any optional
  mode now implicitly turns Mixed Mode on, which is what the checkbox
  amounted to anyway.
- `src/data/gameOptions.ts` gained `QUESTION_TYPE_LABELS/DESCRIPTIONS/ICONS`
  (all 8 types, replacing the old `OPTIONAL_QUESTION_TYPE_LABELS` which
  only covered 7) and `TIMING_STRATEGY_LABELS/DESCRIPTIONS/OPTIONS`.

**Verified**: `npx tsc -b`, `npx vitest run` (56/56 passing, including
new `questionTiming.test.ts` and expanded `gameOptions.test.ts` coverage
for the new option maps), and `npx vite build` all pass. The SQL migration
itself has **not** been run against a live/disposable Postgres instance —
no DB access in the environment this was written in — so it's unverified
beyond careful tracing against the 0030/0034 bodies it was built from.
Test before relying on it: `supabase db reset` (or equivalent), then spin
up a game with `timing_strategy = 'smart'` and confirm
`game_questions.effective_time_limit_seconds` lands in [10, 60] and
roughly tracks question complexity as described above.
