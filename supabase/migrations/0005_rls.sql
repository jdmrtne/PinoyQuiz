-- Pinoy Quiz — 0005: Row Level Security
--
-- Design (see docs/ARCHITECTURE.md "Security model"):
-- Every player — host included — signs in via Supabase Anonymous Auth
-- (supabase.auth.signInAnonymously()) before touching any table, so
-- auth.uid() is always available.
--
-- RLS here only ever grants SELECT. No INSERT/UPDATE/DELETE policy exists
-- for `anon`/`authenticated` on any table in this migration, and 0006
-- explicitly revokes those table privileges too. That's deliberate: every
-- write (create game, join, start, submit answer, advance state...) must go
-- through a SECURITY DEFINER Postgres function (Phase 3+), which runs as the
-- table owner and bypasses RLS. This is what makes "the server stays
-- authoritative" true on a client-only Supabase stack — the functions *are*
-- the server, and the client literally cannot reach the tables any other way.

alter table games enable row level security;
alter table players enable row level security;
alter table questions enable row level security;
alter table game_questions enable row level security;
alter table answers enable row level security;

-- Helper: "is the current user a player in this game?"
--
-- This MUST be its own SECURITY DEFINER function rather than an inline
-- `exists (select 1 from players where ...)` inside the players policy
-- itself. A policy on `players` that queries `players` (even via a self-join
-- alias) makes Postgres re-evaluate the same RLS policy recursively and it
-- errors out with "infinite recursion detected in policy for relation
-- players" — caught while validating these migrations locally. Running the
-- membership check inside a SECURITY DEFINER function makes that inner
-- query execute as the function owner, which bypasses RLS entirely, so
-- there's no recursive policy evaluation.
create or replace function is_game_participant(target_game_id uuid)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1 from players
    where game_id = target_game_id and user_id = auth.uid()
  );
$$;

-- games: visible to the host, and to anyone who has already joined as a
-- player. A not-yet-joined client looking up a room code does NOT use this
-- policy — that lookup goes through a narrow SECURITY DEFINER function
-- (Phase 3) that returns only {exists, status, room_code}, so someone
-- probing room codes can't harvest full game rows.
create policy games_select_participant on games
  for select
  to authenticated
  using (
    host_user_id = auth.uid()
    or is_game_participant(games.id)
  );

-- players: visible to fellow players in the same game (lobby roster,
-- leaderboard). Prefer selecting from the `leaderboard` view in app code —
-- this table policy exists mainly so that view can resolve correctly and
-- for any direct-table reads the client genuinely needs (e.g. "am I host").
create policy players_select_same_game on players
  for select
  to authenticated
  using (is_game_participant(players.game_id));

-- questions: NO select policy at all. Direct table access is revoked in
-- 0006 regardless; RLS is enabled here too as defense in depth. All reads
-- go through the `questions_public` view (no correct_option/explanation) or,
-- for in-game delivery, a Phase 5 function scoped to the player's current
-- question only (so future questions in the same game aren't fetchable
-- early either).

-- game_questions: NO select policy. This table is server-internal — it
-- carries `shuffle_map`, which is exactly the thing a cheating client would
-- want. Only SECURITY DEFINER functions ever read it.

-- answers: a player may see only their own submissions. Aggregate stats
-- ("63% of players answered correctly") are computed by a SECURITY DEFINER
-- function in Phase 6, not by exposing other players' raw answer rows.
create policy answers_select_own on answers
  for select
  to authenticated
  using (
    exists (
      select 1 from players p
      where p.id = answers.player_id and p.user_id = auth.uid()
    )
  );
