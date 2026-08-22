-- Pinoy Quiz — 0018: expand question categories
--
-- Adds 15 new category values to both `game_category_setting` and
-- `question_category` (see 0002_enums.sql). Of the 20 categories requested
-- for this expansion, 5 already existed under a different (already-
-- Philippines-scoped) name and are intentionally NOT duplicated:
--   "Philippine History"          -> existing `history`
--   "Filipino Food & Cuisine"     -> existing `food`
--   "Filipino Sports"             -> existing `sports`
--   "Filipino Slang & Expressions"-> existing `slang`
--   "General Philippines Trivia"  -> existing `trivia`
-- New questions for those five were added to the existing enum values in
-- 0019 rather than creating redundant categories.
--
-- IMPORTANT — why this is its own migration file, doing nothing else:
-- Postgres does not allow a newly-added enum value to be referenced by the
-- same transaction that added it (`ALTER TYPE ... ADD VALUE` cannot run in
-- the same transaction as a later `INSERT`/`SELECT` using that value,
-- unless run outside a transaction block entirely on PG12+, which most
-- migration runners including Supabase's do not guarantee). Since Supabase
-- CLI applies each migration file as its own transaction, keeping the
-- enum-expansion isolated in this file — with the actual question INSERTs
-- deferred to 0019_new_categories_and_questions.sql — is what makes this
-- migration set safe to run end-to-end, unattended, in one pass.
--
-- Safe to re-run: `ADD VALUE IF NOT EXISTS` is a no-op if the value is
-- already present.

alter type game_category_setting add value if not exists 'politics_government';
alter type game_category_setting add value if not exists 'provinces_cities';
alter type game_category_setting add value if not exists 'languages';
alter type game_category_setting add value if not exists 'literature';
alter type game_category_setting add value if not exists 'music';
alter type game_category_setting add value if not exists 'movies_tv';
alter type game_category_setting add value if not exists 'celebrities';
alter type game_category_setting add value if not exists 'festivals';
alter type game_category_setting add value if not exists 'mythology_folklore';
alter type game_category_setting add value if not exists 'nature_wildlife';
alter type game_category_setting add value if not exists 'landmarks';
alter type game_category_setting add value if not exists 'innovations';
alter type game_category_setting add value if not exists 'economy_business';
alter type game_category_setting add value if not exists 'technology';
alter type game_category_setting add value if not exists 'religion_traditions';

alter type question_category add value if not exists 'politics_government';
alter type question_category add value if not exists 'provinces_cities';
alter type question_category add value if not exists 'languages';
alter type question_category add value if not exists 'literature';
alter type question_category add value if not exists 'music';
alter type question_category add value if not exists 'movies_tv';
alter type question_category add value if not exists 'celebrities';
alter type question_category add value if not exists 'festivals';
alter type question_category add value if not exists 'mythology_folklore';
alter type question_category add value if not exists 'nature_wildlife';
alter type question_category add value if not exists 'landmarks';
alter type question_category add value if not exists 'innovations';
alter type question_category add value if not exists 'economy_business';
alter type question_category add value if not exists 'technology';
alter type question_category add value if not exists 'religion_traditions';

-- No changes needed to create_game/start_game/lookup_game_by_room_code
-- (0014_security_hardening.sql): they all filter/accept by the enum TYPE,
-- not by an enumerated list of its values, so the new categories are
-- automatically selectable and playable the moment this migration lands.
