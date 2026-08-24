-- Pinoy Quiz — 0032: dedupe by question content within a single game round
--
-- Bug report: "some questions are duplicating" — a question with the
-- same wording showed up twice in one game.
--
-- Root cause: the question bank has at least one case (the "What is
-- the capital city of the Philippines?" pair from the early sample
-- seeds — geography/easy as both multiple_choice and identification)
-- where the *same fact* exists as two separate rows with two
-- different question_ids, because it was authored once per question
-- type. That's not caught by the game_questions_no_dupes constraint
-- (0016), which keys on question_id, not content — two different rows
-- are, as far as that constraint is concerned, two different
-- questions.
--
-- Before 0031, a flat random() draw over the whole enabled-type pool
-- made it statistically unlikely both copies would land in the same
-- game. 0031 deliberately draws one candidate *per enabled type* to
-- fix the opposite problem (new types barely showing up), which as a
-- side effect makes it much more likely that two same-content rows of
-- different types both get pulled into the same game when a host
-- enables multiple types.
--
-- Fix: while building v_question_ids in start_game, track the
-- normalized (trimmed, lowercased) prompt text of everything already
-- picked this round and exclude matches from every subsequent pick —
-- both across types and within a single type's own draw (via a
-- `distinct on (normalized prompt)` pre-filter, in case a type ever
-- has its own internal near-duplicate rows). If content-dedup ever
-- prunes a type below its target count (extremely unlikely — the
-- current bank has exactly one duplicate pair), a fallback top-up
-- fills the remainder ignoring the content filter so the game still
-- gets its full question_count rather than coming up short.
--
-- Everything else is identical to 0031 — only the per-type selection
-- block changes.

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
  -- balanced per-type allocation
  v_idx int;
  v_target int[];
  v_avail int[];
  v_avail_count int;
  v_picked uuid[];
  v_leftover int;
  v_progress boolean;
  -- content-level dedup, on top of the per-type balancing
  v_used_prompts text[] := array[]::text[];
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

  v_use_custom_categories := v_game.categories is not null and array_length(v_game.categories, 1) > 0;
  v_category_filter := nullif(v_game.category::text, 'random');
  v_difficulty_filter := nullif(v_game.difficulty::text, 'mixed');
  v_types := resolve_enabled_question_types(v_game.enabled_question_types, v_game.include_new_question_types);

  -- Randomize the order the types are processed in, so which type(s)
  -- get the "remainder" slot(s) below (when question_count doesn't
  -- divide evenly) and which get first pick during shortfall
  -- redistribution isn't always the same type game after game.
  select array_agg(t order by random()) into v_types from unnest(v_types) t;
  v_n_types := array_length(v_types, 1);

  -- Per-type availability, excluding questions already used earlier in
  -- this game (Play Again / no-repeat, same rule 0016 already applied).
  v_target := array_fill(0, array[v_n_types]);
  v_avail := array_fill(0, array[v_n_types]);

  for v_idx in 1..v_n_types loop
    select count(*) into v_avail_count
    from questions
    where question_type = v_types[v_idx]
      and (
        (v_use_custom_categories and category = any(v_game.categories))
        or (not v_use_custom_categories and (v_category_filter is null or category::text = v_category_filter))
      )
      and (v_difficulty_filter is null or difficulty::text = v_difficulty_filter)
      and id not in (select question_id from game_questions where game_id = p_game_id);
    v_avail[v_idx] := v_avail_count;
  end loop;

  select coalesce(sum(x), 0) into v_total_available from unnest(v_avail) x;

  if v_total_available < v_game.question_count then
    raise exception 'Not enough questions available for these settings. Try Random category, Mixed difficulty, or more question types.'
      using errcode = 'P0005';
  end if;

  -- Even split of question_count across the n enabled types, remainder
  -- going one-each to the first v_leftover types (already randomized
  -- above).
  for v_idx in 1..v_n_types loop
    v_target[v_idx] := v_game.question_count / v_n_types;
  end loop;
  v_leftover := v_game.question_count - (v_game.question_count / v_n_types) * v_n_types;
  for v_idx in 1..v_leftover loop
    v_target[v_idx] := v_target[v_idx] + 1;
  end loop;

  -- Cap each type's target at what's actually available for it, and
  -- collect the shortfall to hand to other types.
  v_leftover := 0;
  for v_idx in 1..v_n_types loop
    if v_target[v_idx] > v_avail[v_idx] then
      v_leftover := v_leftover + (v_target[v_idx] - v_avail[v_idx]);
      v_target[v_idx] := v_avail[v_idx];
    end if;
  end loop;

  -- Redistribute the shortfall round-robin to types with spare
  -- capacity (target < avail). The total-availability check above
  -- guarantees this always fully resolves; v_progress is just a
  -- safety valve against an infinite loop if it somehow didn't.
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

  -- Fill each type's slots with a random draw scoped to that type,
  -- excluding any question whose normalized prompt text has already
  -- been picked for this round under a different type (or, via the
  -- distinct-on pre-filter, a different row of the *same* type).
  for v_idx in 1..v_n_types loop
    if v_target[v_idx] > 0 then
      select array_agg(id) into v_picked
      from (
        select id from (
          select distinct on (lower(trim(prompt))) id, prompt
          from questions
          where question_type = v_types[v_idx]
            and (
              (v_use_custom_categories and category = any(v_game.categories))
              or (not v_use_custom_categories and (v_category_filter is null or category::text = v_category_filter))
            )
            and (v_difficulty_filter is null or difficulty::text = v_difficulty_filter)
            and id not in (select question_id from game_questions where game_id = p_game_id)
            and not (id = any(v_question_ids))
            and not (lower(trim(prompt)) = any(v_used_prompts))
          order by lower(trim(prompt)), random()
        ) deduped
        order by random()
        limit v_target[v_idx]
      ) sub;
      v_picked := coalesce(v_picked, array[]::uuid[]);

      -- Fallback top-up: if content-dedup happened to prune this
      -- type's pool below its target (only possible if this type has
      -- several rows sharing the same prompt as each other or as an
      -- already-picked question — not the case anywhere in the
      -- current bank, but kept as a safety net), fill the remainder
      -- ignoring the prompt filter so the game still gets its full
      -- question_count. Content-dedup is a nice-to-have; hitting the
      -- requested question count is not optional.
      v_shortfall := v_target[v_idx] - coalesce(array_length(v_picked, 1), 0);
      if v_shortfall > 0 then
        select array_agg(id) into v_topup
        from (
          select id from questions
          where question_type = v_types[v_idx]
            and (
              (v_use_custom_categories and category = any(v_game.categories))
              or (not v_use_custom_categories and (v_category_filter is null or category::text = v_category_filter))
            )
            and (v_difficulty_filter is null or difficulty::text = v_difficulty_filter)
            and id not in (select question_id from game_questions where game_id = p_game_id)
            and not (id = any(v_question_ids))
            and not (id = any(v_picked))
          order by random()
          limit v_shortfall
        ) sub;
        v_picked := v_picked || coalesce(v_topup, array[]::uuid[]);
      end if;

      if coalesce(array_length(v_picked, 1), 0) > 0 then
        select v_used_prompts || array_agg(distinct lower(trim(prompt)))
          into v_used_prompts
          from questions where id = any(v_picked);
      end if;

      v_question_ids := v_question_ids || v_picked;
    end if;
  end loop;

  -- Shuffle the combined, now type-balanced list so questions of the
  -- same type don't land back to back in the game's running order.
  select array_agg(x order by random()) into v_question_ids from unnest(v_question_ids) x;

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

grant execute on function start_game(uuid) to authenticated;
