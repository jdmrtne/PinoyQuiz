-- Pinoy Quiz — seed: Phase 3 question types sample
--
-- Small verified starter set for sequence (0030 migration), same spirit
-- as the earlier phase-sample seeds.
--
-- Run after 0001-0003, against a project with migrations 0001-0030 applied.

-- ============ SEQUENCE ============
-- sequence_items is the canonical CORRECT order — the server shuffles a
-- *display* order per game (game_questions.sequence_shuffle); the stored
-- array itself is never shuffled.
insert into questions (category, difficulty, question_type, prompt, sequence_items, explanation) values
('history','medium','sequence','Arrange these Philippine historical events in chronological order (earliest first).',
  array['Magellan arrives in the Philippines (1521)','Spanish colonization begins with Legazpi (1565)','The Katipunan is founded (1892)','Philippine independence is declared (1898)','The Philippines gains full independence from the US (1946)'],
  'These five events span the full arc from first European contact to full sovereignty.'),
('trivia','easy','sequence','Arrange these Philippine presidents in the order they served (first to most recent among these four).',
  array['Manuel L. Quezon','Ramon Magsaysay','Ferdinand Marcos','Corazon Aquino'],
  'Quezon served 1935-1944, Magsaysay 1953-1957, Marcos 1965-1986, and Aquino 1986-1992.'),
('geography','medium','sequence','Arrange these islands from largest to smallest by land area: Luzon, Mindanao, Samar, Palawan.',
  array['Luzon','Mindanao','Palawan','Samar'],
  'Luzon and Mindanao are the two largest islands in the Philippines by a wide margin; Palawan and Samar follow.');

-- ============ TIME_LIMIT_OVERRIDE examples ============
-- Demonstrates a per-question timer shorter than whatever the game's
-- default time_limit_seconds is — e.g. for a host building a
-- deliberately fast-paced round. Nullable on every other row (the
-- default — "use the game's time_limit_seconds").
update questions set time_limit_override = 8
where question_type = 'true_false' and category = 'trivia';
