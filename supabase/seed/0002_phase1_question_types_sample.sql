-- Pinoy Quiz — seed: Phase 1 question types sample
--
-- A small, verified starter set (not the full bank) so the new
-- True/False, Identification, and Fill-in-the-Blank types (0026 migration)
-- are actually reachable end-to-end — enough to test "Include new question
-- types (Beta)" on Create Game without waiting on a full 240-question
-- expansion for these types too. Same accuracy bar as 0001: only facts
-- I'm confident are unambiguous.
--
-- Run after 0001_sample_questions.sql, against a project with migrations
-- 0001-0026 applied.

-- ============ TRUE / FALSE ============
-- option_a/option_b are always the literal strings 'True'/'False' —
-- required by questions_true_false_fields (see 0026_question_types_phase1.sql).
insert into questions (category, difficulty, question_type, prompt, option_a, option_b, correct_option, explanation) values
('history','easy','true_false','Jose Rizal was executed at Bagumbayan (present-day Rizal Park) in 1896.','True','False','A','Rizal was executed by firing squad on December 30, 1896, at Bagumbayan.'),
('geography','easy','true_false','Mindanao is the largest island in the Philippines by land area.','True','False','B','Luzon is the largest island; Mindanao is the second-largest.'),
('food','easy','true_false','Adobo is traditionally cooked with soy sauce, vinegar, garlic, and bay leaves.','True','False','A','These four ingredients form the base of most traditional adobo recipes.'),
('culture','medium','true_false','Baybayin is an ancient Filipino script that reads strictly left to right, top to bottom, with no other valid direction.','True','False','B','Baybayin could historically be written in multiple directions depending on the writing surface.'),
('sports','easy','true_false','The Philippines has won an Olympic gold medal in weightlifting.','True','False','A','Hidilyn Diaz won the Philippines'' first-ever Olympic gold medal in weightlifting at the Tokyo 2020 Games.'),
('trivia','medium','true_false','The Philippine flag is displayed with the red stripe on top during peacetime.','True','False','B','Blue is on top during peacetime; red on top signals a state of war, per Philippine flag law.');

-- ============ IDENTIFICATION ============
-- correct_answer is the canonical typed answer; acceptable_answers lists
-- extra strings that also count as correct (matched trimmed/case-
-- insensitively — see submit_text_answer in 0026_question_types_phase1.sql).
insert into questions (category, difficulty, question_type, prompt, correct_answer, acceptable_answers, explanation) values
('history','medium','identification','What is the name of the 1896 secret society founded by Andres Bonifacio that led the revolution against Spain?','Katipunan', array['Kataastaasan Kagalanggalangang Katipunan'],'The Katipunan (KKK) launched the armed revolution against Spanish rule.'),
('geography','easy','identification','What is the capital city of the Philippines?','Manila', null,'Manila is the capital and one of the cities that make up Metro Manila.'),
('culture','medium','identification','What pre-colonial Filipino writing system used symbols to represent syllables?','Baybayin', array['Alibata'],'Baybayin (sometimes called Alibata, though scholars prefer "Baybayin") was widely used before Spanish colonization.'),
('food','easy','identification','What is the Filipino term for the popular street food of grilled chicken or pork blood, often on a stick?','Betamax', null,'Betamax is grilled coagulated blood, named for its resemblance to a Betamax videotape.');

-- ============ FILL IN THE BLANK ============
insert into questions (category, difficulty, question_type, prompt, correct_answer, acceptable_answers, explanation) values
('culture','easy','fill_blank','Ang pambansang bulaklak ng Pilipinas ay ______.','Sampaguita', null,'Sampaguita was declared the national flower by Proclamation No. 652 in 1934.'),
('geography','medium','fill_blank','Ang pinakamataas na bundok sa Pilipinas ay Bundok ______.','Apo', array['Mount Apo'],'Mount Apo in Mindanao is the highest mountain in the Philippines at 2,954 meters.'),
('trivia','easy','fill_blank','Ang pambansang ibon ng Pilipinas ay ang Philippine ______.','Eagle', array['Philippine Eagle'],'The Philippine Eagle is the national bird, also called the monkey-eating eagle.'),
('history','medium','fill_blank','Ipinahayag ang kalayaan ng Pilipinas noong Hunyo 12, ______.','1898', null,'Philippine independence was declared on June 12, 1898.');
