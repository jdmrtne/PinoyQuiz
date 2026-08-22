-- Pinoy Quiz — 0019: new categories + 200 new questions (Phase 15 expansion)
--
-- Adds 200 new, English-language, Philippines-focused questions across the
-- 15 newly-added categories from 0018 (10 each = 150) plus a top-up of the
-- 8 original categories (50 more, varying per category) — see
-- CHANGELOG.md and docs/MASTER_HANDOFF.md for the full breakdown and
-- rationale. None of the 80 questions from
-- supabase/seed/0001_sample_questions.sql are modified, removed, or
-- duplicated here — this migration only adds new rows.
--
-- Must run after 0018_expand_categories.sql has committed (see that
-- file's header for why the enum additions are a separate, already-
-- applied migration rather than combined with this one).
--
-- Idempotency: questions has no natural unique key on content, so this
-- uses a NOT EXISTS guard per row (matching on category + prompt) to make
-- the migration safe to run more than once without inserting duplicates.

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'medium', 'How long is a single term for the President of the Philippines under the 1987 Constitution?', '4 years', '6 years', '5 years', '8 years', 'B', 'Philippine presidents serve a single six-year term and cannot be re-elected.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'How long is a single term for the President of the Philippines under the 1987 Constitution?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'easy', 'How many senators serve in the Philippine Senate?', '12', '24', '50', '100', 'B', 'The Senate is composed of 24 senators elected at large.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'How many senators serve in the Philippine Senate?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'easy', 'Where does the Philippine House of Representatives hold its sessions?', 'Malacanang Palace', 'Batasang Pambansa Complex', 'Rizal Hall', 'Sandiganbayan Building', 'B', 'The House of Representatives convenes at the Batasang Pambansa Complex in Quezon City.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'Where does the Philippine House of Representatives hold its sessions?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'easy', 'Who holds the constitutional power to grant pardons in the Philippines?', 'The Chief Justice', 'The President', 'The Senate President', 'The Ombudsman', 'B', 'The 1987 Constitution vests the power of executive clemency, including pardons, in the President.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'Who holds the constitutional power to grant pardons in the Philippines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'medium', 'What is the official residence of the President of the Philippines called?', 'Rizal Hall', 'Malacanang Palace', 'Batasang Pambansa', 'Fort Santiago', 'B', 'Malacanang Palace, along the Pasig River in Manila, has served as the presidential residence and office since the late 19th century.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'What is the official residence of the President of the Philippines called?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'medium', 'The Sandiganbayan is a special court that primarily hears what kind of cases?', 'Family and custody disputes', 'Graft and corruption cases against public officials', 'Tax disputes between private companies', 'Labor union disputes', 'B', 'The Sandiganbayan is an anti-graft court that tries corruption and related offenses committed by government officials.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'The Sandiganbayan is a special court that primarily hears what kind of cases?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'medium', 'Which government body is constitutionally responsible for conducting and supervising Philippine elections?', 'Department of Justice', 'Commission on Elections (COMELEC)', 'Department of the Interior and Local Government', 'Office of the Ombudsman', 'B', 'COMELEC is the independent constitutional commission tasked with enforcing and administering election laws in the Philippines.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'Which government body is constitutionally responsible for conducting and supervising Philippine elections?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'medium', 'The 1987 Constitution, ratified after the EDSA Revolution, replaced which earlier charter associated with the martial law era?', 'The 1935 Constitution', 'The 1973 Constitution', 'The Malolos Constitution', 'The Commonwealth Charter', 'B', 'The 1973 Constitution, adopted under President Marcos, was superseded by the 1987 Constitution following the EDSA People Power Revolution.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'The 1987 Constitution, ratified after the EDSA Revolution, replaced which earlier charter associated with the martial law era?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'hard', 'How many justices, including the Chief Justice, sit on the Supreme Court of the Philippines?', '9', '11', '15', '21', 'C', 'The Supreme Court is composed of a Chief Justice and 14 Associate Justices, for a total of 15.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'How many justices, including the Chief Justice, sit on the Supreme Court of the Philippines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'hard', 'Which office investigates and can prosecute graft complaints against public officials, headed by an appointee serving a single, non-renewable seven-year term?', 'Commission on Audit', 'Office of the Ombudsman', 'Department of Justice', 'National Bureau of Investigation', 'B', 'The Ombudsman investigates and may prosecute erring public officials and is appointed to a single seven-year term.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'Which office investigates and can prosecute graft complaints against public officials, headed by an appointee serving a single, non-renewable seven-year term?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'easy', 'What is the most populous city in the Philippines?', 'Manila', 'Quezon City', 'Davao City', 'Cebu City', 'B', 'Quezon City is the most populous city in the Philippines and part of Metro Manila.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'What is the most populous city in the Philippines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'easy', 'The Davao Region is popularly nicknamed the "Fruit Basket of the Philippines" because of its abundance of which crops?', 'Tropical fruits such as durian and pomelo', 'Root crops like cassava and taro', 'Grains such as corn and wheat', 'Nuts such as cashew and peanut', 'A', 'Davao Region is renowned for durian, mangosteen, pomelo, and other tropical fruits.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'The Davao Region is popularly nicknamed the "Fruit Basket of the Philippines" because of its abundance of which crops?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'easy', 'Which Philippine city, located in the Cordillera highlands, is popularly called the "Summer Capital of the Philippines" for its cool climate?', 'Tagaytay', 'Baguio', 'Sagada', 'Banaue', 'B', 'Baguio City is popularly known as the Summer Capital of the Philippines due to its cool mountain climate.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'Which Philippine city, located in the Cordillera highlands, is popularly called the "Summer Capital of the Philippines" for its cool climate?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'easy', 'What is the capital city of the province of Palawan?', 'El Nido', 'Puerto Princesa', 'Coron', 'Roxas', 'B', 'Puerto Princesa City is the capital of Palawan province.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'What is the capital city of the province of Palawan?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'medium', 'Zamboanga City is located on which major Philippine island?', 'Luzon', 'Visayas (island group)', 'Mindanao', 'Palawan', 'C', 'Zamboanga City sits on the western tip of Mindanao.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'Zamboanga City is located on which major Philippine island?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'medium', 'Which is the smallest province in the Philippines by land area?', 'Batanes', 'Siquijor', 'Camiguin', 'Guimaras', 'A', 'Batanes, located in the far north of the Philippines, is the country''s smallest province by land area.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'Which is the smallest province in the Philippines by land area?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'medium', 'Iloilo City serves as the regional center of which administrative region?', 'Central Visayas', 'Western Visayas', 'Eastern Visayas', 'Bicol Region', 'B', 'Iloilo City is the regional center of Western Visayas (Region VI).'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'Iloilo City serves as the regional center of which administrative region?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'medium', 'Lanao del Sur, home to Lake Lanao, is considered a heartland of which Filipino ethnic group?', 'Maranao', 'Tausug', 'Subanen', 'Ilocano', 'A', 'Lanao del Sur is a center of Maranao culture, named for their historic ties to Lake Lanao ("Ranao").'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'Lanao del Sur, home to Lake Lanao, is considered a heartland of which Filipino ethnic group?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'medium', 'General Santos City, a major fishing port in Mindanao, is popularly nicknamed what because of its tuna industry?', 'Tuna Capital of the Philippines', 'Rice Granary of Mindanao', 'Coconut Capital', 'Textile Capital', 'A', 'General Santos City is the country''s leading tuna processing and export hub, earning it the nickname "Tuna Capital of the Philippines."'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'General Santos City, a major fishing port in Mindanao, is popularly nicknamed what because of its tuna industry?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'hard', 'Baguio City serves as the seat of which administrative region, even though it is chartered as a city independent from that region''s provinces?', 'Ilocos Region', 'Cordillera Administrative Region', 'Cagayan Valley', 'Central Luzon', 'B', 'Baguio City functions as the regional center of the Cordillera Administrative Region, despite being a highly urbanized city separate from its constituent provinces.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'Baguio City serves as the seat of which administrative region, even though it is chartered as a city independent from that region''s provinces?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'easy', 'What is the national language of the Philippines, based largely on Tagalog?', 'Filipino', 'Cebuano', 'Ilocano', 'Spanish', 'A', 'Filipino, developed primarily from Tagalog, is the national language of the Philippines.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'What is the national language of the Philippines, based largely on Tagalog?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'easy', 'Besides Filipino, what is the other official language of the Philippines, as named in the 1987 Constitution?', 'Spanish', 'English', 'Chinese', 'Malay', 'B', 'The 1987 Constitution names Filipino and English as the two official languages of the Philippines.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'Besides Filipino, what is the other official language of the Philippines, as named in the 1987 Constitution?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'easy', 'Which regional language is most widely spoken in Cebu and much of the Visayas?', 'Cebuano', 'Ilocano', 'Bicolano', 'Waray', 'A', 'Cebuano, also called Bisaya, is the most widely spoken language in Cebu and large parts of the Visayas and Mindanao.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'Which regional language is most widely spoken in Cebu and much of the Visayas?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'easy', 'What do Filipinos commonly call the casual practice of mixing English and Filipino words within the same conversation?', 'Taglish', 'Konyo', 'Chavacano', 'Swardspeak', 'A', '"Taglish" describes the everyday blending of Tagalog and English common in Filipino speech.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'What do Filipinos commonly call the casual practice of mixing English and Filipino words within the same conversation?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'medium', 'Chavacano, a unique language spoken mainly in Zamboanga, is a creole based primarily on which foreign language?', 'Spanish', 'Portuguese', 'Malay', 'Arabic', 'A', 'Chavacano is a Spanish-based creole language, one of the few of its kind in Asia.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'Chavacano, a unique language spoken mainly in Zamboanga, is a creole based primarily on which foreign language?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'medium', 'Which language is predominantly spoken in the Ilocos Region of northern Luzon?', 'Ilocano', 'Pangasinan', 'Kapampangan', 'Bicolano', 'A', 'Ilocano (Iloko) is the dominant language of the Ilocos Region.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'Which language is predominantly spoken in the Ilocos Region of northern Luzon?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'medium', 'Waray-Waray is the major regional language of which island group?', 'Eastern Visayas (Samar and Leyte)', 'Western Visayas', 'Bicol Region', 'Northern Mindanao', 'A', 'Waray-Waray is spoken primarily in Samar and Leyte, in Eastern Visayas.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'Waray-Waray is the major regional language of which island group?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'medium', 'What is the name of the creative, coded slang associated with parts of the Filipino LGBTQ+ community, known for playful wordplay?', 'Swardspeak', 'Chavacano', 'Taglish', 'Baybayin', 'A', 'Swardspeak is an informal, ever-evolving slang known for its inventive wordplay, widely used within Filipino LGBTQ+ communities.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'What is the name of the creative, coded slang associated with parts of the Filipino LGBTQ+ community, known for playful wordplay?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'hard', 'Roughly how many living languages are spoken across the Philippine archipelago, according to commonly cited linguistic surveys?', 'About 20', 'About 80', 'About 180', 'About 400', 'C', 'The Philippines is home to roughly 180 living languages, reflecting the country''s significant linguistic diversity.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'Roughly how many living languages are spoken across the Philippine archipelago, according to commonly cited linguistic surveys?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'hard', 'Baybayin, the pre-colonial Filipino writing system, is classified by linguists as what type of script?', 'An abugida, where symbols pair a consonant with a vowel', 'A purely pictographic script', 'An alphabet like the Latin script, with separate vowel letters', 'A logographic script like Chinese characters', 'A', 'Baybayin is an abugida: each base character represents a consonant-vowel combination that can be modified with diacritical marks (kudlit).'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'Baybayin, the pre-colonial Filipino writing system, is classified by linguists as what type of script?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'easy', 'Jose Rizal''s novel "Noli Me Tangere" was originally written in which language?', 'Spanish', 'Tagalog', 'Latin', 'English', 'A', 'Rizal wrote "Noli Me Tangere" in Spanish, the language of the educated elite in his era.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'Jose Rizal''s novel "Noli Me Tangere" was originally written in which language?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'easy', '"Hinilawod," one of the longest epics in the world, comes from which Filipino ethnic group?', 'The Panay Bukidnon people', 'The Ilocano people', 'The Maranao people', 'The Ivatan people', 'A', 'The Hinilawod is a pre-colonial epic of the Panay Bukidnon, an indigenous group of Panay Island.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = '"Hinilawod," one of the longest epics in the world, comes from which Filipino ethnic group?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'easy', 'In the Filipino epic "Ibong Adarna," the Adarna is what kind of creature?', 'A magical, healing bird', 'A giant serpent', 'A talking carabao', 'A sea monster', 'A', 'The Ibong Adarna is a magical bird whose song is said to have healing powers in the epic.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'In the Filipino epic "Ibong Adarna," the Adarna is what kind of creature?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'easy', 'Who wrote the classic Filipino narrative poem "Florante at Laura"?', 'Francisco Balagtas', 'Jose Rizal', 'Nick Joaquin', 'F. Sionil Jose', 'A', 'Francisco Balagtas wrote the epic poem "Florante at Laura" in the early 19th century.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'Who wrote the classic Filipino narrative poem "Florante at Laura"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'medium', '"Biag ni Lam-ang," a famous pre-colonial epic, comes from which ethnolinguistic group?', 'Ilocano', 'Tagalog', 'Cebuano', 'Maranao', 'A', '"Biag ni Lam-ang" (The Life of Lam-ang) is a well-known epic of the Ilocano people.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = '"Biag ni Lam-ang," a famous pre-colonial epic, comes from which ethnolinguistic group?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'medium', 'Which National Artist for Literature wrote the acclaimed short story "The Woman Who Had Two Navels"?', 'Nick Joaquin', 'F. Sionil Jose', 'Bienvenido Santos', 'NVM Gonzalez', 'A', 'Nick Joaquin, a National Artist for Literature, wrote "The Woman Who Had Two Navels," among many other works exploring Filipino identity.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'Which National Artist for Literature wrote the acclaimed short story "The Woman Who Had Two Navels"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'medium', 'F. Sionil Jose is best known for a multi-novel work often called his masterpiece, commonly referred to as what?', 'The Rosales Saga', 'The Rice Chronicles', 'The Dusk Trilogy', 'The Manila Cycle', 'A', 'F. Sionil Jose''s pentalogy of novels centered on the Samson family is widely known as the Rosales Saga.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'F. Sionil Jose is best known for a multi-novel work often called his masterpiece, commonly referred to as what?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'medium', 'What is the name of the formal, improvised poetic debate tradition, named in honor of Francisco Balagtas, still performed in the Philippines today?', 'Balagtasan', 'Duplo', 'Harana', 'Kundiman', 'A', 'Balagtasan is a debate performed in verse, named after the poet Francisco Balagtas.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'What is the name of the formal, improvised poetic debate tradition, named in honor of Francisco Balagtas, still performed in the Philippines today?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'hard', 'Carlos Bulosan, a Filipino immigrant writer in America, is best known for which autobiographical work about Filipino migrant laborers?', 'America Is in the Heart', 'Dogeaters', 'State of War', 'In My Father''s House', 'A', '"America Is in the Heart" is Carlos Bulosan''s best-known work, chronicling the struggles of Filipino immigrant laborers in the United States.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'Carlos Bulosan, a Filipino immigrant writer in America, is best known for which autobiographical work about Filipino migrant laborers?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'hard', 'Apolinario Mabini, a close adviser of Emilio Aguinaldo, is often remembered by what nickname reflecting both his intellect and his physical disability?', 'The Sublime Paralytic', 'The Brains of the Revolution', 'The Silent Diplomat', 'The Great Reformer', 'A', 'Apolinario Mabini, paralyzed from the waist down, is popularly called the "Sublime Paralytic" for his intellectual contributions to the revolutionary government despite his disability.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'Apolinario Mabini, a close adviser of Emilio Aguinaldo, is often remembered by what nickname reflecting both his intellect and his physical disability?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'easy', '"Harana" is a traditional Filipino practice in which a suitor does what?', 'Serenades the woman he is courting at night', 'Prepares a feast for a wedding', 'Performs a formal marriage proposal to the woman''s parents', 'Writes a letter proposing marriage', 'A', 'Harana is the Filipino tradition of courtship serenading, usually performed outside a woman''s window at night.'
where not exists (
  select 1 from questions where category = 'music' and prompt = '"Harana" is a traditional Filipino practice in which a suitor does what?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'easy', '"Kundiman," a classic genre of Filipino art songs, is traditionally centered on what theme?', 'Love and romantic longing', 'Harvest celebrations', 'Military victories', 'Children''s games', 'A', 'Kundiman songs traditionally express love and romantic longing, often layered with patriotic symbolism.'
where not exists (
  select 1 from questions where category = 'music' and prompt = '"Kundiman," a classic genre of Filipino art songs, is traditionally centered on what theme?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'easy', 'Which Filipino band, formed in the 1980s, became one of the most influential OPM acts with hits like "Ang Huling El Bimbo"?', 'Eraserheads', 'Rivermaya', 'Parokya ni Edgar', 'Sugarfree', 'A', 'The Eraserheads are one of the most influential bands in Original Pilipino Music (OPM) history.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'Which Filipino band, formed in the 1980s, became one of the most influential OPM acts with hits like "Ang Huling El Bimbo"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'easy', 'Freddie Aguilar''s iconic 1978 song "Anak" is about what kind of relationship?', 'A parent and child', 'Two lovers', 'Two best friends', 'A soldier and his homeland', 'A', '"Anak" is Freddie Aguilar''s best-known song, reflecting on the bond and heartbreak between a parent and a wayward child.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'Freddie Aguilar''s iconic 1978 song "Anak" is about what kind of relationship?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'medium', '"Ili-Ili Tulog Anay" is a well-known traditional lullaby from which Philippine language group?', 'Hiligaynon (Ilonggo)', 'Tagalog', 'Ilocano', 'Bicolano', 'A', '"Ili-Ili Tulog Anay" is a widely known Hiligaynon lullaby originating from Panay Island.'
where not exists (
  select 1 from questions where category = 'music' and prompt = '"Ili-Ili Tulog Anay" is a well-known traditional lullaby from which Philippine language group?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'medium', 'The Filipino folk song "Bahay Kubo" primarily lists what?', 'Vegetables grown around a nipa hut', 'Philippine provinces', 'Types of local fish', 'Philippine festivals', 'A', '"Bahay Kubo" is a well-loved folk song enumerating vegetables typically grown around a small nipa hut.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'The Filipino folk song "Bahay Kubo" primarily lists what?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'medium', 'Composer Ryan Cayabyab, a National Artist for Music, is popularly known by what nickname?', 'Mr. C', 'Maestro', 'The Voice', 'Kuya Ryan', 'A', 'Ryan Cayabyab is widely known in Philippine entertainment as "Mr. C."'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'Composer Ryan Cayabyab, a National Artist for Music, is popularly known by what nickname?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'medium', 'The "kulintang," a traditional ensemble of tuned gongs, is most closely associated with which part of the Philippines?', 'Mindanao', 'Luzon', 'Palawan', 'Batanes', 'A', 'Kulintang gong-chime music is a traditional art form of various indigenous and Muslim groups of Mindanao, such as the Maguindanao and Maranao.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'The "kulintang," a traditional ensemble of tuned gongs, is most closely associated with which part of the Philippines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'hard', 'The patriotic Filipino song "Bayan Ko," later adopted as an anthem of protest during the Marcos era, has music composed by whom?', 'Constancio de Guzman', 'Nicanor Abelardo', 'Francisco Santiago', 'Levi Celerio', 'A', '"Bayan Ko" was composed by Constancio de Guzman, with lyrics by the poet Jose Corazon de Jesus.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'The patriotic Filipino song "Bayan Ko," later adopted as an anthem of protest during the Marcos era, has music composed by whom?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'hard', 'The "kudyapi," a traditional two-stringed boat-shaped lute, is played among indigenous groups from which part of the Philippines?', 'Mindanao (such as the T''boli and Maguindanao)', 'Ilocos Region', 'Tagalog provinces', 'Batanes', 'A', 'The kudyapi is a boat-lute traditionally played by various indigenous groups of Mindanao, including the T''boli.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'The "kudyapi," a traditional two-stringed boat-shaped lute, is played among indigenous groups from which part of the Philippines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'easy', 'What is the name of the Philippines'' major annual film festival held every December, showcasing local films exclusively?', 'Metro Manila Film Festival', 'Cinemalaya', 'Gawad Urian', 'PPP Film Fest', 'A', 'The Metro Manila Film Festival (MMFF) is held annually in December and features only Filipino-made films.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'What is the name of the Philippines'' major annual film festival held every December, showcasing local films exclusively?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'easy', 'Which long-running Philippine noontime variety show, launched to rival "Eat Bulaga," is currently one of the country''s top-rated daytime programs?', 'It''s Showtime', 'Wowowee', 'ASAP', 'TV Patrol', 'A', '"It''s Showtime" is a long-running noontime variety program on Philippine television.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'Which long-running Philippine noontime variety show, launched to rival "Eat Bulaga," is currently one of the country''s top-rated daytime programs?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'easy', '"Maalaala Mo Kaya" (MMK), a long-running Philippine anthology series, is known for dramatizing what kind of stories?', 'Real-life, viewer-submitted stories', 'Fictional crime mysteries', 'Celebrity interviews', 'Sports highlights', 'A', 'MMK dramatizes true-to-life stories, often submitted by viewers, in an anthology format.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = '"Maalaala Mo Kaya" (MMK), a long-running Philippine anthology series, is known for dramatizing what kind of stories?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'easy', '"Ang Probinsyano," a long-running Philippine action drama, follows a police officer named Cardo Dalisay played by which actor?', 'Coco Martin', 'John Lloyd Cruz', 'Piolo Pascual', 'Robin Padilla', 'A', 'Coco Martin starred as Cardo Dalisay in the long-running series "Ang Probinsyano."'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = '"Ang Probinsyano," a long-running Philippine action drama, follows a police officer named Cardo Dalisay played by which actor?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'medium', 'Brillante Mendoza became the first Filipino director to win Best Director at which major film festival, for his 2009 film "Kinatay"?', 'Cannes Film Festival', 'Venice Film Festival', 'Berlin Film Festival', 'Sundance Film Festival', 'A', 'Brillante Mendoza won the Best Director award at the 2009 Cannes Film Festival for "Kinatay."'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'Brillante Mendoza became the first Filipino director to win Best Director at which major film festival, for his 2009 film "Kinatay"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'medium', 'The critically acclaimed 2015 Filipino historical film "Heneral Luna" tells the story of which revolutionary general?', 'Antonio Luna', 'Gregorio del Pilar', 'Emilio Aguinaldo', 'Miguel Malvar', 'A', '"Heneral Luna" (2015) dramatizes the life and death of General Antonio Luna during the Philippine-American War.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'The critically acclaimed 2015 Filipino historical film "Heneral Luna" tells the story of which revolutionary general?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'medium', 'What is the name of the annual independent film festival founded in 2005 to support Filipino indie filmmakers?', 'Cinemalaya', 'Cinema One Originals', 'QCinema', 'Sinag Maynila', 'A', 'Cinemalaya is a prominent independent film festival established in 2005 to showcase Filipino indie cinema.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'What is the name of the annual independent film festival founded in 2005 to support Filipino indie filmmakers?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'medium', 'Lino Brocka, a National Artist for Film, directed which acclaimed 1975 drama about a young man searching for his missing girlfriend in Manila''s slums?', 'Maynila: Sa Mga Kuko ng Liwanag', 'Oro, Plata, Mata', 'Himala', 'Insiang', 'A', '"Maynila: Sa Mga Kuko ng Liwanag" (1975), directed by Lino Brocka, follows a young provincial man''s desperate search through Manila''s underbelly.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'Lino Brocka, a National Artist for Film, directed which acclaimed 1975 drama about a young man searching for his missing girlfriend in Manila''s slums?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'hard', 'Lino Brocka''s 1976 film "Insiang," about a young woman seeking revenge in a Manila slum, holds what historic distinction?', 'It was the first Philippine film shown at the Cannes Film Festival', 'It was the first Filipino film with sound', 'It was the first Filipino film to win an Oscar', 'It was the first Filipino animated feature film', 'A', '"Insiang" (1976) was the first Philippine film to be shown at the Cannes Film Festival, screened there in 1978.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'Lino Brocka''s 1976 film "Insiang," about a young woman seeking revenge in a Manila slum, holds what historic distinction?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'hard', 'Which experimental Filipino film, directed by Kidlat Tahimik, won the International Critics'' Prize at the 1977 Berlin Film Festival?', 'Mababangong Bangungot (Perfumed Nightmare)', 'Himala', 'Oro Plata Mata', 'Sister Stella L', 'A', 'Kidlat Tahimik''s "Mababangong Bangungot" (Perfumed Nightmare) is a landmark of Philippine independent cinema, recognized at the Berlin Film Festival.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'Which experimental Filipino film, directed by Kidlat Tahimik, won the International Critics'' Prize at the 1977 Berlin Film Festival?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'easy', 'Manny Pacquiao, the famous Filipino boxer-turned-senator, ran for President of the Philippines in which election year?', '2016', '2019', '2022', '2025', 'C', 'Manny Pacquiao ran for president in the 2022 Philippine national elections.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Manny Pacquiao, the famous Filipino boxer-turned-senator, ran for President of the Philippines in which election year?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'medium', 'As of the mid-2020s, how many times has the Philippines won the Miss Universe crown?', '2', '3', '4', '5', 'C', 'The Philippines has won Miss Universe four times: 1969, 1973, 2015, and 2018.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'As of the mid-2020s, how many times has the Philippines won the Miss Universe crown?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'easy', 'Which veteran Filipina actress, active in film and television since the 1980s, is popularly dubbed "The Star for All Seasons"?', 'Vilma Santos', 'Nora Aunor', 'Sharon Cuneta', 'Judy Ann Santos', 'A', 'Vilma Santos is widely known by the moniker "The Star for All Seasons" for her enduring, versatile career.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which veteran Filipina actress, active in film and television since the 1980s, is popularly dubbed "The Star for All Seasons"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'easy', 'Filipino acting icon and National Artist Nora Aunor is popularly known by what nickname?', 'Superstar', 'Megastar', 'Ultimate Star', 'Star for All Seasons', 'A', 'Nora Aunor has long been known as the "Superstar" of Philippine entertainment.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Filipino acting icon and National Artist Nora Aunor is popularly known by what nickname?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'medium', 'Sharon Cuneta, one of the most popular entertainers in Philippine history, is popularly called what?', 'Megastar', 'Superstar', 'Diva', 'Queen of Talk', 'A', 'Sharon Cuneta is widely known in the Philippines as the "Megastar."'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Sharon Cuneta, one of the most popular entertainers in Philippine history, is popularly called what?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'medium', 'Which Filipino chess player became the first Southeast Asian to earn the Grandmaster title, in 1974?', 'Eugenio Torre', 'Wesley So', 'Mark Paragua', 'Rodolfo Tan Cardoso', 'A', 'Eugenio Torre became the first Filipino and non-Soviet Asian Grandmaster in 1974.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipino chess player became the first Southeast Asian to earn the Grandmaster title, in 1974?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'medium', 'Lea Salonga became the first Asian actress to win which major American theater award, for originating the role of Kim in "Miss Saigon"?', 'Tony Award', 'Grammy Award', 'Emmy Award', 'Academy Award', 'A', 'Lea Salonga won the 1991 Tony Award for Best Actress in a Musical, becoming the first Asian actress to win in that category.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Lea Salonga became the first Asian actress to win which major American theater award, for originating the role of Kim in "Miss Saigon"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'medium', 'Which Filipino painter created the monumental 1884 painting "Spoliarium," now displayed at the National Museum of the Philippines?', 'Juan Luna', 'Fernando Amorsolo', 'Guillermo Tolentino', 'Vicente Manansala', 'A', 'Juan Luna painted "Spoliarium," which won a gold medal at the 1884 Madrid Exposition and became a symbol of Filipino artistic achievement.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipino painter created the monumental 1884 painting "Spoliarium," now displayed at the National Museum of the Philippines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'hard', 'Fernando Amorsolo, celebrated for his luminous depictions of rural Philippine life, was honored in 1972 as the first-ever recipient of what distinction?', 'National Artist of the Philippines', 'Ramon Magsaysay Award', 'Order of Lakandula', 'Gawad CCP Para sa Sining', 'A', 'Fernando Amorsolo was the first person ever named National Artist of the Philippines, honored in 1972 for his contributions to visual arts.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Fernando Amorsolo, celebrated for his luminous depictions of rural Philippine life, was honored in 1972 as the first-ever recipient of what distinction?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'hard', 'Which Filipino martial artist developed and popularized "Modern Arnis," helping bring the Filipino martial art to international recognition?', 'Remy Presas', 'Dan Inosanto', 'Cacoy Canete', 'Leo Giron', 'A', 'Remy Presas developed Modern Arnis and is widely credited with popularizing the Filipino martial art on the world stage.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipino martial artist developed and popularized "Modern Arnis," helping bring the Filipino martial art to international recognition?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'easy', 'The Panagbenga Festival, famous for its flower floats and parades, is held annually in which city?', 'Baguio', 'Davao', 'Cebu', 'Iloilo', 'A', 'Panagbenga, or the Baguio Flower Festival, is celebrated every February in Baguio City.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'The Panagbenga Festival, famous for its flower floats and parades, is held annually in which city?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'easy', 'The MassKara Festival, known for its colorful, smiling masks, is celebrated in which city?', 'Bacolod', 'Iloilo', 'Roxas', 'Dumaguete', 'A', 'The MassKara Festival is Bacolod City''s signature celebration, famous for its smiling festival masks.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'The MassKara Festival, known for its colorful, smiling masks, is celebrated in which city?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'easy', 'What Philippine festival, held every January in Quiapo, Manila, centers on a procession of a famous statue of Christ?', 'Feast of the Black Nazarene', 'Sinulog', 'Ati-Atihan', 'Pahiyas', 'A', 'The Feast of the Black Nazarene (Traslacion) draws massive crowds to Quiapo every January 9th.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'What Philippine festival, held every January in Quiapo, Manila, centers on a procession of a famous statue of Christ?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'easy', 'The Pahiyas Festival, where houses are decorated with colorful rice and produce in thanksgiving for the harvest, is celebrated in which province?', 'Quezon', 'Batangas', 'Cavite', 'Laguna', 'A', 'Pahiyas is celebrated in Lucban and other towns of Quezon Province every May.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'The Pahiyas Festival, where houses are decorated with colorful rice and produce in thanksgiving for the harvest, is celebrated in which province?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'medium', 'The Kadayawan Festival, celebrating the harvest and Indigenous culture, is held annually in which city?', 'Davao', 'Zamboanga', 'Cagayan de Oro', 'General Santos', 'A', 'Kadayawan is Davao City''s major annual festival celebrating the region''s bountiful harvest and Indigenous heritage.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'The Kadayawan Festival, celebrating the harvest and Indigenous culture, is held annually in which city?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'medium', 'The Dinagyang Festival, honoring the Santo Nino and the historical alliance between the Ati people and Malay settlers, is held in which city?', 'Iloilo', 'Kalibo', 'Cebu', 'Roxas', 'A', 'Dinagyang is celebrated annually in Iloilo City every January.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'The Dinagyang Festival, honoring the Santo Nino and the historical alliance between the Ati people and Malay settlers, is held in which city?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'medium', 'The "Higantes Festival" of Angono, Rizal, famous for its towering papier-mache figures, honors which patron saint?', 'San Clemente, patron of fishermen', 'San Isidro, patron of farmers', 'San Roque, patron of the sick', 'Santo Nino, the Child Jesus', 'A', 'The Higantes Festival honors San Clemente, the patron saint of fishermen in Angono.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'The "Higantes Festival" of Angono, Rizal, famous for its towering papier-mache figures, honors which patron saint?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'medium', 'The T''nalak Festival in South Cotabato celebrates the culture of which indigenous group, known for weaving sacred cloth from abaca fiber?', 'T''boli', 'Maranao', 'B''laan', 'Subanen', 'A', 'The T''boli people are traditionally credited with weaving t''nalak, the sacred abaca cloth celebrated at the festival.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'The T''nalak Festival in South Cotabato celebrates the culture of which indigenous group, known for weaving sacred cloth from abaca fiber?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'hard', 'The Moriones Festival, featuring participants dressed as Roman centurions reenacting the story of Longinus, is held during Holy Week in which province?', 'Marinduque', 'Mindoro', 'Romblon', 'Masbate', 'A', 'Moriones is Marinduque''s signature Holy Week festival, centered on the legend of the centurion Longinus.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'The Moriones Festival, featuring participants dressed as Roman centurions reenacting the story of Longinus, is held during Holy Week in which province?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'hard', 'The Pintados-Kasadyaan Festival, in which participants paint their bodies with intricate tribal designs recalling the tattooed warriors of the Visayas, is celebrated in which city?', 'Tacloban', 'Ormoc', 'Catbalogan', 'Borongan', 'A', 'The Pintados-Kasadyaan Festival is held annually in Tacloban City.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'The Pintados-Kasadyaan Festival, in which participants paint their bodies with intricate tribal designs recalling the tattooed warriors of the Visayas, is celebrated in which city?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'easy', 'In Filipino folklore, what is an "aswang" generally believed to be?', 'A shape-shifting evil creature', 'A guardian forest spirit', 'A friendly house elf', 'A type of ghost ship', 'A', 'The aswang is a broad category of shape-shifting, malevolent creatures in Filipino folk belief.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'In Filipino folklore, what is an "aswang" generally believed to be?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'easy', 'Which legendary creature in Visayan mythology is often blamed for eclipses, believed to try to swallow the moon?', 'Bakunawa', 'Tikbalang', 'Kapre', 'Sarimanok', 'A', 'The Bakunawa is a giant serpent-like sea creature in Visayan folklore said to swallow the moon during eclipses.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'Which legendary creature in Visayan mythology is often blamed for eclipses, believed to try to swallow the moon?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'easy', 'The "tikbalang," a well-known creature in Filipino folklore, is typically described as having the head of what animal?', 'A horse', 'A carabao', 'A goat', 'A pig', 'A', 'The tikbalang is commonly depicted with a horse''s head on a tall, humanlike body.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'The "tikbalang," a well-known creature in Filipino folklore, is typically described as having the head of what animal?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'easy', 'A "kapre" in Filipino folklore is usually described as a giant who likes to smoke a pipe while dwelling in what?', 'A large tree, such as a balete tree', 'A cave', 'A riverbank', 'An abandoned house', 'A', 'The kapre is traditionally said to live in large trees, particularly balete trees.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'A "kapre" in Filipino folklore is usually described as a giant who likes to smoke a pipe while dwelling in what?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'medium', 'The "sarimanok," a legendary bird important in Maranao art and folklore, is traditionally depicted holding what in its beak or claws?', 'A fish', 'A flower', 'A snake', 'A pearl', 'A', 'The sarimanok is traditionally shown grasping a fish, symbolizing good fortune.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'The "sarimanok," a legendary bird important in Maranao art and folklore, is traditionally depicted holding what in its beak or claws?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'medium', 'In Philippine folklore, a "diwata" is generally understood to be what kind of being?', 'A nature spirit or fairy-like deity', 'An evil sea monster', 'A trickster clown spirit', 'A ghost of a drowned sailor', 'A', 'Diwatas are generally regarded as benevolent nature spirits or deities, similar to fairies.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'In Philippine folklore, a "diwata" is generally understood to be what kind of being?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'medium', '"Maria Makiling," a well-known guardian spirit in Filipino folklore, is associated with which mountain in Laguna?', 'Mount Makiling', 'Mount Banahaw', 'Mount Arayat', 'Mount Apo', 'A', 'Maria Makiling is the legendary diwata said to guard Mount Makiling in Laguna.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = '"Maria Makiling," a well-known guardian spirit in Filipino folklore, is associated with which mountain in Laguna?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'medium', 'The "manananggal," a well-known Filipino mythical creature, is distinct for its ability to do what?', 'Sever its upper torso and fly at night in search of prey', 'Transform into a black cat', 'Live only underwater', 'Turn invisible during the day', 'A', 'The manananggal is famed in Filipino folklore for detaching its upper body and flying off at night to hunt.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'The "manananggal," a well-known Filipino mythical creature, is distinct for its ability to do what?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'hard', '"Bathala" is the supreme deity in the pre-colonial belief system of which major Filipino ethnolinguistic group?', 'The Tagalog people', 'The Visayan people', 'The Ilocano people', 'The Kapampangan people', 'A', 'Bathala was the chief deity in the pre-colonial religious beliefs of the Tagalog people.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = '"Bathala" is the supreme deity in the pre-colonial belief system of which major Filipino ethnolinguistic group?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'hard', 'Which Filipino mythical figure is described as an old, witch-like woman who casts curses, often blamed in folk belief for a child''s unexplained illness?', 'Mangkukulam', 'Manananggal', 'Tiyanak', 'Duwende', 'A', 'The mangkukulam is a folkloric sorceress or witch believed to cause harm through curses.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'Which Filipino mythical figure is described as an old, witch-like woman who casts curses, often blamed in folk belief for a child''s unexplained illness?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'easy', 'What is the national animal of the Philippines, a domesticated work animal common in rural farming areas?', 'Carabao', 'Horse', 'Goat', 'Ox', 'A', 'The carabao, or water buffalo, is regarded as the national animal of the Philippines and a symbol of the Filipino farmer.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'What is the national animal of the Philippines, a domesticated work animal common in rural farming areas?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'easy', 'The critically endangered Philippine Eagle is found primarily on which island?', 'Mindanao', 'Luzon', 'Palawan', 'Cebu', 'A', 'The largest remaining population of the Philippine Eagle is found on the island of Mindanao.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'The critically endangered Philippine Eagle is found primarily on which island?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'easy', 'What is the national flower of the Philippines?', 'Sampaguita', 'Waling-waling', 'Ylang-ylang', 'Gumamela', 'A', 'The sampaguita, a fragrant white jasmine, is the national flower of the Philippines.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'What is the national flower of the Philippines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'easy', 'The whale shark, a gentle giant often seen by tourists in the Philippines, is locally called what?', 'Butanding', 'Balyena', 'Dyugong', 'Pating', 'A', 'The whale shark is locally known as "butanding" in the Philippines.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'The whale shark, a gentle giant often seen by tourists in the Philippines, is locally called what?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'medium', 'Which town in Sorsogon province is world-renowned as a whale shark-watching destination?', 'Donsol', 'Legazpi', 'Bulan', 'Sorsogon City', 'A', 'Donsol, in Sorsogon province, is famous worldwide for whale shark ("butanding") interaction tours.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'Which town in Sorsogon province is world-renowned as a whale shark-watching destination?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'medium', 'The Tubbataha Reefs, a UNESCO World Heritage marine park teeming with biodiversity, are located in which province?', 'Palawan', 'Bohol', 'Cebu', 'Zamboanga', 'A', 'The Tubbataha Reefs Natural Park is located in the Sulu Sea, part of Palawan province.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'The Tubbataha Reefs, a UNESCO World Heritage marine park teeming with biodiversity, are located in which province?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'medium', 'The Philippine mouse-deer, one of the smallest hoofed mammals in the world, is endemic to which island group?', 'Balabac Island, in Palawan', 'Siargao', 'Marinduque', 'Catanduanes', 'A', 'The Philippine mouse-deer (pilandok) is endemic to Balabac Island and nearby islets in Palawan.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'The Philippine mouse-deer, one of the smallest hoofed mammals in the world, is endemic to which island group?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'medium', 'The Philippines is considered a global biodiversity hotspot largely because of its extremely high rate of what characteristic among its species?', 'Endemism, meaning species found nowhere else', 'Migration to and from neighboring countries', 'Hybridization between species', 'Domestication by early settlers', 'A', 'The Philippines has an unusually high rate of endemism, with many species found nowhere else on Earth.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'The Philippines is considered a global biodiversity hotspot largely because of its extremely high rate of what characteristic among its species?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'hard', 'The Philippine crocodile, among the most critically endangered crocodile species in the world, survives today mainly in small wild populations in which parts of the country?', 'Pockets of northern Luzon and Mindanao', 'Nearly all major islands', 'Palawan only', 'The Visayas only', 'A', 'Remaining wild Philippine crocodile populations are found mainly in scattered areas of northern Luzon and Mindanao.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'The Philippine crocodile, among the most critically endangered crocodile species in the world, survives today mainly in small wild populations in which parts of the country?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'hard', 'The "tamaraw," a critically endangered dwarf buffalo species, is endemic only to which island?', 'Mindoro', 'Palawan', 'Panay', 'Leyte', 'A', 'The tamaraw is found only on the island of Mindoro and nowhere else in the world.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'The "tamaraw," a critically endangered dwarf buffalo species, is endemic only to which island?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'easy', 'Which historic walled district within Manila, built during the Spanish colonial era, is a major heritage tourist site today?', 'Intramuros', 'Fort Santiago', 'Rizal Park', 'Binondo', 'A', 'Intramuros is the historic walled city at the heart of colonial-era Manila.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'Which historic walled district within Manila, built during the Spanish colonial era, is a major heritage tourist site today?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'easy', 'The EDSA Shrine and People Power Monument in Metro Manila commemorate what historic 1986 event?', 'The EDSA People Power Revolution', 'Philippine independence in 1898', 'The end of World War II', 'The Philippine Revolution of 1896', 'A', 'These landmarks commemorate the 1986 EDSA People Power Revolution that peacefully ousted President Marcos.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'The EDSA Shrine and People Power Monument in Metro Manila commemorate what historic 1986 event?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'easy', 'Which Manila park honors the national hero and contains his monument and burial site?', 'Rizal Park (Luneta)', 'Intramuros', 'Fort Santiago', 'Paco Park', 'A', 'Rizal Park, also called Luneta, is the site of Jose Rizal''s monument and where he was executed and later honored.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'Which Manila park honors the national hero and contains his monument and burial site?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'easy', 'The Banaue Rice Terraces are often popularly nicknamed what, reflecting their scale and the fact they were hand-carved by ancestors of the Ifugao people?', 'The Eighth Wonder of the World', 'The Great Wall of Asia', 'The Green Pyramids', 'The Stairway to the Sky', 'A', 'The Banaue Rice Terraces are popularly called "The Eighth Wonder of the World" for their scale and craftsmanship.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'The Banaue Rice Terraces are often popularly nicknamed what, reflecting their scale and the fact they were hand-carved by ancestors of the Ifugao people?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'medium', 'San Agustin Church in Intramuros, Manila, is notable for being what?', 'The oldest stone church in the Philippines', 'The tallest cathedral in Asia', 'The first church built entirely without Spanish oversight', 'The largest church in the Philippines', 'A', 'San Agustin Church, completed in 1607, is the oldest stone church still standing in the Philippines and a UNESCO World Heritage Site.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'San Agustin Church in Intramuros, Manila, is notable for being what?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'medium', 'Fort Santiago, within Intramuros, is historically significant as the site where which national hero was imprisoned before his execution?', 'Jose Rizal', 'Andres Bonifacio', 'Apolinario Mabini', 'Emilio Aguinaldo', 'A', 'Jose Rizal was imprisoned at Fort Santiago in the days before his execution in 1896.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'Fort Santiago, within Intramuros, is historically significant as the site where which national hero was imprisoned before his execution?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'medium', 'The Puerto Princesa Subterranean River, a UNESCO World Heritage Site and a New7Wonders of Nature, is located on which island?', 'Palawan', 'Bohol', 'Siargao', 'Mindoro', 'A', 'The Puerto Princesa Subterranean River National Park is located in Palawan.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'The Puerto Princesa Subterranean River, a UNESCO World Heritage Site and a New7Wonders of Nature, is located on which island?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'medium', 'Taal Volcano, one of the smallest active volcanoes in the world, is famously situated within what kind of geographic feature?', 'A lake, forming a volcano within a lake', 'A desert crater', 'An underground cave system', 'A coral atoll', 'A', 'Taal Volcano sits within Taal Lake, making it a striking "volcano within a lake" landmark in Batangas.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'Taal Volcano, one of the smallest active volcanoes in the world, is famously situated within what kind of geographic feature?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'hard', 'The UNESCO-listed Paoay Church, known for its massive coral-stone buttresses, is located in which province?', 'Ilocos Norte', 'Ilocos Sur', 'Pangasinan', 'La Union', 'A', 'Paoay Church, one of the Baroque Churches of the Philippines UNESCO site, is located in Ilocos Norte.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'The UNESCO-listed Paoay Church, known for its massive coral-stone buttresses, is located in which province?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'hard', 'The Enchanted River in Hinatuan, known for its brilliant blue waters, is located in which province?', 'Surigao del Sur', 'Surigao del Norte', 'Agusan del Sur', 'Davao Oriental', 'A', 'The Enchanted River is located in the municipality of Hinatuan, Surigao del Sur.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'The Enchanted River in Hinatuan, known for its brilliant blue waters, is located in which province?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'easy', 'Which Filipino engineer is popularly credited in the Philippines with contributing to NASA''s design of the lunar rover, or "moon buggy"?', 'Eduardo San Juan', 'Roberto del Rosario', 'Gregorio Zara', 'Diosdado Banatao', 'A', 'Eduardo San Juan is popularly credited in the Philippines with contributing to NASA''s lunar rover design team.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Which Filipino engineer is popularly credited in the Philippines with contributing to NASA''s design of the lunar rover, or "moon buggy"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'easy', 'Filipino inventor Roberto del Rosario patented an early version of which now-ubiquitous entertainment device in the 1970s?', 'The karaoke sing-along machine', 'The jeepney', 'The video game console', 'The digital camera', 'A', 'Roberto del Rosario patented the "Sing-Along System," an early karaoke device, in the 1970s.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Filipino inventor Roberto del Rosario patented an early version of which now-ubiquitous entertainment device in the 1970s?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'easy', 'The iconic Filipino "jeepney" was originally created by modifying surplus vehicles left behind by which country after World War II?', 'The United States', 'Japan', 'Spain', 'Britain', 'A', 'Jeepneys were originally built from surplus US military jeeps left in the Philippines after World War II.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'The iconic Filipino "jeepney" was originally created by modifying surplus vehicles left behind by which country after World War II?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'easy', 'Filipino scientist Gregorio Zara is best known for pioneering work in which field, including early experiments with a two-way videophone?', 'Electrical engineering and video telephony', 'Marine biology', 'Agriculture and rice breeding', 'Pediatric medicine', 'A', 'Gregorio Zara was a pioneering Filipino scientist known for his contributions to electrical engineering, including early videophone experiments.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Filipino scientist Gregorio Zara is best known for pioneering work in which field, including early experiments with a two-way videophone?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'medium', 'Filipino scientist Fe del Mundo, the first woman admitted to Harvard Medical School, made pioneering contributions to which field of medicine?', 'Pediatrics', 'Cardiology', 'Neurology', 'Dermatology', 'A', 'Fe del Mundo pioneered advances in pediatric medicine in the Philippines and internationally.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Filipino scientist Fe del Mundo, the first woman admitted to Harvard Medical School, made pioneering contributions to which field of medicine?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'medium', 'Which Filipino National Scientist is known for research into producing alternative fuel from coconut oil?', 'Julian Banzon', 'Dioscoro Umali', 'Ramon Barba', 'Eduardo Quisumbing', 'A', 'Julian Banzon was recognized as a National Scientist for his pioneering research on coconut-based alternative fuels.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Which Filipino National Scientist is known for research into producing alternative fuel from coconut oil?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'medium', 'Filipino scientist Abelardo Aguilar''s discovery of a soil bacterium in Iloilo in the 1940s led to the development of which important antibiotic?', 'Erythromycin', 'Penicillin', 'Amoxicillin', 'Streptomycin', 'A', 'Abelardo Aguilar''s discovery of a soil sample from Iloilo led to the isolation of the bacterium behind erythromycin.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Filipino scientist Abelardo Aguilar''s discovery of a soil bacterium in Iloilo in the 1940s led to the development of which important antibiotic?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'medium', 'Diosdado Banatao, a Filipino-American engineer, made significant contributions to the tech industry through his pioneering work on what?', 'Microchips for graphics and computer networking', 'The first mobile phone battery', 'Rice-milling machinery', 'The first solar panel', 'A', 'Diosdado Banatao is known for pioneering work developing single-chip graphics accelerators and networking chips.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Diosdado Banatao, a Filipino-American engineer, made significant contributions to the tech industry through his pioneering work on what?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'hard', 'Filipino horticulturist Ramon Barba is renowned for developing a technique to induce off-season flowering in which important Philippine export crop?', 'Mango', 'Banana', 'Pineapple', 'Coconut', 'A', 'Ramon Barba developed a widely used technique to induce off-season flowering in mango trees, boosting the industry.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Filipino horticulturist Ramon Barba is renowned for developing a technique to induce off-season flowering in which important Philippine export crop?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'hard', 'Eduardo Quisumbing, a distinguished Filipino National Scientist, specialized in which field of natural science?', 'Botany', 'Zoology', 'Geology', 'Astronomy', 'A', 'Eduardo Quisumbing was a National Scientist specializing in botany, particularly Philippine flora.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Eduardo Quisumbing, a distinguished Filipino National Scientist, specialized in which field of natural science?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'easy', 'Which major source of foreign income, involving Filipinos working abroad and sending money home, contributes significantly to the Philippine economy?', 'Overseas Filipino Worker (OFW) remittances', 'Domestic tourism only', 'Coal mining exports', 'Automobile manufacturing', 'A', 'Remittances from Overseas Filipino Workers form a major and consistent source of foreign income for the Philippine economy.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'Which major source of foreign income, involving Filipinos working abroad and sending money home, contributes significantly to the Philippine economy?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'easy', 'What does "BPO," a major growth industry in the Philippines involving call centers and outsourced services, stand for?', 'Business Process Outsourcing', 'Bureau of Philippine Operations', 'Banking Process Office', 'Business Partnership Organization', 'A', 'BPO stands for Business Process Outsourcing, a major and fast-growing sector of the Philippine economy.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'What does "BPO," a major growth industry in the Philippines involving call centers and outsourced services, stand for?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'easy', 'The Philippine Stock Exchange is currently headquartered in which city, following its 2018 move?', 'Taguig', 'Makati', 'Quezon City', 'Pasig', 'A', 'The Philippine Stock Exchange relocated its headquarters to Bonifacio Global City in Taguig in 2018.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'The Philippine Stock Exchange is currently headquartered in which city, following its 2018 move?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'easy', 'What is the name of the Philippines'' central bank, responsible for monetary policy and issuing currency?', 'Bangko Sentral ng Pilipinas', 'Land Bank of the Philippines', 'Development Bank of the Philippines', 'Philippine National Bank', 'A', 'Bangko Sentral ng Pilipinas (BSP) is the central bank of the Philippines.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'What is the name of the Philippines'' central bank, responsible for monetary policy and issuing currency?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'medium', 'San Miguel Corporation, one of the largest conglomerates in the Philippines, originally began in the late 1800s as what type of business?', 'A brewery', 'A shipping company', 'A textile mill', 'A bank', 'A', 'San Miguel Corporation traces its roots to a brewery founded in Manila in 1890.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'San Miguel Corporation, one of the largest conglomerates in the Philippines, originally began in the late 1800s as what type of business?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'medium', 'Jollibee Foods Corporation, the Philippines'' largest fast-food chain, originally started in the 1970s as what kind of business?', 'An ice cream parlor chain', 'A bakery', 'A rice trading company', 'A grocery store', 'A', 'Jollibee began as a chain of ice cream parlors before expanding into fast food.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'Jollibee Foods Corporation, the Philippines'' largest fast-food chain, originally started in the 1970s as what kind of business?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'medium', 'The Philippines is consistently one of the world''s largest producers and exporters of which tropical crop?', 'Coconuts', 'Wheat', 'Soybeans', 'Grapes', 'A', 'The Philippines is among the top coconut-producing and exporting countries in the world.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'The Philippines is consistently one of the world''s largest producers and exporters of which tropical crop?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'medium', 'Which Special Economic Zone, a former US naval base converted into an economic hub, is located in the Zambales-Olongapo area?', 'Subic Bay Freeport Zone', 'Clark Freeport Zone', 'Cavite Economic Zone', 'Batangas Economic Zone', 'A', 'Subic Bay Freeport Zone, a former US Navy base, was converted into a major special economic zone.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'Which Special Economic Zone, a former US naval base converted into an economic hub, is located in the Zambales-Olongapo area?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'hard', 'What is the ISO 4217 currency code for the Philippine peso?', 'PHP', 'PES', 'PHL', 'PHI', 'A', 'The Philippine peso''s official international currency code is PHP.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'What is the ISO 4217 currency code for the Philippine peso?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'hard', 'President Fidel Ramos''s 1990s development program, aiming for the Philippines to reach Newly Industrialized Country status, was known by what name?', 'Philippines 2000', 'Bagong Lipunan', 'Masagana 99', 'Ambisyon Natin 2040', 'A', '"Philippines 2000" was President Ramos''s flagship development program of the 1990s.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'President Fidel Ramos''s 1990s development program, aiming for the Philippines to reach Newly Industrialized Country status, was known by what name?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'easy', 'What is the most widely used mobile e-wallet app in the Philippines, supporting cashless payments and transfers?', 'GCash', 'PayPal', 'Venmo', 'Cash App', 'A', 'GCash is the most widely used mobile e-wallet app in the Philippines.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'What is the most widely used mobile e-wallet app in the Philippines, supporting cashless payments and transfers?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'easy', 'In the early 2000s, the Philippines earned what nickname due to its extremely high volume of daily SMS text messages?', 'Texting Capital of the World', 'Silicon Valley of Asia', 'Social Media Capital', 'App Capital of Asia', 'A', 'The Philippines was widely dubbed the "Texting Capital of the World" for its exceptionally high SMS usage in the early 2000s.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'In the early 2000s, the Philippines earned what nickname due to its extremely high volume of daily SMS text messages?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'easy', 'What does "PLDT," one of the Philippines'' major telecommunications companies, stand for?', 'Philippine Long Distance Telephone Company', 'Philippine Local Data Transmission', 'Philippine Land and Digital Technologies', 'Pacific Long-Distance Telecom', 'A', 'PLDT stands for Philippine Long Distance Telephone Company.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'What does "PLDT," one of the Philippines'' major telecommunications companies, stand for?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'easy', 'The Philippines consistently ranks among the world''s top countries for time spent on which type of platform, according to global digital reports?', 'Social media', 'Online banking', 'Cloud storage', 'Enterprise software', 'A', 'Global digital usage reports have repeatedly ranked the Philippines among the countries spending the most daily time on social media.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'The Philippines consistently ranks among the world''s top countries for time spent on which type of platform, according to global digital reports?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'medium', 'GCash, the Philippines'' leading e-wallet, was originally launched in 2004 by which major Philippine telecom company?', 'Globe Telecom', 'PLDT/Smart', 'A joint venture of Globe and Smart', 'DITO Telecommunity', 'A', 'GCash was originally launched by Globe Telecom in 2004.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'GCash, the Philippines'' leading e-wallet, was originally launched in 2004 by which major Philippine telecom company?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'medium', 'DITO Telecommunity, the Philippines'' third major telecom player, began commercial operations in which year?', '2019', '2021', '2023', '2018', 'B', 'DITO Telecommunity launched commercial mobile service in March 2021.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'DITO Telecommunity, the Philippines'' third major telecom player, began commercial operations in which year?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'medium', 'GCash is operated by the fintech company Mynt, which is backed primarily by Ant Group and which Philippine telecom company?', 'Globe Telecom', 'PLDT', 'DITO Telecommunity', 'Converge ICT', 'A', 'Mynt, the company behind GCash, is backed by Globe Telecom together with Ant Group.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'GCash is operated by the fintech company Mynt, which is backed primarily by Ant Group and which Philippine telecom company?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'medium', 'Converge ICT Solutions is a major Philippine telecommunications company primarily known for providing what kind of service?', 'Fixed fiber broadband internet', 'Satellite television', 'Mobile-only prepaid SIM services', 'Cloud gaming', 'A', 'Converge ICT is best known as a leading fixed fiber broadband internet provider in the Philippines.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'Converge ICT Solutions is a major Philippine telecommunications company primarily known for providing what kind of service?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'hard', 'The Philippines'' first microsatellite, developed with Japanese support and deployed from the ISS in 2016 for disaster monitoring and remote sensing, was named what?', 'Diwata-1', 'Maya-1', 'Agila-1', 'Bagong Sibol', 'A', 'Diwata-1, launched in 2016, was the Philippines'' first microsatellite, built with significant involvement from Filipino engineers.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'The Philippines'' first microsatellite, developed with Japanese support and deployed from the ISS in 2016 for disaster monitoring and remote sensing, was named what?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'hard', 'Maya-1, deployed into orbit in 2018, holds what distinction for the Philippines?', 'It was the first satellite designed and built entirely by Filipino engineers', 'It was the first Philippine telecom satellite', 'It was the first satellite launched from Philippine soil', 'It was the first Philippine weather satellite', 'A', 'Maya-1 is recognized as the first cube satellite designed and built entirely by a team of Filipino engineers.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'Maya-1, deployed into orbit in 2018, holds what distinction for the Philippines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'easy', 'What is the predominant religion in the Philippines, practiced by the majority of the population?', 'Roman Catholicism', 'Islam', 'Protestantism', 'Buddhism', 'A', 'The Philippines is a majority Roman Catholic country, a legacy of over three centuries of Spanish colonial rule.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'What is the predominant religion in the Philippines, practiced by the majority of the population?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'easy', 'Which major island of the Philippines has the largest concentration of Muslim Filipinos?', 'Mindanao', 'Luzon', 'Visayas', 'Palawan', 'A', 'Mindanao, particularly the Bangsamoro region, has the largest concentration of Muslim Filipinos in the country.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'Which major island of the Philippines has the largest concentration of Muslim Filipinos?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'easy', 'What is the Filipino Catholic tradition called in which families visit and clean the graves of departed loved ones around November 1st?', 'Undas', 'Simbang Gabi', 'Flores de Mayo', 'Pabasa', 'A', '"Undas," observed around All Saints'' and All Souls'' Day, is when Filipino families visit and tend to the graves of relatives.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'What is the Filipino Catholic tradition called in which families visit and clean the graves of departed loved ones around November 1st?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'easy', '"Flores de Mayo," a Filipino Catholic tradition held throughout May, honors the Virgin Mary through daily offerings of what?', 'Flowers', 'Fruits', 'Candles only', 'Rice cakes', 'A', 'Flores de Mayo involves daily floral offerings to the Virgin Mary throughout the month of May.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = '"Flores de Mayo," a Filipino Catholic tradition held throughout May, honors the Virgin Mary through daily offerings of what?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'medium', 'The "Santacruzan" procession, usually held as part of Flores de Mayo, reenacts the search for what sacred relic, led by Reyna Elena?', 'The True Cross', 'The Holy Grail', 'The Crown of Thorns', 'The Ark of the Covenant', 'A', 'The Santacruzan commemorates Queen Helena''s search for the True Cross.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'The "Santacruzan" procession, usually held as part of Flores de Mayo, reenacts the search for what sacred relic, led by Reyna Elena?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'medium', 'Iglesia ni Cristo, a Christian religious organization founded in the Philippines, was established in 1914 by whom?', 'Felix Manalo', 'Gregorio Aglipay', 'Apolinario de la Cruz', 'Erano Manalo', 'A', 'Felix Manalo founded Iglesia ni Cristo in 1914.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'Iglesia ni Cristo, a Christian religious organization founded in the Philippines, was established in 1914 by whom?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'medium', 'The Philippine Independent Church, also called the "Aglipayan Church," which broke away from Roman Catholic authority during the revolutionary period, was founded by whom?', 'Gregorio Aglipay', 'Felix Manalo', 'Jose Rizal', 'Apolinario Mabini', 'A', 'Gregorio Aglipay founded the Philippine Independent Church in the early 1900s.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'The Philippine Independent Church, also called the "Aglipayan Church," which broke away from Roman Catholic authority during the revolutionary period, was founded by whom?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'medium', 'Muslim Filipinos observe the fasting month of Ramadan based on which calendar system?', 'The Islamic lunar (Hijri) calendar', 'The Gregorian solar calendar', 'The Chinese lunar calendar', 'The Julian calendar', 'A', 'Ramadan is observed according to the Islamic lunar (Hijri) calendar.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'Muslim Filipinos observe the fasting month of Ramadan based on which calendar system?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'hard', 'The "Pabasa," a Lenten tradition still practiced in many Filipino communities, involves the continuous chanting of what text?', 'The Pasyon, an epic poem on the life and death of Jesus Christ', 'The entire Bible', 'Novena prayers', 'The Stations of the Cross script', 'A', 'The Pabasa is the chanted, often continuous reading of the Pasyon during Holy Week.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'The "Pabasa," a Lenten tradition still practiced in many Filipino communities, involves the continuous chanting of what text?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'hard', 'Islam reached the Sulu Archipelago and Mindanao centuries before Christianity, brought largely by traders and missionaries from where?', 'The Malay Archipelago, via Arab and Malay traders', 'Spanish missionaries', 'Chinese Buddhist monks', 'Indian Hindu traders', 'A', 'Islam reached Sulu as early as the 14th century, spread by Arab and Malay Muslim traders and missionaries well before Spanish colonization.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'Islam reached the Sulu Archipelago and Mindanao centuries before Christianity, brought largely by traders and missionaries from where?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'history', 'medium', 'What is the name of the 1872 uprising by Filipino soldiers and workers at a Spanish naval arsenal in Cavite, which led to the execution of the priests known as GomBurZa?', 'The Cavite Mutiny', 'The Katipunan Uprising', 'The Pact of Biak-na-Bato', 'The Battle of Manila', 'A', 'The Cavite Mutiny of 1872 led to the execution of three Filipino priests, an event that fueled the growth of Filipino nationalism.'
where not exists (
  select 1 from questions where category = 'history' and prompt = 'What is the name of the 1872 uprising by Filipino soldiers and workers at a Spanish naval arsenal in Cavite, which led to the execution of the priests known as GomBurZa?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'history', 'easy', 'For approximately how many years was the Philippines a colony of Spain?', 'About 100 years', 'About 200 years', 'About 300 years', 'About 500 years', 'C', 'Spain ruled the Philippines for approximately 333 years, from 1565 to 1898.'
where not exists (
  select 1 from questions where category = 'history' and prompt = 'For approximately how many years was the Philippines a colony of Spain?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'history', 'medium', '"GomBurZa" refers to three Filipino priests executed by garrote in 1872. What are their names?', 'Gomez, Burgos, and Zamora', 'Rizal, Bonifacio, and Mabini', 'Aguinaldo, Luna, and del Pilar', 'Zamora, Lopez, and Jaena', 'A', 'GomBurZa is short for Mariano Gomez, Jose Burgos, and Jacinto Zamora, the three priests executed in 1872.'
where not exists (
  select 1 from questions where category = 'history' and prompt = '"GomBurZa" refers to three Filipino priests executed by garrote in 1872. What are their names?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'history', 'medium', 'The 1898 Treaty of Paris, which ended the Spanish-American War, resulted in Spain ceding the Philippines to which country?', 'The United States', 'Great Britain', 'Germany', 'Japan', 'A', 'The Treaty of Paris (1898) transferred control of the Philippines from Spain to the United States.'
where not exists (
  select 1 from questions where category = 'history' and prompt = 'The 1898 Treaty of Paris, which ended the Spanish-American War, resulted in Spain ceding the Philippines to which country?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'history', 'medium', 'Which Filipino general is remembered for his last stand and heroic death at the Battle of Tirad Pass in 1899, earning him the nickname "Boy General"?', 'Gregorio del Pilar', 'Antonio Luna', 'Miguel Malvar', 'Artemio Ricarte', 'A', 'Gregorio del Pilar, known as the "Boy General," died defending Tirad Pass in 1899 to cover Aguinaldo''s retreat.'
where not exists (
  select 1 from questions where category = 'history' and prompt = 'Which Filipino general is remembered for his last stand and heroic death at the Battle of Tirad Pass in 1899, earning him the nickname "Boy General"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'history', 'hard', 'The 1897 Pact of Biak-na-Bato was a truce between Spanish authorities and Filipino revolutionaries that resulted in Emilio Aguinaldo''s temporary exile to which location?', 'Hong Kong', 'Singapore', 'Guam', 'Japan', 'A', 'Under the Pact of Biak-na-Bato, Aguinaldo and other revolutionary leaders went into exile in Hong Kong.'
where not exists (
  select 1 from questions where category = 'history' and prompt = 'The 1897 Pact of Biak-na-Bato was a truce between Spanish authorities and Filipino revolutionaries that resulted in Emilio Aguinaldo''s temporary exile to which location?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'geography', 'easy', 'Which sea lies to the west of the Philippine archipelago, between the Philippines and Vietnam?', 'West Philippine Sea', 'Sulu Sea', 'Celebes Sea', 'Philippine Sea', 'A', 'The West Philippine Sea is the portion of the South China Sea that lies within the Philippines'' exclusive economic zone.'
where not exists (
  select 1 from questions where category = 'geography' and prompt = 'Which sea lies to the west of the Philippine archipelago, between the Philippines and Vietnam?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'geography', 'easy', 'Which sea lies to the east of the Philippines, associated with the deep Philippine Trench?', 'Philippine Sea', 'Sulu Sea', 'Celebes Sea', 'Bohol Sea', 'A', 'The Philippine Sea lies to the east of the archipelago and contains the deep Philippine Trench.'
where not exists (
  select 1 from questions where category = 'geography' and prompt = 'Which sea lies to the east of the Philippines, associated with the deep Philippine Trench?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'geography', 'medium', 'Mindoro is separated from the island of Luzon by which strait?', 'Verde Island Passage', 'San Bernardino Strait', 'Surigao Strait', 'Bashi Channel', 'A', 'The Verde Island Passage separates Mindoro from the Batangas coast of Luzon.'
where not exists (
  select 1 from questions where category = 'geography' and prompt = 'Mindoro is separated from the island of Luzon by which strait?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'geography', 'medium', 'Which is the largest lake in the Philippines, located just southeast of Metro Manila?', 'Laguna de Bay', 'Lake Lanao', 'Taal Lake', 'Lake Naujan', 'A', 'Laguna de Bay, southeast of Metro Manila, is the largest lake in the Philippines.'
where not exists (
  select 1 from questions where category = 'geography' and prompt = 'Which is the largest lake in the Philippines, located just southeast of Metro Manila?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'geography', 'medium', 'The Sierra Madre, the longest mountain range in the Philippines, runs primarily along the eastern side of which island?', 'Luzon', 'Mindanao', 'Panay', 'Negros', 'A', 'The Sierra Madre mountain range extends along the eastern coast of Luzon.'
where not exists (
  select 1 from questions where category = 'geography' and prompt = 'The Sierra Madre, the longest mountain range in the Philippines, runs primarily along the eastern side of which island?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'geography', 'hard', 'Mount Kanlaon, an active volcano and the highest peak in the Visayas, is located on which island?', 'Negros', 'Panay', 'Cebu', 'Leyte', 'A', 'Mount Kanlaon is located on the island of Negros and is the highest peak in the Visayas.'
where not exists (
  select 1 from questions where category = 'geography' and prompt = 'Mount Kanlaon, an active volcano and the highest peak in the Visayas, is located on which island?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'culture', 'easy', 'What is the traditional formal shirt worn by Filipino men, often made of pina or jusi fabric and worn untucked?', 'Barong Tagalog', 'Malong', 'Salakot', 'Bahag', 'A', 'The Barong Tagalog is the traditional formal shirt for Filipino men, typically made from delicate pina or jusi fabric.'
where not exists (
  select 1 from questions where category = 'culture' and prompt = 'What is the traditional formal shirt worn by Filipino men, often made of pina or jusi fabric and worn untucked?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'culture', 'easy', 'What is the term for the traditional woven, tube-shaped garment worn by various groups in Mindanao, used as a skirt, headwear, or blanket?', 'Malong', 'Barong', 'Salakot', 'Terno', 'A', 'The malong is a versatile tube-shaped woven garment traditional to various Mindanao ethnic groups.'
where not exists (
  select 1 from questions where category = 'culture' and prompt = 'What is the term for the traditional woven, tube-shaped garment worn by various groups in Mindanao, used as a skirt, headwear, or blanket?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'culture', 'easy', 'What is a "salakot"?', 'A wide-brimmed traditional Filipino hat', 'A type of native footwear', 'A ceremonial dagger', 'A woven bag', 'A', 'A salakot is a traditional wide-brimmed hat, often made of rattan, bamboo, or nito vine.'
where not exists (
  select 1 from questions where category = 'culture' and prompt = 'What is a "salakot"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'culture', 'medium', 'Which traditional Filipino dance imitates a bird by having performers hop between clapping bamboo poles?', 'Tinikling', 'Pandanggo sa Ilaw', 'Singkil', 'Carinosa', 'A', 'Tinikling is a folk dance in which performers step between rhythmically clapping bamboo poles, mimicking a bird.'
where not exists (
  select 1 from questions where category = 'culture' and prompt = 'Which traditional Filipino dance imitates a bird by having performers hop between clapping bamboo poles?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'culture', 'medium', '"Pandanggo sa Ilaw" is a traditional Filipino dance in which performers balance what object on their heads and hands?', 'Oil lamps', 'Baskets of fruit', 'Clay pots', 'Fans', 'A', 'In Pandanggo sa Ilaw, dancers balance small oil lamps on their head and the backs of their hands.'
where not exists (
  select 1 from questions where category = 'culture' and prompt = '"Pandanggo sa Ilaw" is a traditional Filipino dance in which performers balance what object on their heads and hands?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'culture', 'hard', '"Singkil," a traditional Maranao dance performed amid clashing bamboo poles, is based on which epic story?', 'The Darangen epic', 'The Hinilawod epic', 'The Ibong Adarna tale', 'The Biag ni Lam-ang epic', 'A', 'Singkil is drawn from the Darangen, the epic cycle of the Maranao people.'
where not exists (
  select 1 from questions where category = 'culture' and prompt = '"Singkil," a traditional Maranao dance performed amid clashing bamboo poles, is based on which epic story?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'food', 'easy', 'What popular Filipino breakfast combination pairs garlic fried rice and a fried egg with cured or fried meat, collectively called "silog" meals?', 'Tapsilog and similar "silog" dishes', 'Merienda dishes', 'Kakanin dishes', 'Pulutan dishes', 'A', '"Silog" meals, like tapsilog and tocilog, pair garlic fried rice and egg with a cured or fried meat.'
where not exists (
  select 1 from questions where category = 'food' and prompt = 'What popular Filipino breakfast combination pairs garlic fried rice and a fried egg with cured or fried meat, collectively called "silog" meals?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'food', 'easy', 'What is "longganisa"?', 'A type of Filipino sausage', 'A rice cake', 'A dried, salted fish', 'A fruit preserve', 'A', 'Longganisa is a Filipino sausage, typically made from ground pork and enjoyed at breakfast.'
where not exists (
  select 1 from questions where category = 'food' and prompt = 'What is "longganisa"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'food', 'easy', 'What is "Pancit Canton" primarily made of?', 'Stir-fried wheat noodles with vegetables and meat', 'Rice porridge', 'Grilled meat skewers', 'Coconut curry', 'A', 'Pancit Canton is a stir-fried wheat noodle dish typically cooked with vegetables and meat.'
where not exists (
  select 1 from questions where category = 'food' and prompt = 'What is "Pancit Canton" primarily made of?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'food', 'easy', 'Which sweet rice cake, traditionally cooked in a clay oven and topped with salted egg and cheese, is especially popular during the Christmas season?', 'Bibingka', 'Turon', 'Halo-Halo', 'Sapin-Sapin', 'A', 'Bibingka is a rice cake traditionally baked in a clay oven, a Christmas-season favorite in the Philippines.'
where not exists (
  select 1 from questions where category = 'food' and prompt = 'Which sweet rice cake, traditionally cooked in a clay oven and topped with salted egg and cheese, is especially popular during the Christmas season?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'food', 'medium', '"Sisig," a popular dish originating from Pampanga, is traditionally made from chopped and seasoned parts of which animal?', 'Pig', 'Chicken', 'Cow', 'Goat', 'A', 'Sisig is traditionally made from chopped pig''s face and liver, seasoned and served sizzling.'
where not exists (
  select 1 from questions where category = 'food' and prompt = '"Sisig," a popular dish originating from Pampanga, is traditionally made from chopped and seasoned parts of which animal?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'food', 'medium', '"Bagoong," a staple Filipino condiment, is made by fermenting what?', 'Fish or shrimp', 'Soybeans', 'Coconut meat', 'Rice', 'A', 'Bagoong is a fermented fish or shrimp paste widely used as a condiment in Filipino cooking.'
where not exists (
  select 1 from questions where category = 'food' and prompt = '"Bagoong," a staple Filipino condiment, is made by fermenting what?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'food', 'hard', '"Batchoy," a noodle soup famous for its use of pork organs and crushed chicharon in a rich broth, originated in which city?', 'La Paz, Iloilo City', 'Cebu City', 'Davao City', 'Bacolod City', 'A', 'Batchoy, or "La Paz Batchoy," originated in the La Paz district of Iloilo City.'
where not exists (
  select 1 from questions where category = 'food' and prompt = '"Batchoy," a noodle soup famous for its use of pork organs and crushed chicharon in a rich broth, originated in which city?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'entertainment', 'easy', 'Which Filipina singer/actress, known as the "Phenomenal Star," rose to fame as a teen artist in the early 2000s?', 'Sarah Geronimo', 'Regine Velasquez', 'Kyla', 'Angeline Quinto', 'A', 'Sarah Geronimo is popularly known in the Philippines as the "Phenomenal Star."'
where not exists (
  select 1 from questions where category = 'entertainment' and prompt = 'Which Filipina singer/actress, known as the "Phenomenal Star," rose to fame as a teen artist in the early 2000s?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'entertainment', 'easy', '"ASAP," one of the Philippines'' longest-running Sunday variety shows, primarily focuses on what kind of content?', 'Live musical performances', 'Cooking competitions', 'Investigative reporting', 'Sports coverage', 'A', 'ASAP is best known for its live concert-style musical performances by Filipino artists.'
where not exists (
  select 1 from questions where category = 'entertainment' and prompt = '"ASAP," one of the Philippines'' longest-running Sunday variety shows, primarily focuses on what kind of content?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'entertainment', 'medium', 'Which acclaimed 2013 Filipino crime film, directed by Erik Matti and starring Coco Martin, follows a hitman navigating Manila''s criminal underworld?', 'On the Job', 'Heneral Luna', 'Kinatay', 'Insiang', 'A', '"On the Job" (2013), directed by Erik Matti, gained critical acclaim internationally for its portrayal of a prison-based hitman syndicate.'
where not exists (
  select 1 from questions where category = 'entertainment' and prompt = 'Which acclaimed 2013 Filipino crime film, directed by Erik Matti and starring Coco Martin, follows a hitman navigating Manila''s criminal underworld?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'entertainment', 'medium', 'Judy Ann Santos won acclaim for her role in which 2000 Filipino drama film "Anak," about an overseas worker''s strained relationship with her daughter?', 'Anak', 'Dekada ''70', 'Magnifico', 'Sister Stella L', 'A', 'Judy Ann Santos starred in the acclaimed 2000 drama "Anak" about the toll of overseas work on a Filipino family.'
where not exists (
  select 1 from questions where category = 'entertainment' and prompt = 'Judy Ann Santos won acclaim for her role in which 2000 Filipino drama film "Anak," about an overseas worker''s strained relationship with her daughter?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'entertainment', 'medium', 'Which veteran Filipina actress starred in "Dekada ''70," a film about a family living through the martial law era?', 'Vilma Santos', 'Nora Aunor', 'Hilda Koronel', 'Gloria Romero', 'A', 'Vilma Santos starred in "Dekada ''70" (2002), portraying a mother navigating martial law-era Philippines.'
where not exists (
  select 1 from questions where category = 'entertainment' and prompt = 'Which veteran Filipina actress starred in "Dekada ''70," a film about a family living through the martial law era?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'entertainment', 'hard', 'The 1982 Filipino film "Himala," directed by Ishmael Bernal, starred which iconic actress as Elsa, a woman claiming visions of the Virgin Mary?', 'Nora Aunor', 'Vilma Santos', 'Hilda Koronel', 'Gloria Diaz', 'A', 'Nora Aunor starred as Elsa in "Himala," widely regarded as one of the greatest Filipino films ever made.'
where not exists (
  select 1 from questions where category = 'entertainment' and prompt = 'The 1982 Filipino film "Himala," directed by Ishmael Bernal, starred which iconic actress as Elsa, a woman claiming visions of the Virgin Mary?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'sports', 'easy', 'Which sport, alongside basketball, is extremely popular in the Philippines and especially strong among Filipina athletes?', 'Volleyball', 'Rugby', 'Cricket', 'Field hockey', 'A', 'Volleyball is one of the most popular and widely played sports in the Philippines, particularly among women.'
where not exists (
  select 1 from questions where category = 'sports' and prompt = 'Which sport, alongside basketball, is extremely popular in the Philippines and especially strong among Filipina athletes?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'sports', 'easy', 'The "Philippine Azkals" is the popular nickname for the Philippine national team in which sport?', 'Football (soccer)', 'Basketball', 'Rugby', 'Volleyball', 'A', 'The Azkals are the Philippine men''s national football (soccer) team.'
where not exists (
  select 1 from questions where category = 'sports' and prompt = 'The "Philippine Azkals" is the popular nickname for the Philippine national team in which sport?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'sports', 'medium', 'Filipino gymnast Carlos Yulo made history by winning multiple gold medals at the 2024 Paris Olympics in which sport?', 'Artistic gymnastics', 'Swimming', 'Track and field', 'Weightlifting', 'A', 'Carlos Yulo won gold medals in artistic gymnastics at the 2024 Paris Olympics, a historic achievement for the Philippines.'
where not exists (
  select 1 from questions where category = 'sports' and prompt = 'Filipino gymnast Carlos Yulo made history by winning multiple gold medals at the 2024 Paris Olympics in which sport?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'sports', 'medium', 'Filipino boxer Eumir Marcial won a bronze medal for the Philippines at the Tokyo 2020 Olympics in which sport?', 'Boxing', 'Weightlifting', 'Wrestling', 'Taekwondo', 'A', 'Eumir Marcial won a bronze medal in middleweight boxing at the Tokyo 2020 Olympics.'
where not exists (
  select 1 from questions where category = 'sports' and prompt = 'Filipino boxer Eumir Marcial won a bronze medal for the Philippines at the Tokyo 2020 Olympics in which sport?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'sports', 'medium', 'The "Palarong Pambansa," an annual multi-sport event in the Philippines, primarily brings together athletes from what level of institutions?', 'Public and private schools nationwide', 'Professional sports clubs', 'Corporate leagues', 'Barangay associations only', 'A', 'The Palarong Pambansa is the Philippines'' national school-level multi-sport competition.'
where not exists (
  select 1 from questions where category = 'sports' and prompt = 'The "Palarong Pambansa," an annual multi-sport event in the Philippines, primarily brings together athletes from what level of institutions?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'sports', 'hard', 'Which traditional Filipino stick-fighting martial art was officially declared the national sport and martial art of the Philippines in 2009?', 'Arnis', 'Sikaran', 'Suntukan', 'Dumog', 'A', 'Republic Act 9850, signed in 2009, declared Arnis (also called Eskrima or Kali) the national sport and martial art of the Philippines.'
where not exists (
  select 1 from questions where category = 'sports' and prompt = 'Which traditional Filipino stick-fighting martial art was officially declared the national sport and martial art of the Philippines in 2009?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'trivia', 'easy', 'What is the national tree of the Philippines, a hardwood prized for fine furniture?', 'Narra', 'Molave', 'Kamagong', 'Yakal', 'A', 'Narra is officially recognized as the national tree of the Philippines.'
where not exists (
  select 1 from questions where category = 'trivia' and prompt = 'What is the national tree of the Philippines, a hardwood prized for fine furniture?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'trivia', 'easy', 'What is the national gem of the Philippines, harvested from mollusks in Palawan''s waters?', 'South Sea Pearl', 'Philippine Jade', 'Red Coral', 'Mother of Pearl Shell', 'A', 'The South Sea Pearl was officially proclaimed the national gem of the Philippines.'
where not exists (
  select 1 from questions where category = 'trivia' and prompt = 'What is the national gem of the Philippines, harvested from mollusks in Palawan''s waters?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'trivia', 'medium', 'Manila, and by extension the Philippines, has long been poetically nicknamed what, a phrase echoed in the national anthem''s translations?', 'Pearl of the Orient Seas', 'Gateway to Asia', 'Jewel of the Pacific', 'Crown of the East', 'A', 'The Philippines is traditionally called the "Pearl of the Orient Seas," a phrase referenced in translations of the national anthem "Lupang Hinirang."'
where not exists (
  select 1 from questions where category = 'trivia' and prompt = 'Manila, and by extension the Philippines, has long been poetically nicknamed what, a phrase echoed in the national anthem''s translations?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'trivia', 'medium', 'How many rays does the sun on the Philippine flag have?', 'Eight', 'Seven', 'Ten', 'Twelve', 'A', 'The sun on the Philippine flag has eight rays.'
where not exists (
  select 1 from questions where category = 'trivia' and prompt = 'How many rays does the sun on the Philippine flag have?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'trivia', 'medium', 'What do the eight rays of the sun on the Philippine flag represent?', 'The first eight provinces that revolted against Spain in 1896', 'The eight major islands of the Philippines', 'The eight founding members of the Katipunan', 'The eight regions of Luzon', 'A', 'The eight rays symbolize the first eight provinces placed under martial law for revolting against Spain in 1896.'
where not exists (
  select 1 from questions where category = 'trivia' and prompt = 'What do the eight rays of the sun on the Philippine flag represent?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'trivia', 'hard', 'The Philippine Trench, one of the deepest points in the world''s oceans, reaches a depth of approximately how many meters?', 'About 5,000 meters', 'About 10,000 meters', 'About 15,000 meters', 'About 20,000 meters', 'B', 'The Philippine Trench reaches a depth of roughly 10,000 meters, making it one of the deepest points in the world''s oceans.'
where not exists (
  select 1 from questions where category = 'trivia' and prompt = 'The Philippine Trench, one of the deepest points in the world''s oceans, reaches a depth of approximately how many meters?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'slang', 'easy', 'What does the Filipino slang term "petmalu" mean?', 'Cool or awesome', 'Boring', 'Angry', 'Tired', 'A', '"Petmalu," a reversed-syllable slang term, means cool or awesome.'
where not exists (
  select 1 from questions where category = 'slang' and prompt = 'What does the Filipino slang term "petmalu" mean?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'slang', 'easy', 'What does "lodi," a reversed spelling of "idol," refer to?', 'A role model or someone admired', 'A rival', 'A stranger', 'A pet', 'A', '"Lodi" is slang for a role model or someone one admires or looks up to.'
where not exists (
  select 1 from questions where category = 'slang' and prompt = 'What does "lodi," a reversed spelling of "idol," refer to?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'slang', 'easy', 'What does the encouraging slang term "werpa" (a reversal of "power") typically express?', 'Support or encouragement, similar to "you got this"', 'A formal greeting', 'A farewell', 'An insult', 'A', '"Werpa" is used to express encouragement or support, similar to saying "more power to you."'
where not exists (
  select 1 from questions where category = 'slang' and prompt = 'What does the encouraging slang term "werpa" (a reversal of "power") typically express?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'slang', 'easy', 'What does the internet-slang spelling "naur" typically express in casual online Filipino conversation?', 'A humorous or exaggerated way of saying "no"', 'Strong agreement', 'A greeting', 'A type of food', 'A', '"Naur" is an exaggerated, humorous internet-slang spelling of the word "no."'
where not exists (
  select 1 from questions where category = 'slang' and prompt = 'What does the internet-slang spelling "naur" typically express in casual online Filipino conversation?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'slang', 'medium', 'What does the sarcastic expression "edi wow" typically convey?', 'Sarcastic indifference, similar to "so what"', 'Genuine amazement', 'A polite thank you', 'A formal apology', 'A', '"Edi wow" is used sarcastically to express indifference or an unimpressed "so what" reaction.'
where not exists (
  select 1 from questions where category = 'slang' and prompt = 'What does the sarcastic expression "edi wow" typically convey?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'slang', 'medium', 'What does "nyek" or "nye" commonly express in casual Filipino speech?', 'Mild disbelief or a joking dismissal', 'Deep sadness', 'A formal greeting', 'Strong anger', 'A', '"Nyek" is a casual exclamation expressing mild disbelief or playful dismissal.'
where not exists (
  select 1 from questions where category = 'slang' and prompt = 'What does "nyek" or "nye" commonly express in casual Filipino speech?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'slang', 'hard', 'What did the older Filipino slang term "jejemon," popularized in the late 2000s, originally describe?', 'A subculture known for intentionally stylized, hard-to-read texting spelling', 'A type of street dance', 'A political movement', 'A fashion trend involving bright colors', 'A', '"Jejemon" described a subculture known for its distinctive, hard-to-decipher style of texting.'
where not exists (
  select 1 from questions where category = 'slang' and prompt = 'What did the older Filipino slang term "jejemon," popularized in the late 2000s, originally describe?'
);
