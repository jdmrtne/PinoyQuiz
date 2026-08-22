-- Pinoy Quiz — 0016: Play Again (rematch in the same room) + avoid
-- repeating questions
--
-- Two related bugs reported against the live app, both fixed together
-- because the second fix only works cleanly once the first exists:
--
-- 1. "Play Again" (Results.tsx) just linked to /create — a brand new room,
--    new room code, new invite link, every player (including the host)
--    having to rejoin and retype their nickname. There was no way to
--    replay in the same room at all.
-- 2. Every game (including a hypothetical rematch) drew its question set
--    with a single `order by random() limit question_count` against the
--    *entire* filtered pool, with zero memory of what any previous game
--    — in this room or otherwise — had already used. With a real pool
--    that's often much smaller than 240 once category/difficulty narrow
--    it down (e.g. a single category+difficulty combo can be well under
--    20 questions), repeats inside a handful of replays are expected, not
--    a bug in the random() call itself — the actual bug is that nothing
--    ever *avoided* them.
--
-- ---------------------------------------------------------------------
-- Design: same games.id and room_code, a new round_number
-- ---------------------------------------------------------------------
--
-- The fix for (1) is deliberately NOT "create a new games row and give it
-- the same room_code" — room_code has a global unique index
-- (0003_tables.sql), so two live rows could never share one anyway, and
-- reusing a code only after the first row's `players` were migrated over
-- would be a much bigger, riskier change than this bug calls for.
--
-- Instead, `play_again()` resets the SAME games row back to WAITING and
-- increments a new `games.round_number` column. Since `players.game_id`
-- never changes, every player's row — nickname, is_host, connected,
-- everything — simply carries over untouched. No rejoin, no re-typed
-- nickname, no new room code to re-share: the room the players are
-- already sitting in (and already subscribed to via Realtime) just goes
-- back to its lobby. `start_game` (unchanged host action) is what the
-- host clicks to kick off the next round, exactly like the first one.
--
-- `round_number` also solves (2) directly: `game_questions` and `answers`
-- both gain the same column, and `start_game`'s question-selection query
-- now excludes every `question_id` already used anywhere in this
-- `game_id`'s history (across all previous rounds) before falling back to
-- allowing repeats — only once the "never used in this room" pool is
-- actually exhausted. A game's first-ever round has no history yet, so
-- this is a no-op there; it only changes behavior from round 2 onward.
--
-- Every function that reads/writes `game_questions`/`answers` scoped to
-- "the current question" now also scopes by `round_number` — without
-- that, a question repeating in round 3 would collide with its own
-- leftover `answers` row from round 1 (wrong `already answered` rejection
-- under LOCK_ON_SELECTION, wrong upsert target under
-- CHANGE_UNTIL_TIMER_ENDS, wrong percent-correct in `get_answer_reveal`,
-- wrong score_delta in `get_leaderboard`). Existing rows from prior rounds
-- are never deleted — they're both harmless history and exactly the data
-- `start_game`'s "already used" exclusion query depends on.
--
-- `players.score` is reset to 0 for a new round — "Play Again" starts a
-- fresh scoreboard, not a running cumulative total across rounds. If a
-- future request wants a cumulative "best of N rounds" mode instead,
-- that's a different, larger feature (persistent per-round history UI,
-- an aggregate leaderboard function) — not assumed here.
--
-- ---------------------------------------------------------------------
-- Backward compatibility
-- ---------------------------------------------------------------------
--
-- `round_number` is a `not null default 1` column on all three tables, so
-- every existing row reads as round 1 — exactly what it already was.
-- `start_game`'s new "exclude previously-used questions" clause is a
-- no-op for any game_id with no game_questions history yet (every game
-- that has never been replayed), so round-1 behavior for both new and
-- already-in-flight games is unchanged other than the query shape itself.

-- ---------------------------------------------------------------------
-- Schema
-- ---------------------------------------------------------------------

alter table games
  add column round_number smallint not null default 1,
  add constraint games_round_number_positive check (round_number >= 1);

alter table game_questions
  add column round_number smallint not null default 1;

alter table game_questions
  drop constraint game_questions_order_unique,
  drop constraint game_questions_no_dupes,
  add constraint game_questions_order_unique unique (game_id, round_number, question_order),
  add constraint game_questions_no_dupes unique (game_id, round_number, question_id);

alter table answers
  add column round_number smallint not null default 1;

alter table answers
  drop constraint answers_one_per_player_per_question,
  add constraint answers_one_per_player_per_question unique (game_id, round_number, player_id, question_id);

drop index if exists answers_game_question_idx;
create index answers_game_question_idx on answers (game_id, round_number, question_id);

-- ---------------------------------------------------------------------
-- start_game — now round_number-aware and repeat-avoiding. Everything
-- else (auth/host/status/player-count checks, phase_started_at anchor
-- from 0015) is unchanged.
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

  v_category_filter := nullif(v_game.category::text, 'random');
  v_difficulty_filter := nullif(v_game.difficulty::text, 'mixed');

  select count(*) into v_total_available
  from questions
  where (v_category_filter is null or category::text = v_category_filter)
    and (v_difficulty_filter is null or difficulty::text = v_difficulty_filter);

  if v_total_available < v_game.question_count then
    raise exception 'Not enough questions available for these settings. Try Random category or Mixed difficulty.'
      using errcode = 'P0005';
  end if;

  -- Prefer questions never used before anywhere in this room's history
  -- (any earlier round of this same game_id) — see this migration's
  -- header comment. A brand-new game has no history, so this simply
  -- draws from the full filtered pool, same as before this migration.
  select array_agg(id) into v_fresh_ids
  from (
    select id from questions
    where (v_category_filter is null or category::text = v_category_filter)
      and (v_difficulty_filter is null or difficulty::text = v_difficulty_filter)
      and id not in (select question_id from game_questions where game_id = p_game_id)
    order by random()
    limit v_game.question_count
  ) sub;

  v_question_ids := coalesce(v_fresh_ids, array[]::uuid[]);

  if coalesce(array_length(v_question_ids, 1), 0) < v_game.question_count then
    -- The "never used in this room" pool ran out (a small category pool,
    -- or a room several rounds deep) — top up from the full filtered
    -- pool, excluding whatever this draw already picked so a single
    -- round never shows the same question twice. A top-up pick MAY
    -- repeat a question from an earlier round; that's expected and only
    -- happens once every fresh option has already been used.
    select array_agg(id) into v_topup_ids
    from (
      select id from questions
      where (v_category_filter is null or category::text = v_category_filter)
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

-- ---------------------------------------------------------------------
-- submit_answer — round-scoped existing-answer check/upsert target.
-- ---------------------------------------------------------------------

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
  v_existing answers%rowtype;
begin
  if v_uid is null then
    raise exception 'You must be signed in.' using errcode = '28000';
  end if;

  perform enforce_rate_limit('submit_answer', 30, 10);

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

  if now() >= v_game.question_started_at + make_interval(secs => v_game.time_limit_seconds) then
    raise exception 'This question is no longer accepting answers.' using errcode = 'P0007';
  end if;

  select * into v_gq from game_questions where id = v_game.current_question_id;
  select * into v_q from questions where id = v_gq.question_id;

  select * into v_existing from answers
    where game_id = p_game_id
      and round_number = v_game.round_number
      and player_id = v_player.id
      and question_id = v_q.id;

  if found then
    if v_game.answer_behavior = 'LOCK_ON_SELECTION' then
      raise exception 'You already answered this question.' using errcode = 'P0008';
    end if;
    -- CHANGE_UNTIL_TIMER_ENDS: fall through and upsert below.
  end if;

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
    game_id, round_number, player_id, question_id, selected_option,
    is_correct, response_time_ms, points
  ) values (
    p_game_id, v_game.round_number, v_player.id, v_q.id, p_selected_option,
    v_is_correct, v_response_ms, v_points
  )
  on conflict (game_id, round_number, player_id, question_id) do update
    set selected_option = excluded.selected_option,
        is_correct = excluded.is_correct,
        response_time_ms = excluded.response_time_ms,
        points = excluded.points;

  update players
    set score = score + (v_points - coalesce(v_existing.points, 0))
    where id = v_player.id;

  return query select v_is_correct, v_points;
end;
$$;

-- ---------------------------------------------------------------------
-- end_question — round-scoped no-answer insert/check.
-- ---------------------------------------------------------------------

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

  insert into answers (game_id, round_number, player_id, question_id, selected_option, is_correct, response_time_ms, points)
  select p_game_id, v_game.round_number, p.id, v_gq.question_id, null, false, null, v_no_answer_points
  from players p
  where p.game_id = p_game_id
    and not exists (
      select 1 from answers a
      where a.game_id = p_game_id
        and a.round_number = v_game.round_number
        and a.player_id = p.id
        and a.question_id = v_gq.question_id
    );

  update games set status = 'REVEAL', phase_started_at = now() where id = p_game_id;
end;
$$;

-- ---------------------------------------------------------------------
-- get_answer_reveal — round-scoped own-answer lookup and percent-correct.
-- ---------------------------------------------------------------------

create or replace function get_answer_reveal(p_game_id uuid)
returns table (
  out_question_id uuid,
  out_correct_option smallint,
  out_correct_text text,
  out_explanation text,
  out_your_answer smallint,
  out_your_points integer,
  out_was_correct boolean,
  out_percent_correct numeric
)
language plpgsql
security definer
stable
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_game games%rowtype;
  v_player players%rowtype;
  v_gq game_questions%rowtype;
  v_q questions%rowtype;
  v_opts text[];
  v_correct_index smallint;
  v_correct_slot smallint;
  v_answer answers%rowtype;
  v_total_players int;
  v_correct_count int;
begin
  if v_uid is null then
    raise exception 'You must be signed in.' using errcode = '28000';
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

  if v_game.status <> 'REVEAL' or v_game.current_question_id is null then
    return;
  end if;

  select * into v_gq from game_questions where id = v_game.current_question_id;
  select * into v_q from questions where id = v_gq.question_id;
  v_opts := array[v_q.option_a, v_q.option_b, v_q.option_c, v_q.option_d];

  v_correct_index := array_position(array['A','B','C','D'], v_q.correct_option::text) - 1;
  v_correct_slot := array_position(v_gq.shuffle_map, v_correct_index) - 1;

  select * into v_answer from answers
    where game_id = p_game_id
      and round_number = v_game.round_number
      and player_id = v_player.id
      and question_id = v_q.id;

  select count(*) into v_total_players from players where game_id = p_game_id;
  select count(*) into v_correct_count from answers
    where game_id = p_game_id
      and round_number = v_game.round_number
      and question_id = v_q.id
      and is_correct;

  return query select
    v_q.id,
    v_correct_slot,
    v_opts[v_correct_index + 1],
    v_q.explanation,
    v_answer.selected_option,
    coalesce(v_answer.points, 0),
    coalesce(v_answer.is_correct, false),
    case when v_total_players > 0
      then round(100.0 * v_correct_count / v_total_players, 1)
      else 0
    end;
end;
$$;

-- ---------------------------------------------------------------------
-- get_leaderboard — round-scoped score_delta join.
-- ---------------------------------------------------------------------

create or replace function get_leaderboard(p_game_id uuid)
returns table (
  out_player_id uuid,
  out_nickname text,
  out_score integer,
  out_rank bigint,
  out_score_delta integer
)
language plpgsql
security definer
stable
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_game games%rowtype;
  v_last_question_id uuid;
begin
  if v_uid is null then
    raise exception 'You must be signed in.' using errcode = '28000';
  end if;

  select * into v_game from games where id = p_game_id;
  if not found then
    raise exception 'Game not found.' using errcode = 'P0002';
  end if;

  if not exists (select 1 from players where game_id = p_game_id and user_id = v_uid) then
    raise exception 'You are not part of this game.' using errcode = '42501';
  end if;

  if v_game.current_question_id is not null then
    select question_id into v_last_question_id
    from game_questions where id = v_game.current_question_id;
  end if;

  return query
    select
      p.id,
      p.nickname,
      p.score,
      rank() over (order by p.score desc, p.joined_at asc),
      coalesce(a.points, 0)
    from players p
    left join answers a
      on a.player_id = p.id
      and a.game_id = p_game_id
      and a.round_number = v_game.round_number
      and a.question_id = v_last_question_id
    where p.game_id = p_game_id
    order by rank() over (order by p.score desc, p.joined_at asc);
end;
$$;

-- ---------------------------------------------------------------------
-- auto_advance_game — round-scoped no-answer insert (its QUESTION branch
-- duplicates end_question's logic — see 0015's header comment for why).
-- Everything else is unchanged from 0015.
-- ---------------------------------------------------------------------

create or replace function auto_advance_game(p_game_id uuid)
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
  v_next_index smallint;
  v_next_gq_id uuid;
  countdown_seconds constant int := 3;
  reveal_seconds constant int := 6;
  leaderboard_seconds constant int := 5;
begin
  if v_uid is null then
    raise exception 'You must be signed in.' using errcode = '28000';
  end if;

  perform enforce_rate_limit('auto_advance_game', 60, 20);

  select * into v_game from games where id = p_game_id for update;
  if not found then
    raise exception 'Game not found.' using errcode = 'P0002';
  end if;

  if not exists (select 1 from players where game_id = p_game_id and user_id = v_uid) then
    raise exception 'You are not part of this game.' using errcode = '42501';
  end if;

  if v_game.game_mode <> 'AUTOMATIC' then
    return;
  end if;

  if v_game.status = 'COUNTDOWN' then
    if v_game.phase_started_at is null
      or now() < v_game.phase_started_at + make_interval(secs => countdown_seconds)
    then
      return;
    end if;

    select id into v_next_gq_id from game_questions
      where game_id = p_game_id and round_number = v_game.round_number and question_order = 0;

    if v_next_gq_id is null then
      raise exception 'No questions were prepared for this game.' using errcode = 'P0006';
    end if;

    update games
      set status = 'QUESTION',
          current_question_index = 0,
          current_question_id = v_next_gq_id,
          question_started_at = now()
      where id = p_game_id;
    return;
  end if;

  if v_game.status = 'QUESTION' then
    if v_game.question_started_at is null
      or now() < v_game.question_started_at + make_interval(secs => v_game.time_limit_seconds)
    then
      return;
    end if;

    select * into v_gq from game_questions where id = v_game.current_question_id;
    v_no_answer_points := (v_game.scoring_config->>'noAnswerPoints')::integer;

    insert into answers (game_id, round_number, player_id, question_id, selected_option, is_correct, response_time_ms, points)
    select p_game_id, v_game.round_number, p.id, v_gq.question_id, null, false, null, v_no_answer_points
    from players p
    where p.game_id = p_game_id
      and not exists (
        select 1 from answers a
        where a.game_id = p_game_id
          and a.round_number = v_game.round_number
          and a.player_id = p.id
          and a.question_id = v_gq.question_id
      );

    update games set status = 'REVEAL', phase_started_at = now() where id = p_game_id;
    return;
  end if;

  if v_game.status = 'REVEAL' then
    if v_game.phase_started_at is null
      or now() < v_game.phase_started_at + make_interval(secs => reveal_seconds)
    then
      return;
    end if;

    update games set status = 'LEADERBOARD', phase_started_at = now() where id = p_game_id;
    return;
  end if;

  if v_game.status = 'LEADERBOARD' then
    if v_game.phase_started_at is null
      or now() < v_game.phase_started_at + make_interval(secs => leaderboard_seconds)
    then
      return;
    end if;

    v_next_index := v_game.current_question_index + 1;

    if v_next_index < v_game.question_count then
      select id into v_next_gq_id from game_questions
        where game_id = p_game_id and round_number = v_game.round_number and question_order = v_next_index;

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
    return;
  end if;
end;
$$;

-- ---------------------------------------------------------------------
-- play_again — new. Host-only, only once FINISHED. Resets the SAME games
-- row (same id, same room_code) back to WAITING with a fresh
-- round_number and every player's score zeroed, WITHOUT touching the
-- players table at all — see this migration's header comment.
-- ---------------------------------------------------------------------

create or replace function play_again(p_game_id uuid)
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

  perform enforce_rate_limit('play_again', 10, 30);

  select * into v_game from games where id = p_game_id for update;
  if not found then
    raise exception 'Game not found.' using errcode = 'P0002';
  end if;

  if v_game.host_user_id <> v_uid then
    raise exception 'Only the host can start a new round.' using errcode = '42501';
  end if;

  if v_game.status <> 'FINISHED' then
    raise exception 'This game hasn''t finished yet.' using errcode = 'P0001';
  end if;

  update games
    set status = 'WAITING',
        round_number = round_number + 1,
        current_question_index = 0,
        current_question_id = null,
        question_started_at = null,
        phase_started_at = null,
        started_at = null,
        finished_at = null
    where id = p_game_id;

  update players set score = 0 where game_id = p_game_id;
end;
$$;

revoke execute on function play_again(uuid) from public;
grant execute on function play_again(uuid) to authenticated;
