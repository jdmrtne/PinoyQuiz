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

-- ---------------------------------------------------------------------
-- Scenario 9 (0015): Automatic mode end-to-end — a 2-question game that
-- never calls begin_first_question/end_question/advance_to_leaderboard/
-- advance_question at all, only auto_advance_game, driven purely by
-- backdating the relevant *_started_at column instead of actually
-- sleeping through each phase's real duration (same shortcut Scenario 8
-- uses for staleness).
-- ---------------------------------------------------------------------
do $$
declare
  v_host_uid uuid;
  v_game_id uuid;
  v_room_code text;
  v_host_player_id uuid;
begin
  insert into auth.users default values returning id into v_host_uid;
  perform set_config('request.jwt.claim.sub', v_host_uid::text, false);
  select out_game_id, out_room_code, out_player_id into v_game_id, v_room_code, v_host_player_id
    from create_game('trivia', 'easy', 2::smallint, 5::smallint, 'AutoHost', 'AUTOMATIC'::game_mode, 'LOCK_ON_SELECTION'::answer_behavior);

  perform test_assert(
    (select game_mode from games where id = v_game_id) = 'AUTOMATIC',
    'scenario9: create_game persists AUTOMATIC game_mode'
  );

  perform start_game(v_game_id);
  perform test_assert((select status from games where id = v_game_id) = 'COUNTDOWN', 'scenario9: start_game -> COUNTDOWN (host action, unchanged)');

  -- Not enough time has passed yet — a poll right after COUNTDOWN begins
  -- must be a no-op, not an early transition.
  perform auto_advance_game(v_game_id);
  perform test_assert((select status from games where id = v_game_id) = 'COUNTDOWN', 'scenario9: auto_advance_game is a no-op before COUNTDOWN_SECONDS elapses');

  update games set phase_started_at = now() - interval '10 seconds' where id = v_game_id;
  perform auto_advance_game(v_game_id);
  perform test_assert((select status from games where id = v_game_id) = 'QUESTION', 'scenario9: auto_advance_game moves COUNTDOWN -> QUESTION once elapsed, with no host click');
  perform test_assert((select current_question_index from games where id = v_game_id) = 0, 'scenario9: first question is question_order 0');

  -- No one answers question 1 at all — auto_advance_game must still end it
  -- and record a no-answer row, exactly like end_question would.
  update games set question_started_at = now() - interval '10 seconds' where id = v_game_id;
  perform auto_advance_game(v_game_id);
  perform test_assert((select status from games where id = v_game_id) = 'REVEAL', 'scenario9: auto_advance_game moves QUESTION -> REVEAL once the time limit elapses');
  perform test_assert(
    (select count(*) from answers where game_id = v_game_id) = 1,
    'scenario9: a no-answer row was recorded for the player who never submitted'
  );

  update games set phase_started_at = now() - interval '10 seconds' where id = v_game_id;
  perform auto_advance_game(v_game_id);
  perform test_assert((select status from games where id = v_game_id) = 'LEADERBOARD', 'scenario9: auto_advance_game moves REVEAL -> LEADERBOARD once elapsed');

  update games set phase_started_at = now() - interval '10 seconds' where id = v_game_id;
  perform auto_advance_game(v_game_id);
  perform test_assert((select status from games where id = v_game_id) = 'QUESTION', 'scenario9: auto_advance_game moves LEADERBOARD -> next QUESTION (question 2 of 2)');
  perform test_assert((select current_question_index from games where id = v_game_id) = 1, 'scenario9: second question is question_order 1');

  -- Drive question 2 all the way to FINISHED the same way.
  update games set question_started_at = now() - interval '10 seconds' where id = v_game_id;
  perform auto_advance_game(v_game_id);
  update games set phase_started_at = now() - interval '10 seconds' where id = v_game_id;
  perform auto_advance_game(v_game_id);
  update games set phase_started_at = now() - interval '10 seconds' where id = v_game_id;
  perform auto_advance_game(v_game_id);
  perform test_assert((select status from games where id = v_game_id) = 'FINISHED', 'scenario9: auto_advance_game reaches FINISHED after the last question''s LEADERBOARD elapses');
  perform test_assert((select finished_at from games where id = v_game_id) is not null, 'scenario9: finished_at is stamped, same as the host-controlled advance_question path');
end $$;

-- ---------------------------------------------------------------------
-- Scenario 10 (0015): auto_advance_game is a harmless no-op, both for a
-- Host-Controlled game (must never silently start advancing it) and for
-- a redundant call right after a real transition already happened (the
-- concurrent-callers case — several clients' polling timers landing
-- moments apart, see this migration's `for update` lock).
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
    from create_game('food', 'easy', 1::smallint, 5::smallint, 'ManualHost');
  perform test_assert(
    (select game_mode from games where id = v_game_id) = 'HOST_CONTROLLED',
    'scenario10: create_game defaults game_mode to HOST_CONTROLLED when omitted (backward compatibility)'
  );

  perform start_game(v_game_id);
  update games set phase_started_at = now() - interval '10 seconds' where id = v_game_id;
  perform auto_advance_game(v_game_id);
  perform test_assert(
    (select status from games where id = v_game_id) = 'COUNTDOWN',
    'scenario10: auto_advance_game never advances a HOST_CONTROLLED game, no matter how much time has passed'
  );
  perform begin_first_question(v_game_id);
  perform test_assert((select status from games where id = v_game_id) = 'QUESTION', 'scenario10: host-controlled begin_first_question still works exactly as before');

  -- Redundant-call safety, in an AUTOMATIC game this time: calling
  -- auto_advance_game twice right after the real transition already
  -- landed must not error or double-advance past the next phase.
  perform set_config('request.jwt.claim.sub', v_uid::text, false);
  select out_game_id into v_game_id
    from create_game('food', 'easy', 1::smallint, 5::smallint, 'AutoHost2', 'AUTOMATIC'::game_mode);
  perform start_game(v_game_id);
  update games set phase_started_at = now() - interval '10 seconds' where id = v_game_id;
  perform auto_advance_game(v_game_id); -- COUNTDOWN -> QUESTION
  perform auto_advance_game(v_game_id); -- redundant call, same tick
  perform test_assert(
    (select status from games where id = v_game_id) = 'QUESTION' and (select current_question_index from games where id = v_game_id) = 0,
    'scenario10: a redundant auto_advance_game call right after a real transition is a no-op, not a double-advance'
  );
end $$;

-- ---------------------------------------------------------------------
-- Scenario 11 (0015): CHANGE_UNTIL_TIMER_ENDS — a player picks A, then C,
-- then B before the timer ends; only B is scored, and switching answers
-- never double-counts points onto the running total.
-- ---------------------------------------------------------------------
do $$
declare
  v_host_uid uuid;
  v_game_id uuid;
  v_room_code text;
  v_player_id uuid;
  v_correct_slot smallint;
  v_wrong_slot_1 smallint;
  v_wrong_slot_2 smallint;
  v_final answers%rowtype;
  v_score_after_first int;
  v_score_after_final int;
begin
  insert into auth.users default values returning id into v_host_uid;
  perform set_config('request.jwt.claim.sub', v_host_uid::text, false);
  select out_game_id, out_room_code, out_player_id into v_game_id, v_room_code, v_player_id
    from create_game('culture', 'easy', 1::smallint, 30::smallint, 'ChangerNick', 'HOST_CONTROLLED'::game_mode, 'CHANGE_UNTIL_TIMER_ENDS'::answer_behavior);

  perform start_game(v_game_id);
  perform begin_first_question(v_game_id);

  select (array_position(gq.shuffle_map, (array_position(array['A','B','C','D'], q.correct_option::text) - 1)) - 1)
    into v_correct_slot
  from game_questions gq join questions q on q.id = gq.question_id
  where gq.id = (select current_question_id from games where id = v_game_id);

  select min(s) into v_wrong_slot_1 from unnest(array[0,1,2,3]) s where s <> v_correct_slot;
  select max(s) into v_wrong_slot_2 from unnest(array[0,1,2,3]) s where s <> v_correct_slot and s <> v_wrong_slot_1;

  -- wrong -> wrong -> correct (the final answer).
  perform submit_answer(v_game_id, v_wrong_slot_1::smallint);
  select score into v_score_after_first from players where id = v_player_id;
  perform test_assert(v_score_after_first = 0, 'scenario11: first (wrong) pick scores 0, as normal for an incorrect answer');

  perform submit_answer(v_game_id, v_wrong_slot_2::smallint);
  perform submit_answer(v_game_id, v_correct_slot::smallint);

  select * into v_final from answers where game_id = v_game_id and player_id = v_player_id;
  perform test_assert(
    (select count(*) from answers where game_id = v_game_id and player_id = v_player_id) = 1,
    'scenario11: changing an answer updates the same row (upsert), never inserts a second one'
  );
  perform test_assert(v_final.selected_option = v_correct_slot, 'scenario11: only the final (correct) selection is stored');
  perform test_assert(v_final.is_correct = true, 'scenario11: the final selection is scored as correct');

  select score into v_score_after_final from players where id = v_player_id;
  perform test_assert(v_score_after_final = v_final.points, 'scenario11: switching answers never double-counts — final score equals exactly the final answer''s points, not a sum of every pick');
end $$;

-- ---------------------------------------------------------------------
-- Scenario 12 (0015): LOCK_ON_SELECTION (the default) still rejects a
-- second submit_answer call outright — CHANGE_UNTIL_TIMER_ENDS above must
-- not have loosened the default behavior for games that didn't opt in.
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
    from create_game('sports', 'easy', 1::smallint, 30::smallint, 'LockerNick');
  perform test_assert(
    (select answer_behavior from games where id = v_game_id) = 'LOCK_ON_SELECTION',
    'scenario12: create_game defaults answer_behavior to LOCK_ON_SELECTION when omitted (backward compatibility)'
  );

  perform start_game(v_game_id);
  perform begin_first_question(v_game_id);
  perform submit_answer(v_game_id, 0::smallint);

  begin
    perform submit_answer(v_game_id, 1::smallint);
  exception when others then
    v_raised := true;
    perform test_assert(sqlerrm like '%already answered%', 'scenario12: second submit_answer under LOCK_ON_SELECTION is rejected with the existing friendly message');
  end;
  perform test_assert(v_raised, 'scenario12: LOCK_ON_SELECTION still hard-rejects a change, unaffected by 0015');
end $$;

-- ---------------------------------------------------------------------
-- Scenario 13 (0015): the new real-elapsed-time cutoff in submit_answer —
-- a submission is rejected once the time limit has actually passed, even
-- if `status` technically hasn't flipped to REVEAL yet (the small window
-- this migration closes — see its header comment, section 2).
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
    from create_game('geography', 'easy', 1::smallint, 5::smallint, 'LateNick', 'HOST_CONTROLLED'::game_mode, 'CHANGE_UNTIL_TIMER_ENDS'::answer_behavior);
  perform start_game(v_game_id);
  perform begin_first_question(v_game_id);

  -- Simulate the clock having actually run out without end_question having
  -- landed yet (status is still QUESTION).
  update games set question_started_at = now() - interval '30 seconds' where id = v_game_id;
  perform test_assert((select status from games where id = v_game_id) = 'QUESTION', 'scenario13: status is still QUESTION (end_question has not been called)');

  begin
    perform submit_answer(v_game_id, 0::smallint);
  exception when others then
    v_raised := true;
    perform test_assert(sqlerrm like '%no longer accepting answers%', 'scenario13: submit_answer rejects a late submission by real elapsed time, not just by status');
  end;
  perform test_assert(v_raised, 'scenario13: the real-elapsed-time cutoff actually fired');
end $$;

-- ---------------------------------------------------------------------
-- Scenario 14 (0016): play_again resets the SAME room for a rematch —
-- same games.id, same room_code, same players (nicknames/host untouched),
-- fresh round_number, scores back to 0 — and is properly permission- and
-- status-gated.
-- ---------------------------------------------------------------------
do $$
declare
  v_host_uid uuid;
  v_other_uid uuid;
  v_game_id uuid;
  v_room_code text;
  v_host_player_id uuid;
  v_other_player_id uuid;
  v_room_code_after text;
  v_raised boolean := false;
begin
  insert into auth.users default values returning id into v_host_uid;
  insert into auth.users default values returning id into v_other_uid;

  perform set_config('request.jwt.claim.sub', v_host_uid::text, false);
  select out_game_id, out_room_code, out_player_id into v_game_id, v_room_code, v_host_player_id
    from create_game('trivia', 'easy', 1::smallint, 30::smallint, 'RematchHost');

  perform set_config('request.jwt.claim.sub', v_other_uid::text, false);
  select out_player_id into v_other_player_id from join_game(v_room_code, 'RematchGuest');

  -- play_again before FINISHED must be rejected.
  perform set_config('request.jwt.claim.sub', v_host_uid::text, false);
  begin
    perform play_again(v_game_id);
  exception when others then
    v_raised := true;
  end;
  perform test_assert(v_raised, 'scenario14: play_again is rejected before the game has finished');

  -- Play the single question through to FINISHED.
  perform start_game(v_game_id);
  perform begin_first_question(v_game_id);
  perform submit_answer(v_game_id, 0::smallint);
  perform end_question(v_game_id);
  perform advance_to_leaderboard(v_game_id);
  perform advance_question(v_game_id);
  perform test_assert((select status from games where id = v_game_id) = 'FINISHED', 'scenario14: setup — game reached FINISHED');

  -- Non-host play_again must be rejected.
  v_raised := false;
  perform set_config('request.jwt.claim.sub', v_other_uid::text, false);
  begin
    perform play_again(v_game_id);
  exception when others then
    v_raised := true;
  end;
  perform test_assert(v_raised, 'scenario14: only the host can call play_again');

  perform set_config('request.jwt.claim.sub', v_host_uid::text, false);
  perform play_again(v_game_id);

  select room_code into v_room_code_after from games where id = v_game_id;
  perform test_assert(v_room_code_after = v_room_code, 'scenario14: play_again keeps the exact same room_code — no new room, no new invite link');
  perform test_assert((select status from games where id = v_game_id) = 'WAITING', 'scenario14: play_again resets status back to WAITING (the lobby)');
  perform test_assert((select round_number from games where id = v_game_id) = 2, 'scenario14: play_again advances round_number');
  perform test_assert((select finished_at from games where id = v_game_id) is null, 'scenario14: finished_at is cleared for the new round');
  perform test_assert(
    (select nickname from players where id = v_host_player_id) = 'RematchHost'
      and (select nickname from players where id = v_other_player_id) = 'RematchGuest',
    'scenario14: both players'' nicknames are untouched — no rejoin, no re-typed name'
  );
  perform test_assert(
    (select is_host from players where id = v_host_player_id) = true,
    'scenario14: the host is still the host after a rematch'
  );
  perform test_assert(
    (select score from players where id = v_host_player_id) = 0
      and (select score from players where id = v_other_player_id) = 0,
    'scenario14: scores reset to 0 for the new round'
  );
  perform test_assert(
    (select count(*) from players where game_id = v_game_id) = 2,
    'scenario14: no players rows were added or removed by play_again'
  );

  -- The host can immediately start round 2 in the same room.
  perform start_game(v_game_id);
  perform test_assert((select status from games where id = v_game_id) = 'COUNTDOWN', 'scenario14: start_game works again for round 2, same room');
  perform test_assert(
    (select round_number from game_questions where game_id = v_game_id and question_order = 0 and round_number = 2) is not null,
    'scenario14: round 2''s game_questions are tagged with round_number = 2'
  );
end $$;

-- ---------------------------------------------------------------------
-- Scenario 15 (0016): start_game prefers never-before-used questions
-- across rounds of the same room, and only falls back to repeats once
-- that pool is actually exhausted — never errors either way.
--
-- Uses the seed's trivia/easy pool, which has exactly 4 questions, with
-- question_count = 2 per round:
--   round 1: draws 2 of the 4 (2 remain fresh)
--   round 2: exactly 2 fresh remain — must be disjoint from round 1
--   round 3: 0 fresh remain — forced to repeat, but must not error
-- ---------------------------------------------------------------------
do $$
declare
  v_uid uuid;
  v_game_id uuid;
  v_room_code text;
  v_round1_ids uuid[];
  v_round2_ids uuid[];
  v_round3_ids uuid[];
  v_pool_size int;
begin
  select count(*) into v_pool_size from questions where category = 'trivia' and difficulty = 'easy';
  perform test_assert(v_pool_size = 4, 'scenario15: setup — the seed''s trivia/easy pool is exactly 4 questions (test assumption)');

  insert into auth.users default values returning id into v_uid;
  perform set_config('request.jwt.claim.sub', v_uid::text, false);
  select out_game_id, out_room_code into v_game_id, v_room_code
    from create_game('trivia', 'easy', 2::smallint, 30::smallint, 'RepeatHost');

  -- Round 1.
  perform start_game(v_game_id);
  select array_agg(question_id) into v_round1_ids
    from game_questions where game_id = v_game_id and round_number = 1;
  perform test_assert(array_length(v_round1_ids, 1) = 2, 'scenario15: round 1 drew 2 questions');

  perform begin_first_question(v_game_id);
  perform submit_answer(v_game_id, 0::smallint);
  perform end_question(v_game_id);
  perform advance_to_leaderboard(v_game_id);
  perform advance_question(v_game_id);
  perform submit_answer(v_game_id, 0::smallint);
  perform end_question(v_game_id);
  perform advance_to_leaderboard(v_game_id);
  perform advance_question(v_game_id);
  perform test_assert((select status from games where id = v_game_id) = 'FINISHED', 'scenario15: setup — round 1 finished');

  -- Round 2 — exactly the 2 remaining fresh questions are available;
  -- must be entirely disjoint from round 1.
  perform play_again(v_game_id);
  perform start_game(v_game_id);
  select array_agg(question_id) into v_round2_ids
    from game_questions where game_id = v_game_id and round_number = 2;
  perform test_assert(array_length(v_round2_ids, 1) = 2, 'scenario15: round 2 drew 2 questions');
  perform test_assert(
    not exists (select 1 from unnest(v_round2_ids) x where x = any(v_round1_ids)),
    'scenario15: round 2 has zero overlap with round 1 while fresh questions remain'
  );

  -- Finish round 2 so play_again is allowed again.
  perform begin_first_question(v_game_id);
  perform submit_answer(v_game_id, 0::smallint);
  perform end_question(v_game_id);
  perform advance_to_leaderboard(v_game_id);
  perform advance_question(v_game_id);
  perform submit_answer(v_game_id, 0::smallint);
  perform end_question(v_game_id);
  perform advance_to_leaderboard(v_game_id);
  perform advance_question(v_game_id);
  perform test_assert((select status from games where id = v_game_id) = 'FINISHED', 'scenario15: setup — round 2 finished');

  -- Round 3 — the entire 4-question pool has now been used across rounds
  -- 1 and 2, so this MUST fall back to repeating, and must NOT error.
  perform play_again(v_game_id);
  perform start_game(v_game_id);
  select array_agg(question_id) into v_round3_ids
    from game_questions where game_id = v_game_id and round_number = 3;
  perform test_assert(array_length(v_round3_ids, 1) = 2, 'scenario15: round 3 still drew a full 2 questions (fallback to repeats, not an error)');
  perform test_assert(
    exists (select 1 from unnest(v_round3_ids) x where x = any(v_round1_ids) or x = any(v_round2_ids)),
    'scenario15: round 3 was forced to repeat a question only once the fresh pool was fully exhausted'
  );
end $$;

-- ---------------------------------------------------------------------
-- Scenario 16 (0016): a question repeating across rounds doesn't corrupt
-- scoring or the "already answered" check — round_number scoping on
-- answers keeps round 3's answer to a repeated question independent of
-- whatever that same question scored back in round 1.
-- ---------------------------------------------------------------------
do $$
declare
  v_uid uuid;
  v_game_id uuid;
  v_player_id uuid;
  v_room_code text;
  v_round1_question uuid;
  v_round3_question uuid;
  v_raised boolean := false;
begin
  insert into auth.users default values returning id into v_uid;
  perform set_config('request.jwt.claim.sub', v_uid::text, false);
  select out_game_id, out_room_code, out_player_id into v_game_id, v_room_code, v_player_id
    from create_game('slang', 'easy', 1::smallint, 30::smallint, 'RepeatScorer');

  -- Round 1: answer correctly (option 0 may or may not be correct — what
  -- matters here is that SOME points get recorded against this question).
  perform start_game(v_game_id);
  select question_id into v_round1_question from game_questions
    where game_id = v_game_id and round_number = 1 and question_order = 0;
  perform begin_first_question(v_game_id);
  perform submit_answer(v_game_id, 0::smallint);
  perform end_question(v_game_id);
  perform advance_to_leaderboard(v_game_id);
  perform advance_question(v_game_id);
  perform test_assert((select status from games where id = v_game_id) = 'FINISHED', 'scenario16: setup — round 1 finished');

  -- With only 4 slang/easy questions and question_count=1, round 2 and
  -- round 3 exhaust the fresh pool quickly enough that a repeat of
  -- v_round1_question is likely within a couple of rounds; force it
  -- deterministically for the test instead of depending on random().
  perform play_again(v_game_id);
  update game_questions set question_id = v_round1_question
    where game_id = v_game_id and round_number = 2 and question_order = 0;
  perform start_game(v_game_id);

  -- Re-answering "the same question" in round 2 must NOT be blocked by
  -- round 1's answer row (LOCK_ON_SELECTION default — a fresh round is a
  -- fresh chance to answer, not a continuation of round 1's answer).
  perform begin_first_question(v_game_id);
  begin
    perform submit_answer(v_game_id, 1::smallint);
  exception when others then
    v_raised := true;
  end;
  perform test_assert(not v_raised, 'scenario16: answering a repeated question in a new round is not blocked by that question''s round-1 answer row');
  perform test_assert(
    (select count(*) from answers where game_id = v_game_id and question_id = v_round1_question) = 2,
    'scenario16: round 1''s and round 2''s answers to the same question_id both exist as separate rows (round-scoped)'
  );
end $$;

drop function test_assert(boolean, text);

\echo '=== All Phase 11 + Automatic Mode & Answer Behavior + Play Again scenarios passed ==='
