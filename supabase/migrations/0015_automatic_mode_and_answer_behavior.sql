-- Pinoy Quiz — 0015: Automatic game mode + configurable Answer Behavior
--
-- Two independent, orthogonal per-game settings, chosen at create_game time
-- (host-only, same as category/difficulty/question_count/time_limit_seconds):
--
--   game_mode        HOST_CONTROLLED (existing behavior, now named) |
--                     AUTOMATIC (new)
--   answer_behavior   LOCK_ON_SELECTION (existing behavior, now named) |
--                     CHANGE_UNTIL_TIMER_ENDS (new)
--
-- Both default to the pre-existing behavior, so every game already in
-- flight (or replayed against an older client build) keeps working exactly
-- as before — see "Backward compatibility" below.
--
-- ---------------------------------------------------------------------
-- 1. Automatic mode — mechanism
-- ---------------------------------------------------------------------
--
-- This project has no server-side cron/scheduled-function infrastructure
-- (no pg_cron extension, no Supabase Edge Functions anywhere in this repo
-- — see docs/ARCHITECTURE.md). Every write so far is a plain client-called
-- SECURITY DEFINER function; nothing runs on a timer inside Postgres
-- itself. So "the game must not depend on the host's browser to advance"
-- can't mean "a background job on the server does it" here — that
-- infrastructure doesn't exist in this stack and adding pg_cron/Edge
-- Functions is a hosting-platform decision out of scope for a feature
-- migration (and Phase 12 — production deployment — is explicitly the
-- next task, still unstarted).
--
-- Instead this reuses the exact pattern Phase 8 already established for
-- "the host might be the one who's gone" (mark_stale_players /
-- claim_host, see 0013_disconnect_reconnect.sql's header comment): a
-- single new function, auto_advance_game, that
--   - any participant can call, not just the host,
--   - is a pure no-op unless the relevant phase's server-anchored
--     timestamp shows real elapsed time past that phase's duration, and
--   - is safe to call redundantly and concurrently (see the `for update`
--     lock below) — calling it from every connected client's timer,
--     slightly out of sync with each other, is not just tolerated but the
--     whole point.
--
-- The client side (src/hooks/useAutoAdvance.ts) is the same shape as
-- useHeartbeat.ts: every connected client polls this on a short interval
-- whenever games.game_mode = 'AUTOMATIC' and the game hasn't finished.
-- Because ANY client does this — not just the host's — the game keeps
-- advancing as long as at least one participant's tab is open, even if
-- the host is the one who disconnected. That satisfies "host
-- disconnecting during Automatic Mode does not stop the game" honestly,
-- given what this stack actually has available, rather than promising a
-- true background-job guarantee this codebase has no way to deliver.
--
-- Phase timing: QUESTION already has a server-authoritative anchor
-- (games.question_started_at, used since Phase 5/6 for both the display
-- timer and submit_answer's response-time clamp — untouched here). The
-- three other timed phases (COUNTDOWN, REVEAL, LEADERBOARD) had no
-- anchor at all before this migration, because they were previously only
-- ever advanced by an explicit host click with no server-side duration.
-- A single new nullable column, games.phase_started_at, now serves all
-- three — set to now() at the moment each phase begins (start_game for
-- COUNTDOWN, end_question for REVEAL, advance_to_leaderboard for
-- LEADERBOARD) and left alone otherwise. It's harmless to set even for
-- Host-Controlled games — nothing reads it there.
--
-- Fixed phase durations (COUNTDOWN/REVEAL/LEADERBOARD are not
-- per-game-configurable settings — only QUESTION's duration is, via the
-- existing time_limit_seconds — so these are plain constants, same as
-- Phase 8's STALE_SECONDS or Phase 9's rate-limit numbers):
--   COUNTDOWN_SECONDS   3  — matches CountdownOverlay's existing default
--                            cosmetic countdown (`seconds = 3`), so the
--                            real automatic transition and the animation
--                            every client already sees land together.
--   REVEAL_SECONDS      6  — enough to actually read the correct answer
--                            and explanation before it moves on;
--                            RevealScreen has real content (explanation
--                            text, percent-correct) that a 2-3s flash
--                            wouldn't do justice to.
--   LEADERBOARD_SECONDS  5 — enough to see your rank change before the
--                            next question, shorter than REVEAL_SECONDS
--                            since there's less to read here.
--
-- ---------------------------------------------------------------------
-- 2. Answer Behavior — mechanism
-- ---------------------------------------------------------------------
--
-- LOCK_ON_SELECTION reproduces submit_answer's pre-existing body exactly
-- (single INSERT, `answers_one_per_player_per_question` rejects a
-- second attempt, mapped to the existing "You already answered this
-- question" friendly message).
--
-- CHANGE_UNTIL_TIMER_ENDS instead UPSERTs the same row (`on conflict
-- (game_id, player_id, question_id) do update`) — the unique constraint
-- that used to be a hard "one submission ever" rule becomes the natural
-- upsert target for "this player's current answer to this question",
-- with each new selection recomputing correctness/points from scratch
-- and replacing the previous one, never inserting a second row (so
-- get_answer_reveal's is_correct/points lookup and end_question's
-- "already answered" exists-check both keep working unmodified — neither
-- was touched by this migration). players.score is adjusted by the
-- *delta* between the new and previous points on a change, not
-- incremented again by the full new amount, so switching an answer never
-- double-counts.
--
-- Both behaviors share one new hard cutoff: submit_answer now rejects a
-- submission (or change) once real elapsed time since
-- games.question_started_at has actually passed time_limit_seconds, even
-- if games.status hasn't flipped to REVEAL yet. Previously the only gate
-- was `status = 'QUESTION'`, which is fine when a host clicks
-- end_question as soon as the display timer hits zero, but
-- CHANGE_UNTIL_TIMER_ENDS specifically invites a player to keep tapping
-- right up to zero — closing the small "status hasn't flipped yet" window
-- between the clock actually running out and end_question/auto_advance_game
-- actually landing matters more once changing-until-the-wire is the
-- intended, encouraged interaction rather than an edge case. This applies
-- to LOCK_ON_SELECTION too (a strictly tighter check than before, never
-- looser), which is a deliberate small hardening, not a behavior this
-- migration was asked to change — flagged here rather than left silent.
--
-- ---------------------------------------------------------------------
-- 3. Backward compatibility
-- ---------------------------------------------------------------------
--
-- `game_mode` and `answer_behavior` are both `not null default` columns,
-- so every existing row (and every INSERT from an old, un-upgraded
-- client that doesn't know these params exist) lands on
-- HOST_CONTROLLED + LOCK_ON_SELECTION — exactly Phases 1-11's only
-- behavior. `create_game`'s two new parameters are appended at the end
-- of the argument list with defaults, so old positional/named calls
-- still work unchanged. No existing question, room, player, or answer
-- data is touched — this migration only adds columns/functions and
-- replaces function bodies (create_or_replace, never drop-and-lose-data).

-- ---------------------------------------------------------------------
-- Schema
-- ---------------------------------------------------------------------

create type game_mode as enum ('HOST_CONTROLLED', 'AUTOMATIC');
create type answer_behavior as enum ('LOCK_ON_SELECTION', 'CHANGE_UNTIL_TIMER_ENDS');

alter table games
  add column game_mode game_mode not null default 'HOST_CONTROLLED',
  add column answer_behavior answer_behavior not null default 'LOCK_ON_SELECTION',
  add column phase_started_at timestamptz;

comment on column games.phase_started_at is
  'Server-anchored start time for the current COUNTDOWN/REVEAL/LEADERBOARD phase, used only by auto_advance_game (Automatic mode). QUESTION uses the existing question_started_at instead — unchanged.';

-- create_game's signature grows by two (both defaulted) params, which
-- changes its argument-type identity — `create or replace` cannot widen a
-- function's own argument list, it can only replace a function with the
-- exact same one. Drop the old 5-arg signature explicitly, then create the
-- 7-arg replacement, rather than leaving both overloads callable.
drop function if exists create_game(game_category_setting, game_difficulty_setting, smallint, smallint, text);

create or replace function create_game(
  p_category game_category_setting default 'random',
  p_difficulty game_difficulty_setting default 'mixed',
  p_question_count smallint default 10,
  p_time_limit_seconds smallint default 15,
  p_host_nickname text default 'Host',
  p_game_mode game_mode default 'HOST_CONTROLLED',
  p_answer_behavior answer_behavior default 'LOCK_ON_SELECTION'
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
begin
  if v_uid is null then
    raise exception 'You must be signed in to create a game.' using errcode = '28000';
  end if;

  perform enforce_rate_limit('create_game', 10, 60);

  if char_length(v_nickname) < 1 or char_length(v_nickname) > 20 then
    raise exception 'Nickname must be between 1 and 20 characters.' using errcode = '22023';
  end if;

  loop
    v_attempt := v_attempt + 1;
    v_room_code := generate_room_code();
    begin
      insert into games (
        room_code, host_user_id, category, difficulty, question_count,
        time_limit_seconds, game_mode, answer_behavior
      )
      values (
        v_room_code, v_uid, p_category, p_difficulty, p_question_count,
        p_time_limit_seconds, p_game_mode, p_answer_behavior
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
  game_category_setting, game_difficulty_setting, smallint, smallint, text, game_mode, answer_behavior
) to authenticated;

-- ---------------------------------------------------------------------
-- start_game — unchanged behavior, +phase_started_at anchor for COUNTDOWN
-- ---------------------------------------------------------------------

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
  v_category_filter text;
  v_difficulty_filter text;
  v_question_ids uuid[];
  v_qid uuid;
  v_order smallint := 0;
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

  v_category_filter := nullif(v_game.category::text, 'random');
  v_difficulty_filter := nullif(v_game.difficulty::text, 'mixed');

  select array_agg(id) into v_question_ids
  from (
    select id from questions
    where (v_category_filter is null or category::text = v_category_filter)
      and (v_difficulty_filter is null or difficulty::text = v_difficulty_filter)
    order by random()
    limit v_game.question_count
  ) sub;

  if v_question_ids is null or array_length(v_question_ids, 1) < v_game.question_count then
    raise exception 'Not enough questions available for these settings. Try Random category or Mixed difficulty.'
      using errcode = 'P0005';
  end if;

  foreach v_qid in array v_question_ids loop
    insert into game_questions (game_id, question_id, question_order, shuffle_map)
    values (
      p_game_id,
      v_qid,
      v_order,
      (select array(select x from unnest(array[0,1,2,3]::smallint[]) x order by random()))
    );
    v_order := v_order + 1;
  end loop;

  update games set status = 'COUNTDOWN', started_at = now(), phase_started_at = now() where id = p_game_id;
end;
$$;

-- ---------------------------------------------------------------------
-- submit_answer — LOCK_ON_SELECTION unchanged; CHANGE_UNTIL_TIMER_ENDS
-- upserts; both gated by a real-elapsed-time cutoff in addition to the
-- existing status check (see header comment, section 2).
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

  -- Real-elapsed-time cutoff — see this migration's header comment,
  -- section 2, for why this is checked in addition to `status = 'QUESTION'`.
  if now() >= v_game.question_started_at + make_interval(secs => v_game.time_limit_seconds) then
    raise exception 'This question is no longer accepting answers.' using errcode = 'P0007';
  end if;

  select * into v_gq from game_questions where id = v_game.current_question_id;
  select * into v_q from questions where id = v_gq.question_id;

  select * into v_existing from answers
    where game_id = p_game_id
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
    game_id, player_id, question_id, selected_option,
    is_correct, response_time_ms, points
  ) values (
    p_game_id, v_player.id, v_q.id, p_selected_option,
    v_is_correct, v_response_ms, v_points
  )
  on conflict (game_id, player_id, question_id) do update
    set selected_option = excluded.selected_option,
        is_correct = excluded.is_correct,
        response_time_ms = excluded.response_time_ms,
        points = excluded.points;

  -- Adjust the player's running total by the *delta* from whatever this
  -- exact submission previously scored (0 on a brand-new answer), never
  -- by the full new amount again — otherwise changing an answer under
  -- CHANGE_UNTIL_TIMER_ENDS would double-count every intermediate pick.
  update players
    set score = score + (v_points - coalesce(v_existing.points, 0))
    where id = v_player.id;

  return query select v_is_correct, v_points;
end;
$$;

-- ---------------------------------------------------------------------
-- end_question — unchanged behavior, +phase_started_at anchor for REVEAL
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

  update games set status = 'REVEAL', phase_started_at = now() where id = p_game_id;
end;
$$;

-- ---------------------------------------------------------------------
-- advance_to_leaderboard — unchanged behavior, +phase_started_at anchor
-- ---------------------------------------------------------------------

create or replace function advance_to_leaderboard(p_game_id uuid)
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

  perform enforce_rate_limit('advance_to_leaderboard', 10, 10);

  select * into v_game from games where id = p_game_id;
  if not found then
    raise exception 'Game not found.' using errcode = 'P0002';
  end if;

  if v_game.host_user_id <> v_uid then
    raise exception 'Only the host can do that.' using errcode = '42501';
  end if;

  if v_game.status <> 'REVEAL' then
    raise exception 'This game is not in the reveal phase.' using errcode = 'P0001';
  end if;

  update games set status = 'LEADERBOARD', phase_started_at = now() where id = p_game_id;
end;
$$;

-- advance_question (LEADERBOARD -> next QUESTION | FINISHED) needs no
-- change at all — QUESTION already anchors on question_started_at, and
-- FINISHED isn't a timed phase auto_advance_game ever waits on.

-- ---------------------------------------------------------------------
-- auto_advance_game — new. Automatic-mode-only, any-participant-callable
-- equivalent of begin_first_question / end_question / advance_to_leaderboard
-- / advance_question, gated on real server-elapsed time instead of a host
-- click. See this migration's header comment, section 1, for the full
-- design rationale.
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
  v_no_answer_points integer;
  v_next_index smallint;
  v_next_gq_id uuid;
  countdown_seconds constant int := 3;   -- matches CountdownOverlay's cosmetic default
  reveal_seconds constant int := 6;
  leaderboard_seconds constant int := 5;
begin
  if v_uid is null then
    raise exception 'You must be signed in.' using errcode = '28000';
  end if;

  perform enforce_rate_limit('auto_advance_game', 60, 20);

  -- `for update` locks the games row for the rest of this transaction, so
  -- concurrent calls from several clients' polling timers (the expected,
  -- normal case — see header comment) serialize against each other rather
  -- than racing: whichever commits first performs the transition and
  -- moves `status`/the relevant `*_started_at` column past the condition
  -- below, so every other concurrent caller's own re-read after acquiring
  -- the lock sees the already-updated row and falls through to a no-op.
  -- Same fix as claim_host's TOCTOU close in 0014_security_hardening.sql.
  select * into v_game from games where id = p_game_id for update;
  if not found then
    raise exception 'Game not found.' using errcode = 'P0002';
  end if;

  if not exists (select 1 from players where game_id = p_game_id and user_id = v_uid) then
    raise exception 'You are not part of this game.' using errcode = '42501';
  end if;

  -- Not an Automatic-mode game, or nothing timed to advance right now —
  -- both are ordinary, expected outcomes of a client polling on a plain
  -- interval (see useAutoAdvance.ts), not errors.
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
      where game_id = p_game_id and question_order = 0;

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

    insert into answers (game_id, player_id, question_id, selected_option, is_correct, response_time_ms, points)
    select p_game_id, p.id, v_gq.question_id, null, false, null, v_no_answer_points
    from players p
    where p.game_id = p_game_id
      and not exists (
        select 1 from answers a
        where a.game_id = p_game_id and a.player_id = p.id and a.question_id = v_gq.question_id
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
        where game_id = p_game_id and question_order = v_next_index;

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

  -- WAITING/FINISHED: nothing to auto-advance.
end;
$$;

revoke execute on function auto_advance_game(uuid) from public;
grant execute on function auto_advance_game(uuid) to authenticated;
