-- Pinoy Quiz — 0037: host pause/resume
--
-- Adds a host-only pause/resume control layered on top of the existing
-- status machine rather than a new games.status value: is_paused is a
-- boolean flag that freezes a game in whatever phase it's already in
-- (QUESTION/REVEAL/LEADERBOARD), so current_question_index,
-- current_question_id, round_number, and every other bit of progress
-- stay exactly as they are while paused — nothing about "which question,
-- which phase" changes. Scoped to those three phases only: COUNTDOWN is a
-- purely cosmetic 3-2-1 client animation with no server timer to freeze
-- (see CountdownOverlay.tsx), and WAITING/FINISHED aren't "gameplay" in
-- the sense this feature targets.
--
-- Timer preservation: pausing does NOT stop real time from passing, so
-- resuming shifts question_started_at/phase_started_at forward by however
-- long the pause lasted (paused_at to now()). Every timer-consuming
-- reader — get_current_question, submit_*_answer's response-time math,
-- auto_advance_game's elapsed checks, and the client's own
-- useServerTimer (which reads games.question_started_at, kept live via
-- the existing Realtime subscription on `games`) — already derives
-- "remaining time" purely from that timestamp plus a duration, so
-- shifting it is enough to make the countdown continue from exactly where
-- it left off, with zero changes to any of that math. While paused, the
-- client freezes its own display using paused_at as its clock anchor
-- instead of the real wall clock — see useServerTimer.ts.
--
-- Real-time sync: no new channel/table needed. is_paused/paused_at live on
-- the same `games` row every client already subscribes to
-- (useGameRealtime.ts), so a pause/resume reaches every connected player,
-- and a player who joins or reconnects mid-pause sees the correct state
-- immediately from the initial row fetch — same mechanism as any other
-- status change.

alter table games
  add column if not exists is_paused boolean not null default false,
  add column if not exists paused_at timestamptz;

comment on column games.is_paused is
  'Host-toggled pause flag. Freezes whichever phase the game is already in (QUESTION/REVEAL/LEADERBOARD) — see pause_game/resume_game.';
comment on column games.paused_at is
  'When the current pause began. Null while not paused. Used by resume_game to compute how long to shift question_started_at/phase_started_at forward by.';

-- ---------------------------------------------------------------------
-- pause_game — host-only. No-op-safe guards: rejects if already paused,
-- or if the game isn't in a pausable phase.
-- ---------------------------------------------------------------------

create or replace function pause_game(p_game_id uuid)
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

  perform enforce_rate_limit('pause_game', 20, 30);

  select * into v_game from games where id = p_game_id for update;
  if not found then
    raise exception 'Game not found.' using errcode = 'P0002';
  end if;

  if v_game.host_user_id <> v_uid then
    raise exception 'Only the host can do that.' using errcode = '42501';
  end if;

  if v_game.is_paused then
    raise exception 'This game is already paused.' using errcode = 'P0010';
  end if;

  if v_game.status not in ('QUESTION', 'REVEAL', 'LEADERBOARD') then
    raise exception 'This game cannot be paused right now.' using errcode = 'P0011';
  end if;

  update games set is_paused = true, paused_at = now() where id = p_game_id;
end;
$$;

grant execute on function pause_game(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- resume_game — host-only. Shifts both phase timestamps forward by the
-- pause's real duration so every existing "elapsed since X" calculation
-- (client display timer, submit_*_answer's response-time clamping,
-- auto_advance_game's due-check) continues exactly where it left off
-- instead of counting the paused interval as elapsed time.
-- ---------------------------------------------------------------------

create or replace function resume_game(p_game_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_game games%rowtype;
  v_pause_duration interval;
begin
  if v_uid is null then
    raise exception 'You must be signed in.' using errcode = '28000';
  end if;

  perform enforce_rate_limit('resume_game', 20, 30);

  select * into v_game from games where id = p_game_id for update;
  if not found then
    raise exception 'Game not found.' using errcode = 'P0002';
  end if;

  if v_game.host_user_id <> v_uid then
    raise exception 'Only the host can do that.' using errcode = '42501';
  end if;

  if not v_game.is_paused or v_game.paused_at is null then
    raise exception 'This game is not currently paused.' using errcode = 'P0012';
  end if;

  v_pause_duration := now() - v_game.paused_at;

  update games
    set is_paused = false,
        paused_at = null,
        question_started_at = case
          when question_started_at is not null then question_started_at + v_pause_duration
          else question_started_at
        end,
        phase_started_at = case
          when phase_started_at is not null then phase_started_at + v_pause_duration
          else phase_started_at
        end
    where id = p_game_id;
end;
$$;

grant execute on function resume_game(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- Guard every player-facing/host-facing state-mutating function against
-- acting while paused. Read-only functions (get_current_question,
-- get_answer_reveal, get_leaderboard) are deliberately left untouched —
-- a paused game still needs to serve its current question/reveal/
-- leaderboard payload to a client rendering the paused overlay, and to
-- anyone reconnecting mid-pause. claim_host and heartbeat/
-- mark_stale_players are also left untouched — a stale host can still be
-- taken over, and connectivity tracking still runs, while paused.
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

create or replace function begin_first_question(p_game_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_game games%rowtype;
  v_gq_id uuid;
begin
  if v_uid is null then
    raise exception 'You must be signed in.' using errcode = '28000';
  end if;

  perform enforce_rate_limit('begin_first_question', 10, 10);

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

  if v_game.status <> 'COUNTDOWN' then
    raise exception 'This game is not ready to begin.' using errcode = 'P0001';
  end if;

  select id into v_gq_id from game_questions
  where game_id = p_game_id and question_order = 0;

  if v_gq_id is null then
    raise exception 'No questions were prepared for this game.' using errcode = 'P0006';
  end if;

  update games
    set status = 'QUESTION',
        current_question_index = 0,
        current_question_id = v_gq_id,
        question_started_at = now()
    where id = p_game_id;
end;
$$;

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
end;
$$;

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

  if v_game.is_paused then
    raise exception 'This game is currently paused.' using errcode = 'P0013';
  end if;

  if v_game.status <> 'REVEAL' then
    raise exception 'This game is not in the reveal phase.' using errcode = 'P0001';
  end if;

  update games set status = 'LEADERBOARD', phase_started_at = now() where id = p_game_id;
end;
$$;

create or replace function advance_question(p_game_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_game games%rowtype;
  v_next_index smallint;
  v_next_gq_id uuid;
begin
  if v_uid is null then
    raise exception 'You must be signed in.' using errcode = '28000';
  end if;

  perform enforce_rate_limit('advance_question', 10, 10);

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

  if v_game.status <> 'LEADERBOARD' then
    raise exception 'This game is not on the leaderboard screen.' using errcode = 'P0001';
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
end;
$$;

-- auto_advance_game: same body as 0036's version, plus an is_paused
-- early-return right after the game_mode check — every connected client
-- keeps polling this while paused (harmless), it just does nothing until
-- the host resumes.
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
