-- Pinoy Quiz — seed: Phase 2 question types sample
--
-- Small verified starter set for unscramble/matching/image (0028
-- migration), same spirit as 0002_phase1_question_types_sample.sql —
-- enough to test end-to-end, not the full bank.
--
-- Run after 0001 and 0002, against a project with migrations 0001-0028
-- applied (0027/0028 add the enum values and columns these rows use).
--
-- Image questions need a real image_url — these use Wikimedia Commons
-- URLs for public-domain/CC-licensed photos of well-known Philippine
-- landmarks. Swap in your own hosted images if you'd rather not depend
-- on Commons uptime.

-- ============ UNSCRAMBLE ============
-- correct_answer is the target word — must be a single token (no spaces),
-- 3-20 characters (questions_unscramble_fields, 0028 migration). The
-- server shuffles it into game_questions.unscramble_letters at start_game.
insert into questions (category, difficulty, question_type, prompt, correct_answer, explanation) values
('geography','easy','unscramble','Unscramble the name of this Philippine island province known for its rice terraces region:','Ifugao','Ifugao is home to the UNESCO-listed Banaue Rice Terraces.'),
('food','easy','unscramble','Unscramble the name of this popular Filipino noodle dish:','Pancit','Pancit refers to a broad family of Filipino noodle dishes, often served at birthdays for long life.'),
('culture','medium','unscramble','Unscramble the name of this pre-colonial Filipino writing system:','Baybayin','Baybayin was the primary writing system used across the Philippines before Spanish colonization.'),
('trivia','easy','unscramble','Unscramble the national language of the Philippines:','Filipino','Filipino, based largely on Tagalog, is the national language alongside English.');

-- ============ MATCHING ============
-- match_terms and match_definitions are parallel arrays aligned by index
-- — match_definitions[i] is the correct match for match_terms[i]
-- (questions_matching_fields, 0028 migration; the server shuffles the
-- displayed definition order per game, never the stored arrays).
insert into questions (category, difficulty, question_type, prompt, match_terms, match_definitions, explanation) values
('geography','medium','matching','Match each landmark to its location.',
  array['Banaue Rice Terraces','Chocolate Hills','Mayon Volcano','Boracay'],
  array['Ifugao','Bohol','Albay','Aklan'],
  'Each of these is one of the Philippines'' best-known natural or cultural landmarks.'),
('culture','medium','matching','Match each term to its meaning.',
  array['Baybayin','Bayanihan','Kundiman','Sinigang'],
  array['Ancient writing system','Community spirit of cooperation','Traditional love song genre','Sour soup dish'],
  'These four terms come up often in discussions of Filipino culture and daily life.'),
('history','hard','matching','Match each historical figure to what they''re best known for.',
  array['Jose Rizal','Andres Bonifacio','Melchora Aquino','Gabriela Silang'],
  array['Wrote Noli Me Tangere and El Filibusterismo','Founded the Katipunan','Known as the "Mother of the Katipunan"','Led a revolt against the Spanish in Ilocos'],
  'These figures represent different facets of the Philippine revolutionary movement.');

-- ============ IMAGE IDENTIFICATION ============
-- image_url + correct_answer both required (questions_image_fields,
-- 0028 migration). Grading reuses submit_text_answer, same as
-- identification — see that migration's header.
insert into questions (category, difficulty, question_type, prompt, image_url, correct_answer, acceptable_answers, explanation) values
('geography','easy','image','What is the name of this famous Philippine landmark?',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9b/Chocolate_Hills_overview.JPG/640px-Chocolate_Hills_overview.JPG',
  'Chocolate Hills', array['The Chocolate Hills'],
  'The Chocolate Hills in Bohol are over 1,000 grass-covered limestone mounds that turn brown in the dry season.'),
('geography','medium','image','Identify this active volcano, famous for its near-perfect cone shape.',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/9/94/Mayon_Volcano_2009.jpg/640px-Mayon_Volcano_2009.jpg',
  'Mayon Volcano', array['Mayon', 'Mount Mayon'],
  'Mayon, in Albay province, is renowned worldwide for its symmetrical cone.');
