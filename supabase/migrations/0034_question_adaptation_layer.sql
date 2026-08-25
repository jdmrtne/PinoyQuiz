-- Pinoy Quiz — 0034: question adaptation layer
--
-- Problem being fixed: the alternative question types (true_false,
-- identification, fill_blank, unscramble, matching, sequence) are almost
-- unplayable in practice because the bank has only a handful of natively
-- authored rows for each of them, while multiple_choice has thousands.
-- 0031/0032/0033 already fixed *how evenly* start_game draws across the
-- enabled types — this migration fixes the actual shortage those draws
-- were running into.
--
-- Fix, per the brief ("prefer runtime transformation or a reusable
-- question-generation/adaptation layer... if the existing schema already
-- supports multiple question types, work with the existing architecture
-- instead of creating a conflicting second system"): keep exactly one
-- `questions` table. A multiple_choice row can additionally be
-- *represented* as other question_type rows — a true_false row, an
-- identification row, etc. — each a normal row of that type (so every
-- existing type-specific check constraint, rendering component, and
-- submit_*_answer function needs zero changes), but tagged with which
-- source question(s) it was derived from. That tag is what lets
-- start_game tell "two rows" from "two representations of one fact" and
-- refuse to show both in the same game — the actual ask in "DUPLICATE
-- PREVENTION" below, expressed as a schema relationship instead of the
-- content-text heuristic 0032 used.
--
-- Columns added to `questions`:
--   * source_question_id  — set on a 1:1 adaptation (true_false,
--     identification, fill_blank, unscramble): the single multiple_choice
--     row it was generated from. Null for native rows.
--   * source_question_ids — set on a matching adaptation instead (a
--     matching *set* is built from several source questions in the same
--     category/difficulty — see 0035's generator). Null for every other
--     row, including 1:1 adaptations (which use the singular column).
--   * is_adapted           — true for any generated row, false for every
--     natively authored one. Used purely to rank native above adapted
--     when start_game picks a type's questions (PRIORITY OF QUESTION
--     SOURCES: native first, adaptation second), never to change scoring
--     or rendering.
--   * consumed_source_ids  — generated column, the actual "identity" a
--     row occupies for dedup purposes: source_question_ids if it's a
--     matching set, else array[source_question_id] if it's a 1:1
--     adaptation, else array[id] for a native row (a native row's
--     identity is itself). start_game excludes any candidate whose
--     consumed_source_ids overlaps what's already been picked this game,
--     which is what actually prevents "capital of the Philippines" from
--     appearing once as multiple_choice and again as identification in
--     the same game, regardless of prompt wording.
--
-- No new table. No second question-selection code path — this is the
-- one and only `questions` table and the one and only start_game.

-- ---------------------------------------------------------------------
-- Incidental fix found while testing this migration end-to-end: 0022,
-- 0026 and 0030 each added a parameter to create_game via
-- `create or replace function`, but Postgres identifies a function by
-- name *and* parameter list — a different parameter list creates a new
-- overload instead of replacing the old one. All three create_game
-- signatures (8, 9, and 10 params) were still coexisting, which makes
-- any positional call matching more than one of them ambiguous (this is
-- what broke supabase/tests/run_scenarios.sql, which calls create_game
-- positionally). Supabase's PostgREST RPC layer sends every parameter by
-- name, so the app itself never hit this, but it's a real landmine for
-- anything calling these functions directly (including this project's
-- own test harness). Dropping the two superseded signatures is safe:
-- 0030's 10-param version (defaults for every parameter added after the
-- original 8) already covers every caller of the older ones.
-- ---------------------------------------------------------------------

drop function if exists create_game(
  game_category_setting, game_difficulty_setting, smallint, smallint, text,
  game_mode, answer_behavior, question_category[]
);
drop function if exists create_game(
  game_category_setting, game_difficulty_setting, smallint, smallint, text,
  game_mode, answer_behavior, question_category[], boolean
);


alter table questions
  add column if not exists source_question_id uuid references questions(id) on delete cascade,
  add column if not exists source_question_ids uuid[],
  add column if not exists is_adapted boolean not null default false;

alter table questions add constraint questions_adaptation_shape check (
  -- A row is at most one of: a matching-set adaptation (source_question_ids),
  -- a 1:1 adaptation (source_question_id), or native (neither).
  not (source_question_id is not null and source_question_ids is not null)
  and (source_question_ids is null or array_length(source_question_ids, 1) between 2 and 6)
  and (not is_adapted or source_question_id is not null or source_question_ids is not null)
  and (is_adapted or (source_question_id is null and source_question_ids is null))
);

alter table questions add column if not exists consumed_source_ids uuid[]
  generated always as (
    case
      when source_question_ids is not null then source_question_ids
      when source_question_id is not null then array[source_question_id]
      else array[id]
    end
  ) stored;

comment on column questions.source_question_id is
  'Set for a 1:1 adapted row (true_false/identification/fill_blank/unscramble generated from one multiple_choice row). Null for native rows and for matching sets (see source_question_ids).';
comment on column questions.source_question_ids is
  'Set for an adapted matching row: the 2-6 source questions its terms/definitions were built from. Null otherwise.';
comment on column questions.is_adapted is
  'true for any row produced by the adaptation layer, false for natively authored rows. Used only to rank native above adapted during selection.';
comment on column questions.consumed_source_ids is
  'The source identity/identities this row occupies. A native row consumes itself; an adapted row consumes what it was generated from. start_game excludes any candidate whose consumed_source_ids overlaps a source already used earlier in the same game, so the same underlying fact never appears twice in different clothing.';

create index if not exists questions_source_question_id_idx on questions (source_question_id) where source_question_id is not null;
create index if not exists questions_is_adapted_idx on questions (question_type, is_adapted);
create index if not exists questions_consumed_source_ids_gin_idx on questions using gin (consumed_source_ids);


-- =======================================================================
-- start_game — same overall shape as 0033 (per-type target allocation,
-- redistribution of shortfall, final shuffle), with two changes:
--
--   1. Per-type availability is now "how many usable questions can this
--      type provide" — counted as DISTINCT source identity, not raw row
--      count — so a type that only has adapted rows sharing sources with
--      another type isn't overcounted, and the "not enough questions"
--      check reflects the real ceiling.
--
--   2. The fill step is a bounded per-row loop instead of a single
--      `order by random() limit target` batch query: each pick excludes
--      (a) anything already in this game (no-repeat, unchanged), (b) the
--      shuffled shortfall/topup rules 0032/0033 already used are
--      superseded by explicit "not (consumed_source_ids && v_used_sources)"
--      filtering, and (c) `order by is_adapted asc, random()` ranks any
--      native candidate above adapted ones — priority-of-source, cheaply,
--      right inside the query instead of two separate passes. A row's
--      consumed_source_ids get added to v_used_sources the moment it's
--      picked, so no later pick — same type or a different one, choice-
--      based or matching — can reuse that source. This is a handful of
--      indexed single-row lookups (bounded by question_count, typically
--      well under 50) rather than one big batch, which keeps start_game
--      fast without needing to materialize/cache anything — the
--      adaptation itself was already materialized once, ahead of time,
--      by 0035's generator, not computed here.
--
-- Everything else (per-type target split, redistribution of a type's
-- shortfall to types with spare capacity, per-question shuffle_map /
-- unscramble_letters / match_shuffle / sequence_shuffle generation, the
-- final game_questions insert) is unchanged from 0033.
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

  -- Randomize the order the types are processed in, so which type(s)
  -- get the "remainder" slot(s) below (when question_count doesn't
  -- divide evenly) and which get first pick during shortfall
  -- redistribution isn't always the same type game after game.
  select array_agg(t order by random()) into v_types from unnest(v_types) t;
  v_n_types := array_length(v_types, 1);

  -- Per-type availability = distinct usable source identities, not raw
  -- row count. This is the "how many usable questions can this type
  -- provide" the brief asks for: several adapted rows sharing one
  -- source only count once, matching what dedup will actually allow
  -- start_game to seat in a single game.
  --
  -- This total-availability check matches the original (0016) semantics
  -- deliberately: it does NOT exclude questions already used earlier in
  -- this room's history (across previous rounds of the same game_id).
  -- A room several rounds deep is expected to eventually exhaust its
  -- "never used in this room" pool and fall back to repeats (see the
  -- fill loop below) rather than become unable to start a new round —
  -- excluding room history here would break that fallback and Play Again
  -- on a small category/difficulty pool.
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

  -- Fill each type's slots one row at a time: native ranked above
  -- adapted (`order by is_adapted asc`), excluding anything whose
  -- consumed_source_ids overlaps a source already used earlier in this
  -- loop (any type) or already picked into this game. `limit 1` per
  -- iteration means every pick sees the *current* v_used_sources, so two
  -- rows sharing a source can never both land in the same game — the
  -- single-batch query 0032/0033 used couldn't guarantee that once
  -- adapted rows (which can share sources with each other and with
  -- native rows) entered the pool.
  --
  -- Each pick is two-phase, same fresh-then-repeat fallback as the
  -- original (0016) design: try first excluding every question already
  -- used anywhere in this room's history (earlier rounds of the same
  -- game_id); if that pool is exhausted, fall back to allowing a repeat
  -- from an earlier round (still never a repeat *within this round* —
  -- v_question_ids/v_used_sources still apply either way).
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
        -- Fresh pool exhausted for this type — fall back to a repeat
        -- from an earlier round of this same room.
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

  -- Safety-net top-up: the per-type target split above was capped using
  -- distinct-source availability computed *before* cross-type dedup was
  -- actually applied, so it's possible (if a source is shared across
  -- more types than expected) for the loop above to still fall a little
  -- short of question_count. Scan every enabled type once more, still
  -- respecting category/difficulty/source-dedup (fresh-first, then
  -- repeat-fallback, same as above), to close any remaining gap. The
  -- upfront total-availability check guarantees there is enough supply
  -- across the enabled types combined for this to succeed.
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
