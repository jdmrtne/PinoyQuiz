# Master Handoff

Read this first. It's the single "where are we, what's next" doc for
whichever Claude session picks this project up next. For the full
technical design and per-phase implementation detail, see
[docs/ARCHITECTURE.md](ARCHITECTURE.md); for a chronological log of every
change and how it was tested, see [../CHANGELOG.md](../CHANGELOG.md).

## Current state: Phase 11 complete ✅

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
| 5 | Question system + game engine | ✅ Done (partial question bank — 80/240) |
| 6 | Answer submission + scoring | ✅ Done |
| 7 | Leaderboard + final results | ✅ Done |
| 8 | Disconnect/reconnect handling | ✅ Done |
| 9 | Security + anti-cheat hardening | ✅ Done |
| 10 | Mobile responsiveness + UI polish | ✅ Done |
| 11 | Testing + bug fixing | ✅ Done |
| 12 | Production deployment | ⬜ **Next task** |
| 14 | Expand question bank to 240 | ⬜ Not started (deferred from Phase 5) |

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

## Next task: Phase 12 — production deployment

`docs/ARCHITECTURE.md`'s roadmap table names this next; as of this
session it has no Phase-12-specific detail beyond that roadmap line
(the same situation every prior phase's handoff flagged for the phase
after it, before that section got filled in) — search it yourself for
"Phase 12" to confirm before assuming this list is complete.

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
3. **Every migration in `supabase/migrations/` (0001–0014) and the seed
   file need to actually be applied against that real Supabase project**
   — this session's testing was all against a disposable local Postgres,
   never against a real hosted Supabase instance. That's a genuine,
   still-open gap, not something Phase 11 closed.
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

Do not touch the question bank (Phase 14, deliberately deferred — see
"Things to *not* redo" below).

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
order** (`0001` through the newest — currently `0014`), then the seed
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

- Don't touch the question bank / seed data size (80 of 240 questions) —
  that's tracked separately as Phase 14, not part of the current 1-12
  sequence, and rushing it would violate the accuracy bar documented in
  Phase 5's CHANGELOG entry.
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
- Don't skip ahead to Phase 14 (question bank expansion) instead of
  Phase 12 (production deployment) — 12 is the immediate next task, per
  the numbered sequence this project has followed since Phase 1.
