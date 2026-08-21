-- Pinoy Quiz — 0014: security + anti-cheat hardening (Phase 9)
--
-- Two things, matching the two concrete gaps docs/MASTER_HANDOFF.md's
-- Phase 9 section identified after reviewing the existing functions (this
-- migration does NOT touch submit_answer's scoring/timing logic — that
-- anti-cheat vector was already closed in Phase 6 by computing
-- response_time_ms server-side from games.question_started_at, never a
-- client-reported value; nothing here changes that).
--
-- 1. Rate limiting on every state-mutating SECURITY DEFINER function.
--    Decision (this determination was itself the Phase 9 work the handoff
--    asked for, not assumed either way going in): the SECURITY DEFINER +
--    RLS model closes *who can write what*, but it does nothing about
--    *how often* — every function's own correctness checks (right phase,
--    right caller, uniqueness constraints, etc.) still let a malicious
--    client call a function it's otherwise allowed to call as fast as a
--    tight loop can issue requests. Concretely, a bad client could:
--      - hammer `heartbeat`/`mark_stale_players` far faster than the 8s
--        interval the real client uses, burning DB connections/CPU on
--        pure overhead for no gain to that client (a real, if mild,
--        resource-exhaustion vector against a shared Postgres instance);
--      - spam `lookup_game_by_room_code` to brute-force 6-character room
--        codes (32^6 space, but still worth throttling — this is exactly
--        the enumeration vector docs/ARCHITECTURE.md's Security model
--        section flagged this function as needing "rate limiting" for,
--        left unaddressed when the function itself shipped in Phase 3);
--      - spam `create_game`/`join_game` to flood a room with junk rows or
--        exhaust the room-code space's collision retries.
--    None of these let a bad client corrupt *another* player's game state
--    (every function's existing checks still hold), so this is about
--    resource protection and enumeration resistance, not a data-integrity
--    hole — but it's a real gap worth closing, not a non-issue.
--
--    Mechanism: a small per-(user, action) sliding-window counter table +
--    one internal helper function, `enforce_rate_limit`, called at the top
--    of every mutating function (right after the existing "must be signed
--    in" check, before any real work happens). Deliberately NOT granted
--    EXECUTE to `authenticated` — it's meant to be called only from
--    *within* another SECURITY DEFINER function, the same
--    revoked-from-public-but-called-internally pattern
--    `generate_room_code()` already established in 0007_room_functions.sql.
--    Table is keyed on `auth.uid()`, so limits are per real user (browser's
--    anonymous auth session), not per game — a player in five simultaneous
--    games shares one budget per action, which is fine for this app's
--    actual usage pattern and simpler than per-game bookkeeping.
--
--    Chosen limits are generous multiples of each action's real client
--    cadence (see src/hooks/useHeartbeat.ts's 8s interval, GameRoom.tsx's
--    event-driven — not polled — fetches) so no legitimate client can ever
--    hit one, while still capping a tight-loop spammer at a small,
--    bounded multiple of normal traffic rather than unlimited.
--
-- 2. `claim_host` TOCTOU race (handoff item 2): the function read the
--    current host's `connected`/`last_seen_at` with a plain `select ...
--    into`, then later `update`d based on that snapshot. Between the read
--    and the write, nothing stopped the real host's own `heartbeat` call
--    from landing concurrently and refreshing `last_seen_at` — two
--    concurrent transactions could each read "stale" before either writes,
--    and the host gets demoted a moment after proving they're still there.
--    Fixed by taking `select ... for update` on the host's row up front,
--    so a concurrent `heartbeat` UPDATE on that same row and this
--    transaction serialize against each other instead of racing — whichever
--    commits first is what the other sees.

-- ---------------------------------------------------------------------
-- Rate limiting
-- ---------------------------------------------------------------------

create table rate_limit_hits (
  user_id uuid not null,
  action text not null,
  window_start timestamptz not null default now(),
  call_count integer not null default 1,
  primary key (user_id, action)
);

-- Defense in depth, matching every other table in this schema (0005/0006):
-- enable RLS with zero policies (blocks all client access outright) *and*
-- explicitly revoke table privileges, even though the only intended access
-- path is already the SECURITY DEFINER function below, which bypasses RLS
-- as the table owner regardless.
alter table rate_limit_hits enable row level security;
revoke all on rate_limit_hits from anon, authenticated;

-- enforce_rate_limit: internal helper, not part of the public API surface.
-- Upserts this (user, action) pair's counter: if the existing window has
-- expired, starts a fresh window at count 1; otherwise increments in
-- place. Raises once the incremented count exceeds p_max_calls. Single
-- upsert statement (no separate select-then-branch) so concurrent calls
-- from the same user racing each other still serialize correctly on the
-- table's primary key rather than both reading before either writes.
create or replace function enforce_rate_limit(
  p_action text,
  p_max_calls integer,
  p_window_seconds integer
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_row rate_limit_hits%rowtype;
begin
  if v_uid is null then
    raise exception 'You must be signed in.' using errcode = '28000';
  end if;

  insert into rate_limit_hits as r (user_id, action, window_start, call_count)
  values (v_uid, p_action, now(), 1)
  on conflict (user_id, action) do update
    set call_count = case
        when r.window_start < now() - (p_window_seconds || ' seconds')::interval
          then 1
        else r.call_count + 1
      end,
      window_start = case
        when r.window_start < now() - (p_window_seconds || ' seconds')::interval
          then now()
        else r.window_start
      end
  returning * into v_row;

  if v_row.call_count > p_max_calls then
    raise exception 'You are doing that too fast — please slow down and try again in a moment.'
      using errcode = 'P0429';
  end if;
end;
$$;

revoke execute on function enforce_rate_limit(text, integer, integer) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- Apply enforce_rate_limit to every mutating (and the one
-- enumeration-sensitive read-only) function. Each `create or replace`
-- reproduces the function's existing body verbatim from its original
-- migration with exactly one addition: the rate-limit call, placed
-- immediately after the "must be signed in" check. Signatures are
-- unchanged, so the grants each function already has from its own
-- migration still apply — no grant/revoke statements needed here.
-- ---------------------------------------------------------------------

-- 0007_room_functions.sql: room-code enumeration is the concrete risk for
-- lookup_game_by_room_code (see header comment above); create_game/
-- join_game get the same generous "way above normal use" treatment as
-- everything else.

create or replace function create_game(
  p_category game_category_setting default 'random',
  p_difficulty game_difficulty_setting default 'mixed',
  p_question_count smallint default 10,
  p_time_limit_seconds smallint default 15,
  p_host_nickname text default 'Host'
)
returns table (
  out_game_id uuid,
  out_room_code text,
  out_player_id uuid
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_room_code text;
  v_game_id uuid;
  v_player_id uuid;
  v_nickname text := trim(p_host_nickname);
  v_attempt int := 0;
begin
  if v_uid is null then
    raise exception 'You must be signed in to create a game.' using errcode = '28000';
  end if;

  perform enforce_rate_limit('create_game', 10, 60);

  if char_length(v_nickname) < 1 or char_length(v_nickname) > 20 then
    raise exception 'Nickname must be between 1 and 20 characters.' using errcode = '22023';
  end if;

  loop
    v_attempt := v_attempt + 1;
    v_room_code := generate_room_code();
    begin
      insert into games (room_code, host_user_id, category, difficulty, question_count, time_limit_seconds)
      values (v_room_code, v_uid, p_category, p_difficulty, p_question_count, p_time_limit_seconds)
      returning id into v_game_id;
      exit;
    exception when unique_violation then
      if v_attempt >= 10 then
        raise exception 'Could not allocate a room code — please try again.' using errcode = '55000';
      end if;
    end;
  end loop;

  insert into players (game_id, user_id, nickname, is_host)
  values (v_game_id, v_uid, v_nickname, true)
  returning id into v_player_id;

  return query select v_game_id, v_room_code, v_player_id;
end;
$$;


create or replace function lookup_game_by_room_code(p_room_code text)
returns table (
  found boolean,
  status game_status,
  category game_category_setting,
  difficulty game_difficulty_setting,
  question_count smallint,
  time_limit_seconds smallint
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_game games%rowtype;
begin
  -- Not `stable` anymore now that it calls enforce_rate_limit (which
  -- writes) — Postgres would reject a volatile-underneath function marked
  -- `stable`, so the qualifier is dropped here rather than left
  -- inaccurate. This function was never actually side-effect-free from
  -- the caller's perspective anyway (every call still hits the DB to look
  -- up live game state), so losing the planner hint costs nothing
  -- meaningful.
  if auth.uid() is null then
    raise exception 'You must be signed in.' using errcode = '28000';
  end if;

  perform enforce_rate_limit('lookup_game_by_room_code', 20, 60);

  select * into v_game from games where room_code = upper(trim(p_room_code));
  if not found then
    return query select false, null::game_status, null::game_category_setting,
      null::game_difficulty_setting, null::smallint, null::smallint;
    return;
  end if;
  return query select true, v_game.status, v_game.category, v_game.difficulty,
    v_game.question_count, v_game.time_limit_seconds;
end;
$$;


create or replace function join_game(
  p_room_code text,
  p_nickname text
)
returns table (
  out_game_id uuid,
  out_player_id uuid,
  out_status game_status,
  out_is_host boolean,
  out_reconnected boolean
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_game games%rowtype;
  v_existing players%rowtype;
  v_player_id uuid;
  v_nickname text := trim(p_nickname);
  v_player_count int;
  v_max_players constant int := 50;
begin
  if v_uid is null then
    raise exception 'You must be signed in to join a game.' using errcode = '28000';
  end if;

  perform enforce_rate_limit('join_game', 15, 60);

  if char_length(v_nickname) < 1 or char_length(v_nickname) > 20 then
    raise exception 'Nickname must be between 1 and 20 characters.' using errcode = '22023';
  end if;

  select * into v_game from games where room_code = upper(trim(p_room_code));
  if not found then
    raise exception 'That room code doesn''t exist.' using errcode = 'P0002';
  end if;

  select * into v_existing from players where game_id = v_game.id and user_id = v_uid;
  if found then
    update players
      set connected = true, last_seen_at = now()
      where id = v_existing.id
      returning id into v_player_id;
    return query select v_game.id, v_player_id, v_game.status, v_existing.is_host, true;
    return;
  end if;

  if v_game.status <> 'WAITING' then
    raise exception 'This game has already started.' using errcode = 'P0001';
  end if;

  if exists (
    select 1 from players where game_id = v_game.id and lower(nickname) = lower(v_nickname)
  ) then
    raise exception 'That nickname is already taken in this room.' using errcode = '23505';
  end if;

  select count(*) into v_player_count from players where game_id = v_game.id;
  if v_player_count >= v_max_players then
    raise exception 'This room is full.' using errcode = '53400';
  end if;

  insert into players (game_id, user_id, nickname, is_host)
  values (v_game.id, v_uid, v_nickname, false)
  returning id into v_player_id;

  return query select v_game.id, v_player_id, v_game.status, false, false;
end;
$$;


-- 0009_lobby_functions.sql

create or replace function remove_player(p_player_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_target players%rowtype;
  v_game games%rowtype;
begin
  if v_uid is null then
    raise exception 'You must be signed in.' using errcode = '28000';
  end if;

  perform enforce_rate_limit('remove_player', 30, 60);

  select * into v_target from players where id = p_player_id;
  if not found then
    raise exception 'That player has already left the room.' using errcode = 'P0002';
  end if;

  select * into v_game from games where id = v_target.game_id;

  if v_game.host_user_id <> v_uid then
    raise exception 'Only the host can remove players.' using errcode = '42501';
  end if;

  if v_target.user_id = v_uid then
    raise exception 'You can''t remove yourself — end the game instead.' using errcode = '22023';
  end if;

  delete from players where id = p_player_id;
end;
$$;


-- 0010_game_engine.sql

create or replace function start_game(p_game_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_game games%rowtype;
  v_player_count int;
  v_category_filter text;
  v_difficulty_filter text;
  v_question_ids uuid[];
  v_qid uuid;
  v_order smallint := 0;
begin
  if v_uid is null then
    raise exception 'You must be signed in.' using errcode = '28000';
  end if;

  perform enforce_rate_limit('start_game', 10, 30);

  select * into v_game from games where id = p_game_id;
  if not found then
    raise exception 'Game not found.' using errcode = 'P0002';
  end if;

  if v_game.host_user_id <> v_uid then
    raise exception 'Only the host can start the game.' using errcode = '42501';
  end if;

  if v_game.status <> 'WAITING' then
    raise exception 'This game has already started.' using errcode = 'P0001';
  end if;

  select count(*) into v_player_count from players where game_id = p_game_id;
  if v_player_count < 1 then
    raise exception 'You need at least one player to start.' using errcode = 'P0004';
  end if;

  v_category_filter := nullif(v_game.category::text, 'random');
  v_difficulty_filter := nullif(v_game.difficulty::text, 'mixed');

  select array_agg(id) into v_question_ids
  from (
    select id from questions
    where (v_category_filter is null or category::text = v_category_filter)
      and (v_difficulty_filter is null or difficulty::text = v_difficulty_filter)
    order by random()
    limit v_game.question_count
  ) sub;

  if v_question_ids is null or array_length(v_question_ids, 1) < v_game.question_count then
    raise exception 'Not enough questions available for these settings. Try Random category or Mixed difficulty.'
      using errcode = 'P0005';
  end if;

  foreach v_qid in array v_question_ids loop
    insert into game_questions (game_id, question_id, question_order, shuffle_map)
    values (
      p_game_id,
      v_qid,
      v_order,
      (select array(select x from unnest(array[0,1,2,3]::smallint[]) x order by random()))
    );
    v_order := v_order + 1;
  end loop;

  update games set status = 'COUNTDOWN', started_at = now() where id = p_game_id;
end;
$$;


create or replace function begin_first_question(p_game_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_game games%rowtype;
  v_gq_id uuid;
begin
  if v_uid is null then
    raise exception 'You must be signed in.' using errcode = '28000';
  end if;

  perform enforce_rate_limit('begin_first_question', 10, 10);

  select * into v_game from games where id = p_game_id;
  if not found then
    raise exception 'Game not found.' using errcode = 'P0002';
  end if;

  if v_game.host_user_id <> v_uid then
    raise exception 'Only the host can do that.' using errcode = '42501';
  end if;

  if v_game.status <> 'COUNTDOWN' then
    raise exception 'This game is not ready to begin.' using errcode = 'P0001';
  end if;

  select id into v_gq_id from game_questions
  where game_id = p_game_id and question_order = 0;

  if v_gq_id is null then
    raise exception 'No questions were prepared for this game.' using errcode = 'P0006';
  end if;

  update games
    set status = 'QUESTION',
        current_question_index = 0,
        current_question_id = v_gq_id,
        question_started_at = now()
    where id = p_game_id;
end;
$$;


-- 0011_answer_submission.sql

create or replace function submit_answer(p_game_id uuid, p_selected_option smallint)
returns table (
  out_is_correct boolean,
  out_points integer
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_game games%rowtype;
  v_player players%rowtype;
  v_gq game_questions%rowtype;
  v_q questions%rowtype;
  v_correct_index smallint;
  v_correct_slot smallint;
  v_is_correct boolean;
  v_response_ms integer;
  v_time_limit_ms integer;
  v_scoring jsonb;
  v_speed_ratio numeric;
  v_speed_bonus integer;
  v_points integer;
begin
  if v_uid is null then
    raise exception 'You must be signed in.' using errcode = '28000';
  end if;

  perform enforce_rate_limit('submit_answer', 15, 10);

  if p_selected_option is null or p_selected_option not between 0 and 3 then
    raise exception 'That is not a valid answer option.' using errcode = '22023';
  end if;

  select * into v_game from games where id = p_game_id;
  if not found then
    raise exception 'Game not found.' using errcode = 'P0002';
  end if;

  select * into v_player from players
    where game_id = p_game_id and user_id = v_uid;
  if not found then
    raise exception 'You are not part of this game.' using errcode = '42501';
  end if;

  if v_game.status <> 'QUESTION' or v_game.current_question_id is null then
    raise exception 'This question is no longer accepting answers.' using errcode = 'P0007';
  end if;

  if exists (
    select 1 from answers
    where game_id = p_game_id
      and player_id = v_player.id
      and question_id = (select question_id from game_questions where id = v_game.current_question_id)
  ) then
    raise exception 'You already answered this question.' using errcode = 'P0008';
  end if;

  select * into v_gq from game_questions where id = v_game.current_question_id;
  select * into v_q from questions where id = v_gq.question_id;

  v_correct_index := array_position(array['A','B','C','D'], v_q.correct_option::text) - 1;
  v_correct_slot := array_position(v_gq.shuffle_map, v_correct_index) - 1;
  v_is_correct := (p_selected_option = v_correct_slot);

  v_time_limit_ms := v_game.time_limit_seconds * 1000;
  v_response_ms := greatest(
    0,
    least(
      v_time_limit_ms,
      extract(epoch from (now() - v_game.question_started_at)) * 1000
    )
  )::integer;

  v_scoring := v_game.scoring_config;

  if v_is_correct then
    v_speed_ratio := 1 - (v_response_ms::numeric / greatest(v_time_limit_ms, 1));
    v_speed_bonus := round(
      (v_scoring->>'maxSpeedBonus')::numeric * greatest(0, least(1, v_speed_ratio))
    )::integer;
    v_points := (v_scoring->>'basePoints')::integer + v_speed_bonus;
  else
    v_points := (v_scoring->>'incorrectPoints')::integer;
  end if;

  insert into answers (
    game_id, player_id, question_id, selected_option,
    is_correct, response_time_ms, points
  ) values (
    p_game_id, v_player.id, v_q.id, p_selected_option,
    v_is_correct, v_response_ms, v_points
  );

  update players set score = score + v_points where id = v_player.id;

  return query select v_is_correct, v_points;
end;
$$;


create or replace function end_question(p_game_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_game games%rowtype;
  v_gq game_questions%rowtype;
  v_no_answer_points integer;
begin
  if v_uid is null then
    raise exception 'You must be signed in.' using errcode = '28000';
  end if;

  perform enforce_rate_limit('end_question', 10, 10);

  select * into v_game from games where id = p_game_id;
  if not found then
    raise exception 'Game not found.' using errcode = 'P0002';
  end if;

  if v_game.host_user_id <> v_uid then
    raise exception 'Only the host can do that.' using errcode = '42501';
  end if;

  if v_game.status <> 'QUESTION' or v_game.current_question_id is null then
    raise exception 'This game is not in the question phase.' using errcode = 'P0001';
  end if;

  select * into v_gq from game_questions where id = v_game.current_question_id;
  v_no_answer_points := (v_game.scoring_config->>'noAnswerPoints')::integer;

  insert into answers (game_id, player_id, question_id, selected_option, is_correct, response_time_ms, points)
  select p_game_id, p.id, v_gq.question_id, null, false, null, v_no_answer_points
  from players p
  where p.game_id = p_game_id
    and not exists (
      select 1 from answers a
      where a.game_id = p_game_id and a.player_id = p.id and a.question_id = v_gq.question_id
    );

  update games set status = 'REVEAL' where id = p_game_id;
end;
$$;


-- 0012_leaderboard.sql

create or replace function advance_to_leaderboard(p_game_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_game games%rowtype;
begin
  if v_uid is null then
    raise exception 'You must be signed in.' using errcode = '28000';
  end if;

  perform enforce_rate_limit('advance_to_leaderboard', 10, 10);

  select * into v_game from games where id = p_game_id;
  if not found then
    raise exception 'Game not found.' using errcode = 'P0002';
  end if;

  if v_game.host_user_id <> v_uid then
    raise exception 'Only the host can do that.' using errcode = '42501';
  end if;

  if v_game.status <> 'REVEAL' then
    raise exception 'This game is not in the reveal phase.' using errcode = 'P0001';
  end if;

  update games set status = 'LEADERBOARD' where id = p_game_id;
end;
$$;


create or replace function advance_question(p_game_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_game games%rowtype;
  v_next_index smallint;
  v_next_gq_id uuid;
begin
  if v_uid is null then
    raise exception 'You must be signed in.' using errcode = '28000';
  end if;

  perform enforce_rate_limit('advance_question', 10, 10);

  select * into v_game from games where id = p_game_id;
  if not found then
    raise exception 'Game not found.' using errcode = 'P0002';
  end if;

  if v_game.host_user_id <> v_uid then
    raise exception 'Only the host can do that.' using errcode = '42501';
  end if;

  if v_game.status <> 'LEADERBOARD' then
    raise exception 'This game is not on the leaderboard screen.' using errcode = 'P0001';
  end if;

  v_next_index := v_game.current_question_index + 1;

  if v_next_index < v_game.question_count then
    select id into v_next_gq_id from game_questions
      where game_id = p_game_id and question_order = v_next_index;

    if v_next_gq_id is null then
      raise exception 'No questions were prepared for this game.' using errcode = 'P0006';
    end if;

    update games
      set status = 'QUESTION',
          current_question_index = v_next_index,
          current_question_id = v_next_gq_id,
          question_started_at = now()
      where id = p_game_id;
  else
    update games
      set status = 'FINISHED',
          finished_at = now()
      where id = p_game_id;
  end if;
end;
$$;


-- 0013_disconnect_reconnect.sql — rate limiting, plus the claim_host
-- for-update race fix described in this migration's header comment.

create or replace function heartbeat(p_game_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'You must be signed in.' using errcode = '28000';
  end if;

  perform enforce_rate_limit('heartbeat', 20, 30);

  update players
    set connected = true, last_seen_at = now()
    where game_id = p_game_id and user_id = v_uid;

  if not found then
    raise exception 'You are not part of this game.' using errcode = '42501';
  end if;
end;
$$;


create or replace function mark_stale_players(p_game_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_stale_after constant interval := interval '20 seconds';
begin
  if v_uid is null then
    raise exception 'You must be signed in.' using errcode = '28000';
  end if;

  perform enforce_rate_limit('mark_stale_players', 20, 30);

  if not exists (select 1 from players where game_id = p_game_id and user_id = v_uid) then
    raise exception 'You are not part of this game.' using errcode = '42501';
  end if;

  update players
    set connected = false
    where game_id = p_game_id
      and connected = true
      and last_seen_at < now() - v_stale_after;
end;
$$;


create or replace function claim_host(p_game_id uuid)
returns table (
  out_new_host_player_id uuid,
  out_new_host_nickname text
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_game games%rowtype;
  v_host players%rowtype;
  v_candidate players%rowtype;
  v_stale_after constant interval := interval '20 seconds';
begin
  if v_uid is null then
    raise exception 'You must be signed in.' using errcode = '28000';
  end if;

  perform enforce_rate_limit('claim_host', 8, 30);

  select * into v_game from games where id = p_game_id;
  if not found then
    raise exception 'Game not found.' using errcode = 'P0002';
  end if;

  if not exists (select 1 from players where game_id = p_game_id and user_id = v_uid) then
    raise exception 'You are not part of this game.' using errcode = '42501';
  end if;

  if v_game.status = 'FINISHED' then
    raise exception 'This game has already finished.' using errcode = 'P0001';
  end if;

  -- `for update` locks the current host's row for the rest of this
  -- transaction. A concurrent `heartbeat()` call from the real host does a
  -- plain `update ... where ...` against this same row, so it will block
  -- until this transaction commits or rolls back rather than racing it —
  -- whichever of the two actually commits first is what the other sees,
  -- closing the TOCTOU gap described in this migration's header comment
  -- (previously: read host as "stale" here, host's own heartbeat lands
  -- before the update below, host gets demoted anyway).
  select * into v_host from players
    where game_id = p_game_id and is_host = true
    for update;
  if not found then
    raise exception 'This game has no host on record.' using errcode = 'P0007';
  end if;

  if v_host.user_id = v_uid then
    raise exception 'You are already the host.' using errcode = '22023';
  end if;

  if v_host.connected and v_host.last_seen_at >= now() - v_stale_after then
    raise exception 'The host is still connected.' using errcode = 'P0008';
  end if;

  select * into v_candidate
    from players
    where game_id = p_game_id
      and id <> v_host.id
      and connected = true
    order by joined_at asc
    limit 1;

  if not found then
    raise exception 'No other connected players are available to become host.'
      using errcode = 'P0009';
  end if;

  update players set is_host = false where id = v_host.id;
  update players set is_host = true where id = v_candidate.id;
  update games set host_user_id = v_candidate.user_id where id = p_game_id;

  return query select v_candidate.id, v_candidate.nickname;
end;
$$;
