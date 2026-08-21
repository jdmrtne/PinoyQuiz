-- Pinoy Quiz — 0004: client-safe views
-- These exist so we can revoke direct table access to `questions` and still
-- let clients read what they're allowed to. See 0006_rls.sql / 0007_grants.sql.

-- No correct_option, no explanation. This is the only way the question bank
-- is ever visible to a browser.
create or replace view questions_public as
select
  id,
  category,
  difficulty,
  prompt,
  option_a,
  option_b,
  option_c,
  option_d
from questions;

-- Safe, ranked view of a game's players. Used for the lobby list and the
-- leaderboard — never exposes user_id or any auth-related identifier.
create or replace view leaderboard as
select
  p.id as player_id,
  p.game_id,
  p.nickname,
  p.score,
  p.is_host,
  p.connected,
  rank() over (partition by p.game_id order by p.score desc, p.joined_at asc) as rank
from players p;
