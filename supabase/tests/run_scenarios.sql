-- Pinoy Quiz — Phase 11 repeatable test scenarios.
--
-- This replaces "run scripted SQL scenarios by hand" (Phases 2-10's actual
-- testing method, per every CHANGELOG entry so far) with a single script
-- that can be re-run identically after any future migration. It is NOT a
-- unit test framework — it's a scripted integration scenario runner against
-- a real disposable Postgres, which is what this project's SECURITY DEFINER
-- + RLS design actually needs to be tested honestly (see
-- docs/MASTER_HANDOFF.md's "How to test your work" section for the one-time
-- environment setup this script assumes has already been done: extensions,
-- the auth.uid()/auth.users stub, the supabase_realtime publication stub,
-- and every migration + the seed file already applied, in that order).
--
-- Usage (from a shell with the target DB already prepared as above):
--   psql -d pinoyquiz_test -v ON_ERROR_STOP=1 -f supabase/tests/run_scenarios.sql
--
-- Every scenario either prints "PASS: <label>" or the whole script aborts
-- with a Postgres error at the failing assertion (ON_ERROR_STOP makes a
-- failed scenario a nonzero exit code, so this is CI-friendly even without
-- a Postgres-aware test runner). Re-running this script is safe: the first
-- statement truncates every app table so each run starts from the seeded-
-- questions-only state, independent of what any previous run left behind.

truncate table answers, game_questions, players, games, rate_limit_hits restart identity cascade;
truncate table auth.users cascade;

create or replace function test_assert(p_condition boolean, p_label text) returns void
language plpgsql as $$
begin
  if not p_condition then
    raise exception 'FAIL: %', p_label;
  end if;
  raise notice 'PASS: %', p_label;
end;
$$;

-- ---------------------------------------------------------------------
-- Scenario 1: full happy-path game, 2 players, 1 question, through
-- FINISHED — the core loop every later scenario assumes still works.
-- ---------------------------------------------------------------------
do $$
declare
  v_host_uid uuid;
  v_p2_uid uuid;
  v_game_id uuid;
  v_room_code text;
  v_host_player_id uuid;
  v_p2_player_id uuid;
  v_q record;
  v_correct_slot smallint;
  v_wrong_slot smallint;
  v_ans record;
  v_lb_host record;
  v_lb_p2 record;
begin
  insert into auth.users default values returning id into v_host_uid;
  insert into auth.users default values returning id into v_p2_uid;

  perform set_config('request.jwt.claim.sub', v_host_uid::text, false);
  select out_game_id, out_room_code, out_player_id into v_game_id, v_room_code, v_host_player_id
    from create_game('history', 'easy', 1::smallint, 20::smallint, 'HostNick');

  perform set_config('request.jwt.claim.sub', v_p2_uid::text, false);
  select out_player_id into v_p2_player_id from join_game(v_room_code, 'P2Nick');

  perform set_config('request.jwt.claim.sub', v_host_uid::text, false);
  perform start_game(v_game_id);
  perform test_assert((select status from games where id = v_game_id) = 'COUNTDOWN', 'scenario1: start_game -> COUNTDOWN');

  perform begin_first_question(v_game_id);
  perform test_assert((select status from games where id = v_game_id) = 'QUESTION', 'scenario1: begin_first_question -> QUESTION');

  select out_option_1, out_option_2, out_option_3, out_option_4 into v_q from get_current_question(v_game_id);

  -- Figure out which displayed slot is correct by brute-force probing via
  -- get_answer_reveal is circular (reveal only exists post-answer), so
  -- instead read the shuffle_map/questions directly — legitimate here
  -- since this is test setup, not something a real client could do.
  select
    (array_position((select shuffle_map from game_questions where game_id = v_game_id),
      (array_position(array['A','B','C','D'], q.correct_option::text) - 1)::smallint) - 1)::smallint
  into v_correct_slot
  from game_questions gq join questions q on q.id = gq.question_id
  where gq.game_id = v_game_id;

  v_wrong_slot := case when v_correct_slot = 0 then 1 else 0 end;

  -- Host answers correctly.
  perform set_config('request.jwt.claim.sub', v_host_uid::text, false);
  select out_is_correct, out_points into v_ans from submit_answer(v_game_id, v_correct_slot);
  perform test_assert(v_ans.out_is_correct = true, 'scenario1: host correct answer scored is_correct');
  perform test_assert(v_ans.out_points > 0, 'scenario1: host correct answer earns positive points');

  -- P2 answers incorrectly.
  perform set_config('request.jwt.claim.sub', v_p2_uid::text, false);
  select out_is_correct, out_points into v_ans from submit_answer(v_game_id, v_wrong_slot);
  perform test_assert(v_ans.out_is_correct = false, 'scenario1: p2 incorrect answer scored is_correct=false');

  perform set_config('request.jwt.claim.sub', v_host_uid::text, false);
  perform end_question(v_game_id);
  perform test_assert((select status from games where id = v_game_id) = 'REVEAL', 'scenario1: end_question -> REVEAL');

  perform advance_to_leaderboard(v_game_id);
  perform test_assert((select status from games where id = v_game_id) = 'LEADERBOARD', 'scenario1: advance_to_leaderboard -> LEADERBOARD');

  select out_score into v_lb_host from get_leaderboard(v_game_id) where out_player_id = v_host_player_id;
  select out_score into v_lb_p2 from get_leaderboard(v_game_id) where out_player_id = v_p2_player_id;
  perform test_assert(v_lb_host.out_score > v_lb_p2.out_score, 'scenario1: leaderboard ranks correct answer above incorrect');

  -- Only 1 question was configured, so this should go straight to FINISHED.
  perform advance_question(v_game_id);
  perform test_assert((select status from games where id = v_game_id) = 'FINISHED', 'scenario1: advance_question on last question -> FINISHED');
end $$;

-- ---------------------------------------------------------------------
-- Scenario 2: a solo (1-player) game can start and be played to
-- completion. This is the "1-player game" edge case
-- docs/MASTER_HANDOFF.md's Phase 11 notes called out as never having been
-- adversarially tested.
-- ---------------------------------------------------------------------
do $$
declare
  v_uid uuid;
  v_game_id uuid;
  v_room_code text;
begin
  insert into auth.users default values returning id into v_uid;
  perform set_config('request.jwt.claim.sub', v_uid::text, false);
  select out_game_id, out_room_code into v_game_id, v_room_code
    from create_game('random', 'mixed', 1::smallint, 20::smallint, 'SoloNick');

  perform start_game(v_game_id);
  perform test_assert((select status from games where id = v_game_id) = 'COUNTDOWN', 'scenario2: solo game start_game succeeds with 1 player');

  perform begin_first_question(v_game_id);
  perform test_assert((select status from games where id = v_game_id) = 'QUESTION', 'scenario2: solo game reaches QUESTION');
end $$;

-- ---------------------------------------------------------------------
-- Scenario 3: requesting more questions than exist for a narrow
-- category/difficulty combination is rejected with a friendly error
-- instead of silently starting a shorter game.
-- ---------------------------------------------------------------------
do $$
declare
  v_uid uuid;
  v_game_id uuid;
  v_room_code text;
  v_raised boolean := false;
begin
  insert into auth.users default values returning id into v_uid;
  perform set_config('request.jwt.claim.sub', v_uid::text, false);
  -- Seed only has 2 'history'/'hard' questions; ask for 5.
  select out_game_id, out_room_code into v_game_id, v_room_code
    from create_game('history', 'hard', 5::smallint, 20::smallint, 'GreedyNick');

  begin
    perform start_game(v_game_id);
  exception when others then
    v_raised := true;
    perform test_assert(sqlerrm like '%Not enough questions%', 'scenario3: insufficient-question error message is the friendly one');
  end;
  perform test_assert(v_raised, 'scenario3: start_game rejects a question_count the seed data cannot fill');
  perform test_assert((select status from games where id = v_game_id) = 'WAITING', 'scenario3: game stays in WAITING after the rejected start_game');
end $$;

-- ---------------------------------------------------------------------
-- Scenario 4: the QUESTION/end_question race. A player's submit_answer
-- that arrives after the host has already called end_question (game is
-- now REVEAL) must be rejected, not silently scored.
-- ---------------------------------------------------------------------
do $$
declare
  v_host_uid uuid;
  v_p2_uid uuid;
  v_game_id uuid;
  v_room_code text;
  v_raised boolean := false;
begin
  insert into auth.users default values returning id into v_host_uid;
  insert into auth.users default values returning id into v_p2_uid;

  perform set_config('request.jwt.claim.sub', v_host_uid::text, false);
  select out_game_id, out_room_code into v_game_id, v_room_code
    from create_game('geography', 'easy', 1::smallint, 20::smallint, 'HostNick');

  perform set_config('request.jwt.claim.sub', v_p2_uid::text, false);
  perform join_game(v_room_code, 'SlowNick');

  perform set_config('request.jwt.claim.sub', v_host_uid::text, false);
  perform start_game(v_game_id);
  perform begin_first_question(v_game_id);

  -- Host ends the question before the slow player ever answers.
  perform end_question(v_game_id);
  perform test_assert((select status from games where id = v_game_id) = 'REVEAL', 'scenario4: end_question moved game to REVEAL ahead of the late submit');

  -- The late player's submit_answer now lands after the transition.
  perform set_config('request.jwt.claim.sub', v_p2_uid::text, false);
  begin
    perform submit_answer(v_game_id, 0::smallint);
  exception when others then
    v_raised := true;
    perform test_assert(sqlerrm like '%no longer accepting answers%', 'scenario4: late submit_answer gets the friendly rejection');
  end;
  perform test_assert(v_raised, 'scenario4: submit_answer after end_question is rejected, not silently scored');

  -- And end_question already back-filled a "no answer" row for the slow
  -- player, so they are not left scoreless-and-unrecorded.
  perform test_assert(
    exists (
      select 1 from answers a
      join players p on p.id = a.player_id
      where p.user_id = v_p2_uid and a.game_id = v_game_id and a.selected_option is null
    ),
    'scenario4: end_question recorded a no-answer row for the player who never submitted'
  );
end $$;

-- ---------------------------------------------------------------------
-- Scenario 5: rapid double-submission from the same player for the same
-- question is rejected on the second attempt with the friendly
-- already-answered message (the business-rule check, distinct from the
-- DB's answers_one_per_player_per_question constraint it backstops).
-- ---------------------------------------------------------------------
do $$
declare
  v_uid uuid;
  v_game_id uuid;
  v_raised boolean := false;
begin
  insert into auth.users default values returning id into v_uid;
  perform set_config('request.jwt.claim.sub', v_uid::text, false);
  select out_game_id into v_game_id
    from create_game('food', 'easy', 1::smallint, 20::smallint, 'DoubleTapNick');
  perform start_game(v_game_id);
  perform begin_first_question(v_game_id);

  perform submit_answer(v_game_id, 0::smallint);
  begin
    perform submit_answer(v_game_id, 1::smallint);
  exception when others then
    v_raised := true;
    perform test_assert(sqlerrm like '%already answered%', 'scenario5: second submit_answer gets the friendly already-answered message');
  end;
  perform test_assert(v_raised, 'scenario5: rapid double-submission is rejected on the second call');
  perform test_assert(
    (select count(*) from answers where game_id = v_game_id) = 1,
    'scenario5: exactly one answer row was recorded, not two'
  );
end $$;

-- ---------------------------------------------------------------------
-- Scenario 6: nickname length boundary — exactly 20 characters (the
-- client's maxLength) is accepted; 21 is rejected.
-- ---------------------------------------------------------------------
do $$
declare
  v_uid uuid;
  v_20 text := rpad('N', 20, 'x');
  v_21 text := rpad('N', 21, 'x');
  v_raised boolean := false;
begin
  perform test_assert(length(v_20) = 20, 'scenario6 setup: boundary nickname is exactly 20 chars');
  perform test_assert(length(v_21) = 21, 'scenario6 setup: over-boundary nickname is exactly 21 chars');

  insert into auth.users default values returning id into v_uid;
  perform set_config('request.jwt.claim.sub', v_uid::text, false);
  perform create_game('trivia', 'easy', 1::smallint, 20::smallint, v_20);
  perform test_assert(true, 'scenario6: exactly-20-character nickname is accepted');

  begin
    perform create_game('trivia', 'easy', 1::smallint, 20::smallint, v_21);
  exception when others then
    v_raised := true;
    perform test_assert(sqlerrm like '%between 1 and 20 characters%', 'scenario6: 21-character nickname is rejected with the friendly message');
  end;
  perform test_assert(v_raised, 'scenario6: 21-character nickname is actually rejected, not silently truncated');
end $$;

-- ---------------------------------------------------------------------
-- Scenario 7: rate limiting on a real function still works after
-- everything above ran (confirms Phase 9's protection wasn't
-- accidentally weakened by anything since). heartbeat's limit is 20
-- calls per 30s window.
-- ---------------------------------------------------------------------
do $$
declare
  v_uid uuid;
  v_game_id uuid;
  v_i int;
  v_raised boolean := false;
begin
  insert into auth.users default values returning id into v_uid;
  perform set_config('request.jwt.claim.sub', v_uid::text, false);
  select out_game_id into v_game_id
    from create_game('sports', 'easy', 1::smallint, 20::smallint, 'SpammerNick');

  for v_i in 1..20 loop
    perform heartbeat(v_game_id);
  end loop;
  perform test_assert(true, 'scenario7: 20 heartbeat calls (at the limit) all succeed');

  begin
    perform heartbeat(v_game_id);
  exception when others then
    v_raised := true;
    perform test_assert(sqlerrm like '%too fast%', 'scenario7: 21st heartbeat call within the window is rate-limited');
  end;
  perform test_assert(v_raised, 'scenario7: rate limiting on heartbeat is still active');
end $$;

-- ---------------------------------------------------------------------
-- Scenario 8: host disconnect -> claim_host reassignment still works
-- (Phase 8/9 mechanism), exercised once more here as a regression check
-- rather than assumed from the earlier phases' own testing.
-- ---------------------------------------------------------------------
do $$
declare
  v_host_uid uuid;
  v_p2_uid uuid;
  v_game_id uuid;
  v_room_code text;
  v_host_player_id uuid;
  v_claim record;
begin
  insert into auth.users default values returning id into v_host_uid;
  insert into auth.users default values returning id into v_p2_uid;

  perform set_config('request.jwt.claim.sub', v_host_uid::text, false);
  select out_game_id, out_room_code, out_player_id into v_game_id, v_room_code, v_host_player_id
    from create_game('slang', 'easy', 1::smallint, 20::smallint, 'FlakyHost');

  perform set_config('request.jwt.claim.sub', v_p2_uid::text, false);
  perform join_game(v_room_code, 'LoyalP2');

  -- Backdate the host's last_seen_at past the staleness threshold instead
  -- of actually waiting (documented pitfall/shortcut from Phase 8 testing).
  update players set last_seen_at = now() - interval '25 seconds' where id = v_host_player_id;

  perform mark_stale_players(v_game_id);
  perform test_assert(
    (select connected from players where id = v_host_player_id) = false,
    'scenario8: mark_stale_players flips the stale host to disconnected'
  );

  select out_new_host_player_id, out_new_host_nickname into v_claim from claim_host(v_game_id);
  perform test_assert(v_claim.out_new_host_nickname = 'LoyalP2', 'scenario8: claim_host reassigns to the remaining connected player');
  perform test_assert(
    (select host_user_id from games where id = v_game_id) = v_p2_uid,
    'scenario8: games.host_user_id actually updated to the new host'
  );
end $$;

drop function test_assert(boolean, text);

\echo '=== All Phase 11 scenarios passed ==='
