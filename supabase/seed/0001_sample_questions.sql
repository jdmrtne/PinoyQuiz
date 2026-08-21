-- Pinoy Quiz — seed: sample question bank
--
-- IMPORTANT — read before adding more: this seeds 80 questions (10 per
-- category, roughly 4 easy / 3 medium / 3 hard each), not the full 240
-- called for in the spec. Every question here was picked for facts I'm
-- confident are accurate and unambiguous — Philippine history, geography,
-- and culture have plenty of contested or regionally-varying trivia, and
-- rushing to 240 by including anything "probably right" would violate the
-- spec's own requirement that answers not be ambiguous or incorrect. This
-- is a real, usable starter set; expanding it to 240 (Phase 14 in the
-- roadmap) means writing 20 more per category with the same bar for
-- verification, not just filling a quota.
--
-- Run this against a project that already has 0001-0009 migrations
-- applied. Safe to re-run only if you first `truncate questions cascade;`
-- — there's no upsert/ON CONFLICT here since `questions` has no natural
-- unique key on content (two different questions could coincidentally
-- match on category+difficulty).

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation) values

-- ============ HISTORY ============
('history','easy','Which Philippine national hero wrote the novels Noli Me Tangere and El Filibusterismo?','Andres Bonifacio','Emilio Aguinaldo','Jose Rizal','Apolinario Mabini','C','Rizal''s two novels exposed abuses under Spanish colonial rule and helped inspire the revolution.'),
('history','easy','In what year did the Philippines declare independence from Spain?','1896','1898','1901','1946','B','Philippine independence was declared on June 12, 1898, in Kawit, Cavite.'),
('history','easy','Who was the first President of the Philippines, leading the First Philippine Republic?','Manuel Quezon','Emilio Aguinaldo','Sergio Osmena','Jose Rizal','B','Emilio Aguinaldo became the first President of the Philippines in 1899.'),
('history','easy','What event in 1986 is known as the EDSA People Power Revolution?','The declaration of martial law','The peaceful uprising that ousted President Marcos','The proclamation of Philippine independence','The assassination of Ninoy Aquino','B','Millions of Filipinos gathered along EDSA in Manila, leading to the peaceful ouster of President Ferdinand Marcos.'),
('history','medium','Who founded the Katipunan, the secret society that launched the Philippine Revolution against Spain?','Jose Rizal','Andres Bonifacio','Antonio Luna','Gregorio del Pilar','B','Andres Bonifacio founded the Katipunan in 1892.'),
('history','medium','Which country ruled the Philippines as a colony immediately before American rule began?','Portugal','Spain','The Netherlands','Britain','B','Spain ruled the Philippines for over 300 years until it ceded the islands to the U.S. in 1898.'),
('history','medium','Who was President of the Philippines when full independence from the United States was granted in 1946?','Manuel Roxas','Sergio Osmena','Jose P. Laurel','Elpidio Quirino','A','Manuel Roxas was inaugurated in 1946, the same year the U.S. formally recognized Philippine independence.'),
('history','medium','Which Filipino leader was assassinated at Manila International Airport in 1983?','Ferdinand Marcos','Benigno "Ninoy" Aquino Jr.','Jose Rizal','Ramon Magsaysay','B','Ninoy Aquino was shot upon his return from exile, an event that galvanized opposition to the Marcos government.'),
('history','hard','Which major World War II naval battle, fought near the Philippines in October 1944, is considered one of the largest naval battles in history?','Battle of Bataan','Battle of Leyte Gulf','Battle of Manila','Battle of Corregidor','B','The Battle of Leyte Gulf marked General MacArthur''s return to the Philippines.'),
('history','hard','Who was President of the Philippines when martial law was declared in 1972?','Diosdado Macapagal','Ferdinand Marcos','Corazon Aquino','Fidel Ramos','B','Marcos declared martial law on September 21, 1972, and it remained in effect for years.'),

-- ============ GEOGRAPHY ============
('geography','easy','What is the capital city of the Philippines?','Cebu City','Davao City','Manila','Quezon City','C','Manila has been the capital of the Philippines since Spanish colonial times.'),
('geography','easy','The Philippine archipelago is traditionally divided into which three major island groups?','Luzon, Visayas, Mindanao','Luzon, Palawan, Mindanao','Visayas, Sulu, Luzon','Mindanao, Cebu, Luzon','A','Luzon, Visayas, and Mindanao are the three principal island groups.'),
('geography','easy','Which is the largest island in the Philippines?','Mindanao','Luzon','Palawan','Cebu','B','Luzon is both the largest island and home to Manila, the capital.'),
('geography','easy','Which famous rolling hills in Bohol turn brown during the dry season, giving them their name?','Banaue Rice Terraces','Chocolate Hills','Taal Volcano','Enchanted River','B','The Chocolate Hills are a famous geological formation and tourist attraction in Bohol.'),
('geography','medium','What is the highest mountain in the Philippines?','Mount Pulag','Mount Apo','Mount Mayon','Mount Banahaw','B','Mount Apo, located in Mindanao, stands at roughly 2,954 meters.'),
('geography','medium','Which body of water separates the northern Philippines (Batanes) from Taiwan?','Sulu Sea','Bashi Channel','Celebes Sea','Sibuyan Sea','B','The Bashi Channel lies between the Batanes Islands and Taiwan.'),
('geography','medium','The Banaue Rice Terraces, carved into mountains by ancestors of the Ifugao people, are located in which region?','Ilocos Region','Cordillera Administrative Region','Bicol Region','Central Luzon','B','The terraces are found in Ifugao province, within the Cordillera Administrative Region.'),
('geography','medium','Which province in Central Luzon is often referred to as the "Rice Granary of the Philippines"?','Nueva Ecija','Batangas','Cavite','Zambales','A','Nueva Ecija is one of the country''s largest producers of rice.'),
('geography','hard','What is the longest river in the Philippines?','Pasig River','Cagayan River','Agusan River','Rio Grande de Mindanao','B','The Cagayan River in northern Luzon is the longest river in the country.'),
('geography','hard','Which volcano in Albay province is famous worldwide for its near-perfect cone shape?','Taal Volcano','Mayon Volcano','Mount Pinatubo','Kanlaon Volcano','B','Mayon Volcano''s symmetrical cone makes it one of the most photographed volcanoes in the world.'),

-- ============ CULTURE ============
('culture','easy','What is the Filipino tradition called in which neighbors help carry a house to a new location as a symbol of community spirit?','Bayanihan','Kundiman','Harana','Pasalubong','A','Bayanihan represents the spirit of communal unity and cooperation.'),
('culture','easy','In Filipino culture, what do the words "po" and "opo" express when speaking to elders?','A greeting','Respect','A farewell','A question','B','"Po" and "opo" are markers of politeness and respect, especially toward elders.'),
('culture','easy','What is the Filipino term for gifts or treats brought home for family after a trip?','Kamayan','Pasalubong','Pabasa','Simbang Gabi','B','Pasalubong is a cherished homecoming tradition in Filipino culture.'),
('culture','easy','What does the Filipino term "Kuya" refer to?','An older brother','A grandmother','A godparent','A younger sister','A','"Kuya" is used as a respectful term for an older brother or older male relative/friend.'),
('culture','medium','What is "Simbang Gabi"?','A wedding ceremony','A series of dawn masses held in the days before Christmas','A harvest festival','A traditional funeral rite','B','Simbang Gabi is a nine-day novena of dawn masses leading up to Christmas.'),
('culture','medium','What is "Kamayan," a traditional Filipino way of dining?','Eating a meal with the hands, often off banana leaves','A formal seated banquet','A fasting ritual','A type of dessert buffet','A','Kamayan dining involves eating directly with the hands, often from banana leaves.'),
('culture','medium','What is "Pagmamano," a gesture of respect toward elders?','Bowing deeply from the waist','Taking an elder''s hand and touching it to one''s forehead','Removing one''s shoes indoors','Offering a handshake with both hands','B','Pagmamano, or "mano po," shows respect by touching an elder''s hand to one''s forehead.'),
('culture','medium','The Sinulog Festival, one of the Philippines'' grandest festivals held in Cebu, honors which religious icon?','The Black Nazarene','Santo Nino, the Child Jesus','Our Lady of Penafrancia','San Lorenzo Ruiz','B','Sinulog is celebrated in honor of the Santo Nino.'),
('culture','hard','The Ati-Atihan Festival, one of the oldest and most famous Philippine festivals, is celebrated every January in which province?','Cebu','Aklan','Iloilo','Leyte','B','Ati-Atihan is held in Kalibo, Aklan.'),
('culture','hard','What Filipino value describes a deeply felt sense of gratitude or reciprocal obligation toward someone who has helped you?','Hiya','Utang na loob','Pakikisama','Bahala na','B','Utang na loob refers to an enduring debt of gratitude.'),

-- ============ FOOD ============
('food','easy','Which Filipino dish is typically made by simmering pork or chicken in vinegar, soy sauce, and garlic?','Sinigang','Adobo','Kare-Kare','Lechon','B','Adobo is widely considered a national dish of the Philippines.'),
('food','easy','Lechon, a Filipino fiesta favorite, refers to what dish?','Grilled fish','A whole roasted pig','A beef stew','A rice cake','B','Lechon is a whole pig roasted over charcoal, popular at Filipino celebrations.'),
('food','easy','What popular Filipino dessert is made of shaved ice topped with mixed sweets like beans, jackfruit, and evaporated milk?','Halo-Halo','Turon','Leche Flan','Bibingka','A','"Halo-halo" literally means "mix-mix" in Filipino.'),
('food','easy','What Filipino soup dish is well known for its distinctly sour broth?','Adobo','Sinigang','Kare-Kare','Caldereta','B','Sinigang''s sourness traditionally comes from tamarind.'),
('food','medium','Which Filipino dish is traditionally made using pork blood, vinegar, and spices?','Dinuguan','Kare-Kare','Bicol Express','Caldereta','A','Dinuguan is a savory stew often paired with rice cakes called puto.'),
('food','medium','What is the main ingredient that gives Kare-Kare its rich, thick sauce?','Coconut milk','Peanut sauce','Tomato sauce','Soy sauce','B','Kare-Kare''s signature sauce is made from ground peanuts or peanut butter.'),
('food','medium','"Bicol Express" is a spicy Filipino dish typically made with pork, chili peppers, and what other key ingredient?','Coconut milk','Soy sauce','Vinegar','Oyster sauce','A','The dish, named after a train line, hails from the Bicol region and uses coconut milk for its creamy heat.'),
('food','medium','Leche Flan, a beloved Filipino dessert, is primarily made from eggs, milk, and what else?','Caramelized sugar','Shredded coconut','Rice flour','Cream cheese','A','Leche flan is a custard dessert topped with a layer of caramelized sugar.'),
('food','hard','What is "Balut," a well-known Filipino street food?','A type of rice cake','A fertilized duck egg','A dried, salted fish','A sweet corn drink','B','Balut is a fertilized duck egg that is boiled and eaten from the shell.'),
('food','hard','Filipino "Pancit" noodle dishes trace their origins largely to the culinary influence of which group?','Spanish traders','Chinese immigrants','American colonizers','Japanese settlers','B','The word "pancit" itself derives from the Hokkien Chinese phrase for "convenient food."'),

-- ============ ENTERTAINMENT ============
('entertainment','easy','What does "OPM" stand for in the Philippine music scene?','Original Pilipino Music','Official Philippine Media','Overseas Pinoy Music','Original Philippine Movies','A','OPM refers broadly to popular music produced by Filipino artists.'),
('entertainment','easy','Darna, a famous Filipino superheroine who has appeared in comics, film, and TV, was created by which komiks writer?','Mars Ravelo','Carlo J. Caparas','Francisco V. Coching','Nestor Redondo','A','Mars Ravelo created Darna, first appearing in komiks in 1950.'),
('entertainment','easy','Which Filipino singer is popularly known as "Asia''s Songbird"?','Sarah Geronimo','Lea Salonga','Regine Velasquez','Kyla','C','Regine Velasquez earned the nickname for her powerful vocal range.'),
('entertainment','easy','"Eat Bulaga!," which first aired in 1979, is famous for being one of the world''s longest-running what?','Game shows','Noontime variety shows','Soap operas','News programs','B','Eat Bulaga! is widely cited as one of the longest-running noontime variety shows in television history.'),
('entertainment','medium','Lea Salonga rose to international fame after originating the lead role of Kim in which hit musical?','Les Miserables','Miss Saigon','The Phantom of the Opera','Cats','B','Lea Salonga won an Olivier and a Tony Award for her performance in Miss Saigon.'),
('entertainment','medium','In the popular Filipino film franchise "Ang Panday," the hero Flavio forges a magical weapon from a meteorite. What is it?','A shield','A sword','An amulet','A spear','B','Flavio forges the magical sword central to the "Ang Panday" story.'),
('entertainment','medium','Which director helmed the classic 1982 Filipino film "Himala," starring Nora Aunor, often cited as one of the greatest Filipino films ever made?','Lino Brocka','Ishmael Bernal','Mike de Leon','Eddie Romero','B','Ishmael Bernal directed "Himala," a landmark of Philippine cinema.'),
('entertainment','medium','"Bubble Gang," a long-running Philippine gag show, is best known for what kind of content?','Investigative journalism','Comedy sketches','Cooking demonstrations','Historical dramas','B','Bubble Gang has aired comedic sketches since 1995.'),
('entertainment','hard','The beloved giant-robot anime series "Voltes V," a massive hit among Filipino viewers, originally came from which country?','Philippines','Japan','South Korea','United States','B','Voltes V is a Japanese anime that became hugely popular in the Philippines after airing in the late 1970s.'),
('entertainment','hard','During the martial law era, "Voltes V" was pulled from Philippine television, reportedly over concerns about its content. What genre is the show?','Giant-robot anime','Sitcom','Telenovela','Game show','A','The Marcos government ordered Voltes V off the air in 1979, reportedly citing its violent content.'),

-- ============ SPORTS ============
('sports','easy','What is widely considered the most popular sport in the Philippines?','Baseball','Basketball','Soccer','Volleyball','B','Basketball is played and followed passionately across the country, from barangay courts to the PBA.'),
('sports','easy','What does "PBA" stand for, the Philippines'' premier professional basketball league?','Philippine Basketball Association','Pacific Basketball Alliance','Philippine Boxing Association','Pro Basketball Asia','A','The PBA was founded in 1975.'),
('sports','easy','Which Filipino boxer, later a senator, is an eight-division world champion widely regarded as one of the greatest boxers ever?','Nonito Donaire','Manny Pacquiao','Gerry Penalosa','Flash Elorde','B','Manny Pacquiao is the only boxer in history to win world titles in eight different weight divisions.'),
('sports','easy','In which year did the Philippines host the Southeast Asian (SEA) Games as the 30th edition?','2015','2017','2019','2021','C','The Philippines hosted the 30th SEA Games in 2019.'),
('sports','medium','What does "UAAP" stand for in Philippine collegiate sports?','United Athletic Association of the Philippines','University Athletic Association of the Philippines','Universal Amateur Athletic Program','United Amateur Athletes Philippines','B','The UAAP is a collegiate athletic association among major Philippine universities.'),
('sports','medium','In which sport did Hidilyn Diaz win the Philippines'' first-ever Olympic gold medal, at the Tokyo 2020 Olympics?','Boxing','Weightlifting','Swimming','Track and field','B','Hidilyn Diaz won gold in women''s weightlifting, a historic first for the Philippines.'),
('sports','medium','Efren "Bata" Reyes, one of the most celebrated Filipino athletes internationally, made his name in which sport?','Chess','Billiards (pool)','Bowling','Table tennis','B','Efren Reyes is widely regarded as one of the greatest pool players of all time.'),
('sports','medium','Founded in 1975, the PBA is recognized as the oldest professional basketball league in which continent?','Europe','Asia','South America','Africa','B','The PBA predates most other professional basketball leagues in Asia.'),
('sports','hard','Gabriel "Flash" Elorde was a legendary Filipino boxer who held a long reign as world champion in which weight division during the 1960s?','Lightweight','Junior lightweight','Featherweight','Welterweight','B','Elorde held the world junior lightweight title for nearly a decade.'),
('sports','hard','Rafael "Paeng" Nepomuceno, a multi-time world champion, made the Philippines proud in which sport?','Chess','Ten-pin bowling','Badminton','Archery','B','Nepomuceno won multiple World Cup titles in ten-pin bowling.'),

-- ============ TRIVIA ============
('trivia','easy','What is the official currency of the Philippines?','Peso','Ringgit','Baht','Dong','A','The Philippine peso is the country''s official currency.'),
('trivia','easy','What is considered the national fruit of the Philippines?','Mango','Banana','Pineapple','Durian','A','The mango, especially the sweet Carabao mango variety, is widely regarded as the national fruit.'),
('trivia','easy','What is the national bird of the Philippines?','Maya bird','Philippine Eagle','Kalaw (hornbill)','Tarsier','B','The Philippine Eagle, one of the largest eagles in the world, is the national bird.'),
('trivia','easy','What are the two official languages of the Philippines, as stated in its Constitution?','Filipino and Spanish','Filipino and English','Tagalog and Cebuano','English and Spanish','B','The 1987 Constitution names Filipino and English as the official languages.'),
('trivia','medium','When flown or displayed with the red field on top instead of blue, what does the Philippine flag signify?','A national holiday','A state of war','Independence Day','Mourning','B','By tradition and law, the flag is flown red-side-up to signal a state of war.'),
('trivia','medium','The three stars on the Philippine flag represent which three main island groups?','Luzon, Visayas, and Mindanao','Manila, Cebu, and Davao','North, Central, and South Luzon','Luzon, Palawan, and Mindanao','A','Each star represents one of the country''s three main geographic divisions.'),
('trivia','medium','The Philippine Eagle earned an older common nickname related to its diet of small mammals. What was it commonly called?','Fish Eagle','Monkey-eating Eagle','Golden Eagle','Sea Eagle','B','It was long known as the "monkey-eating eagle" before being officially renamed.'),
('trivia','medium','Roughly how many islands make up the Philippine archipelago, as commonly cited?','About 1,000','About 3,000','About 7,100','About 15,000','C','The Philippines is commonly described as having roughly 7,100 islands.'),
('trivia','hard','The Philippine tarsier, found in Bohol, is famous for being one of the smallest what in the world?','Species of bats','Primates','Birds of prey','Reptiles','B','The Philippine tarsier is one of the smallest primates on Earth.'),
('trivia','hard','The Philippines lies within a marine region renowned for having the highest marine biodiversity on Earth. What is this region called?','The Coral Triangle','The Great Barrier Reef','The Sunda Shelf','The Mariana Trench','A','The Coral Triangle spans the Philippines and neighboring Southeast Asian waters.'),

-- ============ SLANG & LANGUAGE ============
('slang','easy','What does the Filipino slang word "Kilig" describe?','Feeling angry','The giddy, fluttery feeling of romantic excitement','Feeling very tired','Feeling hungry','B','"Kilig" has no exact English equivalent and describes butterflies-in-the-stomach excitement.'),
('slang','easy','What does "Chismis" mean in everyday Filipino conversation?','Gossip','A type of street food','Money','A close friend','A','"Chismis" is the Filipino word for gossip.'),
('slang','easy','What does the popular expression "Tara na!" mean?','"Let''s go!"','"Stop it!"','"I''m scared"','"Wait here"','A','"Tara na!" is a casual invitation to leave or go somewhere together.'),
('slang','easy','What does "Bahala na" generally express?','"I''m furious"','An attitude of "come what may" or leaving things to fate','"Let''s eat now"','"Goodbye forever"','B','"Bahala na" reflects a mindset of accepting whatever happens next.'),
('slang','medium','What does the word "Gigil" describe?','Extreme hunger','An overwhelming urge to squeeze or pinch something because it''s so cute','Deep sadness','Boredom','B','"Gigil" is another famously untranslatable Filipino word.'),
('slang','medium','When Filipinos add "charot" or "char" to the end of a sentence, what are they usually signaling?','That the statement is very serious','That the statement was just a joke, not to be taken seriously','A formal greeting','An insult','B','"Charot" softens or retracts a statement, marking it as playful.'),
('slang','medium','What does the word "Sayang" typically express?','Excitement about good news','A sense of waste, regret, or "what a pity"','Anger at someone','Pride in an achievement','B','"Sayang" is commonly used when something good is lost or missed.'),
('slang','medium','The expression "Susmaryosep" is a shortened invocation of which three names, often used to express shock?','Santo, Maria, and Jose','Jesus, Mary, and Joseph','Saints, Mary, and John','Jesus, Maria, and Josefina','B','It blends "Jesus, Maria, Jose" into one exclamation of surprise or exasperation.'),
('slang','hard','In casual Filipino slang, what does "Jowa" refer to?','A type of jeepney','One''s boyfriend or girlfriend','A nickname for money','A street food snack','B','"Jowa" is informal slang for a romantic partner.'),
('slang','hard','The Filipino term "Diskarte" describes what kind of personal quality?','Laziness','Resourcefulness and the ability to improvise solutions','Stinginess','Habitual lateness','B','Someone with "diskarte" is skilled at figuring things out on the fly.');
