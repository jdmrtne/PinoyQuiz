-- Pinoy Quiz — 0028: question types, Phase 2 (Unscramble, Matching, Image ID)
--
-- Builds on 0026/0027. Two of these three types reuse existing machinery
-- almost entirely:
--
--   * image — is really "identification, but with a picture": grading is
--     the exact same typed-answer comparison submit_text_answer already
--     does, so no new submit function. Just a new image_url column and
--     get_current_question/get_answer_reveal returning it.
--   * unscramble — also grades through submit_text_answer unchanged
--     (the player types the unscrambled word, compared against
--     correct_answer same as identification). The only new piece is the
--     server generating a shuffled letter order once at start_game (so
--     it's stable for the question's duration and identical for every
--     player), stored on game_questions the same way shuffle_map already
--     stores the per-game multiple_choice option order.
--   * matching is the one genuinely new grading shape: a term list and a
--     shuffled definition list, graded by whether the player's proposed
--     term->displayed-definition-slot mapping decodes back to the
--     original pairing. Gets its own submit_matching_answer function,
--     built to the same round_number/upsert/timing pattern as
--     submit_answer and submit_text_answer.

-- ---------------------------------------------------------------------
-- questions: new columns, all nullable — only required for the type(s)
-- that use them, enforced by check constraints exactly like 0026.
-- ---------------------------------------------------------------------

alter table questions
  add column if not exists image_url text,
  add column if not exists match_terms text[],
  add column if not exists match_definitions text[];

-- image: needs a picture plus a typed answer (reuses correct_answer/
-- acceptable_answers already added in 0026 — no new "what's the answer"
-- column needed).
alter table questions add constraint questions_image_fields check (
  question_type <> 'image'
  or (
    image_url is not null and char_length(trim(image_url)) > 0
    and correct_answer is not null and char_length(trim(correct_answer)) > 0
  )
);

-- unscramble: reuses correct_answer as the target word. Single token, no
-- spaces (the letter-shuffle below operates per-character and a
-- multi-word phrase would visibly give away word boundaries anyway) and
-- long enough that shuffling it isn't trivially guessable/un-shuffleable.
alter table questions add constraint questions_unscramble_fields check (
  question_type <> 'unscramble'
  or (
    correct_answer is not null
    and correct_answer !~ '\s'
    and char_length(correct_answer) between 3 and 20
  )
);

-- matching: two parallel arrays, aligned by index — match_definitions[i]
-- is the correct definition for match_terms[i]. 2-6 pairs: below 2 isn't
-- really "matching", above 6 doesn't fit a mobile screen without scrolling
-- gymnastics (UI note, not a hard technical ceiling — revisit if needed).
alter table questions add constraint questions_matching_fields check (
  question_type <> 'matching'
  or (
    match_terms is not null and match_definitions is not null
    and array_length(match_terms, 1) = array_length(match_definitions, 1)
    and array_length(match_terms, 1) between 2 and 6
  )
);

comment on column questions.image_url is
  'Image to display for question_type = image. Null for every other type.';
comment on column questions.match_terms is
  'Left column for question_type = matching. match_definitions[i] is the correct match for match_terms[i]. Null for every other type.';
comment on column questions.match_definitions is
  'Right column for question_type = matching, aligned by index with match_terms. Null for every other type.';

-- ---------------------------------------------------------------------
-- game_questions: per-game randomization state for the two types that
-- need it, same idea as shuffle_map for multiple_choice/true_false.
-- ---------------------------------------------------------------------

alter table game_questions
  add column if not exists unscramble_letters text[],
  add column if not exists match_shuffle smallint[];

comment on column game_questions.unscramble_letters is
  'Per-game shuffled letters of the parent question''s correct_answer, for question_type = unscramble. Generated once in start_game, stable for the question''s duration.';
comment on column game_questions.match_shuffle is
  'Maps *displayed* definition slot to original questions.match_definitions index, for question_type = matching — same convention as shuffle_map. Generated once in start_game.';

-- ---------------------------------------------------------------------
-- answers: matching submissions are a small array (one displayed-slot
-- choice per term), not a single option index or a string.
-- ---------------------------------------------------------------------

alter table answers add column if not exists submitted_pairing smallint[];

comment on column answers.submitted_pairing is
  'Player''s proposed term[i] -> displayed-definition-slot mapping for a matching question. Null for every other type.';


-- =======================================================================
-- start_game — same body as 0026's version, with two more branches in
-- the per-question loop: unscramble letter shuffling and matching
-- definition shuffling. Everything else (custom category mix, no-repeat
-- topup, question_type filter, rate limiting) is unchanged.
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
  v_q questions%rowtype;
  v_order smallint := 0;
  v_shuffle smallint[];
  v_letters text[];
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
    select * into v_q from questions where id = v_qid;
    v_letters := null;
    v_shuffle := array[]::smallint[];

    if v_q.question_type = 'multiple_choice' then
      v_shuffle := (select array(select x from unnest(array[0,1,2,3]::smallint[]) x order by random()));
    elsif v_q.question_type = 'true_false' then
      v_shuffle := array[0,1]::smallint[]; -- fixed True-then-False order, nothing to shuffle
    elsif v_q.question_type = 'unscramble' then
      -- Shuffle the letters; retry (bounded) if chance produced the
      -- original word back, so the player isn't handed a free answer.
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
    end if;
    -- identification / fill_blank / image: no options and no letters to shuffle.

    insert into game_questions (
      game_id, question_id, question_order, round_number, shuffle_map,
      unscramble_letters, match_shuffle
    )
    values (
      p_game_id, v_qid, v_order, v_game.round_number, v_shuffle,
      v_letters, case when v_q.question_type = 'matching' then v_shuffle else null end
    );
    v_order := v_order + 1;
  end loop;

  update games set status = 'COUNTDOWN', started_at = now(), phase_started_at = now() where id = p_game_id;
end;
$$;


-- =======================================================================
-- get_current_question — adds out_image_url, out_scramble_letters,
-- out_match_terms, out_match_definitions. All four are null except for
-- the one type that uses them. shuffle_map is repurposed as "the
-- matching shuffle" storage-wise (match_shuffle column, set equal to it
-- in start_game above) purely so this function has one consistent place
-- to read from; out_option_1..4 stay null for matching same as the other
-- non-choice types.
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
      -- match_shuffle is 0-based; +1 for Postgres' 1-based array indexing.
      v_defs := v_defs || v_q.match_definitions[v_gq.match_shuffle[v_i] + 1];
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
    (v_gq.question_order + 1)::smallint,
    v_game.question_count,
    v_game.time_limit_seconds,
    v_game.question_started_at;
end;
$$;

grant execute on function get_current_question(uuid) to authenticated;


-- =======================================================================
-- submit_text_answer — same body as 0026, just widening the type guard
-- to also accept unscramble and image (identical grading logic applies:
-- normalized string compare against correct_answer/acceptable_answers).
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
        submitted_pairing = null,
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
-- submit_matching_answer — p_pairing[i] is the *displayed* definition
-- slot the player assigned to match_terms[i] (0-based, same length as
-- match_terms). Correct iff, for every i, decoding that displayed slot
-- through match_shuffle gives back i — i.e. the whole set of pairs is
-- right. Phase 2 grades all-or-nothing; per-pair partial credit is a
-- reasonable Phase 4 scoring extension, not added here per the brief's
-- "don't add fields/behavior that isn't needed yet."
-- =======================================================================

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

  if now() >= v_game.question_started_at + make_interval(secs => v_game.time_limit_seconds) then
    raise exception 'This question is no longer accepting answers.' using errcode = 'P0007';
  end if;

  select * into v_gq from game_questions where id = v_game.current_question_id;
  select * into v_q from questions where id = v_gq.question_id;

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
        is_correct = excluded.is_correct,
        response_time_ms = excluded.response_time_ms,
        points = excluded.points;

  update players
    set score = score + (v_points - coalesce(v_existing.points, 0))
    where id = v_player.id;

  return query select v_is_correct, v_points;
end;
$$;

revoke execute on function submit_matching_answer(uuid, smallint[]) from public;
grant execute on function submit_matching_answer(uuid, smallint[]) to authenticated;


-- =======================================================================
-- get_answer_reveal — adds out_image_url (image type — show the picture
-- again on reveal) and out_match_terms/out_match_definitions/
-- out_your_pairing (matching — the client redraws the same board and
-- highlights right/wrong lines itself). match_definitions comes back in
-- the *canonical* (unshuffled) order here, unlike get_current_question —
-- reveal isn't a live quiz anymore, no reason to keep them scrambled, and
-- it lets the client zip yourPairing straight against them by index.
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
      v_q.explanation, v_answer.selected_option, null::text,
      coalesce(v_answer.points, 0), coalesce(v_answer.is_correct, false),
      case when v_total_players > 0 then round(100.0 * v_correct_count / v_total_players, 1) else 0 end;

  elsif v_q.question_type = 'matching' then
    return query select
      v_q.id, v_q.question_type, null::smallint, null::text,
      null::text, null::text, v_q.match_terms, v_q.match_definitions, v_answer.submitted_pairing,
      v_q.explanation, null::smallint, null::text,
      coalesce(v_answer.points, 0), coalesce(v_answer.is_correct, false),
      case when v_total_players > 0 then round(100.0 * v_correct_count / v_total_players, 1) else 0 end;

  else
    -- identification / fill_blank / unscramble / image
    return query select
      v_q.id, v_q.question_type, null::smallint, null::text,
      v_q.correct_answer, v_q.image_url, null::text[], null::text[], null::smallint[],
      v_q.explanation, null::smallint, v_answer.submitted_text,
      coalesce(v_answer.points, 0), coalesce(v_answer.is_correct, false),
      case when v_total_players > 0 then round(100.0 * v_correct_count / v_total_players, 1) else 0 end;
  end if;
end;
$$;

grant execute on function get_answer_reveal(uuid) to authenticated;

-- Note: end_question (0016) still needs no changes — its no-answer insert
-- uses an explicit column list; submitted_pairing simply stays null,
-- exactly the right value for "didn't answer" regardless of type.
