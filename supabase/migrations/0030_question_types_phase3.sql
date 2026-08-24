-- Pinoy Quiz — 0030: question types, Phase 3 (Sequence, Timed Challenge, Mixed Mode)
--
-- Three pieces, each smaller than they sound because they reuse Phase
-- 1/2 machinery:
--
--   * Sequence — graded the same shape as Matching (0028): the server
--     shuffles a display order once at start_game, the player proposes a
--     displayed-slot arrangement, submit_sequence_answer decodes it back
--     against the shuffle and checks it matches the canonical order.
--     New submit function because the semantics differ from matching's
--     (one ordered list vs N independent pairs), but the pattern —
--     shuffle stored on game_questions, decode-and-compare grading,
--     round_number/upsert/timing scaffolding — is identical.
--
--   * Timed Challenge — the engine already had per-answer speed bonus
--     scoring and expiry (0011/0016); what was missing was a *timer that
--     can differ per question* instead of one flat games.time_limit_seconds
--     for the whole game. questions.time_limit_override does that: null
--     means "use the game's default", set means "this question gets its
--     own limit" (e.g. a harder question given less time, or a
--     dedicated batch of short-fuse questions for a "Speed Challenge"-
--     style game — see games.enabled_question_types below for how a host
--     would build that game). get_current_question already returns
--     out_time_limit_seconds per-question, and the host-controlled
--     client's countdown (GameRoom.tsx) already reads that value rather
--     than any game-level constant — so making the RPC compute an
--     effective per-question value is enough to make the whole
--     HOST_CONTROLLED flow respect it with zero client changes. Automatic
--     mode's server-driven countdown (auto_advance_game) is the one place
--     that WAS reading games.time_limit_seconds directly; that's fixed
--     below. Every answer-submission function needs the same effective
--     value for its own expiry check + response-time/speed-bonus math,
--     so all four (submit_answer, submit_text_answer,
--     submit_matching_answer, submit_sequence_answer) get it.
--
--   * Mixed Mode — 0026's include_new_question_types was deliberately a
--     blunt "everything or just multiple_choice" switch, noted at the
--     time as good enough to make the new types reachable but not real
--     Mixed Mode. games.enabled_question_types is the real thing: an
--     explicit list a host picks (CreateGame.tsx gets a checkbox per
--     type). include_new_question_types keeps working exactly as before
--     for any caller that still only sends that — it's the fallback when
--     enabled_question_types isn't set, not replaced or removed. A
--     question type without enough real data simply can't have rows of
--     that type at all (every questions_*_fields check constraint from
--     0026/0028 already guarantees that), so "don't select a mode the
--     data doesn't support" from the brief is satisfied structurally,
--     the same way it already was for image/matching in Phase 2.

-- ---------------------------------------------------------------------
-- questions / game_questions / answers / games: new columns.
-- ---------------------------------------------------------------------

alter table questions
  add column if not exists sequence_items text[],
  add column if not exists time_limit_override smallint;

alter table questions add constraint questions_sequence_fields check (
  question_type <> 'sequence'
  or (sequence_items is not null and array_length(sequence_items, 1) between 2 and 8)
);

alter table questions add constraint questions_time_limit_override_range check (
  time_limit_override is null or time_limit_override between 5 and 120
);

comment on column questions.sequence_items is
  'Canonical correct order for question_type = sequence. Null for every other type.';
comment on column questions.time_limit_override is
  'Per-question timer override in seconds, any question type. Null (the common case) means "use this game''s time_limit_seconds".';

alter table game_questions add column if not exists sequence_shuffle smallint[];

comment on column game_questions.sequence_shuffle is
  'Maps *displayed* item slot to original questions.sequence_items index, for question_type = sequence — same convention as shuffle_map/match_shuffle. Generated once in start_game.';

alter table answers add column if not exists submitted_sequence smallint[];

comment on column answers.submitted_sequence is
  'Player''s proposed displayed-slot arrangement for a sequence question. Null for every other type.';

alter table games add column if not exists enabled_question_types question_type[];

comment on column games.enabled_question_types is
  'Explicit Mixed Mode type selection. Null falls back to include_new_question_types (0026) for backward compatibility; see resolve_enabled_question_types below for the exact precedence.';

-- ---------------------------------------------------------------------
-- resolve_enabled_question_types — the fallback chain, factored into its
-- own helper so start_game doesn't duplicate it and nothing has to stay
-- in sync by hand if the chain ever changes.
-- ---------------------------------------------------------------------

create or replace function resolve_enabled_question_types(
  p_enabled question_type[],
  p_include_new boolean
)
returns question_type[]
language sql
immutable
as $$
  select case
    when p_enabled is not null and array_length(p_enabled, 1) > 0 then p_enabled
    when p_include_new then array[
      'multiple_choice','true_false','identification','fill_blank',
      'unscramble','matching','image','sequence'
    ]::question_type[]
    else array['multiple_choice']::question_type[]
  end;
$$;

grant execute on function resolve_enabled_question_types(question_type[], boolean) to authenticated;


-- =======================================================================
-- create_game — adds p_enabled_question_types on top of 0026's signature.
-- Default null, so every existing caller (including one only ever
-- passing p_include_new_question_types) is unaffected.
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
  p_enabled_question_types question_type[] default null
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
        include_new_question_types, enabled_question_types
      )
      values (
        v_room_code, v_uid, p_category, p_difficulty, p_question_count,
        p_time_limit_seconds, p_game_mode, p_answer_behavior, v_categories,
        p_include_new_question_types, nullif(p_enabled_question_types, array[]::question_type[])
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
  game_mode, answer_behavior, question_category[], boolean, question_type[]
) to authenticated;


-- =======================================================================
-- start_game — same body as 0028's version, with the type filter now
-- going through resolve_enabled_question_types instead of the inline
-- include_new_question_types check, plus a sequence branch in the
-- per-question shuffle loop.
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
  v_types question_type[];
  v_total_available int;
  v_fresh_ids uuid[];
  v_topup_ids uuid[];
  v_question_ids uuid[];
  v_qid uuid;
  v_q questions%rowtype;
  v_order smallint := 0;
  v_shuffle smallint[];
  v_letters text[];
  v_seq_shuffle smallint[];
  v_attempt int;
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
  v_types := resolve_enabled_question_types(v_game.enabled_question_types, v_game.include_new_question_types);

  select count(*) into v_total_available
  from questions
  where (
      (v_use_custom_categories and category = any(v_game.categories))
      or (not v_use_custom_categories and (v_category_filter is null or category::text = v_category_filter))
    )
    and (v_difficulty_filter is null or difficulty::text = v_difficulty_filter)
    and question_type = any(v_types);

  if v_total_available < v_game.question_count then
    raise exception 'Not enough questions available for these settings. Try Random category, Mixed difficulty, or more question types.'
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
      and question_type = any(v_types)
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
        and question_type = any(v_types)
        and not (id = any(v_question_ids))
      order by random()
      limit (v_game.question_count - coalesce(array_length(v_question_ids, 1), 0))
    ) sub;
    v_question_ids := v_question_ids || coalesce(v_topup_ids, array[]::uuid[]);
  end if;

  foreach v_qid in array v_question_ids loop
    select * into v_q from questions where id = v_qid;
    v_letters := null;
    v_seq_shuffle := null;
    v_shuffle := array[]::smallint[];

    if v_q.question_type = 'multiple_choice' then
      v_shuffle := (select array(select x from unnest(array[0,1,2,3]::smallint[]) x order by random()));
    elsif v_q.question_type = 'true_false' then
      v_shuffle := array[0,1]::smallint[]; -- fixed True-then-False order, nothing to shuffle
    elsif v_q.question_type = 'unscramble' then
      v_attempt := 0;
      loop
        v_attempt := v_attempt + 1;
        select array_agg(ch) into v_letters
        from (
          select ch from unnest(regexp_split_to_array(v_q.correct_answer, '')) ch
          order by random()
        ) shuffled;
        exit when v_letters <> regexp_split_to_array(v_q.correct_answer, '') or v_attempt >= 8;
      end loop;
    elsif v_q.question_type = 'matching' then
      v_shuffle := (
        select array_agg(x) from (
          select x from generate_series(0, array_length(v_q.match_definitions, 1) - 1) x
          order by random()
        ) shuffled
      );
    elsif v_q.question_type = 'sequence' then
      -- Retry (bounded) if the shuffle happens to land on the already-
      -- correct order, same rationale as unscramble above.
      v_attempt := 0;
      loop
        v_attempt := v_attempt + 1;
        select array_agg(x) into v_seq_shuffle
        from (
          select x from generate_series(0, array_length(v_q.sequence_items, 1) - 1) x
          order by random()
        ) shuffled;
        exit when v_seq_shuffle <> (
          select array_agg(x) from generate_series(0, array_length(v_q.sequence_items, 1) - 1) x
        ) or v_attempt >= 8;
      end loop;
    end if;
    -- identification / fill_blank / image: no options/letters/order to shuffle.

    insert into game_questions (
      game_id, question_id, question_order, round_number, shuffle_map,
      unscramble_letters, match_shuffle, sequence_shuffle
    )
    values (
      p_game_id, v_qid, v_order, v_game.round_number, v_shuffle,
      v_letters,
      case when v_q.question_type = 'matching' then v_shuffle else null end,
      v_seq_shuffle
    );
    v_order := v_order + 1;
  end loop;

  update games set status = 'COUNTDOWN', started_at = now(), phase_started_at = now() where id = p_game_id;
end;
$$;


-- =======================================================================
-- get_current_question — adds out_sequence_items (shuffled display
-- order). out_time_limit_seconds is now the *effective* per-question
-- value (questions.time_limit_override if set, else the game's default)
-- instead of always echoing the game-level constant — see this
-- migration's header for why that alone is enough to make
-- HOST_CONTROLLED games respect it with no client changes.
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
  out_image_url text,
  out_scramble_letters text[],
  out_match_terms text[],
  out_match_definitions text[],
  out_sequence_items text[],
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
  v_defs text[];
  v_seq text[];
  v_n int;
  v_i int;
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

  v_o1 := null; v_o2 := null; v_o3 := null; v_o4 := null;
  v_defs := null;
  v_seq := null;

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
  elsif v_q.question_type = 'matching' then
    v_n := array_length(v_q.match_definitions, 1);
    v_defs := array[]::text[];
    for v_i in 1..v_n loop
      v_defs := v_defs || v_q.match_definitions[v_gq.match_shuffle[v_i] + 1];
    end loop;
  elsif v_q.question_type = 'sequence' then
    v_n := array_length(v_q.sequence_items, 1);
    v_seq := array[]::text[];
    for v_i in 1..v_n loop
      v_seq := v_seq || v_q.sequence_items[v_gq.sequence_shuffle[v_i] + 1];
    end loop;
  end if;

  return query select
    v_q.id,
    v_q.question_type,
    v_q.prompt,
    v_o1,
    v_o2,
    v_o3,
    v_o4,
    v_q.image_url,
    v_gq.unscramble_letters,
    case when v_q.question_type = 'matching' then v_q.match_terms else null end,
    v_defs,
    v_seq,
    (v_gq.question_order + 1)::smallint,
    v_game.question_count,
    coalesce(v_q.time_limit_override, v_game.time_limit_seconds),
    v_game.question_started_at;
end;
$$;

grant execute on function get_current_question(uuid) to authenticated;


-- =======================================================================
-- submit_answer / submit_text_answer / submit_matching_answer — same
-- bodies as before, with the expiry check and response-time/speed-bonus
-- math now using coalesce(v_q.time_limit_override, v_game.time_limit_seconds)
-- instead of v_game.time_limit_seconds directly.
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
  v_effective_limit_secs smallint;
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

  select * into v_gq from game_questions where id = v_game.current_question_id;
  select * into v_q from questions where id = v_gq.question_id;
  v_effective_limit_secs := coalesce(v_q.time_limit_override, v_game.time_limit_seconds);

  if now() >= v_game.question_started_at + make_interval(secs => v_effective_limit_secs) then
    raise exception 'This question is no longer accepting answers.' using errcode = 'P0007';
  end if;

  if v_q.question_type not in ('multiple_choice', 'true_false') then
    raise exception 'This question needs a different kind of answer.' using errcode = '22023';
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
  end if;

  v_correct_index := array_position(array['A','B','C','D'], v_q.correct_option::text) - 1;
  v_correct_slot := array_position(v_gq.shuffle_map, v_correct_index) - 1;
  v_is_correct := (p_selected_option = v_correct_slot);

  v_time_limit_ms := v_effective_limit_secs * 1000;
  v_response_ms := greatest(
    0,
    least(v_time_limit_ms, extract(epoch from (now() - v_game.question_started_at)) * 1000)
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
        submitted_pairing = null,
        submitted_sequence = null,
        is_correct = excluded.is_correct,
        response_time_ms = excluded.response_time_ms,
        points = excluded.points;

  update players
    set score = score + (v_points - coalesce(v_existing.points, 0))
    where id = v_player.id;

  return query select v_is_correct, v_points;
end;
$$;


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
  v_effective_limit_secs smallint;
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

  select * into v_gq from game_questions where id = v_game.current_question_id;
  select * into v_q from questions where id = v_gq.question_id;
  v_effective_limit_secs := coalesce(v_q.time_limit_override, v_game.time_limit_seconds);

  if now() >= v_game.question_started_at + make_interval(secs => v_effective_limit_secs) then
    raise exception 'This question is no longer accepting answers.' using errcode = 'P0007';
  end if;

  if v_q.question_type not in ('identification', 'fill_blank', 'unscramble', 'image') then
    raise exception 'This question needs a different kind of answer.' using errcode = '22023';
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

  v_time_limit_ms := v_effective_limit_secs * 1000;
  v_response_ms := greatest(
    0,
    least(v_time_limit_ms, extract(epoch from (now() - v_game.question_started_at)) * 1000)
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
        submitted_pairing = null,
        submitted_sequence = null,
        is_correct = excluded.is_correct,
        response_time_ms = excluded.response_time_ms,
        points = excluded.points;

  update players
    set score = score + (v_points - coalesce(v_existing.points, 0))
    where id = v_player.id;

  return query select v_is_correct, v_points;
end;
$$;


create or replace function submit_matching_answer(p_game_id uuid, p_pairing smallint[])
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
  v_effective_limit_secs smallint;
  v_n int;
  v_i int;
  v_is_correct boolean := true;
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

  select * into v_gq from game_questions where id = v_game.current_question_id;
  select * into v_q from questions where id = v_gq.question_id;
  v_effective_limit_secs := coalesce(v_q.time_limit_override, v_game.time_limit_seconds);

  if now() >= v_game.question_started_at + make_interval(secs => v_effective_limit_secs) then
    raise exception 'This question is no longer accepting answers.' using errcode = 'P0007';
  end if;

  if v_q.question_type <> 'matching' then
    raise exception 'This question needs a different kind of answer.' using errcode = '22023';
  end if;

  v_n := array_length(v_q.match_terms, 1);

  if p_pairing is null or array_length(p_pairing, 1) <> v_n then
    raise exception 'You need to match every term before submitting.' using errcode = '22023';
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

  for v_i in 1..v_n loop
    if p_pairing[v_i] is null
       or p_pairing[v_i] < 0 or p_pairing[v_i] >= v_n
       or v_gq.match_shuffle[p_pairing[v_i] + 1] <> (v_i - 1) then
      v_is_correct := false;
      exit;
    end if;
  end loop;

  v_time_limit_ms := v_effective_limit_secs * 1000;
  v_response_ms := greatest(
    0,
    least(v_time_limit_ms, extract(epoch from (now() - v_game.question_started_at)) * 1000)
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
    game_id, round_number, player_id, question_id, selected_option, submitted_pairing,
    is_correct, response_time_ms, points
  ) values (
    p_game_id, v_game.round_number, v_player.id, v_q.id, null, p_pairing,
    v_is_correct, v_response_ms, v_points
  )
  on conflict (game_id, round_number, player_id, question_id) do update
    set selected_option = null,
        submitted_text = null,
        submitted_pairing = excluded.submitted_pairing,
        submitted_sequence = null,
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
-- submit_sequence_answer — p_order[i] is the *displayed* item slot the
-- player placed at chronological position i (0-based, length = number of
-- items). Correct iff, for every i, decoding that slot through
-- sequence_shuffle gives back i — i.e. the whole arrangement matches the
-- canonical order. Same all-or-nothing grading as matching, same
-- reasoning (see that function's comment in 0028).
-- =======================================================================

create or replace function submit_sequence_answer(p_game_id uuid, p_order smallint[])
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
  v_effective_limit_secs smallint;
  v_n int;
  v_i int;
  v_is_correct boolean := true;
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

  select * into v_gq from game_questions where id = v_game.current_question_id;
  select * into v_q from questions where id = v_gq.question_id;
  v_effective_limit_secs := coalesce(v_q.time_limit_override, v_game.time_limit_seconds);

  if now() >= v_game.question_started_at + make_interval(secs => v_effective_limit_secs) then
    raise exception 'This question is no longer accepting answers.' using errcode = 'P0007';
  end if;

  if v_q.question_type <> 'sequence' then
    raise exception 'This question needs a different kind of answer.' using errcode = '22023';
  end if;

  v_n := array_length(v_q.sequence_items, 1);

  if p_order is null or array_length(p_order, 1) <> v_n then
    raise exception 'You need to place every item before submitting.' using errcode = '22023';
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

  for v_i in 1..v_n loop
    if p_order[v_i] is null
       or p_order[v_i] < 0 or p_order[v_i] >= v_n
       or v_gq.sequence_shuffle[p_order[v_i] + 1] <> (v_i - 1) then
      v_is_correct := false;
      exit;
    end if;
  end loop;

  v_time_limit_ms := v_effective_limit_secs * 1000;
  v_response_ms := greatest(
    0,
    least(v_time_limit_ms, extract(epoch from (now() - v_game.question_started_at)) * 1000)
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
    game_id, round_number, player_id, question_id, selected_option, submitted_sequence,
    is_correct, response_time_ms, points
  ) values (
    p_game_id, v_game.round_number, v_player.id, v_q.id, null, p_order,
    v_is_correct, v_response_ms, v_points
  )
  on conflict (game_id, round_number, player_id, question_id) do update
    set selected_option = null,
        submitted_text = null,
        submitted_pairing = null,
        submitted_sequence = excluded.submitted_sequence,
        is_correct = excluded.is_correct,
        response_time_ms = excluded.response_time_ms,
        points = excluded.points;

  update players
    set score = score + (v_points - coalesce(v_existing.points, 0))
    where id = v_player.id;

  return query select v_is_correct, v_points;
end;
$$;

revoke execute on function submit_sequence_answer(uuid, smallint[]) from public;
grant execute on function submit_sequence_answer(uuid, smallint[]) to authenticated;


-- =======================================================================
-- get_answer_reveal — adds out_sequence_items (canonical order) and
-- out_your_sequence, same "canonical order, not shuffled" choice as
-- matching's reveal made in 0028 for the same reason (reveal isn't a
-- live quiz anymore).
-- =======================================================================

drop function if exists get_answer_reveal(uuid);

create or replace function get_answer_reveal(p_game_id uuid)
returns table (
  out_question_id uuid,
  out_question_type question_type,
  out_correct_option smallint,
  out_correct_text text,
  out_correct_answer text,
  out_image_url text,
  out_match_terms text[],
  out_match_definitions text[],
  out_your_pairing smallint[],
  out_sequence_items text[],
  out_your_sequence smallint[],
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
      v_q.id, v_q.question_type, v_correct_slot, v_correct_text,
      null::text, null::text, null::text[], null::text[], null::smallint[],
      null::text[], null::smallint[],
      v_q.explanation, v_answer.selected_option, null::text,
      coalesce(v_answer.points, 0), coalesce(v_answer.is_correct, false),
      case when v_total_players > 0 then round(100.0 * v_correct_count / v_total_players, 1) else 0 end;

  elsif v_q.question_type = 'matching' then
    return query select
      v_q.id, v_q.question_type, null::smallint, null::text,
      null::text, null::text, v_q.match_terms, v_q.match_definitions, v_answer.submitted_pairing,
      null::text[], null::smallint[],
      v_q.explanation, null::smallint, null::text,
      coalesce(v_answer.points, 0), coalesce(v_answer.is_correct, false),
      case when v_total_players > 0 then round(100.0 * v_correct_count / v_total_players, 1) else 0 end;

  elsif v_q.question_type = 'sequence' then
    return query select
      v_q.id, v_q.question_type, null::smallint, null::text,
      null::text, null::text, null::text[], null::text[], null::smallint[],
      v_q.sequence_items, v_answer.submitted_sequence,
      v_q.explanation, null::smallint, null::text,
      coalesce(v_answer.points, 0), coalesce(v_answer.is_correct, false),
      case when v_total_players > 0 then round(100.0 * v_correct_count / v_total_players, 1) else 0 end;

  else
    -- identification / fill_blank / unscramble / image
    return query select
      v_q.id, v_q.question_type, null::smallint, null::text,
      v_q.correct_answer, v_q.image_url, null::text[], null::text[], null::smallint[],
      null::text[], null::smallint[],
      v_q.explanation, null::smallint, v_answer.submitted_text,
      coalesce(v_answer.points, 0), coalesce(v_answer.is_correct, false),
      case when v_total_players > 0 then round(100.0 * v_correct_count / v_total_players, 1) else 0 end;
  end if;
end;
$$;

grant execute on function get_answer_reveal(uuid) to authenticated;


-- =======================================================================
-- auto_advance_game — same body as 0017's version, with the QUESTION-
-- phase expiry check now reading the effective per-question time limit
-- (joins to game_questions/questions for the currently-live question)
-- instead of always using games.time_limit_seconds. This was the one
-- place that still needed a direct fix — see this migration's header.
-- =======================================================================

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
  v_effective_limit_secs smallint;
  v_no_answer_points integer;
  v_next_index smallint;
  v_next_gq_id uuid;
  countdown_seconds constant int := 3;   -- unchanged — matches CountdownOverlay
  reveal_seconds constant int := 3;
  leaderboard_seconds constant int := 2;
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
    select * into v_gq from game_questions where id = v_game.current_question_id;
    select coalesce(q.time_limit_override, v_game.time_limit_seconds) into v_effective_limit_secs
      from questions q where q.id = v_gq.question_id;

    if v_game.question_started_at is null
      or now() < v_game.question_started_at + make_interval(secs => v_effective_limit_secs)
    then
      return;
    end if;

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

-- Note: end_question (0016) still needs no changes — it doesn't read
-- time_limit_seconds at all, it just records no-answer rows for whoever
-- the host's client (already respecting the effective per-question limit
-- via get_current_question above) decided time was up for.
