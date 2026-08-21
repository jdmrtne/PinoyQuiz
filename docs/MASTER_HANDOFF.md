# Master Handoff

Read this first. It's the single "where are we, what's next" doc for
whichever Claude session picks this project up next. For the full
technical design and per-phase implementation detail, see
[docs/ARCHITECTURE.md](ARCHITECTURE.md); for a chronological log of every
change and how it was tested, see [../CHANGELOG.md](../CHANGELOG.md).

## Current state: Phase 10 complete ✅

**Phases 1–10 are done and validated.** The game supports the entire core
loop, survives players (including the host) dropping mid-game, every
mutating server function is rate-limited against tight-loop abuse, and
every screen now uses mobile-correct viewport sizing with real touch
targets on the controls that need them.

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
| 11 | Testing + bug fixing | ⬜ **Next task** |
| 12 | Production deployment | ⬜ Not started |
| 14 | Expand question bank to 240 | ⬜ Not started (deferred from Phase 5) |

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

## Next task: Phase 11 — testing + bug fixing

`docs/ARCHITECTURE.md`'s roadmap table names this next; it has no
Phase-11-specific detail beyond that roadmap line (the same situation
Phase 9's handoff flagged for Phase 10 before that section got filled
in this session) — search it yourself for "Phase 11" to confirm before
assuming this list is complete.

**Concrete starting point, not assumed — this is the current real state
of automated testing in this project:** `tests/` and `src/game-engine/`
have existed as empty scaffolded folders since Phase 1 and are still
empty today. Every phase so far has been validated by scripted SQL
scenarios run by hand against a disposable local Postgres (see "How to
test your work" below) and by `npm run build`/`npm run lint` — there is
currently **zero automated, repeatable test suite** anywhere in this
repo. That's very likely a real part of Phase 11's scope, not a gap to
route around:

1. **Decide what "testing" means for Phase 11 before writing code** —
   this project has no test runner installed (no Vitest/Jest/Playwright
   in `package.json`). Introducing one is a real decision (which
   runner, unit vs. integration scope, whether SQL-level scenarios move
   into a repeatable script vs. staying manual) worth making deliberately
   rather than defaulting to whatever's first to hand — the existing
   `src/game-engine/` folder was scaffolded back in Phase 1 specifically
   for "framework-agnostic" logic that "can be unit tested without a DB"
   (see its description in the Phase 1 CHANGELOG entry and
   `ARCHITECTURE.md`'s project-structure section), which suggests unit
   tests for pure logic were the original intent — but no pure game logic
   currently lives outside the SQL functions themselves, so check whether
   that's still the right shape before building around a stale plan.
2. **Bug fixing** — this phase is also the place to chase down anything
   real found during a fresh, deliberate bug-hunt pass (not the
   "confirm this specific mechanism works" testing every prior phase did
   for its own new code) — e.g. edge cases in existing flows that were
   never adversarially tested: what happens with a 1-player game, a
   0-second-remaining race between `submit_answer` and `end_question`,
   rapid double-submission attempts beyond what Phase 9's rate limits
   already guard against, a nickname that's exactly 20 characters (the
   `maxLength`) combined with the longest category label, etc.
3. Whatever else `docs/ARCHITECTURE.md`'s own Phase 11 notes call out, if
   any exist by the time you read this.

Do **not** start Phase 12 (production deployment) early, and do not
touch the question bank (Phase 14, deliberately deferred — see "Things
to *not* redo" below).

## How to test your work (do this — don't just review the SQL)

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
  confirmed not to interfere with a full end-to-end game playthrough. If
  Phase 11 or later changes any client polling/call pattern (e.g. adds
  polling to a currently event-driven fetch), revisit the relevant limit
  then, not preemptively.
- Don't skip ahead to Phase 12 (production deployment) — Phase 11
  (testing + bug fixing) is the immediate next task.
