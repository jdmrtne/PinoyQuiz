-- Pinoy Quiz — 0038: player avatars
--
-- Avatar selection (chibi character shown beside the quiz UI) previously
-- lived only in each browser's localStorage — a deliberate v1 choice to
-- avoid touching the schema. This migration makes it a first-class player
-- attribute so every player in a room can see which character everyone
-- else picked (lobby roster, reveal, leaderboard), matching how nickname
-- already works.
--
-- The catalog of valid avatar ids lives in the frontend
-- (src/data/avatars.ts), not here — the check constraint only enforces
-- the *shape* ("avatar-" + 2 digits), not a fixed list, so adding
-- avatar-21+ later needs zero migration work. An id that's well-formed
-- but not (yet) in the frontend catalog just fails closed to nothing
-- rendered (see getAvatarById) rather than an error.

alter table players
  add column if not exists avatar_id text not null default 'avatar-01';

alter table players
  add constraint players_avatar_id_format
  check (avatar_id ~ '^avatar-[0-9]{2}$');

comment on column players.avatar_id is
  'Chosen character id, e.g. "avatar-01" — see src/data/avatars.ts for the catalog. Purely cosmetic; never used server-side for anything but pass-through.';

-- No RLS change needed: players_select_same_game (0005_rls.sql) already
-- exposes every column, including this new one, to the rest of the room.


-- =======================================================================
-- 1. create_game — same body as 0036's version, +p_avatar_id.
-- =======================================================================
create or replace function create_game(
  p_category game_category_setting default 'random',
  p_difficulty game_difficulty_setting default 'mixed',
  p_question_count smallint default 10,
  p_time_limit_seconds smallint default 15,
  p_host_nickname text default 'Host',
  p_game_mode game_mode default 'HOST_CONTROLLED',
  p_answer_behavior answer_behavior default 'LOCK_ON_SELECTION',
  p_categories question_category[] default null,
  p_include_new_question_types boolean default false,
  p_enabled_question_types question_type[] default null,
  p_timing_strategy timing_strategy default 'fixed',
  p_avatar_id text default 'avatar-01'
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
  v_avatar_id text := coalesce(nullif(trim(p_avatar_id), ''), 'avatar-01');
  v_attempt int := 0;
  v_categories question_category[] := nullif(p_categories, array[]::question_category[]);
begin
  if v_uid is null then
    raise exception 'You must be signed in to create a game.' using errcode = '28000';
  end if;

  perform enforce_rate_limit('create_game', 10, 60);

  if char_length(v_nickname) < 1 or char_length(v_nickname) > 20 then
    raise exception 'Nickname must be between 1 and 20 characters.' using errcode = '22023';
  end if;

  if v_avatar_id !~ '^avatar-[0-9]{2}$' then
    raise exception 'That is not a valid avatar.' using errcode = '22023';
  end if;

  if v_categories is not null and array_length(v_categories, 1) > 30 then
    raise exception 'Select fewer categories.' using errcode = '22023';
  end if;

  loop
    v_attempt := v_attempt + 1;
    v_room_code := generate_room_code();
    begin
      insert into games (
        room_code, host_user_id, category, difficulty, question_count,
        time_limit_seconds, game_mode, answer_behavior, categories,
        include_new_question_types, enabled_question_types, timing_strategy
      )
      values (
        v_room_code, v_uid, p_category, p_difficulty, p_question_count,
        p_time_limit_seconds, p_game_mode, p_answer_behavior, v_categories,
        p_include_new_question_types, nullif(p_enabled_question_types, array[]::question_type[]),
        p_timing_strategy
      )
      returning id into v_game_id;
      exit;
    exception when unique_violation then
      if v_attempt >= 10 then
        raise exception 'Could not allocate a room code — please try again.' using errcode = '55000';
      end if;
    end;
  end loop;

  insert into players (game_id, user_id, nickname, is_host, avatar_id)
  values (v_game_id, v_uid, v_nickname, true, v_avatar_id)
  returning id into v_player_id;

  return query select v_game_id, v_room_code, v_player_id;
end;
$$;

grant execute on function create_game(
  game_category_setting, game_difficulty_setting, smallint, smallint, text,
  game_mode, answer_behavior, question_category[], boolean, question_type[], timing_strategy, text
) to authenticated;

-- Drop the previous 11-arg overload — Postgres treats a changed argument
-- list as a distinct function, and PostgREST's RPC lookup needs exactly
-- one create_game candidate to resolve `supabase.rpc("create_game", ...)`
-- unambiguously (same pattern followed by every prior migration that
-- extended this function's signature).
drop function if exists create_game(
  game_category_setting, game_difficulty_setting, smallint, smallint, text,
  game_mode, answer_behavior, question_category[], boolean, question_type[], timing_strategy
);


-- =======================================================================
-- 2. join_game — same body as 0014's version, +p_avatar_id. On a fresh
-- join the avatar is stored with the new player row. On *reconnect*
-- (existing player row for this user+game), the avatar is refreshed too —
-- if they changed their pick since last time, that follows them in.
-- =======================================================================
create or replace function join_game(
  p_room_code text,
  p_nickname text,
  p_avatar_id text default 'avatar-01'
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
  v_avatar_id text := coalesce(nullif(trim(p_avatar_id), ''), 'avatar-01');
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

  if v_avatar_id !~ '^avatar-[0-9]{2}$' then
    raise exception 'That is not a valid avatar.' using errcode = '22023';
  end if;

  select * into v_game from games where room_code = upper(trim(p_room_code));
  if not found then
    raise exception 'That room code doesn''t exist.' using errcode = 'P0002';
  end if;

  select * into v_existing from players where game_id = v_game.id and user_id = v_uid;
  if found then
    update players
      set connected = true, last_seen_at = now(), avatar_id = v_avatar_id
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

  insert into players (game_id, user_id, nickname, is_host, avatar_id)
  values (v_game.id, v_uid, v_nickname, false, v_avatar_id)
  returning id into v_player_id;

  return query select v_game.id, v_player_id, v_game.status, false, false;
end;
$$;

grant execute on function join_game(text, text, text) to authenticated;

drop function if exists join_game(text, text);


-- =======================================================================
-- 3. set_player_avatar — lets a player change their character while
-- still in the lobby, without a full rejoin. Deliberately WAITING-only:
-- once play has started, mid-game avatar swaps would just be confusing
-- (and pointless — GameAvatar only ever renders the picker's own choice).
-- =======================================================================
create or replace function set_player_avatar(
  p_player_id uuid,
  p_avatar_id text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_player players%rowtype;
  v_game games%rowtype;
  v_avatar_id text := coalesce(nullif(trim(p_avatar_id), ''), '');
begin
  if v_uid is null then
    raise exception 'You must be signed in to do that.' using errcode = '28000';
  end if;

  perform enforce_rate_limit('set_player_avatar', 20, 60);

  if v_avatar_id !~ '^avatar-[0-9]{2}$' then
    raise exception 'That is not a valid avatar.' using errcode = '22023';
  end if;

  select * into v_player from players where id = p_player_id;
  if not found or v_player.user_id <> v_uid then
    raise exception 'You are not part of this game.' using errcode = '42501';
  end if;

  select * into v_game from games where id = v_player.game_id;
  if v_game.status <> 'WAITING' then
    raise exception 'You can only change your character in the lobby.' using errcode = 'P0001';
  end if;

  update players set avatar_id = v_avatar_id where id = p_player_id;
end;
$$;

grant execute on function set_player_avatar(uuid, text) to authenticated;


-- =======================================================================
-- 4. leaderboard view — add avatar_id so Reveal/Leaderboard screens can
-- show each player's character alongside their score, same as nickname.
-- =======================================================================
-- Postgres's CREATE OR REPLACE VIEW only allows new columns to be appended
-- at the end of the output list — inserting avatar_id earlier (e.g. next
-- to nickname) shifts every later column's position and gets rejected as
-- an implicit rename (42P16). So avatar_id goes after `rank` here, even
-- though conceptually it reads more naturally beside nickname.
create or replace view leaderboard as
select
  p.id as player_id,
  p.game_id,
  p.nickname,
  p.score,
  p.is_host,
  p.connected,
  rank() over (partition by p.game_id order by p.score desc, p.joined_at asc) as rank,
  p.avatar_id
from players p;
