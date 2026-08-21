-- Pinoy Quiz — 0007: create/join room functions
--
-- These are the first of the "the functions are the server" writes promised
-- in 0005/0006 — every table write in this app happens through a function
-- like these, never through a direct client INSERT/UPDATE. All of them
-- assume the caller already has an anonymous Supabase Auth session (see
-- ensureAnonymousSession() in src/lib/supabase.ts), so auth.uid() is never
-- null in normal use — the null check below is defense in depth.

-- Internal helper — not granted to any client role. Excludes visually
-- ambiguous characters (0/O, 1/I/L) so a room code is easy to read aloud
-- or type on a phone keyboard.
create or replace function generate_room_code()
returns text
language plpgsql
as $$
declare
  charset text := 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  result text := '';
  i int;
begin
  for i in 1..6 loop
    result := result || substr(charset, (floor(random() * length(charset)) + 1)::int, 1);
  end loop;
  return result;
end;
$$;


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


-- Narrow, pre-join lookup. Deliberately does NOT return the full `games`
-- row (no host_user_id, no id even) — just enough for the join screen to
-- show a friendly "this room doesn't exist" / "this game already started"
-- message before the player commits to joining. See docs/ARCHITECTURE.md.
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
stable
set search_path = public
as $$
declare
  v_game games%rowtype;
begin
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

  if char_length(v_nickname) < 1 or char_length(v_nickname) > 20 then
    raise exception 'Nickname must be between 1 and 20 characters.' using errcode = '22023';
  end if;

  select * into v_game from games where room_code = upper(trim(p_room_code));
  if not found then
    raise exception 'That room code doesn''t exist.' using errcode = 'P0002';
  end if;

  -- Reconnect: this browser (same anonymous auth session) already has a
  -- player row in this game. Rejoining always succeeds regardless of game
  -- status — a full disconnect/reconnect UX lands in Phase 8, but the data
  -- path belongs here since it's the same "arrive at this room" action.
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


-- Lock these down explicitly rather than relying on Postgres's default
-- "EXECUTE granted to PUBLIC on new functions" behavior.
revoke execute on function generate_room_code() from public;
revoke execute on function create_game(game_category_setting, game_difficulty_setting, smallint, smallint, text) from public;
revoke execute on function lookup_game_by_room_code(text) from public;
revoke execute on function join_game(text, text) from public;

grant execute on function create_game(game_category_setting, game_difficulty_setting, smallint, smallint, text) to authenticated;
grant execute on function lookup_game_by_room_code(text) to authenticated;
grant execute on function join_game(text, text) to authenticated;
