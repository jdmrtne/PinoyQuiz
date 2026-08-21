# Master Handoff

Read this first. It's the single "where are we, what's next" doc for
whichever Claude session picks this project up next. For the full
technical design and per-phase implementation detail, see
[docs/ARCHITECTURE.md](ARCHITECTURE.md); for a chronological log of every
change and how it was tested, see [../CHANGELOG.md](../CHANGELOG.md).

## Current state: Phase 8 complete ✅

**Phases 1–8 are done and validated.** The game now supports the entire
core loop, and survives players (including the host) dropping mid-game:

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
| 9 | Security + anti-cheat hardening | ⬜ **Next task** |
| 10 | Mobile responsiveness + UI polish | ⬜ Not started |
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

## Next task: Phase 9 — security and anti-cheat hardening

`docs/ARCHITECTURE.md`'s roadmap table names this next; check that file
for whatever specifics it has (search for "Phase 9" and "anti-cheat") the
same way Phase 8's section there pointed at "Presence"/"disconnect"
before starting. Based on what's already in place vs. not, at minimum
this phase likely needs to look at:

1. **Rate limiting on state-transition functions.** Nothing currently
   stops a malicious client from hammering `submit_answer`,
   `advance_question`, `claim_host`, etc. in a tight loop. Every one of
   these functions already has its own correctness checks (right phase,
   right caller, etc.), but repeated *valid* calls in quick succession —
   e.g. spamming `mark_stale_players` — aren't rate-limited at all. Decide
   whether this needs a real mechanism (a `rate_limit_hits` table + a
   check at the top of each function, or Supabase's built-in
   `auth.rate_limit` type features if applicable) or whether the
   `SECURITY DEFINER` + RLS model already makes this a non-issue in
   practice (spamming a correctly-guarded function mostly just wastes the
   caller's own quota, not others' game state) — that determination
   itself is Phase 9 work, not something to assume either way.
2. **`claim_host` abuse potential specifically** — new in Phase 8, so
   Phase 7's security review never looked at it. Worth checking: can a
   player deliberately stop heartbeating to force a host transfer away
   from an active host who's just being slow, then heartbeat again
   immediately after to "steal" a game? Current design requires the
   *outgoing* host to actually go 20s+ stale first (checked server-side),
   so a healthy host can't be forced out by someone else's inaction —
   but confirm there isn't a subtler race (e.g. calling `claim_host`
   in the same instant the real host's heartbeat lands).
3. **Timing/scoring anti-cheat beyond what Phase 6 already built** —
   `submit_answer` already computes `response_time_ms` server-side from
   `question_started_at`, never a client-reported value (see Phase 6's
   CHANGELOG entry), so the obvious "claim I answered instantly" vector
   is already closed. Check `docs/ARCHITECTURE.md`'s "Security model"
   section for whatever else it flags as still open.
4. Whatever else `docs/ARCHITECTURE.md`'s own Phase 9 notes (if any exist
   beyond the roadmap table) call out — read it before assuming this list
   above is complete; it was compiled from the current codebase's own
   gaps, not from architecture doc content specific to Phase 9, since
   that section wasn't fleshed out in detail the way Phase 8's was.

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
  transitions, or the new heartbeat/staleness/host-transfer mechanics from
  Phase 8 — all implemented and tested. Reuse `useGameRealtime`,
  `useHeartbeat`, `useCurrentUserId`, the existing `gameApi.ts` patterns,
  and the existing design tokens (`src/index.css`) rather than
  introducing new ones.
- Don't skip ahead to Phase 10 (mobile polish) or beyond — Phase 9 is the
  immediate next task.
