-- Pinoy Quiz — 0012: leaderboard and game completion (Phase 7)
--
-- Closes the loop the state machine has been stopping short of since
-- Phase 5/6: REVEAL -> LEADERBOARD -> (next QUESTION | FINISHED). Three
-- new host-callable/participant-callable functions, following the exact
-- SECURITY DEFINER pattern used by every write/scoped-read so far.

-- get_leaderboard: any participant, any status. Ranked standings for the
-- whole game (same ranking the `leaderboard` view already computes:
-- score desc, joined_at asc), plus a per-player `score_delta` — the points
-- earned on the question that was just played. Delta has to come from a
-- SECURITY DEFINER function rather than a direct client query against
-- `answers`, because `answers_select_own` (0005_rls.sql) only lets a
-- player read their own submissions — exactly the same reason
-- `get_answer_reveal`'s percent_correct is computed server-side in
-- 0011_answer_submission.sql. The `leaderboard` view itself remains fine
-- for the ranked score/rank columns (it's already client-readable), but
-- since we need one function anyway for the delta, it returns everything
-- the LEADERBOARD screen needs in a single call.
--
-- Also used, unmodified, by the FINISHED/Results screen: at that point
-- `current_question_id` still points at the last game_questions row
-- played, so score_delta there reflects "how the final question went" —
-- harmless, since Results only displays final score/rank, not the delta.
create or replace function get_leaderboard(p_game_id uuid)
returns table (
  out_player_id uuid,
  out_nickname text,
  out_score integer,
  out_rank bigint,
  out_score_delta integer
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
      coalesce(a.points, 0)
    from players p
    left join answers a
      on a.player_id = p.id
      and a.game_id = p_game_id
      and a.question_id = v_last_question_id
    where p.game_id = p_game_id
    order by rank() over (order by p.score desc, p.joined_at asc);
end;
$$;


-- advance_to_leaderboard: host-only. REVEAL -> LEADERBOARD. A pure status
-- flip — score_delta is computed on read (get_leaderboard above) from the
-- answers already recorded during REVEAL/end_question, so nothing else on
-- the row needs to change here.
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

  update games set status = 'LEADERBOARD' where id = p_game_id;
end;
$$;


-- advance_question: host-only. LEADERBOARD -> next QUESTION, mirroring
-- begin_first_question's pattern (0010_game_engine.sql) for anchoring the
-- server-authoritative timer. If the question just shown on the
-- leaderboard was the last one in the set, moves to FINISHED instead and
-- stamps finished_at — the only way a game ever reaches FINISHED.
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

  select * into v_game from games where id = p_game_id;
  if not found then
    raise exception 'Game not found.' using errcode = 'P0002';
  end if;

  if v_game.host_user_id <> v_uid then
    raise exception 'Only the host can do that.' using errcode = '42501';
  end if;

  if v_game.status <> 'LEADERBOARD' then
    raise exception 'This game is not on the leaderboard screen.' using errcode = 'P0001';
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
end;
$$;


revoke execute on function get_leaderboard(uuid) from public;
revoke execute on function advance_to_leaderboard(uuid) from public;
revoke execute on function advance_question(uuid) from public;

grant execute on function get_leaderboard(uuid) to authenticated;
grant execute on function advance_to_leaderboard(uuid) to authenticated;
grant execute on function advance_question(uuid) to authenticated;
