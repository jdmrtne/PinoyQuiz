# Master Handoff

Read this first. It's the single "where are we, what's next" doc for
whichever Claude session picks this project up next. For the full
technical design and per-phase implementation detail, see
[docs/ARCHITECTURE.md](ARCHITECTURE.md); for a chronological log of every
change and how it was tested, see [../CHANGELOG.md](../CHANGELOG.md).

## Current state: Phase 7 complete ✅

**Phases 1–7 are done and validated.** The game now supports the entire
core loop: create a room → join via code/link → realtime lobby → host
starts the game → countdown → question 1 → players answer → reveal →
leaderboard → next question → … → reveal on the last question →
leaderboard → **every client** (host and non-host, at the same time) is
routed to `/results/:roomCode` → final rankings, with "Play Again"/"Back
Home" CTAs.

```
WAITING → COUNTDOWN → QUESTION → REVEAL → LEADERBOARD → (next QUESTION | FINISHED)
```

**What it cannot do yet:** survive anyone dropping connection mid-game.
If the host closes their tab while the game is on `LEADERBOARD` (or
`QUESTION`, waiting for their timer to fire `end_question`), everyone
else is stuck — there's no one left who can call the next host-only
transition function. `players.connected`/`last_seen_at` already exist and
`join_game` already flips `connected = true` on rejoin (see
`0007_room_functions.sql`), but nothing yet detects a *drop*, migrates
host privileges, or lets a returning player rejoin an in-progress game
smoothly from the UI. That's Phase 8, described below.

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
| 8 | Disconnect/reconnect handling | ⬜ **Next task** |
| 9 | Security + anti-cheat hardening | ⬜ Not started |
| 10 | Mobile responsiveness + UI polish | ⬜ Not started |
| 11 | Testing + bug fixing | ⬜ Not started |
| 12 | Production deployment | ⬜ Not started |
| 14 | Expand question bank to 240 | ⬜ Not started (deferred from Phase 5) |

## What Phase 7 actually built (so you don't re-derive it)

- `supabase/migrations/0012_leaderboard.sql`:
  - `get_leaderboard(game_id)` — any participant, any status. Returns
    ranked standings (`out_player_id`, `out_nickname`, `out_score`,
    `out_rank`, `out_score_delta`). `score_delta` is the points earned on
    whatever question `games.current_question_id` currently points at —
    computed server-side (the same reason `get_answer_reveal` computes
    `percent_correct` server-side: `answers_select_own` RLS blocks a
    client from reading another player's `answers` rows directly). This
    single function backs both the mid-game `LEADERBOARD` screen *and*
    the final `Results` page — at `FINISHED`, `current_question_id` still
    points at the last question played, so the delta is just "how the
    final question went" and Results ignores it, using only score/rank.
  - `advance_to_leaderboard(game_id)` — host-only, `REVEAL → LEADERBOARD`.
  - `advance_question(game_id)` — host-only. `LEADERBOARD → QUESTION`
    (next one, re-anchoring `question_started_at` the same way
    `begin_first_question` does) if `current_question_index + 1 <
    question_count`, else `LEADERBOARD → FINISHED` + `finished_at = now()`.
- `src/lib/gameApi.ts` — `advanceToLeaderboard`, `getLeaderboard`,
  `advanceQuestion`, reusing the `LeaderboardEntry` type already defined
  in `src/types/game.ts` since Phase 1.
- `LeaderboardScreen` (new, `src/components/game/`) + a host-only "See
  Leaderboard" button added to `RevealScreen` (previously just text
  saying "Phase 7 will add this").
- `GameRoom.tsx` — new `LEADERBOARD` branch; a `FINISHED` effect that
  `navigate()`s every client to `/results/:roomCode` (fires for host and
  non-host alike since `game.status` arrives via the existing Realtime
  subscription on `games`).
- `Results.tsx` — no longer a placeholder; final rankings via
  `get_leaderboard`, medal-style top-3, "(you)" highlight, "Play
  Again"/"Back Home".

## Next task: Phase 8 — disconnect/reconnect handling

The state machine is now a complete loop, but every transition in it is
still **host-triggered from the host's own client** (`start_game`,
`begin_first_question`, `end_question`, `advance_to_leaderboard`,
`advance_question`) — there is no server-side fallback. Concretely, this
phase needs to cover at least:

1. **Detecting a drop.** Nothing currently flips `players.connected` to
   `false` or updates `last_seen_at` on disconnect — only `join_game`'s
   reconnect path touches those columns today. Decide the mechanism:
   Supabase Realtime Presence (a second channel alongside the existing
   `postgres_changes` one in `useGameRealtime.ts`) is the natural fit for
   "who's actually got a live socket open right now," separate from the
   `connected` DB column, which could instead become "haven't ack'd in
   N seconds" via a heartbeat. Check whether `docs/ARCHITECTURE.md` has
   more specific guidance (search it for "Presence" and "disconnect")
   before inventing an approach from scratch.
2. **Host migration.** If the *host's* connection drops mid-game, someone
   else needs to become host so the game isn't permanently stuck on
   whichever host-only transition was next. Likely a new
   `SECURITY DEFINER` function (`transfer_host` or similar) — decide
   whether it's automatic (server picks the next-oldest connected player)
   or requires an explicit action from a remaining player.
3. **Rejoining an in-progress game from the UI.** The RPC-level plumbing
   already exists (`join_game`'s reconnect branch returns the current
   `out_status` regardless of phase), but `JoinGame.tsx` and `GameRoom.tsx`
   haven't been exercised against a game that's already past `WAITING` —
   confirm the full client flow (rejoin mid-`QUESTION`, mid-`LEADERBOARD`,
   etc.) actually lands the returning player in the right render branch
   with correct state (e.g. they should probably see themselves as "not
   yet answered" rather than crash if `getCurrentQuestion` returns a
   question they haven't submitted for yet).
4. **UI affordances.** Roster already dims disconnected players
   (`PlayerRoster.tsx`'s `!p.connected && "opacity-40"`) — decide whether
   that's sufficient during live play too, or whether `QuestionScreen`/
   `LeaderboardScreen` need their own "N of M connected" indicator.

## How to test your work (do this — don't just review the SQL)

Every phase so far has been validated against a **disposable local
Postgres**, not just read over, and every phase caught at least one real
bug this way (see CHANGELOG.md phase-by-phase; Phase 7 confirmed correct
`score_delta`/rank behavior across a full 3-question game and a
single-question edge case this way). Reproduce that setup:

```bash
# Postgres 16 was installed via apt in this sandbox; a fresh sandbox needs:
# (the nodesource.sources apt list may need moving out of
# /etc/apt/sources.list.d/ first if `apt-get update` 403s on it — that's
# an unrelated broken repo in this sandbox image, not a project issue)
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
order** (`0001` through the newest — currently `0012`), then the seed
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
`submit_answer(v_game_id, 0::smallint)`. Bit us again this session, same
as it apparently did in an earlier one — worth remembering.

**After the SQL is validated:** run `npm run build` (not a bare
`tsc --noEmit` — see Phase 3's CHANGELOG entry for why that's misleading
on this project's tsconfig) and fix everything it reports before calling
the phase done. `npm run lint` (oxlint) currently reports 110
pre-existing errors and a large, growing number of warnings unrelated to
this project's own code — verified by diffing against a fresh unmodified
extract of the project before Phase 7's changes, which showed the exact
same 110 errors. Don't chase those down as part of an unrelated phase;
just confirm your changes don't add *new* errors to that count (they
didn't, Phase 6→7: 110 before, 110 after).

## Things to *not* redo

- Don't touch the question bank / seed data size (80 of 240 questions) —
  that's tracked separately as Phase 14, not part of the current 1-12
  sequence, and rushing it would violate the accuracy bar documented in
  Phase 5's CHANGELOG entry.
- Don't rebuild Realtime, RLS, the create/join functions, the
  WAITING→COUNTDOWN→QUESTION→REVEAL transitions, or the new
  REVEAL→LEADERBOARD→(QUESTION|FINISHED) transitions from Phase 7 — all
  implemented and tested. Reuse `useGameRealtime`, the existing
  `gameApi.ts` patterns, and the existing design tokens (`src/index.css`)
  rather than introducing new ones.
- Don't skip ahead to Phase 9 (anti-cheat hardening) or Phase 10 (mobile
  polish) — Phase 8 is the immediate next task, and the game isn't
  reliable for real multiplayer use (as opposed to a demo with everyone
  staying connected the whole time) without it.
