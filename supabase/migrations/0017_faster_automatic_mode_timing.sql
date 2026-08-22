-- Pinoy Quiz — 0017: Automatic mode felt too slow — retune phase
-- durations
--
-- Reported directly: Automatic mode felt sluggish. The cause was the
-- fixed REVEAL_SECONDS/LEADERBOARD_SECONDS constants set in
-- 0015_automatic_mode_and_answer_behavior.sql — 6s + 5s = 11 seconds of
-- pure "waiting for the auto-advance timer" dead time on TOP of however
-- long the question itself takes, every single question. A 10-question
-- Automatic game was spending roughly two full minutes just sitting on
-- Reveal/Leaderboard screens with nothing left to do on them, before
-- counting the actual question time at all.
--
-- This migration only retunes those two constants — the mechanism itself
-- (auto_advance_game, phase_started_at, any-participant polling) is
-- unchanged and still fully explained in 0015's header comment:
--   REVEAL_SECONDS:      6 -> 3   (still enough to read a short
--                                  explanation and the correct answer;
--                                  the original 6s was sized generously
--                                  rather than tightly)
--   LEADERBOARD_SECONDS:  5 -> 2   (a rank/score change reads in about a
--                                  second; 5s was the biggest single
--                                  contributor to the sluggish feeling)
--   COUNTDOWN_SECONDS:    3 -> 3   (unchanged — this one is a cosmetic
--                                  "3, 2, 1, Go" the player is meant to
--                                  watch tick down, not dead time to
--                                  trim, and it has to keep matching
--                                  CountdownOverlay's default seconds
--                                  prop on the client)
--
-- src/hooks/useAutoAdvance.ts's poll interval also drops from 1000ms to
-- 500ms, so the extra lag between a phase's timer actually elapsing and
-- some client's next poll picking it up shrinks too — see that file for
-- why 500ms still stays comfortably under auto_advance_game's rate limit
-- (0015: 60 calls / 20s per user, i.e. an average of 3/s; 500ms is 2/s).
--
-- Net effect per question: ~11s of forced dead time drops to ~5s, plus
-- less than half as much poll lag on either side of it.

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
  countdown_seconds constant int := 3;   -- unchanged — matches CountdownOverlay
  reveal_seconds constant int := 3;      -- was 6
  leaderboard_seconds constant int := 2; -- was 5
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
