-- Pinoy Quiz — 0023: general-knowledge category expansion
--
-- Renumbered from a branch that was originally drafted as "0020" before
-- this project's live 0020/0021 (science_medical_categories/questions) and
-- 0022 (custom_category_mix) had landed. Content is unchanged from that
-- draft other than the file/migration number and this note. `science`
-- already exists as of 0020_science_medical_categories.sql — its
-- `add value if not exists` below is a harmless no-op here; `medical`
-- (also added in 0020) is untouched by this migration and keeps its own
-- separate category rather than being folded into any of the 20 below.
--
-- Adds 20 new subject categories to both `game_category_setting` and
-- `question_category`, on top of the 8 original + 15 Phase 15 Philippine
-- categories. These are deliberately NOT Philippines-scoped — Science,
-- Mathematics, Technology, Computer Science, World Geography, World
-- History, World Literature, Language, Arts, World Music, World Movies &
-- TV, World Sports, World Food, Animals, Nature & Environment, Space &
-- Astronomy, Human Body, Business & Economics, Logic & Reasoning, and
-- General Trivia.
--
-- Naming collisions with existing Philippine-scoped categories: several
-- of the 20 requested subjects (Geography, History, Literature, Language,
-- Music, Movies & TV, Sports, Food, Technology) already have an existing
-- enum value that in practice only contains Philippine-focused questions
-- (e.g. `history` = Philippine history, `music` = OPM/kundiman). Per the
-- request's own instruction — "do not duplicate existing categories if
-- the project already has equivalent categories" — those existing values
-- are left as-is and NOT reused for general-knowledge content, because
-- reusing them would silently mix world-history questions into a
-- category a player picks expecting only Philippine history (or vice
-- versa). Instead each gets a distinctly-named sibling:
--   history         (PH)  vs  world_history        (general)
--   geography       (PH)  vs  world_geography       (general)
--   literature      (PH)  vs  world_literature       (general)
--   languages       (PH)  vs  general_language        (general)
--   music           (PH)  vs  world_music            (general)
--   movies_tv       (PH)  vs  world_movies_tv        (general)
--   sports          (PH)  vs  world_sports           (general)
--   food            (PH)  vs  world_food             (general)
--   technology      (PH)  vs  world_technology        (general)
-- The remaining 11 new subjects (Mathematics, Computer Science, Arts,
-- Animals, Nature & Environment, Space & Astronomy, Human Body, Business
-- & Economics, Logic & Reasoning, General Trivia) had no existing
-- equivalent at all, so they're added once, plainly named.
--
-- Existing category *display labels* are being updated on the frontend
-- in this same change to disambiguate the Philippine-scoped originals
-- (e.g. `history` now shows as "Philippine History", `trivia` as
-- "Philippine Trivia") from their new general-knowledge siblings — see
-- src/data/gameOptions.ts. That is a label-only change; it requires no
-- migration, since the underlying enum values and stored question rows
-- are untouched.
--
-- Same reasoning as 0018 for why this is its own migration, separate
-- from the question INSERTs that will use these values: Postgres won't
-- let a transaction reference an enum value it just added in the same
-- transaction, and each migration file runs as its own transaction.
--
-- Safe to re-run: `ADD VALUE IF NOT EXISTS` is a no-op if already present.

alter type game_category_setting add value if not exists 'science';
alter type game_category_setting add value if not exists 'mathematics';
alter type game_category_setting add value if not exists 'world_technology';
alter type game_category_setting add value if not exists 'computer_science';
alter type game_category_setting add value if not exists 'world_geography';
alter type game_category_setting add value if not exists 'world_history';
alter type game_category_setting add value if not exists 'world_literature';
alter type game_category_setting add value if not exists 'general_language';
alter type game_category_setting add value if not exists 'arts';
alter type game_category_setting add value if not exists 'world_music';
alter type game_category_setting add value if not exists 'world_movies_tv';
alter type game_category_setting add value if not exists 'world_sports';
alter type game_category_setting add value if not exists 'world_food';
alter type game_category_setting add value if not exists 'animals';
alter type game_category_setting add value if not exists 'general_nature';
alter type game_category_setting add value if not exists 'space_astronomy';
alter type game_category_setting add value if not exists 'human_body';
alter type game_category_setting add value if not exists 'business_economics';
alter type game_category_setting add value if not exists 'logic_reasoning';
alter type game_category_setting add value if not exists 'general_trivia';

alter type question_category add value if not exists 'science';
alter type question_category add value if not exists 'mathematics';
alter type question_category add value if not exists 'world_technology';
alter type question_category add value if not exists 'computer_science';
alter type question_category add value if not exists 'world_geography';
alter type question_category add value if not exists 'world_history';
alter type question_category add value if not exists 'world_literature';
alter type question_category add value if not exists 'general_language';
alter type question_category add value if not exists 'arts';
alter type question_category add value if not exists 'world_music';
alter type question_category add value if not exists 'world_movies_tv';
alter type question_category add value if not exists 'world_sports';
alter type question_category add value if not exists 'world_food';
alter type question_category add value if not exists 'animals';
alter type question_category add value if not exists 'general_nature';
alter type question_category add value if not exists 'space_astronomy';
alter type question_category add value if not exists 'human_body';
alter type question_category add value if not exists 'business_economics';
alter type question_category add value if not exists 'logic_reasoning';
alter type question_category add value if not exists 'general_trivia';

-- No changes needed to create_game/start_game/auto_advance_game/
-- play_again: all of them filter/accept by the enum TYPE, not an
-- enumerated list of its values (see 0014, 0015, 0016), so the 20 new
-- categories are automatically selectable and playable — in both
-- Host-Controlled and Automatic mode, with full no-repeat-across-rounds
-- behavior — the moment this migration lands. "All Categories" already
-- exists too: it's the pre-existing `random` setting value, which
-- `start_game` already treats as "no category filter" (see
-- `v_category_filter := nullif(v_game.category::text, 'random')` in
-- 0014_security_hardening.sql) — it now transparently includes all 20
-- new subjects plus the 23 existing ones, with no code change required.
