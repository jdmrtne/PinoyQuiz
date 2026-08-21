-- Pinoy Quiz — 0010: game engine (Phase 5)
--
-- Covers the state machine from WAITING through serving the first
-- question: WAITING -> COUNTDOWN -> QUESTION. Answer submission, scoring,
-- and the REVEAL/LEADERBOARD/next-question/FINISHED transitions are
-- Phase 6/7 — deliberately not built here, so the state machine stops
-- part-way through its full cycle for now.

-- start_game: host-only. Builds this game's randomized, de-duplicated
-- question set (respecting the category/difficulty settings chosen at
-- creation) and moves the room from WAITING to COUNTDOWN. Does NOT yet
-- reveal a question to anyone — see begin_first_question.
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

  -- 'random'/'mixed' settings mean "no filter on that column"
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

  update games set status = 'COUNTDOWN', started_at = now() where id = p_game_id;
end;
$$;


-- begin_first_question: host-only. Flips COUNTDOWN -> QUESTION and anchors
-- the server-authoritative timer (question_started_at). The client plays
-- a purely cosmetic countdown animation, then the host's client calls
-- this. A later phase may automate this away from being host-triggered,
-- but restricting it to the host for now means an impatient non-host
-- client can't cut the countdown short for everyone else.
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

  select * into v_game from games where id = p_game_id;
  if not found then
    raise exception 'Game not found.' using errcode = 'P0002';
  end if;

  if v_game.host_user_id <> v_uid then
    raise exception 'Only the host can do that.' using errcode = '42501';
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


-- get_current_question: any participant. Returns ONLY the currently-live
-- question, with its answer options already shuffled into this game's
-- per-question order (via game_questions.shuffle_map) and NO correct-answer
-- field — the anti-cheat boundary from Phase 2 carried through to live
-- play. Returns zero rows if the game isn't in QUESTION status, so a
-- client can't fetch ahead by guessing at question IDs.
create or replace function get_current_question(p_game_id uuid)
returns table (
  out_question_id uuid,
  out_prompt text,
  out_option_1 text,
  out_option_2 text,
  out_option_3 text,
  out_option_4 text,
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
    return; -- no rows — nothing to show right now
  end if;

  select * into v_gq from game_questions where id = v_game.current_question_id;
  select * into v_q from questions where id = v_gq.question_id;

  v_opts := array[v_q.option_a, v_q.option_b, v_q.option_c, v_q.option_d];

  return query select
    v_q.id,
    v_q.prompt,
    v_opts[v_gq.shuffle_map[1] + 1],
    v_opts[v_gq.shuffle_map[2] + 1],
    v_opts[v_gq.shuffle_map[3] + 1],
    v_opts[v_gq.shuffle_map[4] + 1],
    (v_gq.question_order + 1)::smallint,
    v_game.question_count,
    v_game.time_limit_seconds,
    v_game.question_started_at;
end;
$$;


revoke execute on function start_game(uuid) from public;
revoke execute on function begin_first_question(uuid) from public;
revoke execute on function get_current_question(uuid) from public;

grant execute on function start_game(uuid) to authenticated;
grant execute on function begin_first_question(uuid) to authenticated;
grant execute on function get_current_question(uuid) to authenticated;
