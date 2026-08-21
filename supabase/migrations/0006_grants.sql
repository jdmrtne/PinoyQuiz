-- Pinoy Quiz — 0006: grants
-- Belt-and-suspenders alongside 0005's RLS: revoke table privileges outright
-- so even a misconfigured policy can't accidentally allow a write.
-- Supabase's anonymous auth issues the `authenticated` role (with an
-- `is_anonymous` JWT claim) — there is no unauthenticated `anon` access in
-- this app; every client signs in anonymously first.

revoke all on games, players, questions, game_questions, answers
  from anon, authenticated;

-- Tables: authenticated clients may only ever SELECT, and only the rows
-- their RLS policy allows. No table grants INSERT/UPDATE/DELETE to anon or
-- authenticated anywhere in this schema — all writes happen inside
-- SECURITY DEFINER functions (Phase 3+), which run as the function owner
-- and are therefore unaffected by these revokes.
grant select on games, players, answers to authenticated;

-- questions and game_questions get NO direct grant, not even SELECT — see
-- 0005 comments. Client access is only ever through the views below or a
-- future scoped function.
grant select on questions_public to authenticated;
grant select on leaderboard to authenticated;
