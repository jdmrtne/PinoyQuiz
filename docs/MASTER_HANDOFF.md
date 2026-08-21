# Master Handoff

Read this first. It's the single "where are we, what's next" doc for
whichever Claude session picks this project up next. For the full
technical design and per-phase implementation detail, see
[docs/ARCHITECTURE.md](ARCHITECTURE.md); for a chronological log of every
change and how it was tested, see [../CHANGELOG.md](../CHANGELOG.md).

## Current state: Phase 9 complete ✅

**Phases 1–9 are done and validated.** The game now supports the entire
core loop, survives players (including the host) dropping mid-game, and
every mutating server function is rate-limited against tight-loop abuse.

Phase 9 (security + anti-cheat hardening) closed the two concrete gaps
this doc's previous revision named:
1. **Rate limiting**, on all 13 mutating/enumeration-sensitive functions
   — `supabase/migrations/0014_security_hardening.sql`'s
   `enforce_rate_limit()` helper, called at the top of each one. Limits
   are generous multiples of real client cadence, so normal play never
   trips them (confirmed by a full end-to-end game playthrough during
   testing).
2. **A genuine TOCTOU race in `claim_host`** — it used to read the host's
   staleness, then write based on that snapshot, leaving a window where a
   concurrent `heartbeat()` from the real host could land in between and
   get them incorrectly demoted. Fixed with `select ... for update` on
   the host row so the two operations now serialize instead of racing.
   Verified with an actual two-session concurrency test, not just code
   review — see CHANGELOG's Phase 9 entry for the measured blocking
   behavior.

`submit_answer`'s timing anti-cheat (Phase 6 — server-computed
`response_time_ms`, never client-reported) was re-checked and confirmed
to need no further work.

**Phase 8's disconnect/reconnect mechanics, unchanged this phase:**

```
WAITING → COUNTDOWN → QUESTION → REVEAL → LEADERBOARD → (next QUESTION | FINISHED)
```

Any client's own periodic heartbeat (`src/hooks/useHeartbeat.ts`, every
8s) both proves that client is still around and sweeps the roster for
anyone who's gone quiet for 20+ seconds. If the stale player was the
host, any remaining connected player can trigger `claim_host`, which
deterministically reassigns hosting to the earliest-joined still-
connected player (not necessarily whoever clicked) — so a host closing
their tab mid-`QUESTION`/`REVEAL`/`LEADERBOARD`/even mid-`COUNTDOWN` no
longer permanently strands everyone else. This was validated end-to-end,
not just function-by-function: a scripted scenario starts a 2-question
game, kills the host mid-first-question, has the surviving player claim
host and single-handedly drive the game to `FINISHED` with correct
scores (see CHANGELOG's Phase 8 entry for the full test list).

Rejoining an in-progress game from the UI also now works correctly after
a hard refresh or a directly-opened `/game/:roomCode` link — `GameRoom`/
`Results` no longer rely solely on React Router's `location.state` (which
doesn't survive either of those) to know "who am I"; they re-derive it
from the roster + the browser's persisted anonymous auth session
(`src/hooks/useCurrentUserId.ts`).

**What it still cannot do:** recover if *every* participant disconnects
at once (nobody's left to run the staleness sweep or claim host — would
need a server-side scheduled job, deliberately not introduced, see
below), and detection always has up to ~20s of lag rather than an instant
signal. Both are documented trade-offs from the mechanism choice, not
oversights — see `supabase/migrations/0013_disconnect_reconnect.sql`'s
header comment for the reasoning.

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
| 10 | Mobile responsiveness + UI polish | ⬜ **Next task** |
| 11 | Testing + bug fixing | ⬜ Not started |
| 12 | Production deployment | ⬜ Not started |
| 14 | Expand question bank to 240 | ⬜ Not started (deferred from Phase 5) |

## What Phase 8 actually built (so you don't re-derive it)

- `supabase/migrations/0013_disconnect_reconnect.sql`:
  - `heartbeat(game_id)` — any participant, own row only. Sets
    `connected = true, last_seen_at = now()`.
  - `mark_stale_players(game_id)` — any participant (deliberately not
    host-only — the host is exactly who might be missing). Flips
    `connected = false` for anyone in that game whose `last_seen_at` is
    more than 20 seconds old. Idempotent; safe to call redundantly from
    every client's own timer at slightly different times.
  - `claim_host(game_id)` — any participant other than the current host.
    Re-checks staleness server-side (20s threshold, same as
    `mark_stale_players`) rather than trusting the caller's view; rejects
    with "The host is still connected" otherwise. On success, picks the
    earliest-joined currently-`connected` player (excluding the outgoing
    host) as the new host — deterministic, so simultaneous claim attempts
    from different clients converge on the same answer — and updates
    both that player's `is_host` and `games.host_user_id`.
  - **Why heartbeat/staleness instead of Realtime Presence** (which
    `docs/ARCHITECTURE.md` had flagged as the more "natural" fit): this
    sandbox cannot exercise live Supabase Realtime wire behavior at all
    (same limitation noted since Phase 4), Presence included. A
    heartbeat is a plain function + `UPDATE`, fully testable against the
    disposable local Postgres this project has used to validate every
    phase, and it broadcasts through the *already-validated*
    `postgres_changes` subscription on `players` instead of needing a
    new Realtime feature. Trade-off is real (~20s lag vs. near-instant)
    and worth revisiting once this can be checked against a live
    project — but it's a deliberate, documented choice, not a shortcut.
- `src/lib/gameApi.ts` — `heartbeat`, `markStalePlayers`, `claimHost`.
- `src/hooks/useCurrentUserId.ts` (new) — also closes a real pre-existing
  gap: identity used to come only from router state, which a hard
  refresh or a direct link loses. Now derived from the roster.
- `src/hooks/useHeartbeat.ts` (new) — every 8s, `heartbeat()` +
  `markStalePlayers()`, for as long as this player's identity is known
  and the game isn't `FINISHED`.
- `GameRoom.tsx` — identity rewired onto `useCurrentUserId`; heartbeat
  wired in; new `HostDisconnectedBanner` (non-host players only, shown
  once the host's `connected` flag reads false) rendered above every
  in-progress phase screen.
- `LeaderboardScreen` — optional "N of M connected" note.
- `Results.tsx` — same identity fix as `GameRoom.tsx`.

## What Phase 9 actually built (so you don't re-derive it)

- `supabase/migrations/0014_security_hardening.sql`:
  - `rate_limit_hits` table — one row per `(user_id, action)`, sliding
    window (`window_start`, `call_count`). RLS enabled, zero policies,
    explicit `revoke all ... from anon, authenticated` — same
    defense-in-depth pattern as every other table since 0005/0006. Rows
    are never pruned; it's an upsert-in-place counter bounded by
    `(real users) × (13 actions)`, not an append-only log, so no cleanup
    job was needed.
  - `enforce_rate_limit(p_action, p_max_calls, p_window_seconds)` —
    internal helper, single upsert, raises once a caller's count exceeds
    the limit within the window. **Not** granted `EXECUTE` to
    `authenticated`/`anon` — same "revoked from public, called only from
    inside another `SECURITY DEFINER` function" pattern
    `generate_room_code()` already used. Confirmed uncallable directly by
    either client role via `has_function_privilege()`.
  - Every mutating function (plus `lookup_game_by_room_code`, the one
    enumeration-sensitive read) got a `perform enforce_rate_limit(...)`
    call right after its existing "must be signed in" check —
    `create_game`, `join_game`, `remove_player`, `start_game`,
    `begin_first_question`, `submit_answer`, `end_question`,
    `advance_to_leaderboard`, `advance_question`, `heartbeat`,
    `mark_stale_players`, `claim_host`, `lookup_game_by_room_code`.
    Limits are generous multiples of real client cadence (see
    CHANGELOG's Phase 9 entry for the exact numbers) — confirmed by a
    full end-to-end game playthrough that no legitimate call sequence
    ever trips one.
  - `claim_host`'s TOCTOU race fix: the host row is now read with
    `select ... for update` instead of a plain `select ... into`, so a
    concurrent `heartbeat()` from the real host serializes against a
    `claim_host` call instead of racing it. This was Phase 8's
    `claim_host`, re-examined per this doc's own previous "confirm there
    isn't a subtler race" note — and there was one. Verified with an
    actual two-session concurrency test (one session holds the row lock
    via an explicit transaction + `pg_sleep`, a concurrent session's
    `UPDATE` on the same row measurably blocks until the lock releases),
    not just reasoned about.
  - `submit_answer`'s timing/scoring anti-cheat was re-checked against
    this doc's own previous item 3 and confirmed to need no changes —
    `response_time_ms` and correctness were already fully server-computed
    since Phase 6.
- `src/lib/gameApi.ts` — added `"You are doing that too fast"` to
  `friendlyMessage`'s known-message list, so a rate-limited call surfaces
  a clean message instead of the generic fallback. No other frontend
  changes this phase.

## Next task: Phase 10 — mobile responsiveness + UI polish

`docs/ARCHITECTURE.md`'s roadmap table names this next. Read whatever
specifics it has on Phase 10 (search for "Phase 10", "mobile",
"responsive") the same way each prior phase's handoff section pointed at
that file's own notes before starting — this doc's list below is
compiled from what's known about the current UI, not from ARCHITECTURE's
Phase-10-specific content, since (like Phase 9 before it) that section
wasn't necessarily fleshed out in the same depth as earlier phases were.
At minimum, likely worth checking:

1. **An actual pass on real/emulated small-viewport devices**, not just
   "it uses Tailwind so it's probably fine." Every screen so far
   (`Home`, `CreateGame`, `JoinGame`, lobby, `QuestionScreen`,
   `RevealScreen`, `LeaderboardScreen`, `Results`) was built and validated
   functionally, but no phase has done a dedicated responsive/mobile
   layout review — check tap target sizes on the answer-option buttons
   specifically (this is a Kahoot-style "everyone answers on their own
   phone" game; `QuestionScreen` is the screen under the most real-world
   mobile pressure), text wrapping on long nicknames/prompts, and how the
   countdown/timer UI behaves on narrow screens.
2. **`HostDisconnectedBanner`** (Phase 8) and the **leaderboard "N of M
   connected" note** (Phase 8) were both explicitly built reusing
   existing `Card`/`Button` primitives and design tokens with *no*
   mobile-specific polish pass — Phase 8's handoff deferred that here by
   name. Worth revisiting once the rest of the mobile pass is underway,
   not necessarily first.
3. **`src/index.css`'s design tokens** (Phase 1) were built with a
   distinct visual identity (jeepney-stripes motif, mango/ube/sunset/
   bagoong accents) — Phase 10 should extend that system responsively
   rather than introducing new tokens or falling back to generic
   Tailwind defaults at small breakpoints.
4. Whatever else `docs/ARCHITECTURE.md`'s own Phase 10 notes call out.

Do **not** start Phase 11 (testing + bug fixing) or Phase 12 (production
deployment) early, and do not touch the question bank (Phase 14,
deliberately deferred — see "Things to *not* redo" below).

## How to test your work (do this — don't just review the SQL)

Every phase so far has been validated against a **disposable local
Postgres**, not just read over. Reproduce that setup:

```bash
# Postgres 16 was installed via apt in this sandbox; a fresh sandbox needs:
# (the nodesource.sources apt list needs moving out of
# /etc/apt/sources.list.d/ first if `apt-get update` 403s on it — that's
# an unrelated broken repo in this sandbox image, not a project issue —
# hit again this session, same as the last two)
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
order** (`0001` through the newest — currently `0013`), then the seed
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
`submit_answer(v_game_id, 0::smallint)`. Bit this project again this
session (third time now — Phase 5 and an earlier one too) — worth
remembering.

**New in Phase 8 — simulating a stale player in tests:** to test
staleness-dependent behavior (`mark_stale_players`, `claim_host`)
without actually waiting 20+ seconds, just backdate the row directly:
`update players set last_seen_at = now() - interval '25 seconds' where
user_id = v_some_uid;` before calling the function under test. This is
what every Phase 8 test scenario does — no `pg_sleep` needed.

**After the SQL is validated:** run `npm run build` (not a bare
`tsc --noEmit` — see Phase 3's CHANGELOG entry for why that's misleading
on this project's tsconfig) and fix everything it reports before calling
the phase done. `npm run lint` (oxlint) currently reports 110
pre-existing errors and a large, growing number of warnings unrelated to
this project's own code — verified again this session by running lint
against a fresh unmodified extract of the pre-Phase-8 project side by
side, which showed the exact same 110 errors both before and after.
Don't chase those down as part of an unrelated phase; just confirm your
changes don't add *new* errors to that count.

## Things to *not* redo

- Don't touch the question bank / seed data size (80 of 240 questions) —
  that's tracked separately as Phase 14, not part of the current 1-12
  sequence, and rushing it would violate the accuracy bar documented in
  Phase 5's CHANGELOG entry.
- Don't rebuild Realtime, RLS, the create/join functions, the
  WAITING→COUNTDOWN→QUESTION→REVEAL→LEADERBOARD→(QUESTION|FINISHED)
  transitions, the heartbeat/staleness/host-transfer mechanics from
  Phase 8, or the rate-limiting/`claim_host` race fix from Phase 9 — all
  implemented and tested. Reuse `useGameRealtime`, `useHeartbeat`,
  `useCurrentUserId`, `enforce_rate_limit`, the existing `gameApi.ts`
  patterns, and the existing design tokens (`src/index.css`) rather than
  introducing new ones.
- Don't re-litigate the rate limit numbers chosen in
  `0014_security_hardening.sql` without a concrete reason — they were
  deliberately set as generous multiples of real client cadence and
  confirmed not to interfere with a full end-to-end game playthrough. If
  Phase 10 or later changes any client polling/call pattern (e.g. adds
  polling to a currently event-driven fetch), revisit the relevant
  limit then, not preemptively.
- Don't skip ahead to Phase 11 (testing + bug fixing) or Phase 12
  (production deployment) — Phase 10 (mobile responsiveness + UI polish)
  is the immediate next task.
