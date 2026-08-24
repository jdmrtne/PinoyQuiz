-- Pinoy Quiz — 0034: expand alternate quiz types from the existing question bank
--
-- The question bank is overwhelmingly multiple_choice. The earlier type-
-- balancing migration correctly guarantees that enabled types get a share of
-- a game, but it can only draw rows that were explicitly authored as that
-- type. This migration adds a reusable, deterministic adaptation layer:
--
--   multiple_choice -> true_false
--   multiple_choice -> identification
--   multiple_choice -> fill_blank
--   multiple_choice -> unscramble (single-word answers only)
--
-- Native questions remain untouched and are still preferred by start_game.
-- Adapted rows are generated once from the existing MC bank and then behave
-- exactly like ordinary questions everywhere else: rendering, validation,
-- reveal, scoring, timers, Play Again and RLS all continue using the existing
-- question-type machinery.
--
-- Matching, sequence and image are intentionally NOT fabricated from ordinary
-- MC questions. Matching/sequence require structure that an MC row does not
-- reliably contain, and image requires a real image. Their native pools stay
-- authoritative until compatible source data exists.

alter table questions
  add column if not exists source_question_id uuid references questions(id) on delete cascade;

create unique index if not exists questions_source_type_unique
  on questions (source_question_id, question_type)
  where source_question_id is not null;

create index if not exists questions_source_question_id_idx
  on questions (source_question_id)
  where source_question_id is not null;

comment on column questions.source_question_id is
  'For adapted questions, points to the original multiple-choice source row. Null for native/authored questions.';

-- -------------------------------------------------------------------------
-- Build the reusable adapted pool. ON CONFLICT makes this safe to call from
-- every start_game invocation. Existing native rows are never modified.
-- -------------------------------------------------------------------------

create or replace function ensure_adapted_question_pool()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_q questions%rowtype;
  v_answer text;
  v_correct_idx int;
  v_candidate text;
  v_candidate_idx int;
  v_tf_prompt text;
begin
  for v_q in
    select *
    from questions
    where question_type = 'multiple_choice'
      and source_question_id is null
      and option_a is not null
      and option_b is not null
      and option_c is not null
      and option_d is not null
      and correct_option is not null
  loop
    v_correct_idx := case v_q.correct_option::text
      when 'A' then 0
      when 'B' then 1
      when 'C' then 2
      when 'D' then 3
    end;

    v_answer := case v_correct_idx
      when 0 then v_q.option_a
      when 1 then v_q.option_b
      when 2 then v_q.option_c
      when 3 then v_q.option_d
    end;

    -- Identification: preserve the original question, but expose the
    -- canonical answer through the existing typed-answer fields.
    insert into questions (
      category, difficulty, prompt,
      option_a, option_b, option_c, option_d, correct_option,
      explanation, question_type, correct_answer, acceptable_answers,
      source_question_id, created_at
    )
    values (
      v_q.category,
      v_q.difficulty,
      v_q.prompt,
      null, null, null, null, null,
      v_q.explanation,
      'identification',
      v_answer,
      null,
      v_q.id,
      now()
    )
    on conflict (source_question_id, question_type) where source_question_id is not null
    do nothing;

    -- Fill-in-the-blank: the player supplies the answer to the same source
    -- fact. The wording explicitly identifies this presentation as a blank
    -- instead of pretending that every source prompt naturally contains the
    -- answer text.
    insert into questions (
      category, difficulty, prompt,
      option_a, option_b, option_c, option_d, correct_option,
      explanation, question_type, correct_answer, acceptable_answers,
      source_question_id, created_at
    )
    values (
      v_q.category,
      v_q.difficulty,
      'Fill in the blank: ' || v_q.prompt,
      null, null, null, null, null,
      v_q.explanation,
      'fill_blank',
      v_answer,
      null,
      v_q.id,
      now()
    )
    on conflict (source_question_id, question_type) where source_question_id is not null
    do nothing;

    -- Unscramble only answers that are safe to represent as letter tiles.
    -- Multi-word answers, punctuation and very long answers remain MC-only.
    if v_answer is not null
       and char_length(trim(v_answer)) between 3 and 24
       and trim(v_answer) ~ '^[[:alpha:]]+$'
    then
      insert into questions (
        category, difficulty, prompt,
        option_a, option_b, option_c, option_d, correct_option,
        explanation, question_type, correct_answer, acceptable_answers,
        source_question_id, created_at
      )
      values (
        v_q.category,
        v_q.difficulty,
        'Unscramble the answer to: ' || v_q.prompt,
        null, null, null, null, null,
        v_q.explanation,
        'unscramble',
        trim(v_answer),
        null,
        v_q.id,
        now()
      )
      on conflict (source_question_id, question_type) where source_question_id is not null
      do nothing;
    end if;

    -- True/False: turn one of the source's four choices into a statement
    -- about the original question. A correct choice yields a True statement;
    -- a wrong choice yields False. The candidate is deliberately randomized
    -- once when the adapted row is first created so the pool contains a mix
    -- of True and False items rather than one fixed answer.
    v_candidate_idx := floor(random() * 4)::int;
    v_candidate := case v_candidate_idx
      when 0 then v_q.option_a
      when 1 then v_q.option_b
      when 2 then v_q.option_c
      when 3 then v_q.option_d
    end;

    v_tf_prompt := format(
      'True or False: "%s" is the correct answer to: "%s"',
      v_candidate,
      v_q.prompt
    );

    insert into questions (
      category, difficulty, prompt,
      option_a, option_b, option_c, option_d, correct_option,
      explanation, question_type,
      source_question_id, created_at
    )
    values (
      v_q.category,
      v_q.difficulty,
      v_tf_prompt,
      'True',
      'False',
      null,
      null,
      case when v_candidate_idx = v_correct_idx then 'A'::answer_option else 'B'::answer_option end,
      v_q.explanation,
      'true_false',
      v_q.id,
      now()
    )
    on conflict (source_question_id, question_type) where source_question_id is not null
    do nothing;
  end loop;
end;
$$;

-- Only server-side functions need this helper. It is intentionally not
-- granted directly to clients.

-- -------------------------------------------------------------------------
-- Latest start_game (0033) with one important change: each enabled type's
-- availability includes native rows plus compatible adapted rows. The
-- source-question exclusion prevents an MC source and one of its adapted
-- representations from appearing in the same game.
-- -------------------------------------------------------------------------

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
  v_attempt int;
  v_idx int;
  v_target int[];
  v_avail int[];
  v_avail_count int;
  v_picked uuid[];
  v_leftover int;
  v_progress boolean;
  v_used_prompts text[] := array[]::text[];
  v_used_sources uuid[] := array[]::uuid[];
  v_shortfall int;
  v_topup uuid[];
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

  -- Idempotently expand the current bank before calculating availability.
  perform ensure_adapted_question_pool();

  v_use_custom_categories := v_game.categories is not null and array_length(v_game.categories, 1) > 0;
  v_category_filter := nullif(v_game.category::text, 'random');
  v_difficulty_filter := nullif(v_game.difficulty::text, 'mixed');
  v_types := resolve_enabled_question_types(v_game.enabled_question_types, v_game.include_new_question_types);

  select array_agg(t order by random()) into v_types from unnest(v_types) t;
  v_n_types := array_length(v_types, 1);

  v_target := array_fill(0, array[v_n_types]);
  v_avail := array_fill(0, array[v_n_types]);

  -- Native rows plus eligible adapted rows. A source question can only
  -- contribute one representation to a single game round.
  for v_idx in 1..v_n_types loop
    select count(*) into v_avail_count
    from questions q
    where q.question_type = v_types[v_idx]
      and (
        (v_use_custom_categories and q.category = any(v_game.categories))
        or (not v_use_custom_categories and (v_category_filter is null or q.category::text = v_category_filter))
      )
      and (v_difficulty_filter is null or q.difficulty::text = v_difficulty_filter)
      and q.id not in (select question_id from game_questions where game_id = p_game_id)
      and (
        q.source_question_id is null
        or q.source_question_id not in (select question_id from game_questions where game_id = p_game_id)
      );
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
    if v_target[v_idx] > 0 then
      select array_agg(id) into v_picked
      from (
        select id from (
          select distinct on (lower(trim(q.prompt))) q.id, q.prompt
          from questions q
          where q.question_type = v_types[v_idx]
            and (
              (v_use_custom_categories and q.category = any(v_game.categories))
              or (not v_use_custom_categories and (v_category_filter is null or q.category::text = v_category_filter))
            )
            and (v_difficulty_filter is null or q.difficulty::text = v_difficulty_filter)
            and q.id not in (select question_id from game_questions where game_id = p_game_id)
            and not (q.id = any(v_question_ids))
            and (
              q.source_question_id is null
              or q.source_question_id not in (select question_id from game_questions where game_id = p_game_id)
            )
            and not (lower(trim(q.prompt)) = any(v_used_prompts))
            and (
              q.source_question_id is null
              or not (q.source_question_id = any(v_used_sources))
            )
          order by lower(trim(q.prompt)), (q.source_question_id is not null), random()
        ) deduped
        order by random()
        limit v_target[v_idx]
      ) sub;
      v_picked := coalesce(v_picked, array[]::uuid[]);

      v_shortfall := v_target[v_idx] - coalesce(array_length(v_picked, 1), 0);
      if v_shortfall > 0 then
        select array_agg(id) into v_topup
        from (
          select q.id
          from questions q
          where q.question_type = v_types[v_idx]
            and (
              (v_use_custom_categories and q.category = any(v_game.categories))
              or (not v_use_custom_categories and (v_category_filter is null or q.category::text = v_category_filter))
            )
            and (v_difficulty_filter is null or q.difficulty::text = v_difficulty_filter)
            and q.id not in (select question_id from game_questions where game_id = p_game_id)
            and not (q.id = any(v_question_ids))
            and (
              q.source_question_id is null
              or q.source_question_id not in (select question_id from game_questions where game_id = p_game_id)
            )
            and (
              q.source_question_id is null
              or not (q.source_question_id = any(v_used_sources))
            )
            and not (q.id = any(v_picked))
          order by random()
          limit v_shortfall
        ) sub;
        v_picked := v_picked || coalesce(v_topup, array[]::uuid[]);
      end if;

      if coalesce(array_length(v_picked, 1), 0) > 0 then
        select
          v_used_prompts || array_agg(distinct lower(trim(q.prompt))),
          v_used_sources || coalesce(array_agg(distinct coalesce(q.source_question_id, q.id)), array[]::uuid[])
        into v_used_prompts, v_used_sources
        from questions q
        where q.id = any(v_picked);
      end if;

      v_question_ids := v_question_ids || v_picked;
    end if;
  end loop;

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

  update games
    set status = 'COUNTDOWN', started_at = now(), phase_started_at = now()
    where id = p_game_id;
end;
$$;

grant execute on function start_game(uuid) to authenticated;

-- A small helper for diagnostics/admin SQL. It is not granted to normal
-- clients, so it cannot be used to mutate the bank from the browser.
create or replace function adapted_question_counts()
returns table (
  question_type question_type,
  native_count bigint,
  adapted_count bigint,
  usable_count bigint
)
language sql
security definer
stable
set search_path = public
as $$
  select qt.question_type,
         count(*) filter (where q.source_question_id is null),
         count(*) filter (where q.source_question_id is not null),
         count(*)
  from unnest(enum_range(null::question_type)) qt(question_type)
  left join questions q on q.question_type = qt.question_type
  group by qt.question_type
  order by qt.question_type;
$$;


revoke all on function ensure_adapted_question_pool() from public;
revoke all on function adapted_question_counts() from public;
