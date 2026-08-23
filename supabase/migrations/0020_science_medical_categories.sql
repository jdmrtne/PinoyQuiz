-- Pinoy Quiz — 0020: add Science and Medical categories
--
-- Adds 2 new category values to both `game_category_setting` and
-- `question_category` (see 0002_enums.sql): `science` and `medical`.
-- Unlike the Phase 14 expansion (0018/0019), these are intentionally NOT
-- Philippines-scoped — they cover general, globally-established science
-- and medical knowledge (see 0021's header for the full rationale and
-- subject breakdown), so no existing category was a fit and no existing
-- category is being renamed or reused.
--
-- IMPORTANT — why this is its own migration file, doing nothing else:
-- same reason as 0018: Postgres does not allow a newly-added enum value
-- to be referenced by the same transaction that added it (`ALTER TYPE
-- ... ADD VALUE` cannot run in the same transaction as a later
-- `INSERT`/`SELECT` using that value on PG < 12, and Supabase's migration
-- runner applies each file as its own transaction regardless). Keeping
-- the enum-expansion isolated here — with the actual question INSERTs
-- deferred to 0021_science_medical_questions.sql — is what makes this
-- migration pair safe to run end-to-end, unattended, in one pass.
--
-- Safe to re-run: `ADD VALUE IF NOT EXISTS` is a no-op if the value is
-- already present.

alter type game_category_setting add value if not exists 'science';
alter type game_category_setting add value if not exists 'medical';

alter type question_category add value if not exists 'science';
alter type question_category add value if not exists 'medical';

-- No changes needed to create_game/start_game/lookup_game_by_room_code
-- (0014_security_hardening.sql): they all filter/accept by the enum TYPE,
-- not by an enumerated list of its values, so `science` and `medical` are
-- automatically selectable and playable the moment this migration lands
-- (same note as 0018 made for its 15 categories).
