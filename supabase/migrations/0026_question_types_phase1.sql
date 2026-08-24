-- Pinoy Quiz — 0026: question types, Phase 1
--
-- Adds three new question types alongside the existing multiple-choice
-- system: true_false, identification, fill_blank. Additive/backward-
-- compatible by design:
--
--   * `questions.question_type` defaults to 'multiple_choice', so every
--     row inserted before this migration reads as multiple_choice with
--     zero data changes required.
--   * option_a/b/c/d and correct_option go from NOT NULL to nullable
--     (text-answer types don't use them), but existing multiple_choice
--     rows already have all four populated, so nothing breaks.
--   * `games.include_new_question_types` defaults to false, so any
--     caller that never passes the new create_game parameter keeps
--     getting pure multiple_choice games, exactly as today. Only a host
--     who explicitly opts in (new checkbox in CreateGame.tsx) draws from
--     the wider pool.
--
-- IMPORTANT: every function redefined below is redefined from its LATEST
-- prior version (0022 for create_game/start_game, 0016 for
-- submit_answer/end_question/get_answer_reveal — round_number/"Play
-- Again"/custom-category-mix scoping all carried forward), not the
-- original 0010/0011 bodies, so none of that later work regresses.
--
-- More question_type enum values (unscramble, matching, image, sequence,
-- scenario — Phase 2/3 per docs/MASTER_HANDOFF.md's Phase 12 addendum)
-- get added later with `alter type question_type add value`, which is
-- cheap and doesn't require touching this migration.

create type question_type as enum (
  'multiple_choice',
  'true_false',
  'identification',
  'fill_blank'
);

-- ---------------------------------------------------------------------
-- questions: widen the schema to fit all four Phase 1 types without a
-- second table. A type-specific check constraint (not a NOT NULL on the
-- column itself) enforces "the fields this type needs are present",
-- since which fields are required varies by row.
-- ---------------------------------------------------------------------

alter table questions
  add column if not exists question_type question_type not null default 'multiple_choice',
  add column if not exists correct_answer text,
  add column if not exists acceptable_answers text[];

alter table questions alter column option_a drop not null;
alter table questions alter column option_b drop not null;
alter table questions alter column option_c drop not null;
alter table questions alter column option_d drop not null;
alter table questions alter column correct_option drop not null;

alter table questions add constraint questions_multiple_choice_fields check (
  question_type <> 'multiple_choice'
  or (
    option_a is not null and option_b is not null and
    option_c is not null and option_d is not null and
    correct_option is not null
  )
);

-- true_false reuses option_a/option_b (as the literal strings 'True' and
-- 'False') and correct_option (A or B) — the same answer-slot machinery
-- multiple_choice already uses, just with a 2-element shuffle_map instead
-- of 4. No new columns needed for this type.
alter table questions add constraint questions_true_false_fields check (
  question_type <> 'true_false'
  or (option_a = 'True' and option_b = 'False' and correct_option in ('A', 'B'))
);

-- identification / fill_blank: free-typed answer. correct_answer is the
-- canonical answer shown on reveal; acceptable_answers is an optional list
-- of additional strings that also count as correct — both compared
-- trimmed/case-insensitively by submit_text_answer below.
alter table questions add constraint questions_text_answer_fields check (
  question_type not in ('identification', 'fill_blank')
  or (correct_answer is not null and char_length(trim(correct_answer)) > 0)
);

comment on column questions.correct_answer is
  'Canonical typed answer for identification/fill_blank questions. Null for choice-based types.';
comment on column questions.acceptable_answers is
  'Additional strings accepted as correct for identification/fill_blank, compared trimmed/case-insensitively. Null/empty means only correct_answer counts.';

-- ---------------------------------------------------------------------
-- game_questions: shuffle_map now varies by type — 4 elements for
-- multiple_choice, 2 for true_false, empty for the text-answer types.
-- ---------------------------------------------------------------------

alter table game_questions drop constraint if exists game_questions_shuffle_map_shape;
alter table game_questions add constraint game_questions_shuffle_map_shape check (
  array_length(shuffle_map, 1) is null or array_length(shuffle_map, 1) between 2 and 4
);

-- ---------------------------------------------------------------------
-- answers: text-typed submissions land in submitted_text instead of
-- selected_option.
-- ---------------------------------------------------------------------

alter table answers add column if not exists submitted_text text;

-- ---------------------------------------------------------------------
-- games: Phase 1 opt-in lever. Any caller that never sends this keeps
-- getting pure-multiple_choice games, so nothing about today's Classic
-- games changes by default.
-- ---------------------------------------------------------------------

alter table games add column if not exists include_new_question_types boolean not null default false;


-- =======================================================================
-- create_game — adds p_include_new_question_types on top of 0022's
-- signature (custom category mix + game_mode/answer_behavior). Default
-- false, so every existing caller is unaffected.
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
  p_include_new_question_types boolean default false
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
        time_limit_seconds, game_mode, answer_behavior, categories,
        include_new_question_types
      )
      values (
        v_room_code, v_uid, p_category, p_difficulty, p_question_count,
        p_time_limit_seconds, p_game_mode, p_answer_behavior, v_categories,
        p_include_new_question_types
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
  game_mode, answer_behavior, question_category[], boolean
) to authenticated;


-- =======================================================================
-- start_game — same as 0022's version (custom mix + no-repeat-questions
-- topup logic + phase_started_at), with a question_type filter layered
-- into all three selection queries and shuffle_map generation now
-- branching per-question by type.
-- =======================================================================

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
  v_qtype question_type;
  v_order smallint := 0;
  v_shuffle smallint[];
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

  v_use_custom_categories := v_game.categories is not null and array_length(v_game.categories, 1) > 0;
  v_category_filter := nullif(v_game.category::text, 'random');
  v_difficulty_filter := nullif(v_game.difficulty::text, 'mixed');

  select count(*) into v_total_available
  from questions
  where (
      (v_use_custom_categories and category = any(v_game.categories))
      or (not v_use_custom_categories and (v_category_filter is null or category::text = v_category_filter))
    )
    and (v_difficulty_filter is null or difficulty::text = v_difficulty_filter)
    and (v_game.include_new_question_types or question_type = 'multiple_choice');

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
      and (v_game.include_new_question_types or question_type = 'multiple_choice')
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
        and (v_game.include_new_question_types or question_type = 'multiple_choice')
        and not (id = any(v_question_ids))
      order by random()
      limit (v_game.question_count - coalesce(array_length(v_question_ids, 1), 0))
    ) sub;
    v_question_ids := v_question_ids || coalesce(v_topup_ids, array[]::uuid[]);
  end if;

  foreach v_qid in array v_question_ids loop
    select question_type into v_qtype from questions where id = v_qid;

    if v_qtype = 'multiple_choice' then
      v_shuffle := (select array(select x from unnest(array[0,1,2,3]::smallint[]) x order by random()));
    elsif v_qtype = 'true_false' then
      v_shuffle := array[0,1]::smallint[]; -- fixed True-then-False order, nothing to shuffle
    else
      v_shuffle := array[]::smallint[]; -- identification/fill_blank: no options to shuffle
    end if;

    insert into game_questions (game_id, question_id, question_order, round_number, shuffle_map)
    values (p_game_id, v_qid, v_order, v_game.round_number, v_shuffle);
    v_order := v_order + 1;
  end loop;

  update games set status = 'COUNTDOWN', started_at = now(), phase_started_at = now() where id = p_game_id;
end;
$$;


-- =======================================================================
-- get_current_question — adds out_question_type. Options stay 4 output
-- columns for wire-format stability, null past however many the question
-- actually has (true_false: only 1/2 populated; identification/fill_blank:
-- all four null). Never returns the correct answer — unchanged anti-cheat
-- boundary. Not round_number-scoped (never was — it reads off
-- games.current_question_id, already a specific round's row).
-- =======================================================================

drop function if exists get_current_question(uuid);

create or replace function get_current_question(p_game_id uuid)
returns table (
  out_question_id uuid,
  out_question_type question_type,
  out_prompt text,
  out_option_1 text,
  out_option_2 text,
  out_option_3 text,
  out_option_4 text,
  out_order smallint,
  out_total smallint,
  out_time_limit_seconds smallint,
  out_question_started_at timestamptz
)
language plpgsql
security definer
stable
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_game games%rowtype;
  v_gq game_questions%rowtype;
  v_q questions%rowtype;
  v_opts text[];
  v_o1 text;
  v_o2 text;
  v_o3 text;
  v_o4 text;
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

  if v_game.status <> 'QUESTION' or v_game.current_question_id is null then
    return;
  end if;

  select * into v_gq from game_questions where id = v_game.current_question_id;
  select * into v_q from questions where id = v_gq.question_id;

  if v_q.question_type = 'multiple_choice' then
    v_opts := array[v_q.option_a, v_q.option_b, v_q.option_c, v_q.option_d];
    v_o1 := v_opts[v_gq.shuffle_map[1] + 1];
    v_o2 := v_opts[v_gq.shuffle_map[2] + 1];
    v_o3 := v_opts[v_gq.shuffle_map[3] + 1];
    v_o4 := v_opts[v_gq.shuffle_map[4] + 1];
  elsif v_q.question_type = 'true_false' then
    v_opts := array[v_q.option_a, v_q.option_b];
    v_o1 := v_opts[v_gq.shuffle_map[1] + 1];
    v_o2 := v_opts[v_gq.shuffle_map[2] + 1];
    v_o3 := null;
    v_o4 := null;
  else
    v_o1 := null;
    v_o2 := null;
    v_o3 := null;
    v_o4 := null;
  end if;

  return query select
    v_q.id,
    v_q.question_type,
    v_q.prompt,
    v_o1,
    v_o2,
    v_o3,
    v_o4,
    (v_gq.question_order + 1)::smallint,
    v_game.question_count,
    v_game.time_limit_seconds,
    v_game.question_started_at;
end;
$$;

grant execute on function get_current_question(uuid) to authenticated;


-- =======================================================================
-- submit_answer — choice-based types only (multiple_choice, true_false),
-- rebuilt from 0016's round_number/upsert/time-expiry version. Range-
-- checks p_selected_option against this question's actual option count
-- (2 or 4) instead of a hard-coded 0-3, and rejects a text-answer
-- question outright — see submit_text_answer below for those.
-- =======================================================================

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
  v_option_count smallint;
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

  if v_q.question_type not in ('multiple_choice', 'true_false') then
    raise exception 'This question needs a typed answer.' using errcode = '22023';
  end if;

  v_option_count := array_length(v_gq.shuffle_map, 1);

  if p_selected_option is null or p_selected_option < 0 or p_selected_option >= v_option_count then
    raise exception 'That is not a valid answer option.' using errcode = '22023';
  end if;

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
        submitted_text = null,
        is_correct = excluded.is_correct,
        response_time_ms = excluded.response_time_ms,
        points = excluded.points;

  update players
    set score = score + (v_points - coalesce(v_existing.points, 0))
    where id = v_player.id;

  return query select v_is_correct, v_points;
end;
$$;


-- =======================================================================
-- submit_text_answer — identification/fill_blank counterpart to
-- submit_answer, mirroring the same round_number/upsert/time-expiry shape
-- so CHANGE_UNTIL_TIMER_ENDS games let a player retype their answer right
-- up until the timer ends, same as choice-based games let them re-pick.
-- Grades by normalized string comparison against correct_answer and
-- acceptable_answers instead of an option index. Normalization: trim,
-- collapse internal whitespace to a single space, case-fold — forgiving
-- per the brief ("do not make answers unnecessarily strict"), not
-- fuzzy/typo-tolerant.
-- =======================================================================

create or replace function submit_text_answer(p_game_id uuid, p_answer_text text)
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
  v_normalized text;
  v_is_correct boolean := false;
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

  if v_q.question_type not in ('identification', 'fill_blank') then
    raise exception 'This question needs an option, not typed text.' using errcode = '22023';
  end if;

  select * into v_existing from answers
    where game_id = p_game_id
      and round_number = v_game.round_number
      and player_id = v_player.id
      and question_id = v_q.id;

  if found then
    if v_game.answer_behavior = 'LOCK_ON_SELECTION' then
      raise exception 'You already answered this question.' using errcode = 'P0008';
    end if;
  end if;

  v_normalized := lower(trim(regexp_replace(coalesce(p_answer_text, ''), '\s+', ' ', 'g')));

  if v_normalized <> '' then
    if v_normalized = lower(trim(regexp_replace(v_q.correct_answer, '\s+', ' ', 'g'))) then
      v_is_correct := true;
    elsif v_q.acceptable_answers is not null and exists (
      select 1 from unnest(v_q.acceptable_answers) alt
      where v_normalized = lower(trim(regexp_replace(alt, '\s+', ' ', 'g')))
    ) then
      v_is_correct := true;
    end if;
  end if;

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
    game_id, round_number, player_id, question_id, selected_option, submitted_text,
    is_correct, response_time_ms, points
  ) values (
    p_game_id, v_game.round_number, v_player.id, v_q.id, null, nullif(trim(coalesce(p_answer_text, '')), ''),
    v_is_correct, v_response_ms, v_points
  )
  on conflict (game_id, round_number, player_id, question_id) do update
    set selected_option = null,
        submitted_text = excluded.submitted_text,
        is_correct = excluded.is_correct,
        response_time_ms = excluded.response_time_ms,
        points = excluded.points;

  update players
    set score = score + (v_points - coalesce(v_existing.points, 0))
    where id = v_player.id;

  return query select v_is_correct, v_points;
end;
$$;

revoke execute on function submit_text_answer(uuid, text) from public;
grant execute on function submit_text_answer(uuid, text) to authenticated;


-- =======================================================================
-- get_answer_reveal — rebuilt from 0016's round_number-scoped version.
-- Adds out_question_type, out_correct_answer (canonical typed answer,
-- text types only) and out_your_text_answer. out_correct_option/
-- out_correct_text/out_your_answer are kept for choice-based types and
-- come back null for text types, so existing multiple_choice reveal
-- rendering is untouched.
-- =======================================================================

drop function if exists get_answer_reveal(uuid);

create or replace function get_answer_reveal(p_game_id uuid)
returns table (
  out_question_id uuid,
  out_question_type question_type,
  out_correct_option smallint,
  out_correct_text text,
  out_correct_answer text,
  out_explanation text,
  out_your_answer smallint,
  out_your_text_answer text,
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
  v_correct_text text;
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

  if v_q.question_type in ('multiple_choice', 'true_false') then
    if v_q.question_type = 'multiple_choice' then
      v_opts := array[v_q.option_a, v_q.option_b, v_q.option_c, v_q.option_d];
    else
      v_opts := array[v_q.option_a, v_q.option_b];
    end if;
    v_correct_index := array_position(array['A','B','C','D'], v_q.correct_option::text) - 1;
    v_correct_slot := array_position(v_gq.shuffle_map, v_correct_index) - 1;
    v_correct_text := v_opts[v_correct_index + 1];

    return query select
      v_q.id,
      v_q.question_type,
      v_correct_slot,
      v_correct_text,
      null::text,
      v_q.explanation,
      v_answer.selected_option,
      null::text,
      coalesce(v_answer.points, 0),
      coalesce(v_answer.is_correct, false),
      case when v_total_players > 0
        then round(100.0 * v_correct_count / v_total_players, 1)
        else 0
      end;
  else
    return query select
      v_q.id,
      v_q.question_type,
      null::smallint,
      null::text,
      v_q.correct_answer,
      v_q.explanation,
      null::smallint,
      v_answer.submitted_text,
      coalesce(v_answer.points, 0),
      coalesce(v_answer.is_correct, false),
      case when v_total_players > 0
        then round(100.0 * v_correct_count / v_total_players, 1)
        else 0
      end;
  end if;
end;
$$;

grant execute on function get_answer_reveal(uuid) to authenticated;

-- Note: end_question (0016) needs no changes — its no-answer insert uses
-- an explicit column list that doesn't reference question_type, and a
-- null selected_option/submitted_text pair is already exactly what a
-- "no answer" row should have for a text-type question too.
