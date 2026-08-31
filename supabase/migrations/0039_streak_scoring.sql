-- Pinoy Quiz — 0039: streak-based scoring bonus
--
-- Until now `streak` was purely a client-side display counter
-- (GameRoom.tsx's `streak` state, driven off `get_answer_reveal`'s
-- `wasCorrect` — see StreakBadge.tsx) with zero effect on `players.score`.
-- This migration makes the streak actually count: consecutive correct
-- answers now earn an extra "streak bonus" on top of the existing
-- basePoints + speedBonus formula, table-driven via the same
-- `scoring_config` JSONB column as everything else (spec 3, "configurable
-- scoring system" — see docs/ARCHITECTURE.md).
--
-- Formula (correct answers only): streakBonus = min(maxStreakBonus,
-- (newStreak - 1) * streakBonusPerCorrect) — so the first correct answer
-- of a fresh streak earns no bonus (streak of 1 isn't "a streak" yet),
-- the second earns one streakBonusPerCorrect, the third two, and so on up
-- to the cap. A wrong answer or a timeout resets the streak to 0 and
-- earns no streak bonus, same as today.
--
-- Server-authoritative persistence: `players.current_streak` is the
-- source of truth (was nowhere in the DB before). `answers` gains two
-- columns: `streak_before` (this player's streak *entering* this
-- question, stamped once on first insert and never touched again — see
-- below) and `streak_bonus` (the bonus portion of `points` this specific
-- answer earned), so the leaderboard and reveal screens can show
-- "score + streak bonus" as a breakdown rather than just a lump sum.
--
-- Resubmission correctness under CHANGE_UNTIL_TIMER_ENDS: exactly the
-- same problem `players.score`'s existing delta-on-conflict handling
-- solves for total points also applies to the streak — only the FINAL
-- submission for a question should affect it, not every intermediate
-- pick. `streak_before` is the fix: every submit_*_answer function reads
-- it from `v_existing` (already fetched for the score-delta calculation)
-- when this is a resubmission, or from `v_player.current_streak` when
-- it's the first submission for this question — and the `on conflict do
-- update` clause deliberately never overwrites `streak_before` itself,
-- only `streak_bonus`/`points`. That means every resubmission
-- recomputes newStreak/streakBonus from the *same* pre-question anchor,
-- so `players.current_streak` always reflects "as if only the latest pick
-- had ever been submitted" — switching an answer back and forth can
-- never double-bump or double-reset the streak.
--
-- `end_question`'s and `auto_advance_game`'s "no answer" backfill (for
-- players who never submitted before time ran out) now also stamps
-- `streak_before` (from `players.current_streak` at that moment) and
-- resets `players.current_streak` to 0 for exactly those players — a
-- skipped question breaks a streak the same way a wrong answer does.
-- `play_again` zeroes `current_streak` alongside `score` for the rematch.

alter table players
  add column if not exists current_streak integer not null default 0;

comment on column players.current_streak is
  'Consecutive correct answers, most recent question backwards. Reset to 0 on a wrong answer, a skipped question, or play_again. Source of truth for the streak bonus in scoring_config — see 0039_streak_scoring.sql.';

alter table answers
  add column if not exists streak_before integer not null default 0,
  add column if not exists streak_bonus integer not null default 0;

comment on column answers.streak_before is
  'players.current_streak at the moment this question started for this player — the anchor used to (re)compute streak_bonus on every submission/resubmission. Stamped once on first insert, never changed by a resubmission.';
comment on column answers.streak_bonus is
  'The portion of `points` earned from the streak bonus (0 for incorrect/no-answer). Subset of `points`, not additional to it — see submit_answer.';

-- Extend every game's scoring_config with the two new streak knobs.
-- Existing rows already have a concrete jsonb value from the old column
-- default, so altering the default alone wouldn't reach them — merge the
-- new keys into every row that doesn't already have them.
alter table games
  alter column scoring_config set default jsonb_build_object(
    'basePoints', 1000,
    'maxSpeedBonus', 500,
    'incorrectPoints', 0,
    'noAnswerPoints', 0,
    'streakBonusPerCorrect', 100,
    'maxStreakBonus', 500
  );

update games
  set scoring_config = scoring_config || jsonb_build_object(
    'streakBonusPerCorrect', 100,
    'maxStreakBonus', 500
  )
  where not (scoring_config ? 'streakBonusPerCorrect');

-- ---------------------------------------------------------------------
-- submit_answer — multiple_choice / true_false. Same body as 0037's,
-- plus streak bookkeeping.
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
  v_streak_before integer;
  v_new_streak integer;
  v_streak_bonus integer;
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

  if v_game.is_paused then
    raise exception 'This game is currently paused.' using errcode = 'P0013';
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
  v_streak_before := coalesce(v_existing.streak_before, v_player.current_streak);

  if v_is_correct then
    v_speed_ratio := 1 - (v_response_ms::numeric / greatest(v_time_limit_ms, 1));
    v_speed_bonus := round(
      (v_scoring->>'maxSpeedBonus')::numeric * greatest(0, least(1, v_speed_ratio))
    )::integer;
    v_new_streak := v_streak_before + 1;
    v_streak_bonus := least(
      (v_scoring->>'maxStreakBonus')::integer,
      greatest(0, v_new_streak - 1) * (v_scoring->>'streakBonusPerCorrect')::integer
    );
    v_points := (v_scoring->>'basePoints')::integer + v_speed_bonus + v_streak_bonus;
  else
    v_new_streak := 0;
    v_streak_bonus := 0;
    v_points := (v_scoring->>'incorrectPoints')::integer;
  end if;

  insert into answers (
    game_id, round_number, player_id, question_id, selected_option,
    is_correct, response_time_ms, points, streak_before, streak_bonus
  ) values (
    p_game_id, v_game.round_number, v_player.id, v_q.id, p_selected_option,
    v_is_correct, v_response_ms, v_points, v_streak_before, v_streak_bonus
  )
  on conflict (game_id, round_number, player_id, question_id) do update
    set selected_option = excluded.selected_option,
        submitted_text = null,
        submitted_pairing = null,
        submitted_sequence = null,
        is_correct = excluded.is_correct,
        response_time_ms = excluded.response_time_ms,
        points = excluded.points,
        streak_bonus = excluded.streak_bonus;

  update players
    set score = score + (v_points - coalesce(v_existing.points, 0)),
        current_streak = v_new_streak
    where id = v_player.id;

  return query select v_is_correct, v_points;
end;
$$;

-- ---------------------------------------------------------------------
-- submit_text_answer — identification / fill_blank / unscramble / image.
-- ---------------------------------------------------------------------

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
  v_streak_before integer;
  v_new_streak integer;
  v_streak_bonus integer;
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

  if v_game.is_paused then
    raise exception 'This game is currently paused.' using errcode = 'P0013';
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

  v_time_limit_ms := v_effective_limit_secs * 1000;
  v_response_ms := greatest(
    0,
    least(v_time_limit_ms, extract(epoch from (now() - v_game.question_started_at)) * 1000)
  )::integer;

  v_scoring := v_game.scoring_config;
  v_streak_before := coalesce(v_existing.streak_before, v_player.current_streak);

  if v_is_correct then
    v_speed_ratio := 1 - (v_response_ms::numeric / greatest(v_time_limit_ms, 1));
    v_speed_bonus := round(
      (v_scoring->>'maxSpeedBonus')::numeric * greatest(0, least(1, v_speed_ratio))
    )::integer;
    v_new_streak := v_streak_before + 1;
    v_streak_bonus := least(
      (v_scoring->>'maxStreakBonus')::integer,
      greatest(0, v_new_streak - 1) * (v_scoring->>'streakBonusPerCorrect')::integer
    );
    v_points := (v_scoring->>'basePoints')::integer + v_speed_bonus + v_streak_bonus;
  else
    v_new_streak := 0;
    v_streak_bonus := 0;
    v_points := (v_scoring->>'incorrectPoints')::integer;
  end if;

  insert into answers (
    game_id, round_number, player_id, question_id, selected_option, submitted_text,
    is_correct, response_time_ms, points, streak_before, streak_bonus
  ) values (
    p_game_id, v_game.round_number, v_player.id, v_q.id, null, nullif(trim(coalesce(p_answer_text, '')), ''),
    v_is_correct, v_response_ms, v_points, v_streak_before, v_streak_bonus
  )
  on conflict (game_id, round_number, player_id, question_id) do update
    set selected_option = null,
        submitted_text = excluded.submitted_text,
        submitted_pairing = null,
        submitted_sequence = null,
        is_correct = excluded.is_correct,
        response_time_ms = excluded.response_time_ms,
        points = excluded.points,
        streak_bonus = excluded.streak_bonus;

  update players
    set score = score + (v_points - coalesce(v_existing.points, 0)),
        current_streak = v_new_streak
    where id = v_player.id;

  return query select v_is_correct, v_points;
end;
$$;

-- ---------------------------------------------------------------------
-- submit_matching_answer
-- ---------------------------------------------------------------------

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
  v_streak_before integer;
  v_new_streak integer;
  v_streak_bonus integer;
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

  if v_game.is_paused then
    raise exception 'This game is currently paused.' using errcode = 'P0013';
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
  v_streak_before := coalesce(v_existing.streak_before, v_player.current_streak);

  if v_is_correct then
    v_speed_ratio := 1 - (v_response_ms::numeric / greatest(v_time_limit_ms, 1));
    v_speed_bonus := round(
      (v_scoring->>'maxSpeedBonus')::numeric * greatest(0, least(1, v_speed_ratio))
    )::integer;
    v_new_streak := v_streak_before + 1;
    v_streak_bonus := least(
      (v_scoring->>'maxStreakBonus')::integer,
      greatest(0, v_new_streak - 1) * (v_scoring->>'streakBonusPerCorrect')::integer
    );
    v_points := (v_scoring->>'basePoints')::integer + v_speed_bonus + v_streak_bonus;
  else
    v_new_streak := 0;
    v_streak_bonus := 0;
    v_points := (v_scoring->>'incorrectPoints')::integer;
  end if;

  insert into answers (
    game_id, round_number, player_id, question_id, selected_option, submitted_pairing,
    is_correct, response_time_ms, points, streak_before, streak_bonus
  ) values (
    p_game_id, v_game.round_number, v_player.id, v_q.id, null, p_pairing,
    v_is_correct, v_response_ms, v_points, v_streak_before, v_streak_bonus
  )
  on conflict (game_id, round_number, player_id, question_id) do update
    set selected_option = null,
        submitted_text = null,
        submitted_pairing = excluded.submitted_pairing,
        submitted_sequence = null,
        is_correct = excluded.is_correct,
        response_time_ms = excluded.response_time_ms,
        points = excluded.points,
        streak_bonus = excluded.streak_bonus;

  update players
    set score = score + (v_points - coalesce(v_existing.points, 0)),
        current_streak = v_new_streak
    where id = v_player.id;

  return query select v_is_correct, v_points;
end;
$$;

-- ---------------------------------------------------------------------
-- submit_sequence_answer
-- ---------------------------------------------------------------------

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
  v_streak_before integer;
  v_new_streak integer;
  v_streak_bonus integer;
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

  if v_game.is_paused then
    raise exception 'This game is currently paused.' using errcode = 'P0013';
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
  v_streak_before := coalesce(v_existing.streak_before, v_player.current_streak);

  if v_is_correct then
    v_speed_ratio := 1 - (v_response_ms::numeric / greatest(v_time_limit_ms, 1));
    v_speed_bonus := round(
      (v_scoring->>'maxSpeedBonus')::numeric * greatest(0, least(1, v_speed_ratio))
    )::integer;
    v_new_streak := v_streak_before + 1;
    v_streak_bonus := least(
      (v_scoring->>'maxStreakBonus')::integer,
      greatest(0, v_new_streak - 1) * (v_scoring->>'streakBonusPerCorrect')::integer
    );
    v_points := (v_scoring->>'basePoints')::integer + v_speed_bonus + v_streak_bonus;
  else
    v_new_streak := 0;
    v_streak_bonus := 0;
    v_points := (v_scoring->>'incorrectPoints')::integer;
  end if;

  insert into answers (
    game_id, round_number, player_id, question_id, selected_option, submitted_sequence,
    is_correct, response_time_ms, points, streak_before, streak_bonus
  ) values (
    p_game_id, v_game.round_number, v_player.id, v_q.id, null, p_order,
    v_is_correct, v_response_ms, v_points, v_streak_before, v_streak_bonus
  )
  on conflict (game_id, round_number, player_id, question_id) do update
    set selected_option = null,
        submitted_text = null,
        submitted_pairing = null,
        submitted_sequence = excluded.submitted_sequence,
        is_correct = excluded.is_correct,
        response_time_ms = excluded.response_time_ms,
        points = excluded.points,
        streak_bonus = excluded.streak_bonus;

  update players
    set score = score + (v_points - coalesce(v_existing.points, 0)),
        current_streak = v_new_streak
    where id = v_player.id;

  return query select v_is_correct, v_points;
end;
$$;

-- ---------------------------------------------------------------------
-- end_question — same body as 0037's, plus: the no-answer backfill now
-- stamps streak_before per player and resets current_streak to 0 for
-- exactly the players it just backfilled (single statement, via a
-- data-modifying CTE, so it can't race against a submission landing
-- between the insert and a separate update).
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

  if v_game.is_paused then
    raise exception 'This game is currently paused.' using errcode = 'P0013';
  end if;

  if v_game.status <> 'QUESTION' or v_game.current_question_id is null then
    raise exception 'This game is not in the question phase.' using errcode = 'P0001';
  end if;

  select * into v_gq from game_questions where id = v_game.current_question_id;
  v_no_answer_points := (v_game.scoring_config->>'noAnswerPoints')::integer;

  with inserted as (
    insert into answers (
      game_id, round_number, player_id, question_id, selected_option,
      is_correct, response_time_ms, points, streak_before, streak_bonus
    )
    select p_game_id, v_game.round_number, p.id, v_gq.question_id, null, false, null,
      v_no_answer_points, p.current_streak, 0
    from players p
    where p.game_id = p_game_id
      and not exists (
        select 1 from answers a
        where a.game_id = p_game_id
          and a.round_number = v_game.round_number
          and a.player_id = p.id
          and a.question_id = v_gq.question_id
      )
    returning player_id
  )
  update players set current_streak = 0
    where id in (select player_id from inserted);

  update games set status = 'REVEAL', phase_started_at = now() where id = p_game_id;
end;
$$;

-- ---------------------------------------------------------------------
-- auto_advance_game — same body as 0037's, with the same no-answer
-- backfill change as end_question above (its QUESTION branch duplicates
-- end_question's logic — see 0015's header comment for why).
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

  if v_game.is_paused then
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

    with inserted as (
      insert into answers (
        game_id, round_number, player_id, question_id, selected_option,
        is_correct, response_time_ms, points, streak_before, streak_bonus
      )
      select p_game_id, v_game.round_number, p.id, v_gq.question_id, null, false, null,
        v_no_answer_points, p.current_streak, 0
      from players p
      where p.game_id = p_game_id
        and not exists (
          select 1 from answers a
          where a.game_id = p_game_id
            and a.round_number = v_game.round_number
            and a.player_id = p.id
            and a.question_id = v_gq.question_id
        )
      returning player_id
    )
    update players set current_streak = 0
      where id in (select player_id from inserted);

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
-- get_leaderboard — same round-scoped join as 0016's, plus the streak
-- bonus portion of that delta so the LEADERBOARD screen can show
-- "score + streak bonus" instead of just a lump-sum delta.
-- ---------------------------------------------------------------------

create or replace function get_leaderboard(p_game_id uuid)
returns table (
  out_player_id uuid,
  out_nickname text,
  out_score integer,
  out_rank bigint,
  out_score_delta integer,
  out_streak_bonus integer
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
      coalesce(a.points, 0),
      coalesce(a.streak_bonus, 0)
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
-- get_answer_reveal — same body as 0030's, plus out_streak_bonus so the
-- REVEAL screen can show the same "score + streak bonus" breakdown a
-- question earlier than the leaderboard does.
-- ---------------------------------------------------------------------

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
  out_percent_correct numeric,
  out_streak_bonus integer
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
      case when v_total_players > 0 then round(100.0 * v_correct_count / v_total_players, 1) else 0 end,
      coalesce(v_answer.streak_bonus, 0);

  elsif v_q.question_type = 'matching' then
    return query select
      v_q.id, v_q.question_type, null::smallint, null::text,
      null::text, null::text, v_q.match_terms, v_q.match_definitions, v_answer.submitted_pairing,
      null::text[], null::smallint[],
      v_q.explanation, null::smallint, null::text,
      coalesce(v_answer.points, 0), coalesce(v_answer.is_correct, false),
      case when v_total_players > 0 then round(100.0 * v_correct_count / v_total_players, 1) else 0 end,
      coalesce(v_answer.streak_bonus, 0);

  elsif v_q.question_type = 'sequence' then
    return query select
      v_q.id, v_q.question_type, null::smallint, null::text,
      null::text, null::text, null::text[], null::text[], null::smallint[],
      v_q.sequence_items, v_answer.submitted_sequence,
      v_q.explanation, null::smallint, null::text,
      coalesce(v_answer.points, 0), coalesce(v_answer.is_correct, false),
      case when v_total_players > 0 then round(100.0 * v_correct_count / v_total_players, 1) else 0 end,
      coalesce(v_answer.streak_bonus, 0);

  else
    -- identification / fill_blank / unscramble / image
    return query select
      v_q.id, v_q.question_type, null::smallint, null::text,
      v_q.correct_answer, v_q.image_url, null::text[], null::text[], null::smallint[],
      null::text[], null::smallint[],
      v_q.explanation, null::smallint, v_answer.submitted_text,
      coalesce(v_answer.points, 0), coalesce(v_answer.is_correct, false),
      case when v_total_players > 0 then round(100.0 * v_correct_count / v_total_players, 1) else 0 end,
      coalesce(v_answer.streak_bonus, 0);
  end if;
end;
$$;

-- ---------------------------------------------------------------------
-- play_again — same body as 0016's, plus zeroing current_streak
-- alongside score for the rematch.
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

  update players set score = 0, current_streak = 0 where game_id = p_game_id;
end;
$$;
