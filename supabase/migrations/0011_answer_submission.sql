-- Pinoy Quiz — 0011: answer submission and scoring (Phase 6)
--
-- Covers the rest of the state machine's live-play half: submitting an
-- answer, the configurable scoring formula (games.scoring_config), the
-- QUESTION -> REVEAL transition, and a scoped reveal read. Advancing from
-- REVEAL to LEADERBOARD, moving to the next question, and FINISHED are
-- Phase 7 — deliberately not built here.

-- submit_answer: any participant, once per question. Validates the game is
-- actually in QUESTION status and the caller hasn't already answered this
-- question (the DB's answers_one_per_player_per_question constraint is the
-- real backstop, but we check first for a friendly error instead of a raw
-- constraint violation). Correctness and timing are both computed
-- server-side: correctness by mapping the *displayed* option the player
-- picked back through this game's shuffle_map to the question's real
-- correct_option, and timing from now() minus the server-authoritative
-- games.question_started_at — never from a client-reported elapsed time.
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
  v_correct_index smallint; -- 0-3, original A-D index of the correct option
  v_correct_slot smallint;  -- 0-3, displayed slot (post-shuffle) that is correct
  v_is_correct boolean;
  v_response_ms integer;
  v_time_limit_ms integer;
  v_scoring jsonb;
  v_speed_ratio numeric;
  v_speed_bonus integer;
  v_points integer;
begin
  if v_uid is null then
    raise exception 'You must be signed in.' using errcode = '28000';
  end if;

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

  if exists (
    select 1 from answers
    where game_id = p_game_id
      and player_id = v_player.id
      and question_id = (select question_id from game_questions where id = v_game.current_question_id)
  ) then
    raise exception 'You already answered this question.' using errcode = 'P0008';
  end if;

  select * into v_gq from game_questions where id = v_game.current_question_id;
  select * into v_q from questions where id = v_gq.question_id;

  -- Original A/B/C/D index (0-3) of the correct option.
  v_correct_index := array_position(array['A','B','C','D'], v_q.correct_option::text) - 1;
  -- Which *displayed* slot (post-shuffle) currently shows that original index.
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
    game_id, player_id, question_id, selected_option,
    is_correct, response_time_ms, points
  ) values (
    p_game_id, v_player.id, v_q.id, p_selected_option,
    v_is_correct, v_response_ms, v_points
  );

  update players set score = score + v_points where id = v_player.id;

  return query select v_is_correct, v_points;
end;
$$;


-- end_question: host-only. Called once the host's client-side timer runs
-- out (a purely display-driven trigger — the server doesn't otherwise
-- police the clock, matching the rest of this app's "host controls
-- pacing" pattern from Phase 5). Anyone who never submitted an answer for
-- the live question gets a zero-points "no answer" row inserted, using
-- noAnswerPoints from the same per-game scoring_config, so scoring stays
-- table-driven rather than a hard-coded constant. Then flips
-- QUESTION -> REVEAL.
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

  insert into answers (game_id, player_id, question_id, selected_option, is_correct, response_time_ms, points)
  select p_game_id, p.id, v_gq.question_id, null, false, null, v_no_answer_points
  from players p
  where p.game_id = p_game_id
    and not exists (
      select 1 from answers a
      where a.game_id = p_game_id and a.player_id = p.id and a.question_id = v_gq.question_id
    );

  update games set status = 'REVEAL' where id = p_game_id;
end;
$$;


-- get_answer_reveal: any participant, only while the game is in REVEAL.
-- Returns the correct answer (in this game's displayed/shuffled slot, so
-- the client can highlight the same option it rendered during QUESTION),
-- an explanation if one exists, this player's own submission and points,
-- and the percentage of players in the game who answered correctly —
-- computed here server-side rather than by relaxing answers_select_own,
-- so one player still can never read another's individual answer row.
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
    return; -- no rows — nothing to reveal right now
  end if;

  select * into v_gq from game_questions where id = v_game.current_question_id;
  select * into v_q from questions where id = v_gq.question_id;
  v_opts := array[v_q.option_a, v_q.option_b, v_q.option_c, v_q.option_d];

  v_correct_index := array_position(array['A','B','C','D'], v_q.correct_option::text) - 1;
  v_correct_slot := array_position(v_gq.shuffle_map, v_correct_index) - 1;

  select * into v_answer from answers
    where game_id = p_game_id and player_id = v_player.id and question_id = v_q.id;

  select count(*) into v_total_players from players where game_id = p_game_id;
  select count(*) into v_correct_count from answers
    where game_id = p_game_id and question_id = v_q.id and is_correct;

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


revoke execute on function submit_answer(uuid, smallint) from public;
revoke execute on function end_question(uuid) from public;
revoke execute on function get_answer_reveal(uuid) from public;

grant execute on function submit_answer(uuid, smallint) to authenticated;
grant execute on function end_question(uuid) to authenticated;
grant execute on function get_answer_reveal(uuid) to authenticated;
