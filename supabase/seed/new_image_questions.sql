-- New "image" type identification questions for PinoyQuiz.
-- Run AFTER uploading all 14 images (see filenames below) into the
-- question-images bucket in Supabase Storage.
--
-- image_url base: https://qfnynkxfkfwdixgiotgi.supabase.co/storage/v1/object/public/question-images/

insert into questions (category, difficulty, question_type, prompt, image_url, correct_answer, acceptable_answers, explanation) values

('landmarks', 'easy', 'image',
  'Identify this UNESCO World Heritage site, carved into the mountains of Ifugao over 2,000 years ago and often called the "Eighth Wonder of the World."',
  'https://qfnynkxfkfwdixgiotgi.supabase.co/storage/v1/object/public/question-images/banaue_rice_terraces.jpg',
  'Banaue Rice Terraces', array['Banaue Rice Terraces', 'The Rice Terraces', 'Ifugao Rice Terraces', 'Banaue'],
  'The Banaue Rice Terraces were hand-carved by the ancestors of the Ifugao people using simple tools.'),

('landmarks', 'medium', 'image',
  'Identify this cobblestone street lined with preserved Spanish colonial houses, the heart of a UNESCO World Heritage city in Ilocos Sur.',
  'https://qfnynkxfkfwdixgiotgi.supabase.co/storage/v1/object/public/question-images/calle_crisologo.jpg',
  'Vigan', array['Vigan', 'Vigan City', 'Calle Crisologo'],
  'Calle Crisologo in Vigan is one of the best-preserved examples of a Spanish colonial town in Asia.'),

('landmarks', 'medium', 'image',
  'Identify this historic Spanish-era fort in Manila, where national hero Jose Rizal was imprisoned before his execution.',
  'https://qfnynkxfkfwdixgiotgi.supabase.co/storage/v1/object/public/question-images/fort_santiago.jpg',
  'Fort Santiago', array['Fort Santiago', 'Fuerte de Santiago'],
  'Fort Santiago, within the walled city of Intramuros, now houses a shrine to Jose Rizal.'),

('history', 'easy', 'image',
  'Identify this Philippine national hero, author of Noli Me Tangere and El Filibusterismo.',
  'https://qfnynkxfkfwdixgiotgi.supabase.co/storage/v1/object/public/question-images/jose_rizal.jpg',
  'Jose Rizal', array['Jose Rizal', 'Dr. Jose Rizal', 'Rizal', 'Jose P. Rizal'],
  'Rizal''s writings and execution in 1896 helped ignite the Philippine Revolution against Spain.'),

('history', 'medium', 'image',
  'Identify this founder of the Katipunan, regarded as the "Father of the Philippine Revolution."',
  'https://qfnynkxfkfwdixgiotgi.supabase.co/storage/v1/object/public/question-images/andres_bonifacio.jpg',
  'Andres Bonifacio', array['Andres Bonifacio', 'Bonifacio', 'Andrés Bonifacio'],
  'Bonifacio founded the Katipunan in 1892 to organize an armed revolution against Spanish rule.'),

('culture', 'easy', 'image',
  'Identify this iconic mode of public transportation, famous for its colorful designs and originally built from surplus U.S. military vehicles.',
  'https://qfnynkxfkfwdixgiotgi.supabase.co/storage/v1/object/public/question-images/jeepney.jpg',
  'Jeepney', array['Jeepney', 'Jeep'],
  'Jeepneys became a Philippine icon after World War II, when surplus U.S. Army jeeps were refurbished for public transport.'),

('food', 'easy', 'image',
  'Identify this dish, often considered the unofficial national dish, made by braising meat in vinegar, soy sauce, and garlic.',
  'https://qfnynkxfkfwdixgiotgi.supabase.co/storage/v1/object/public/question-images/adobo.jpg',
  'Adobo', array['Adobo', 'Chicken Adobo', 'Pork Adobo'],
  'Adobo''s name comes from the Spanish word for marinade, though the cooking method predates Spanish colonization.'),

('food', 'medium', 'image',
  'Identify this whole roasted pig dish, a centerpiece of Filipino fiestas and celebrations.',
  'https://qfnynkxfkfwdixgiotgi.supabase.co/storage/v1/object/public/question-images/lechon.jpg',
  'Lechon', array['Lechon', 'Lechon Baboy'],
  'Cebu''s version of lechon, seasoned and stuffed with herbs, is especially famous nationwide.'),

('nature_wildlife', 'easy', 'image',
  'Identify this critically endangered bird, one of the largest eagles in the world and the Philippines'' national bird.',
  'https://qfnynkxfkfwdixgiotgi.supabase.co/storage/v1/object/public/question-images/philippine_eagle.jpg',
  'Philippine Eagle', array['Philippine Eagle', 'Haribon', 'Monkey-eating Eagle'],
  'The Philippine Eagle is found only in the Philippines and is one of the rarest raptors on Earth.'),

('nature_wildlife', 'easy', 'image',
  'Identify this tiny nocturnal primate, famous for its huge eyes, commonly found in Bohol.',
  'https://qfnynkxfkfwdixgiotgi.supabase.co/storage/v1/object/public/question-images/tarsier.jpg',
  'Tarsier', array['Tarsier', 'Philippine Tarsier'],
  'The Philippine tarsier is one of the smallest primates in the world, small enough to fit in a human hand.'),

('nature_wildlife', 'medium', 'image',
  'Identify this gentle giant of the sea, the world''s largest fish species, that draws tourists to Donsol and Oslob for swimming encounters.',
  'https://qfnynkxfkfwdixgiotgi.supabase.co/storage/v1/object/public/question-images/whale_shark.jpg',
  'Whale Shark', array['Whale Shark', 'Butanding'],
  'Despite their massive size, whale sharks are filter feeders and pose no threat to humans.'),

('festivals', 'medium', 'image',
  'Identify this vibrant Cebu festival held every third Sunday of January, honoring the Santo Nino with street dancing and drumbeats.',
  'https://qfnynkxfkfwdixgiotgi.supabase.co/storage/v1/object/public/question-images/sinulog_festival.jpg',
  'Sinulog', array['Sinulog', 'Sinulog Festival'],
  'Sinulog is one of the largest and most colorful festivals in the Philippines, drawing millions of visitors to Cebu.'),

('landmarks', 'medium', 'image',
  'Identify this UNESCO World Heritage Site and New7Wonders of Nature in Palawan, featuring a navigable underground river.',
  'https://qfnynkxfkfwdixgiotgi.supabase.co/storage/v1/object/public/question-images/underground_river.jpg',
  'Puerto Princesa Underground River', array['Puerto Princesa Underground River', 'Puerto Princesa Subterranean River', 'Underground River'],
  'The Puerto Princesa Subterranean River is one of the longest navigable underground rivers in the world.'),

('sports', 'easy', 'image',
  'Identify this Filipino boxing legend, the only eight-division world champion in boxing history.',
  'https://qfnynkxfkfwdixgiotgi.supabase.co/storage/v1/object/public/question-images/manny_pacquiao.jpg',
  'Manny Pacquiao', array['Manny Pacquiao', 'Pacquiao', 'Emmanuel Pacquiao'],
  'Manny Pacquiao is widely regarded as one of the greatest boxers of all time and later served as a Philippine senator.');
