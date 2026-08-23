-- Pinoy Quiz — 0022: host-selectable custom category mix
--
-- Phase 17. Adds a second, independent way to scope which questions a game
-- draws from: instead of the existing single `category` setting (one fixed
-- category, or 'random' meaning "any category"), the host can now pick a
-- specific SET of categories and get a random draw restricted to just that
-- set — "random, but custom" per the feature request.
--
-- Design: a new nullable column, `games.categories question_category[]`,
-- sitting alongside the existing `category game_category_setting` column
-- rather than replacing it.
--   - `categories` is null (or empty) for every game created before this
--     migration, and for any new game that doesn't use the feature — those
--     games behave EXACTLY as before, filtered by the single `category`
--     column (with 'random' meaning no filter). This is why the column is
--     nullable with no default rather than `not null default '{}'`: null
--     unambiguously means "the old single-category behavior applies",
--     distinct from an explicit-but-empty selection.
--   - When `categories` IS set (non-null and non-empty), it takes priority
--     over `category` for actual question selection — start_game and
--     play_again both filter `category = any(games.categories)` instead of
--     the single-value comparison. `category` itself is still stored as
--     whatever the client sent (expected to be 'random', since the whole
--     point is an unconstrained-except-for-the-set draw) purely so every
--     existing "what's this game's category?" read (lookup_game_by_room_code
--     pre-join, the games-table row GameRoom.tsx already subscribes to)
--     keeps returning a value without a schema change to those call sites
--     beyond the additive `categories` field below.
--   - Uses `question_category`, NOT `game_category_setting` — the array can
--     only ever contain real, question-bearing categories (never 'random'
--     itself), so it reuses the enum that already carries that exact
--     constraint (see 0002_enums.sql's comment on the two-enum split).
--
-- create_game's signature grows by one (defaulted) param, same situation
-- 0015 documented: CREATE OR REPLACE cannot widen a function's own argument
-- list, so the old signature is dropped explicitly before the replacement
-- is created. lookup_game_by_room_code's OUTPUT columns grow too (adding
-- `categories`), which is the same kind of identity change for a
-- `returns table (...)` function — dropped and recreated for the same
-- reason. start_game and play_again both keep their existing signatures
-- (still just `p_game_id uuid`), so those are plain `create or replace`.

alter table games add column categories question_category[];

comment on column games.categories is
  'Host-selected category subset for a "custom mix" game (0022). Null/empty means the single `category` column governs selection as before. When set, question draws filter to `category = any(categories)` instead.';

-- ---------------------------------------------------------------------
-- create_game — adds p_categories, stored as-is (no filtering logic here;
-- selection happens later, in start_game).
-- ---------------------------------------------------------------------

drop function if exists create_game(
  game_category_setting, game_difficulty_setting, smallint, smallint, text, game_mode, answer_behavior
);

create or replace function create_game(
  p_category game_category_setting default 'random',
  p_difficulty game_difficulty_setting default 'mixed',
  p_question_count smallint default 10,
  p_time_limit_seconds smallint default 15,
  p_host_nickname text default 'Host',
  p_game_mode game_mode default 'HOST_CONTROLLED',
  p_answer_behavior answer_behavior default 'LOCK_ON_SELECTION',
  p_categories question_category[] default null
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
  -- Empty array is treated the same as null (no custom selection) —
  -- collapse it here so start_game/play_again only ever need one check.
  v_categories question_category[] := nullif(p_categories, array[]::question_category[]);
begin
  if v_uid is null then
    raise exception 'You must be signed in to create a game.' using errcode = '28000';
  end if;

  perform enforce_rate_limit('create_game', 10, 60);

  if char_length(v_nickname) < 1 or char_length(v_nickname) > 20 then
    raise exception 'Nickname must be between 1 and 20 characters.' using errcode = '22023';
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
        time_limit_seconds, game_mode, answer_behavior, categories
      )
      values (
        v_room_code, v_uid, p_category, p_difficulty, p_question_count,
        p_time_limit_seconds, p_game_mode, p_answer_behavior, v_categories
      )
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

grant execute on function create_game(
  game_category_setting, game_difficulty_setting, smallint, smallint, text,
  game_mode, answer_behavior, question_category[]
) to authenticated;

-- ---------------------------------------------------------------------
-- lookup_game_by_room_code — adds `categories` to the pre-join info so
-- JoinGame.tsx can show "Custom Mix" (or the category list) before the
-- player commits to joining, same as it already shows `category` today.
-- ---------------------------------------------------------------------

drop function if exists lookup_game_by_room_code(text);

create or replace function lookup_game_by_room_code(p_room_code text)
returns table (
  found boolean,
  status game_status,
  category game_category_setting,
  categories question_category[],
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
  -- Not `stable` — see 0014_security_hardening.sql's comment on this
  -- function for why (enforce_rate_limit writes, so the qualifier would
  -- be inaccurate).
  if auth.uid() is null then
    raise exception 'You must be signed in.' using errcode = '28000';
  end if;

  perform enforce_rate_limit('lookup_game_by_room_code', 20, 60);

  select * into v_game from games where room_code = upper(trim(p_room_code));
  if not found then
    return query select false, null::game_status, null::game_category_setting,
      null::question_category[], null::game_difficulty_setting, null::smallint, null::smallint;
    return;
  end if;
  return query select true, v_game.status, v_game.category, v_game.categories,
    v_game.difficulty, v_game.question_count, v_game.time_limit_seconds;
end;
$$;

grant execute on function lookup_game_by_room_code(text) to authenticated;

-- ---------------------------------------------------------------------
-- start_game — same fresh/top-up two-pass draw from 0016, now filtering on
-- `categories` (when set) instead of the single `category` value.
-- ---------------------------------------------------------------------

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
  v_use_custom_categories boolean;
  v_category_filter text;
  v_difficulty_filter text;
  v_total_available int;
  v_fresh_ids uuid[];
  v_topup_ids uuid[];
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

  -- Custom mix (0022) takes priority over the single `category` column
  -- whenever the host picked one. Otherwise, fall back to the original
  -- single-value-or-random filter exactly as before this migration.
  v_use_custom_categories := v_game.categories is not null and array_length(v_game.categories, 1) > 0;
  v_category_filter := nullif(v_game.category::text, 'random');
  v_difficulty_filter := nullif(v_game.difficulty::text, 'mixed');

  select count(*) into v_total_available
  from questions
  where (
      (v_use_custom_categories and category = any(v_game.categories))
      or (not v_use_custom_categories and (v_category_filter is null or category::text = v_category_filter))
    )
    and (v_difficulty_filter is null or difficulty::text = v_difficulty_filter);

  if v_total_available < v_game.question_count then
    raise exception 'Not enough questions available for these settings. Try Random category or Mixed difficulty.'
      using errcode = 'P0005';
  end if;

  select array_agg(id) into v_fresh_ids
  from (
    select id from questions
    where (
        (v_use_custom_categories and category = any(v_game.categories))
        or (not v_use_custom_categories and (v_category_filter is null or category::text = v_category_filter))
      )
      and (v_difficulty_filter is null or difficulty::text = v_difficulty_filter)
      and id not in (select question_id from game_questions where game_id = p_game_id)
    order by random()
    limit v_game.question_count
  ) sub;

  v_question_ids := coalesce(v_fresh_ids, array[]::uuid[]);

  if coalesce(array_length(v_question_ids, 1), 0) < v_game.question_count then
    select array_agg(id) into v_topup_ids
    from (
      select id from questions
      where (
          (v_use_custom_categories and category = any(v_game.categories))
          or (not v_use_custom_categories and (v_category_filter is null or category::text = v_category_filter))
        )
        and (v_difficulty_filter is null or difficulty::text = v_difficulty_filter)
        and not (id = any(v_question_ids))
      order by random()
      limit (v_game.question_count - coalesce(array_length(v_question_ids, 1), 0))
    ) sub;
    v_question_ids := v_question_ids || coalesce(v_topup_ids, array[]::uuid[]);
  end if;

  foreach v_qid in array v_question_ids loop
    insert into game_questions (game_id, question_id, question_order, round_number, shuffle_map)
    values (
      p_game_id,
      v_qid,
      v_order,
      v_game.round_number,
      (select array(select x from unnest(array[0,1,2,3]::smallint[]) x order by random()))
    );
    v_order := v_order + 1;
  end loop;

  update games set status = 'COUNTDOWN', started_at = now(), phase_started_at = now() where id = p_game_id;
end;
$$;

-- Note: play_again (0016) is untouched — it only resets the row to WAITING
-- and bumps round_number; it does no question selection itself. The next
-- start_game call (already updated above) does the actual draw for the new
-- round, so it automatically respects `categories` on a rematch too.
