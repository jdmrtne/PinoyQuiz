-- Pinoy Quiz — 0036: Smart / Auto question timing
--
-- Requested: a per-game Timing Strategy (Fixed | Smart Auto) alongside the
-- existing flat time_limit_seconds. Fixed is the pre-existing behavior
-- (every question gets the same host-chosen number of seconds) and stays
-- the default, so no existing game/caller changes. Smart Auto derives a
-- recommended time per question from question_type, prompt length, option
-- length, and matching/sequence complexity, via a new reusable
-- `calculate_question_time` function — the single place this algorithm
-- lives, so it's easy to retune later (per the brief's "make the
-- calculation predictable and consistent... easy to adjust later").
--
-- Custom Per Question (the third strategy the brief mentions as optional/
-- "advanced") is NOT included in this migration. Questions and their
-- content are intentionally not queryable by the client before a game
-- starts (see 0006's grants — the host plays too, so exposing prompts
-- pre-game would leak answers to the host same as to anyone else). Giving
-- a host a per-question override UI needs a question-preview surface that
-- doesn't exist yet and is a bigger, separate piece of work — deferred,
-- same spirit as MASTER_HANDOFF.md's "Not done yet, in priority order"
-- list for the question-types track, rather than bolted on half-built.
-- `questions.time_limit_override` (0030) already gives *content authors*
-- a per-question override at seed time; that's untouched and still wins
-- over both Fixed and Smart Auto below.
--
-- ---------------------------------------------------------------------
-- Where the calculation runs
-- ---------------------------------------------------------------------
-- Computed ONCE per question, at start_game, and stored on the
-- game_questions row (`effective_time_limit_seconds`) rather than
-- recomputed on every read. This matches how shuffle_map/unscramble_letters/
-- match_shuffle/sequence_shuffle already work (generated once at
-- start_game, stable for the question's duration) and means
-- get_current_question / submit_answer / submit_text_answer /
-- submit_matching_answer / submit_sequence_answer / auto_advance_game all
-- just read one column instead of each re-deriving
-- coalesce(time_limit_override, ...) — six call sites collapse to one
-- computation. A host's Smart Auto game therefore shows a stable time for
-- a question no matter which client (or how many times) reads it.
--
-- Every one of those six functions is redefined below via
-- `create or replace function` with an unchanged signature (so this is a
-- true replace, not a new overload — see 0034's note on why that
-- matters), each with exactly one line changed: the coalesce(...) that
-- used to compute the effective limit inline now just reads
-- v_gq.effective_time_limit_seconds.

-- =======================================================================
-- 1. Schema
-- =======================================================================

create type timing_strategy as enum ('fixed', 'smart');

alter table games
  add column timing_strategy timing_strategy not null default 'fixed';

comment on column games.timing_strategy is
  'fixed: every question gets time_limit_seconds (pre-existing behavior). smart: per-question time is derived by calculate_question_time() at start_game and stored on game_questions.effective_time_limit_seconds. Either way, a question-level questions.time_limit_override still wins if set.';

-- Not null, so existing (already-played or in-flight) game_questions rows
-- need a default — 15s matches the old fallback default and is never read
-- again for a finished round anyway. Every row inserted from this
-- migration forward gets a real computed value from start_game, not this
-- default.
alter table game_questions
  add column effective_time_limit_seconds smallint not null default 15;

comment on column game_questions.effective_time_limit_seconds is
  'The actual seconds this question runs for in this game, resolved once at start_game: questions.time_limit_override if set, else calculate_question_time() when the game is Smart Auto, else the game''s flat time_limit_seconds. Every reader (get_current_question, submit_*_answer, auto_advance_game) uses this column directly instead of re-deriving it.';


-- =======================================================================
-- 2. calculate_question_time — the reusable Smart Auto calculation.
--
-- Base seconds by question_type, then additive adjustments:
--   + prompt length   — 0.6s per word past the first 12, capped at +15s
--   + option length    — multiple_choice/true_false only: 1s per 20 chars
--                        of combined option text past 80, capped at +10s
--   + matching pairs   — 4s per pair past the first 2
--   + sequence items   — 4s per item past the first 3
-- ...then rounded to the nearest 5 seconds and clamped to [10, 60].
--
-- A pure function of question content — same inputs always produce the
-- same output — so it's safe to call from both start_game (server) and
-- mirrored in the client (src/game-engine/questionTiming.ts) for the
-- Create Game summary preview, without the two ever needing to be kept in
-- sync by hand beyond matching this comment's algorithm description.
-- =======================================================================

create or replace function calculate_question_time(
  p_question_type question_type,
  p_prompt text,
  p_option_a text,
  p_option_b text,
  p_option_c text,
  p_option_d text,
  p_match_terms text[],
  p_sequence_items text[]
)
returns smallint
language plpgsql
immutable
as $$
declare
  v_base smallint;
  v_word_count int;
  v_length_extra numeric;
  v_option_chars int;
  v_option_extra numeric;
  v_match_extra int;
  v_seq_extra int;
  v_total numeric;
  v_min constant smallint := 10;
  v_max constant smallint := 60;
begin
  v_base := case p_question_type
    when 'true_false' then 10
    when 'unscramble' then 18
    when 'matching' then 20
    when 'sequence' then 20
    else 15 -- multiple_choice, identification, fill_blank, image
  end;

  v_word_count := coalesce(
    array_length(regexp_split_to_array(trim(both from coalesce(p_prompt, '')), '\s+'), 1),
    0
  );
  v_length_extra := least(15, greatest(0, v_word_count - 12) * 0.6);

  v_option_chars := coalesce(char_length(p_option_a), 0) + coalesce(char_length(p_option_b), 0)
    + coalesce(char_length(p_option_c), 0) + coalesce(char_length(p_option_d), 0);
  v_option_extra := case
    when p_question_type in ('multiple_choice', 'true_false') and v_option_chars > 80
      then least(10, floor((v_option_chars - 80) / 20.0))
    else 0
  end;

  v_match_extra := case
    when p_match_terms is not null then greatest(0, array_length(p_match_terms, 1) - 2) * 4
    else 0
  end;

  v_seq_extra := case
    when p_sequence_items is not null then greatest(0, array_length(p_sequence_items, 1) - 3) * 4
    else 0
  end;

  v_total := v_base + v_length_extra + v_option_extra + v_match_extra + v_seq_extra;

  return greatest(v_min, least(v_max, (round(v_total / 5) * 5)::smallint));
end;
$$;

grant execute on function calculate_question_time(
  question_type, text, text, text, text, text, text[], text[]
) to authenticated;


-- =======================================================================
-- 3. create_game — adds p_timing_strategy on top of 0030's 10-param
-- signature. Default 'fixed', so every existing caller keeps today's
-- behavior. Dropping the old signature first, same reasoning as 0034: a
-- new trailing parameter is a different parameter-type list, so
-- `create or replace` alone would add a second overload instead of
-- replacing the first, and PostgREST/positional callers would become
-- ambiguous again.
-- =======================================================================

drop function if exists create_game(
  game_category_setting, game_difficulty_setting, smallint, smallint, text,
  game_mode, answer_behavior, question_category[], boolean, question_type[]
);

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
  p_timing_strategy timing_strategy default 'fixed'
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

  insert into players (game_id, user_id, nickname, is_host)
  values (v_game_id, v_uid, v_nickname, true)
  returning id into v_player_id;

  return query select v_game_id, v_room_code, v_player_id;
end;
$$;

grant execute on function create_game(
  game_category_setting, game_difficulty_setting, smallint, smallint, text,
  game_mode, answer_behavior, question_category[], boolean, question_type[], timing_strategy
) to authenticated;


-- =======================================================================
-- 4. start_game — same body as 0034's version, with one addition: each
-- picked question's effective time is computed once (v_effective_time)
-- right before its game_questions row is inserted, and stored in the new
-- effective_time_limit_seconds column. Everything else — the balanced
-- per-type allocation, source-identity dedup, per-row fill, shuffle
-- generation — is byte-for-byte unchanged from 0034.
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
  v_n_types int;
  v_total_available int;
  v_question_ids uuid[] := array[]::uuid[];
  v_qid uuid;
  v_q questions%rowtype;
  v_order smallint := 0;
  v_shuffle smallint[];
  v_letters text[];
  v_seq_shuffle smallint[];
  v_effective_time smallint;
  v_attempt int;
  -- balanced per-type allocation
  v_idx int;
  v_target int[];
  v_avail int[];
  v_avail_count int;
  v_leftover int;
  v_progress boolean;
  -- source-identity dedup + per-row fill (replaces 0032's prompt-text dedup)
  v_used_sources uuid[] := array[]::uuid[];
  v_picked_id uuid;
  v_picked_consumed uuid[];
  v_filled int;
  v_total_shortfall int;
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

  select array_agg(t order by random()) into v_types from unnest(v_types) t;
  v_n_types := array_length(v_types, 1);

  v_target := array_fill(0, array[v_n_types]);
  v_avail := array_fill(0, array[v_n_types]);

  for v_idx in 1..v_n_types loop
    select count(distinct s) into v_avail_count
    from questions q
    cross join lateral unnest(q.consumed_source_ids) as s
    where q.question_type = v_types[v_idx]
      and (
        (v_use_custom_categories and q.category = any(v_game.categories))
        or (not v_use_custom_categories and (v_category_filter is null or q.category::text = v_category_filter))
      )
      and (v_difficulty_filter is null or q.difficulty::text = v_difficulty_filter);
    v_avail[v_idx] := v_avail_count;
  end loop;

  select coalesce(sum(x), 0) into v_total_available from unnest(v_avail) x;

  if v_total_available < v_game.question_count then
    raise exception 'Not enough questions available for these settings. Try Random category, Mixed difficulty, or more question types.'
      using errcode = 'P0005';
  end if;

  for v_idx in 1..v_n_types loop
    v_target[v_idx] := v_game.question_count / v_n_types;
  end loop;
  v_leftover := v_game.question_count - (v_game.question_count / v_n_types) * v_n_types;
  for v_idx in 1..v_leftover loop
    v_target[v_idx] := v_target[v_idx] + 1;
  end loop;

  v_leftover := 0;
  for v_idx in 1..v_n_types loop
    if v_target[v_idx] > v_avail[v_idx] then
      v_leftover := v_leftover + (v_target[v_idx] - v_avail[v_idx]);
      v_target[v_idx] := v_avail[v_idx];
    end if;
  end loop;

  while v_leftover > 0 loop
    v_progress := false;
    for v_idx in 1..v_n_types loop
      exit when v_leftover <= 0;
      if v_target[v_idx] < v_avail[v_idx] then
        v_target[v_idx] := v_target[v_idx] + 1;
        v_leftover := v_leftover - 1;
        v_progress := true;
      end if;
    end loop;
    exit when not v_progress;
  end loop;

  for v_idx in 1..v_n_types loop
    v_filled := 0;
    while v_filled < v_target[v_idx] loop
      select q.id, q.consumed_source_ids into v_picked_id, v_picked_consumed
      from questions q
      where q.question_type = v_types[v_idx]
        and (
          (v_use_custom_categories and q.category = any(v_game.categories))
          or (not v_use_custom_categories and (v_category_filter is null or q.category::text = v_category_filter))
        )
        and (v_difficulty_filter is null or q.difficulty::text = v_difficulty_filter)
        and q.id not in (select question_id from game_questions where game_id = p_game_id)
        and not (q.id = any(v_question_ids))
        and not (q.consumed_source_ids && v_used_sources)
      order by q.is_adapted asc, random()
      limit 1;

      if v_picked_id is null then
        select q.id, q.consumed_source_ids into v_picked_id, v_picked_consumed
        from questions q
        where q.question_type = v_types[v_idx]
          and (
            (v_use_custom_categories and q.category = any(v_game.categories))
            or (not v_use_custom_categories and (v_category_filter is null or q.category::text = v_category_filter))
          )
          and (v_difficulty_filter is null or q.difficulty::text = v_difficulty_filter)
          and not (q.id = any(v_question_ids))
          and not (q.consumed_source_ids && v_used_sources)
        order by q.is_adapted asc, random()
        limit 1;
      end if;

      exit when v_picked_id is null;

      v_question_ids := v_question_ids || v_picked_id;
      v_used_sources := v_used_sources || v_picked_consumed;
      v_filled := v_filled + 1;
    end loop;
  end loop;

  v_total_shortfall := v_game.question_count - coalesce(array_length(v_question_ids, 1), 0);
  if v_total_shortfall > 0 then
    for v_idx in 1..v_n_types loop
      while v_total_shortfall > 0 loop
        select q.id, q.consumed_source_ids into v_picked_id, v_picked_consumed
        from questions q
        where q.question_type = v_types[v_idx]
          and (
            (v_use_custom_categories and q.category = any(v_game.categories))
            or (not v_use_custom_categories and (v_category_filter is null or q.category::text = v_category_filter))
          )
          and (v_difficulty_filter is null or q.difficulty::text = v_difficulty_filter)
          and q.id not in (select question_id from game_questions where game_id = p_game_id)
          and not (q.id = any(v_question_ids))
          and not (q.consumed_source_ids && v_used_sources)
        order by q.is_adapted asc, random()
        limit 1;

        if v_picked_id is null then
          select q.id, q.consumed_source_ids into v_picked_id, v_picked_consumed
          from questions q
          where q.question_type = v_types[v_idx]
            and (
              (v_use_custom_categories and q.category = any(v_game.categories))
              or (not v_use_custom_categories and (v_category_filter is null or q.category::text = v_category_filter))
            )
            and (v_difficulty_filter is null or q.difficulty::text = v_difficulty_filter)
            and not (q.id = any(v_question_ids))
            and not (q.consumed_source_ids && v_used_sources)
          order by q.is_adapted asc, random()
          limit 1;
        end if;

        exit when v_picked_id is null;

        v_question_ids := v_question_ids || v_picked_id;
        v_used_sources := v_used_sources || v_picked_consumed;
        v_total_shortfall := v_total_shortfall - 1;
      end loop;
      exit when v_total_shortfall <= 0;
    end loop;
  end if;

  select array_agg(x order by random()) into v_question_ids from unnest(v_question_ids) x;

  foreach v_qid in array v_question_ids loop
    select * into v_q from questions where id = v_qid;
    v_letters := null;
    v_seq_shuffle := null;
    v_shuffle := array[]::smallint[];

    if v_q.question_type = 'multiple_choice' then
      v_shuffle := (select array(select x from unnest(array[0,1,2,3]::smallint[]) x order by random()));
    elsif v_q.question_type = 'true_false' then
      v_shuffle := array[0,1]::smallint[];
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
      v_attempt := 0;
      loop
        v_attempt := v_attempt + 1;
        select array_agg(x::smallint) into v_seq_shuffle
        from (
          select x from generate_series(0, array_length(v_q.sequence_items, 1) - 1) x
          order by random()
        ) shuffled;
        exit when v_seq_shuffle <> (
          select array_agg(x::smallint) from generate_series(0, array_length(v_q.sequence_items, 1) - 1) x
        ) or v_attempt >= 8;
      end loop;
    end if;

    -- New in 0036: resolve this question's effective time once, here.
    -- questions.time_limit_override (content-author-set) still wins over
    -- everything; Smart Auto only applies when the game itself is
    -- 'smart' and the question has no override.
    v_effective_time := coalesce(
      v_q.time_limit_override,
      case
        when v_game.timing_strategy = 'smart' then calculate_question_time(
          v_q.question_type, v_q.prompt, v_q.option_a, v_q.option_b, v_q.option_c, v_q.option_d,
          v_q.match_terms, v_q.sequence_items
        )
        else v_game.time_limit_seconds
      end
    );

    insert into game_questions (
      game_id, question_id, question_order, round_number, shuffle_map,
      unscramble_letters, match_shuffle, sequence_shuffle, effective_time_limit_seconds
    )
    values (
      p_game_id, v_qid, v_order, v_game.round_number, v_shuffle,
      v_letters,
      case when v_q.question_type = 'matching' then v_shuffle else null end,
      v_seq_shuffle,
      v_effective_time
    );
    v_order := v_order + 1;
  end loop;

  update games set status = 'COUNTDOWN', started_at = now(), phase_started_at = now() where id = p_game_id;
end;
$$;

grant execute on function start_game(uuid) to authenticated;


-- =======================================================================
-- 5. get_current_question / submit_answer / submit_text_answer /
-- submit_matching_answer / submit_sequence_answer / auto_advance_game —
-- unchanged signatures and bodies except each now reads
-- v_gq.effective_time_limit_seconds instead of re-deriving
-- coalesce(v_q.time_limit_override, v_game.time_limit_seconds) inline.
-- =======================================================================

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
    v_gq.effective_time_limit_seconds,
    v_game.question_started_at;
end;
$$;

grant execute on function get_current_question(uuid) to authenticated;


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
  v_effective_limit_secs := v_gq.effective_time_limit_seconds;

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
  v_effective_limit_secs := v_gq.effective_time_limit_seconds;

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
  v_effective_limit_secs := v_gq.effective_time_limit_seconds;

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
  v_effective_limit_secs := v_gq.effective_time_limit_seconds;

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
  countdown_seconds constant int := 3;
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
    v_effective_limit_secs := v_gq.effective_time_limit_seconds;

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

grant execute on function auto_advance_game(uuid) to authenticated;
