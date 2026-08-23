-- Pinoy Quiz — 0024: general-knowledge questions (Phase 16 expansion)
--
-- Adds 160 new questions across the 20 general-knowledge categories
-- added in 0023_expand_general_categories.sql — 8 questions per category
-- (Science, Mathematics, Technology, Computer Science, World Geography,
-- World History, World Literature, Language, Arts, World Music, World
-- Movies & TV, World Sports, World Food, Animals, Nature & Environment,
-- Space & Astronomy, Human Body, Business & Economics, Logic & Reasoning,
-- General Trivia). None of the existing 280 Philippine-focused questions
-- from supabase/seed/0001_sample_questions.sql, 0019, or any other prior
-- migration are modified, removed, or duplicated here — this migration
-- only adds new rows.
--
-- Must run after 0023_expand_general_categories.sql has committed (same
-- reasoning as 0018/0019: Postgres will not let a transaction reference an
-- enum value it just added in the same transaction).
--
-- Idempotency: same NOT EXISTS guard per row (matching on category +
-- prompt) as every prior question migration, so this is safe to re-run.

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'easy', 'What is the chemical symbol for water?', 'H2O', 'CO2', 'O2', 'NaCl', 'A', 'Water is composed of two hydrogen atoms and one oxygen atom, giving it the chemical formula H2O.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'What is the chemical symbol for water?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'easy', 'Which gas do plants absorb from the atmosphere during photosynthesis?', 'Carbon dioxide', 'Oxygen', 'Nitrogen', 'Hydrogen', 'A', 'Plants absorb carbon dioxide and use sunlight to convert it, along with water, into glucose and oxygen.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Which gas do plants absorb from the atmosphere during photosynthesis?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'easy', 'What is the powerhouse of the cell, responsible for producing most of a cell''s energy?', 'The mitochondria', 'The nucleus', 'The ribosome', 'The chloroplast', 'A', 'Mitochondria generate most of a cell''s supply of ATP, the molecule cells use for energy.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'What is the powerhouse of the cell, responsible for producing most of a cell''s energy?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'medium', 'What is the smallest unit of matter that retains the chemical properties of an element?', 'An atom', 'A molecule', 'An electron', 'A proton', 'A', 'An atom is the smallest unit of an element that still has that element''s chemical properties.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'What is the smallest unit of matter that retains the chemical properties of an element?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'medium', 'What is the pH value of a neutral solution at 25 degrees Celsius?', '7', '0', '14', '5', 'A', 'A pH of 7 is neutral; values below 7 are acidic and values above 7 are basic (alkaline).'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'What is the pH value of a neutral solution at 25 degrees Celsius?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'medium', 'Which subatomic particle carries no electric charge?', 'The neutron', 'The proton', 'The electron', 'The positron', 'A', 'Neutrons have no electric charge, unlike protons (positive) and electrons (negative).'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Which subatomic particle carries no electric charge?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'hard', 'Saturn currently holds the record for the most confirmed moons of any planet in the solar system, after a wave of discoveries in the mid-2020s. Which planet does it lead?', 'Jupiter', 'Uranus', 'Neptune', 'Mars', 'A', 'A series of discoveries announced in 2025 and 2026 pushed Saturn''s confirmed moon count well past Jupiter''s, making Saturn the current leader in the solar system.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Saturn currently holds the record for the most confirmed moons of any planet in the solar system, after a wave of discoveries in the mid-2020s. Which planet does it lead?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'hard', 'What type of chemical bond involves atoms sharing pairs of electrons?', 'A covalent bond', 'An ionic bond', 'A metallic bond', 'A hydrogen bond', 'A', 'In a covalent bond, atoms share electron pairs, whereas an ionic bond involves the transfer of electrons between atoms.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'What type of chemical bond involves atoms sharing pairs of electrons?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'easy', 'What is 12 multiplied by 8?', '96', '86', '108', '90', 'A', '12 times 8 equals 96.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'What is 12 multiplied by 8?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'easy', 'What is the value of pi (π), rounded to two decimal places?', '3.14', '3.41', '3.12', '3.16', 'A', 'Pi, the ratio of a circle''s circumference to its diameter, is approximately 3.14159, which rounds to 3.14.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'What is the value of pi (π), rounded to two decimal places?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'easy', 'How many sides does a hexagon have?', '6', '5', '7', '8', 'A', 'A hexagon is a polygon with six sides.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'How many sides does a hexagon have?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'medium', 'What is the square root of 144?', '12', '14', '11', '13', 'A', '12 multiplied by itself (12 x 12) equals 144, so the square root of 144 is 12.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'What is the square root of 144?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'medium', 'If 2x + 6 = 20, what is the value of x?', '7', '6', '8', '5', 'A', 'Subtracting 6 from both sides gives 2x = 14, and dividing by 2 gives x = 7.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'If 2x + 6 = 20, what is the value of x?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'medium', 'What is the sum of the interior angles of any triangle?', '180 degrees', '90 degrees', '360 degrees', '270 degrees', 'A', 'The three interior angles of any triangle always add up to exactly 180 degrees.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'What is the sum of the interior angles of any triangle?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'hard', 'What is the value of 7 factorial (7!)?', '5040', '720', '4200', '5400', 'A', '7! means 7 x 6 x 5 x 4 x 3 x 2 x 1, which equals 5040.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'What is the value of 7 factorial (7!)?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'hard', 'In a right triangle, if the two legs measure 3 and 4 units, what is the length of the hypotenuse?', '5', '6', '7', '4.5', 'A', 'By the Pythagorean theorem, the hypotenuse equals the square root of (3 squared plus 4 squared), which is the square root of 25, or 5.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'In a right triangle, if the two legs measure 3 and 4 units, what is the length of the hypotenuse?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'easy', 'What does the abbreviation "CPU" stand for?', 'Central Processing Unit', 'Computer Personal Unit', 'Central Program Utility', 'Central Processing Utility', 'A', 'CPU stands for Central Processing Unit, the primary component that carries out a computer''s instructions.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'What does the abbreviation "CPU" stand for?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'easy', 'What does "www" stand for at the start of many website addresses?', 'World Wide Web', 'World Wide Wire', 'Web World Wide', 'Wide World Web', 'A', '"www" stands for World Wide Web, the system of interlinked web pages accessed via the internet.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'What does "www" stand for at the start of many website addresses?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'easy', 'In technology, what does the abbreviation "AI" most commonly stand for?', 'Artificial Intelligence', 'Automated Interface', 'Advanced Internet', 'Auto Integration', 'A', 'AI stands for Artificial Intelligence, the simulation of human-like reasoning and learning by machines.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'In technology, what does the abbreviation "AI" most commonly stand for?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'medium', 'What does the abbreviation "USB" stand for?', 'Universal Serial Bus', 'United System Bus', 'Universal System Board', 'Unified Serial Board', 'A', 'USB stands for Universal Serial Bus, a common standard for connecting devices to computers.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'What does the abbreviation "USB" stand for?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'medium', 'What is the process of converting data into a coded format to prevent unauthorized access called?', 'Encryption', 'Compression', 'Formatting', 'Indexing', 'A', 'Encryption scrambles data using an algorithm so that only someone with the correct key can read it.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'What is the process of converting data into a coded format to prevent unauthorized access called?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'medium', 'What general term describes malicious software designed to damage or gain unauthorized access to a computer system?', 'Malware', 'Firmware', 'Freeware', 'Shareware', 'A', 'Malware is an umbrella term for viruses, worms, ransomware, and other software designed to cause harm or gain unauthorized access.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'What general term describes malicious software designed to damage or gain unauthorized access to a computer system?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'hard', 'What does the abbreviation "HTTP" stand for?', 'Hypertext Transfer Protocol', 'High Transfer Text Protocol', 'Hyperlink Text Transport Program', 'Home Transfer Text Protocol', 'A', 'HTTP stands for Hypertext Transfer Protocol, the foundational protocol used for transmitting web pages.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'What does the abbreviation "HTTP" stand for?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'hard', 'What is the term for a network attack that overwhelms a system with traffic to make it unavailable to legitimate users?', 'A Denial-of-Service (DoS) attack', 'A phishing attack', 'A man-in-the-middle attack', 'A SQL injection', 'A', 'A Denial-of-Service attack floods a system with excessive traffic or requests, making it unavailable to its intended users.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'What is the term for a network attack that overwhelms a system with traffic to make it unavailable to legitimate users?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'easy', 'What data structure follows a First-In-First-Out (FIFO) order?', 'A queue', 'A stack', 'A tree', 'A graph', 'A', 'A queue processes elements in the same order they were added, like a line of people waiting.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'What data structure follows a First-In-First-Out (FIFO) order?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'easy', 'What data structure follows a Last-In-First-Out (LIFO) order?', 'A stack', 'A queue', 'An array', 'A linked list', 'A', 'A stack processes elements so the most recently added one is removed first, like a stack of plates.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'What data structure follows a Last-In-First-Out (LIFO) order?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'easy', 'What symbol is commonly used to denote a single-line comment in Python?', '#', '//', '/* */', '--', 'A', 'In Python, a hash symbol (#) marks the rest of a line as a comment that the interpreter ignores.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'What symbol is commonly used to denote a single-line comment in Python?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'medium', 'Which sorting algorithm repeatedly steps through a list, compares adjacent elements, and swaps them if they are in the wrong order?', 'Bubble Sort', 'Quick Sort', 'Merge Sort', 'Heap Sort', 'A', 'Bubble Sort repeatedly compares and swaps adjacent elements, causing larger values to "bubble" toward the end of the list.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'Which sorting algorithm repeatedly steps through a list, compares adjacent elements, and swaps them if they are in the wrong order?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'medium', 'What is the decimal number 5 represented as in binary?', '101', '110', '111', '100', 'A', '5 in binary is 101, since 1x4 + 0x2 + 1x1 = 5.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'What is the decimal number 5 represented as in binary?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'medium', 'What does the abbreviation "SQL" stand for?', 'Structured Query Language', 'Sequential Query Logic', 'Simple Query Language', 'System Query Language', 'A', 'SQL stands for Structured Query Language, used to manage and query relational databases.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'What does the abbreviation "SQL" stand for?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'hard', 'What is the time complexity of binary search on a sorted array of n elements?', 'O(log n)', 'O(n)', 'O(n squared)', 'O(1)', 'A', 'Binary search repeatedly halves the search space, giving it a logarithmic time complexity of O(log n).'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'What is the time complexity of binary search on a sorted array of n elements?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'hard', 'What term describes a function that calls itself to solve smaller instances of the same problem?', 'Recursion', 'Iteration', 'Inheritance', 'Polymorphism', 'A', 'Recursion is when a function calls itself, typically to break a problem down into smaller sub-problems.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'What term describes a function that calls itself to solve smaller instances of the same problem?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'easy', 'What is the largest continent by land area?', 'Asia', 'Africa', 'North America', 'Europe', 'A', 'Asia is the largest continent by both land area and population.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'What is the largest continent by land area?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'easy', 'What is the largest country in the world by total land area?', 'Russia', 'Canada', 'China', 'United States', 'A', 'Russia spans roughly 17 million square kilometers, making it the largest country in the world by land area.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'What is the largest country in the world by total land area?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'easy', 'What is the smallest country in the world by land area?', 'Vatican City', 'Monaco', 'San Marino', 'Liechtenstein', 'A', 'Vatican City, at roughly 0.44 square kilometers, is the smallest sovereign state in the world.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'What is the smallest country in the world by land area?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'medium', 'Which desert is the largest hot desert in the world?', 'The Sahara', 'The Gobi', 'The Kalahari', 'The Arabian Desert', 'A', 'The Sahara, spanning much of North Africa, is the largest hot desert in the world.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'Which desert is the largest hot desert in the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'medium', 'What is the capital city of Australia?', 'Canberra', 'Sydney', 'Melbourne', 'Perth', 'A', 'Canberra, not Sydney or Melbourne, is the capital of Australia, chosen as a compromise between the two larger rival cities.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'What is the capital city of Australia?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'medium', 'Which mountain range is often considered the traditional dividing line between Europe and Asia within Russia?', 'The Ural Mountains', 'The Alps', 'The Andes', 'The Himalayas', 'A', 'The Ural Mountains, running north to south through Russia, are traditionally used to mark the boundary between Europe and Asia.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'Which mountain range is often considered the traditional dividing line between Europe and Asia within Russia?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'hard', 'What is the tallest mountain in the world, measured from sea level to its peak?', 'Mount Everest', 'K2', 'Kangchenjunga', 'Denali', 'A', 'Mount Everest, on the border of Nepal and China, stands at 8,849 meters above sea level, the tallest peak on Earth.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'What is the tallest mountain in the world, measured from sea level to its peak?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'hard', 'Which African country was formerly known as Abyssinia?', 'Ethiopia', 'Eritrea', 'Sudan', 'Somalia', 'A', 'Ethiopia was historically referred to as Abyssinia, a name used widely in Europe before the 20th century.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'Which African country was formerly known as Abyssinia?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'easy', 'In which year did World War II end?', '1945', '1939', '1918', '1950', 'A', 'World War II ended in 1945, with Germany surrendering in May and Japan surrendering in September.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'In which year did World War II end?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'easy', 'Who was the first President of the United States?', 'George Washington', 'Thomas Jefferson', 'Abraham Lincoln', 'John Adams', 'A', 'George Washington served as the first President of the United States, from 1789 to 1797.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'Who was the first President of the United States?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'easy', 'Which ancient civilization built the pyramids of Giza?', 'The ancient Egyptians', 'The ancient Greeks', 'The ancient Romans', 'The Mesopotamians', 'A', 'The pyramids of Giza were built by the ancient Egyptians, primarily during the Old Kingdom period.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'Which ancient civilization built the pyramids of Giza?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'medium', 'The Renaissance, a period of renewed interest in art, science, and learning, began in which country?', 'Italy', 'France', 'England', 'Spain', 'A', 'The Renaissance began in Italy in the 14th century before spreading across Europe.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'The Renaissance, a period of renewed interest in art, science, and learning, began in which country?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'medium', 'Julius Caesar was a famous general and statesman of which ancient civilization?', 'The Roman Republic', 'The Roman Empire', 'Ancient Greece', 'Ancient Egypt', 'A', 'Julius Caesar rose to power within the Roman Republic; the Roman Empire formally began only after his assassination, under his successor Augustus.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'Julius Caesar was a famous general and statesman of which ancient civilization?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'medium', 'In which year did the Berlin Wall fall?', '1989', '1991', '1975', '1985', 'A', 'The Berlin Wall fell in November 1989, a pivotal moment leading to German reunification.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'In which year did the Berlin Wall fall?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'hard', 'Which treaty officially ended World War I?', 'The Treaty of Versailles', 'The Treaty of Paris', 'The Treaty of Vienna', 'The Treaty of Tordesillas', 'A', 'The Treaty of Versailles, signed in 1919, formally ended the state of war between Germany and the Allied Powers.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'Which treaty officially ended World War I?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'hard', 'In which year did the French Revolution begin?', '1789', '1799', '1776', '1804', 'A', 'The French Revolution began in 1789 with events including the storming of the Bastille.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'In which year did the French Revolution begin?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'easy', 'Who wrote the play "Romeo and Juliet"?', 'William Shakespeare', 'Charles Dickens', 'Mark Twain', 'Jane Austen', 'A', 'William Shakespeare wrote "Romeo and Juliet" in the late 16th century.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'Who wrote the play "Romeo and Juliet"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'easy', 'Who wrote the "Harry Potter" book series?', 'J.K. Rowling', 'Suzanne Collins', 'J.R.R. Tolkien', 'Roald Dahl', 'A', 'J.K. Rowling wrote the seven-book "Harry Potter" series.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'Who wrote the "Harry Potter" book series?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'easy', 'Who wrote the dystopian novel "1984"?', 'George Orwell', 'Aldous Huxley', 'Ray Bradbury', 'H.G. Wells', 'A', 'George Orwell published "1984" in 1949, depicting a totalitarian surveillance state.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'Who wrote the dystopian novel "1984"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'medium', 'Who wrote the novel "Pride and Prejudice"?', 'Jane Austen', 'Charlotte Bronte', 'Emily Bronte', 'George Eliot', 'A', 'Jane Austen wrote "Pride and Prejudice," first published in 1813.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'Who wrote the novel "Pride and Prejudice"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'medium', 'Who is traditionally credited as the author of the ancient Greek epic poems "The Iliad" and "The Odyssey"?', 'Homer', 'Virgil', 'Sophocles', 'Aristotle', 'A', 'The epics "The Iliad" and "The Odyssey" are traditionally attributed to the ancient Greek poet Homer.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'Who is traditionally credited as the author of the ancient Greek epic poems "The Iliad" and "The Odyssey"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'medium', 'Which author wrote "One Hundred Years of Solitude," a landmark work of magical realism?', 'Gabriel Garcia Marquez', 'Jorge Luis Borges', 'Pablo Neruda', 'Mario Vargas Llosa', 'A', 'Colombian author Gabriel Garcia Marquez wrote "One Hundred Years of Solitude," published in 1967.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'Which author wrote "One Hundred Years of Solitude," a landmark work of magical realism?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'hard', 'Who wrote the Russian novel "War and Peace"?', 'Leo Tolstoy', 'Fyodor Dostoevsky', 'Anton Chekhov', 'Ivan Turgenev', 'A', 'Leo Tolstoy wrote "War and Peace," a sweeping novel set during the Napoleonic era.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'Who wrote the Russian novel "War and Peace"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'hard', '"Don Quixote," often cited as one of the first modern novels, was written by which Spanish author?', 'Miguel de Cervantes', 'Federico Garcia Lorca', 'Pedro Calderon de la Barca', 'Lope de Vega', 'A', 'Miguel de Cervantes published "Don Quixote" in two parts, in 1605 and 1615.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = '"Don Quixote," often cited as one of the first modern novels, was written by which Spanish author?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'easy', 'What part of speech describes an action or a state of being?', 'A verb', 'A noun', 'An adjective', 'An adverb', 'A', 'A verb expresses an action, occurrence, or state of being in a sentence.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'What part of speech describes an action or a state of being?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'easy', 'What is the correct plural form of "child"?', 'Children', 'Childs', 'Childes', 'Childrens', 'A', '"Children" is the irregular plural form of "child."'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'What is the correct plural form of "child"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'easy', 'What punctuation mark is used at the end of a question?', 'A question mark', 'An exclamation point', 'A comma', 'A period', 'A', 'A question mark (?) is placed at the end of a direct question.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'What punctuation mark is used at the end of a question?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'medium', 'What is a word that means the same or nearly the same as another word called?', 'A synonym', 'An antonym', 'A homonym', 'An acronym', 'A', 'A synonym is a word with the same or a very similar meaning to another word.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'What is a word that means the same or nearly the same as another word called?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'medium', 'What is a word that means the opposite of another word called?', 'An antonym', 'A synonym', 'A homophone', 'A metaphor', 'A', 'An antonym is a word that means the opposite of another word.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'What is a word that means the opposite of another word called?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'medium', 'What figure of speech directly compares two unlike things using "like" or "as"?', 'A simile', 'A metaphor', 'Personification', 'Hyperbole', 'A', 'A simile compares two different things using "like" or "as," such as "brave as a lion."'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'What figure of speech directly compares two unlike things using "like" or "as"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'hard', 'What is the branch of linguistics concerned with the study of meaning in language called?', 'Semantics', 'Syntax', 'Phonetics', 'Morphology', 'A', 'Semantics is the study of meaning in language, including how words and sentences convey meaning.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'What is the branch of linguistics concerned with the study of meaning in language called?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'hard', 'What term describes a word that is spelled the same as another but has a different meaning?', 'A homonym', 'A synonym', 'An antonym', 'An acronym', 'A', 'A homonym is a word that shares its spelling (and often pronunciation) with another word but differs in meaning.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'What term describes a word that is spelled the same as another but has a different meaning?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'easy', 'Who painted the "Mona Lisa"?', 'Leonardo da Vinci', 'Michelangelo', 'Raphael', 'Pablo Picasso', 'A', 'Leonardo da Vinci painted the "Mona Lisa" in the early 16th century.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'Who painted the "Mona Lisa"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'easy', 'Who painted "The Starry Night"?', 'Vincent van Gogh', 'Claude Monet', 'Salvador Dali', 'Edvard Munch', 'A', 'Vincent van Gogh painted "The Starry Night" in 1889.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'Who painted "The Starry Night"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'easy', 'In traditional color theory, what are the three primary colors?', 'Red, blue, and yellow', 'Red, green, and blue', 'Yellow, green, and purple', 'Red, orange, and yellow', 'A', 'Red, blue, and yellow are the traditional primary colors, from which other colors can be mixed.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'In traditional color theory, what are the three primary colors?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'medium', 'Which Italian artist painted the ceiling of the Sistine Chapel?', 'Michelangelo', 'Leonardo da Vinci', 'Raphael', 'Donatello', 'A', 'Michelangelo painted the ceiling of the Sistine Chapel between 1508 and 1512.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'Which Italian artist painted the ceiling of the Sistine Chapel?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'medium', 'Which art movement, associated with artists like Salvador Dali, focused on dreamlike and irrational imagery?', 'Surrealism', 'Impressionism', 'Cubism', 'Realism', 'A', 'Surrealism sought to express the workings of the unconscious mind through dreamlike, irrational imagery.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'Which art movement, associated with artists like Salvador Dali, focused on dreamlike and irrational imagery?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'medium', 'Pablo Picasso, along with Georges Braque, is credited with pioneering which early 20th-century art movement?', 'Cubism', 'Fauvism', 'Dadaism', 'Expressionism', 'A', 'Picasso and Braque are considered the co-founders of Cubism, which depicted subjects from multiple angles at once.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'Pablo Picasso, along with Georges Braque, is credited with pioneering which early 20th-century art movement?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'hard', 'Which architectural style, associated with pointed arches and flying buttresses, dominated European cathedral-building in the Middle Ages?', 'Gothic architecture', 'Baroque architecture', 'Romanesque architecture', 'Neoclassical architecture', 'A', 'Gothic architecture, known for pointed arches, ribbed vaults, and flying buttresses, dominated medieval European cathedral design.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'Which architectural style, associated with pointed arches and flying buttresses, dominated European cathedral-building in the Middle Ages?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'hard', 'The famous marble sculpture "David" was created by which Renaissance artist?', 'Michelangelo', 'Donatello', 'Bernini', 'Cellini', 'A', 'Michelangelo carved the marble sculpture "David" between 1501 and 1504.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'The famous marble sculpture "David" was created by which Renaissance artist?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'easy', 'How many strings does a standard guitar have?', '6', '4', '8', '12', 'A', 'A standard guitar has six strings.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'How many strings does a standard guitar have?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'easy', 'Which composer, famous for losing his hearing, wrote the Ninth Symphony?', 'Ludwig van Beethoven', 'Wolfgang Amadeus Mozart', 'Johann Sebastian Bach', 'Franz Schubert', 'A', 'Ludwig van Beethoven composed his Ninth Symphony while almost completely deaf.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'Which composer, famous for losing his hearing, wrote the Ninth Symphony?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'easy', 'Which musical instrument typically has 88 keys?', 'The piano', 'The violin', 'The flute', 'The trumpet', 'A', 'A standard piano has 88 keys, spanning seven octaves plus a few extra notes.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'Which musical instrument typically has 88 keys?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'medium', 'Which pop icon is known as the "King of Pop"?', 'Michael Jackson', 'Elvis Presley', 'Prince', 'Stevie Wonder', 'A', 'Michael Jackson earned the nickname "King of Pop" for his immense influence on popular music.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'Which pop icon is known as the "King of Pop"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'medium', 'Which music genre originated in New Orleans in the early 20th century, blending blues and ragtime influences?', 'Jazz', 'Reggae', 'Country', 'Disco', 'A', 'Jazz emerged in New Orleans in the early 1900s, drawing on blues, ragtime, and other African American musical traditions.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'Which music genre originated in New Orleans in the early 20th century, blending blues and ragtime influences?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'medium', 'The Beatles, one of the most influential bands in music history, originated in which city?', 'Liverpool', 'London', 'Manchester', 'Birmingham', 'A', 'The Beatles formed in Liverpool, England, in 1960.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'The Beatles, one of the most influential bands in music history, originated in which city?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'hard', 'Which composer wrote "The Four Seasons," a famous set of four violin concertos?', 'Antonio Vivaldi', 'Johann Sebastian Bach', 'George Frideric Handel', 'Joseph Haydn', 'A', 'Antonio Vivaldi composed "The Four Seasons" in the early 1720s.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'Which composer wrote "The Four Seasons," a famous set of four violin concertos?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'hard', 'What musical term describes the speed or pace at which a piece of music is played?', 'Tempo', 'Timbre', 'Dynamics', 'Pitch', 'A', 'Tempo refers to how fast or slow a piece of music is performed.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'What musical term describes the speed or pace at which a piece of music is played?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'easy', 'Which studio produced the animated film "Frozen"?', 'Walt Disney Animation Studios', 'Pixar', 'DreamWorks', 'Warner Bros', 'A', '"Frozen" (2013) was produced by Walt Disney Animation Studios, not Pixar.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Which studio produced the animated film "Frozen"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'easy', 'Who directed the original 1993 film "Jurassic Park"?', 'Steven Spielberg', 'George Lucas', 'James Cameron', 'Ridley Scott', 'A', 'Steven Spielberg directed "Jurassic Park," released in 1993.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Who directed the original 1993 film "Jurassic Park"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'easy', 'Which long-running animated sitcom follows the Simpson family?', 'The Simpsons', 'Family Guy', 'South Park', 'King of the Hill', 'A', '"The Simpsons," which premiered in 1989, follows the misadventures of the Simpson family.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Which long-running animated sitcom follows the Simpson family?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'medium', 'Which actor is famous for playing Captain Jack Sparrow in the "Pirates of the Caribbean" film series?', 'Johnny Depp', 'Orlando Bloom', 'Geoffrey Rush', 'Javier Bardem', 'A', 'Johnny Depp originated and starred as Captain Jack Sparrow across the "Pirates of the Caribbean" franchise.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Which actor is famous for playing Captain Jack Sparrow in the "Pirates of the Caribbean" film series?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'medium', 'What was the first feature-length fully computer-animated film, released in 1995?', 'Toy Story', 'Shrek', 'Toy Story 2', 'A Bug''s Life', 'A', '"Toy Story" (1995), produced by Pixar, was the first fully computer-animated feature film.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'What was the first feature-length fully computer-animated film, released in 1995?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'medium', 'Which 1993 historical drama, directed by Steven Spielberg, won the Academy Award for Best Picture?', 'Schindler''s List', 'Jurassic Park', 'The Fugitive', 'In the Name of the Father', 'A', '"Schindler''s List" won the Academy Award for Best Picture at the 1994 ceremony, honoring films from 1993.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Which 1993 historical drama, directed by Steven Spielberg, won the Academy Award for Best Picture?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'hard', 'Which 1941 film, directed by and starring Orson Welles, is widely regarded by critics as one of the greatest films ever made?', 'Citizen Kane', 'Casablanca', 'Gone with the Wind', 'The Maltese Falcon', 'A', '"Citizen Kane" (1941) is frequently cited by critics and historians as one of the greatest films ever made.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Which 1941 film, directed by and starring Orson Welles, is widely regarded by critics as one of the greatest films ever made?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'hard', 'Which long-running British science fiction series, first aired in 1963, features a time-traveling alien known as "the Doctor"?', 'Doctor Who', 'Star Trek', 'Blake''s 7', 'Red Dwarf', 'A', '"Doctor Who" first aired on the BBC in 1963 and remains one of the longest-running science fiction series in television history.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Which long-running British science fiction series, first aired in 1963, features a time-traveling alien known as "the Doctor"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'easy', 'How many players from each team are on the field at one time in standard soccer (football)?', '11', '10', '9', '12', 'A', 'Each soccer team fields 11 players at a time, including the goalkeeper.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'How many players from each team are on the field at one time in standard soccer (football)?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'easy', 'In which sport would a player perform a "slam dunk"?', 'Basketball', 'Volleyball', 'Tennis', 'Badminton', 'A', 'A slam dunk is a basketball scoring move where a player jumps and forces the ball directly through the hoop.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'In which sport would a player perform a "slam dunk"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'easy', 'How often are the Summer Olympic Games held?', 'Every 4 years', 'Every 2 years', 'Every 3 years', 'Every 5 years', 'A', 'The Summer Olympic Games are held once every four years.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'How often are the Summer Olympic Games held?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'medium', 'As of the 2026 FIFA World Cup, which country has won the most World Cup titles overall?', 'Brazil', 'Germany', 'Italy', 'Argentina', 'A', 'Brazil has won the FIFA World Cup five times (1958, 1962, 1970, 1994, 2002), more than any other nation, even after Spain''s 2026 title.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'As of the 2026 FIFA World Cup, which country has won the most World Cup titles overall?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'medium', 'In tennis, what is a score of zero called?', 'Love', 'Nil', 'Zero', 'Duck', 'A', 'In tennis scoring, a score of zero is traditionally called "love."'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'In tennis, what is a score of zero called?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'medium', 'Which boxer was known by the nickname "The Greatest" and famously said he could "float like a butterfly, sting like a bee"?', 'Muhammad Ali', 'Mike Tyson', 'Joe Frazier', 'George Foreman', 'A', 'Muhammad Ali was widely known as "The Greatest" and used that phrase to describe his boxing style.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'Which boxer was known by the nickname "The Greatest" and famously said he could "float like a butterfly, sting like a bee"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'hard', 'In which city were the first modern Olympic Games held, in 1896?', 'Athens', 'Paris', 'London', 'Rome', 'A', 'The first modern Olympic Games were held in Athens, Greece, in 1896.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'In which city were the first modern Olympic Games held, in 1896?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'hard', 'What is the maximum possible break (score) a player can achieve in a single visit in a standard game of snooker?', '147', '150', '100', '180', 'A', 'A maximum break in snooker is 147 points, achieved by potting all 15 reds with blacks, followed by all six colors.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'What is the maximum possible break (score) a player can achieve in a single visit in a standard game of snooker?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'easy', 'Which country is the traditional origin of pizza?', 'Italy', 'France', 'Greece', 'Spain', 'A', 'Pizza, in roughly its modern form, originated in Naples, Italy.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'Which country is the traditional origin of pizza?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'easy', 'Sushi is a traditional dish that originated in which country?', 'Japan', 'China', 'Korea', 'Thailand', 'A', 'Sushi originated in Japan, though its earliest forms were quite different from the dish eaten today.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'Sushi is a traditional dish that originated in which country?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'easy', 'What is the main ingredient in traditional hummus?', 'Chickpeas', 'Lentils', 'Black beans', 'Peanuts', 'A', 'Hummus is traditionally made primarily from mashed chickpeas, blended with tahini, lemon, and garlic.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'What is the main ingredient in traditional hummus?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'medium', 'What cooking technique involves quickly cooking food in a small amount of hot oil while stirring constantly?', 'Stir-frying', 'Braising', 'Poaching', 'Blanching', 'A', 'Stir-frying uses high heat and constant motion to quickly cook small, uniformly cut pieces of food.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'What cooking technique involves quickly cooking food in a small amount of hot oil while stirring constantly?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'medium', 'What French culinary technique means to slowly cook food, fully submerged in fat, at a low temperature?', 'Confit', 'Saute', 'Flambe', 'Julienne', 'A', 'Confit is a preservation and cooking technique in which food, often duck or pork, is cooked slowly submerged in its own fat.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'What French culinary technique means to slowly cook food, fully submerged in fat, at a low temperature?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'medium', 'What is the process of preserving food by soaking it in an acidic liquid, such as vinegar, called?', 'Pickling', 'Curing', 'Smoking', 'Fermenting', 'A', 'Pickling preserves food by submerging it in an acidic liquid, most commonly vinegar.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'What is the process of preserving food by soaking it in an acidic liquid, such as vinegar, called?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'hard', 'What is the French culinary term for cutting vegetables into thin, matchstick-sized strips?', 'Julienne', 'Brunoise', 'Chiffonade', 'Mirepoix', 'A', 'Julienne refers to cutting vegetables into long, thin, matchstick-shaped strips.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'What is the French culinary term for cutting vegetables into thin, matchstick-sized strips?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'hard', 'Which spice, derived from the stigma of a crocus flower, is the most expensive spice by weight in the world?', 'Saffron', 'Vanilla', 'Cardamom', 'Cinnamon', 'A', 'Saffron, harvested by hand from the crocus flower, is the world''s most expensive spice by weight due to the labor required to produce it.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'Which spice, derived from the stigma of a crocus flower, is the most expensive spice by weight in the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'easy', 'What is the largest mammal in the world?', 'The blue whale', 'The African elephant', 'The giraffe', 'The sperm whale', 'A', 'The blue whale is the largest animal known to have ever existed, let alone the largest living mammal.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'What is the largest mammal in the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'easy', 'How many legs does a typical spider have?', '8', '6', '10', '4', 'A', 'Spiders are arachnids, and like nearly all arachnids, they have eight legs.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'How many legs does a typical spider have?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'easy', 'What is a baby kangaroo called?', 'A joey', 'A cub', 'A kid', 'A pup', 'A', 'A baby kangaroo is called a joey.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'What is a baby kangaroo called?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'medium', 'Which flightless bird, found mostly in the Southern Hemisphere, is known for being an excellent swimmer?', 'The penguin', 'The ostrich', 'The emu', 'The kiwi', 'A', 'Penguins cannot fly but are highly adapted swimmers, found mostly in the Southern Hemisphere.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'Which flightless bird, found mostly in the Southern Hemisphere, is known for being an excellent swimmer?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'medium', 'What is the fastest land animal in the world?', 'The cheetah', 'The lion', 'The pronghorn', 'The greyhound', 'A', 'The cheetah can reach speeds of up to about 70 miles (113 km) per hour, making it the fastest land animal.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'What is the fastest land animal in the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'medium', 'Which reptile is well known for changing the color of its skin to blend into its surroundings?', 'The chameleon', 'The gecko', 'The iguana', 'The Komodo dragon', 'A', 'Chameleons are famous for their ability to change skin color, which they use for camouflage and communication.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'Which reptile is well known for changing the color of its skin to blend into its surroundings?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'hard', 'What is a group of lions called?', 'A pride', 'A pack', 'A herd', 'A flock', 'A', 'A group of lions is called a pride.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'What is a group of lions called?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'hard', 'Which of these animals is generally considered to have the longest lifespan of any land mammal (besides humans), sometimes living over 60 years?', 'The elephant', 'The rhinoceros', 'The hippopotamus', 'The giraffe', 'A', 'Elephants can live 60 to 70 years in the wild, making them among the longest-lived land mammals.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'Which of these animals is generally considered to have the longest lifespan of any land mammal (besides humans), sometimes living over 60 years?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'easy', 'What is the process by which plants make their own food using sunlight called?', 'Photosynthesis', 'Respiration', 'Transpiration', 'Germination', 'A', 'Photosynthesis is the process plants use to convert sunlight, water, and carbon dioxide into food.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'What is the process by which plants make their own food using sunlight called?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'easy', 'What is the layer of gases surrounding the Earth called?', 'The atmosphere', 'The biosphere', 'The lithosphere', 'The hydrosphere', 'A', 'The atmosphere is the layer of gases, held in place by gravity, that surrounds the Earth.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'What is the layer of gases surrounding the Earth called?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'easy', 'What term describes a long period of unusually low rainfall that leads to a water shortage?', 'A drought', 'A flood', 'A monsoon', 'A blizzard', 'A', 'A drought is a prolonged period of abnormally low rainfall, leading to water shortages.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'What term describes a long period of unusually low rainfall that leads to a water shortage?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'medium', 'What is the term for the variety of plant and animal life found in a particular habitat?', 'Biodiversity', 'Ecosystem', 'Habitat', 'Population', 'A', 'Biodiversity refers to the variety of living species found within a given area or ecosystem.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'What is the term for the variety of plant and animal life found in a particular habitat?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'medium', 'What natural phenomenon is caused by the sudden release of energy in the Earth''s crust, producing seismic waves?', 'An earthquake', 'A volcano', 'A tsunami', 'A landslide', 'A', 'Earthquakes are caused by the sudden release of built-up energy along fault lines in the Earth''s crust.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'What natural phenomenon is caused by the sudden release of energy in the Earth''s crust, producing seismic waves?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'medium', 'A large, rotating storm system with a low-pressure center is called a "hurricane" in the Atlantic and what in the Western Pacific?', 'A typhoon', 'A tornado', 'A monsoon', 'A cold front', 'A', 'The same type of storm is called a hurricane in the Atlantic, a typhoon in the Western Pacific, and simply a tropical cyclone elsewhere.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'A large, rotating storm system with a low-pressure center is called a "hurricane" in the Atlantic and what in the Western Pacific?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'hard', 'What is the primary greenhouse gas released by burning fossil fuels, widely linked to climate change?', 'Carbon dioxide', 'Oxygen', 'Nitrogen', 'Helium', 'A', 'Carbon dioxide, released when fossil fuels are burned, is the greenhouse gas most strongly linked to human-caused climate change.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'What is the primary greenhouse gas released by burning fossil fuels, widely linked to climate change?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'hard', 'What term describes the gradual transformation of fertile land into desert, often due to drought or poor agricultural practices?', 'Desertification', 'Erosion', 'Deforestation', 'Eutrophication', 'A', 'Desertification is the process by which fertile land becomes increasingly arid, often as a result of drought, deforestation, or unsustainable farming.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'What term describes the gradual transformation of fertile land into desert, often due to drought or poor agricultural practices?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'easy', 'Which planet is known as the "Red Planet"?', 'Mars', 'Venus', 'Jupiter', 'Mercury', 'A', 'Mars is called the "Red Planet" because of iron oxide (rust) on its surface, which gives it a reddish appearance.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'Which planet is known as the "Red Planet"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'easy', 'What is the closest star to Earth?', 'The Sun', 'Proxima Centauri', 'Alpha Centauri', 'Sirius', 'A', 'The Sun is by far the closest star to Earth; Proxima Centauri is the next-closest star system.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'What is the closest star to Earth?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'easy', 'What is the name of the galaxy that contains our solar system?', 'The Milky Way', 'Andromeda', 'Triangulum', 'The Whirlpool Galaxy', 'A', 'Our solar system lies within the Milky Way galaxy.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'What is the name of the galaxy that contains our solar system?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'medium', 'Which planet in our solar system is the largest?', 'Jupiter', 'Saturn', 'Neptune', 'Earth', 'A', 'Jupiter is the largest planet in our solar system by both mass and volume.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'Which planet in our solar system is the largest?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'medium', 'Who was the first human to walk on the Moon?', 'Neil Armstrong', 'Buzz Aldrin', 'Yuri Gagarin', 'John Glenn', 'A', 'Neil Armstrong became the first person to walk on the Moon, during the Apollo 11 mission in July 1969.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'Who was the first human to walk on the Moon?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'medium', 'What term describes a massive explosion caused by the death of a large, massive star?', 'A supernova', 'A nova', 'A black hole', 'A nebula', 'A', 'A supernova is the powerful explosion that occurs when certain massive stars reach the end of their life cycle.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'What term describes a massive explosion caused by the death of a large, massive star?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'hard', 'What was the name of the first artificial satellite launched into space, by the Soviet Union in 1957?', 'Sputnik 1', 'Explorer 1', 'Vostok 1', 'Voyager 1', 'A', 'Sputnik 1, launched by the Soviet Union in October 1957, was the first artificial satellite in orbit.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'What was the name of the first artificial satellite launched into space, by the Soviet Union in 1957?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'hard', 'What is the name of NASA''s space telescope, launched in 2021, considered the scientific successor to the Hubble Space Telescope?', 'The James Webb Space Telescope', 'The Kepler Space Telescope', 'The Spitzer Space Telescope', 'The Chandra X-ray Observatory', 'A', 'The James Webb Space Telescope launched in December 2021 and observes primarily in infrared light, complementing Hubble.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'What is the name of NASA''s space telescope, launched in 2021, considered the scientific successor to the Hubble Space Telescope?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'easy', 'How many chambers does the human heart have?', '4', '2', '3', '6', 'A', 'The human heart has four chambers: two atria and two ventricles.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'How many chambers does the human heart have?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'easy', 'What is the largest organ of the human body?', 'The skin', 'The liver', 'The lungs', 'The brain', 'A', 'The skin is the body''s largest organ by surface area and weight.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'What is the largest organ of the human body?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'easy', 'How many bones are in the adult human body?', '206', '210', '195', '220', 'A', 'An adult human body typically has 206 bones, down from about 270 at birth as some bones fuse together with growth.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'How many bones are in the adult human body?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'medium', 'Which part of the brain is primarily responsible for coordinating balance and muscle movement?', 'The cerebellum', 'The cerebrum', 'The medulla oblongata', 'The hypothalamus', 'A', 'The cerebellum, located at the back of the brain, plays a key role in coordinating balance, posture, and voluntary movement.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'Which part of the brain is primarily responsible for coordinating balance and muscle movement?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'medium', 'What is the main function of red blood cells?', 'To carry oxygen throughout the body', 'To fight infection', 'To clot blood', 'To digest food', 'A', 'Red blood cells contain hemoglobin, which binds oxygen and carries it from the lungs to tissues throughout the body.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'What is the main function of red blood cells?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'medium', 'Which organ is primarily responsible for filtering waste from the blood and producing urine?', 'The kidneys', 'The liver', 'The pancreas', 'The spleen', 'A', 'The kidneys filter waste products and excess fluid from the blood, producing urine.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'Which organ is primarily responsible for filtering waste from the blood and producing urine?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'hard', 'What is the name of the longest bone in the human body?', 'The femur', 'The tibia', 'The humerus', 'The fibula', 'A', 'The femur, or thigh bone, is the longest and strongest bone in the human body.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'What is the name of the longest bone in the human body?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'hard', 'What is the medical term for the voice box, which contains the vocal cords?', 'The larynx', 'The pharynx', 'The trachea', 'The esophagus', 'A', 'The larynx, commonly called the voice box, houses the vocal cords and sits atop the trachea.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'What is the medical term for the voice box, which contains the vocal cords?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'easy', 'What term describes the total value of goods and services produced by a country in a year?', 'Gross Domestic Product (GDP)', 'Gross National Debt', 'Net Profit Margin', 'Consumer Price Index', 'A', 'GDP measures the total monetary value of all goods and services produced within a country''s borders in a given period.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'What term describes the total value of goods and services produced by a country in a year?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'easy', 'What do we call a person who starts and runs their own business, taking on financial risk?', 'An entrepreneur', 'A shareholder', 'An employee', 'A consultant', 'A', 'An entrepreneur is someone who founds and operates a business, typically taking on significant financial risk.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'What do we call a person who starts and runs their own business, taking on financial risk?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'easy', 'What is the term for the amount of money a company earns after subtracting all of its expenses?', 'Profit', 'Revenue', 'Capital', 'Equity', 'A', 'Profit is what remains of a company''s revenue after all expenses have been subtracted.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'What is the term for the amount of money a company earns after subtracting all of its expenses?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'medium', 'What economic term describes a general, sustained increase in prices and a corresponding fall in the purchasing power of money?', 'Inflation', 'Deflation', 'Recession', 'Depression', 'A', 'Inflation refers to a broad, sustained rise in prices over time, which erodes the purchasing power of money.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'What economic term describes a general, sustained increase in prices and a corresponding fall in the purchasing power of money?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'medium', 'What term describes a market structure in which a single company dominates and controls an entire industry?', 'A monopoly', 'An oligopoly', 'A duopoly', 'Perfect competition', 'A', 'A monopoly exists when a single company controls the entire supply of a good or service in a market, with no significant competitors.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'What term describes a market structure in which a single company dominates and controls an entire industry?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'medium', 'Which financial statement shows a company''s revenues, expenses, and profit over a specific period of time?', 'An income statement', 'A balance sheet', 'A cash flow statement', 'A tax return', 'A', 'An income statement (also called a profit and loss statement) summarizes revenues and expenses over a given period.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'Which financial statement shows a company''s revenues, expenses, and profit over a specific period of time?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'hard', 'What economic term describes a sustained period of economic decline, typically marked by two consecutive quarters of negative GDP growth?', 'A recession', 'A depression', 'Stagflation', 'Inflation', 'A', 'A recession is commonly defined as two or more consecutive quarters of negative GDP growth.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'What economic term describes a sustained period of economic decline, typically marked by two consecutive quarters of negative GDP growth?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'hard', 'What is the term for the total amount of money a government owes to its creditors?', 'National debt', 'Fiscal deficit', 'Trade deficit', 'Budget surplus', 'A', 'National debt refers to the cumulative total a government owes, distinct from a deficit, which is the shortfall in a single year.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'What is the term for the total amount of money a government owes to its creditors?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'easy', 'What number comes next in this sequence: 2, 4, 6, 8, __?', '10', '12', '9', '11', 'A', 'The sequence increases by 2 each time, so the next number after 8 is 10.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'What number comes next in this sequence: 2, 4, 6, 8, __?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'easy', 'If all cats are animals, and Whiskers is a cat, what can we conclude?', 'Whiskers is an animal', 'Whiskers is not an animal', 'All animals are cats', 'Whiskers is a dog', 'A', 'Since all cats are animals and Whiskers is a cat, it logically follows that Whiskers is an animal.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'If all cats are animals, and Whiskers is a cat, what can we conclude?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'easy', 'What number comes next in this sequence: 1, 1, 2, 3, 5, 8, __?', '13', '11', '12', '14', 'A', 'This is the Fibonacci sequence, where each number is the sum of the two before it: 5 + 8 = 13.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'What number comes next in this sequence: 1, 1, 2, 3, 5, 8, __?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'medium', 'If it takes 5 machines 5 minutes to make 5 widgets, how long would it take 100 machines to make 100 widgets?', '5 minutes', '100 minutes', '20 minutes', '1 minute', 'A', 'Each machine makes 1 widget in 5 minutes, regardless of how many machines are working at once, so 100 machines still take 5 minutes to make 100 widgets.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'If it takes 5 machines 5 minutes to make 5 widgets, how long would it take 100 machines to make 100 widgets?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'medium', 'A farmer has 17 sheep, and all but 9 die. How many sheep does the farmer have left?', '9', '8', '17', '0', 'A', '"All but 9 die" means 9 sheep survive, so the farmer is left with 9 sheep.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'A farmer has 17 sheep, and all but 9 die. How many sheep does the farmer have left?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'medium', 'What is the next number in this sequence: 3, 6, 12, 24, __?', '48', '36', '30', '44', 'A', 'Each number in the sequence is double the previous one, so the next number after 24 is 48.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'What is the next number in this sequence: 3, 6, 12, 24, __?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'hard', 'In a certain code, "CAT" is written as "DBU" (each letter shifted forward by one in the alphabet). Using the same code, how would "DOG" be written?', 'EPH', 'EQH', 'DPH', 'FPI', 'A', 'Shifting each letter of "DOG" forward by one gives D->E, O->P, G->H, resulting in "EPH."'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'In a certain code, "CAT" is written as "DBU" (each letter shifted forward by one in the alphabet). Using the same code, how would "DOG" be written?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'hard', 'If today is Monday, what day of the week will it be 100 days from now?', 'Wednesday', 'Tuesday', 'Thursday', 'Friday', 'A', '100 days is 14 full weeks (98 days) plus 2 extra days; 14 weeks from Monday is still Monday, and 2 more days lands on Wednesday.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'If today is Monday, what day of the week will it be 100 days from now?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'easy', 'How many days are there in a leap year?', '366', '365', '364', '367', 'A', 'A leap year has 366 days, with the extra day added as February 29.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'How many days are there in a leap year?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'easy', 'What is the freezing point of water in degrees Celsius?', '0 degrees Celsius', '32 degrees Celsius', '100 degrees Celsius', '-10 degrees Celsius', 'A', 'Water freezes at 0 degrees Celsius (32 degrees Fahrenheit) at standard atmospheric pressure.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'What is the freezing point of water in degrees Celsius?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'easy', 'How many colors are traditionally listed in a rainbow?', '7', '5', '6', '8', 'A', 'A rainbow is traditionally described as having seven colors: red, orange, yellow, green, blue, indigo, and violet.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'How many colors are traditionally listed in a rainbow?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'medium', 'As of the mid-2020s, what is the tallest completed man-made building in the world?', 'The Burj Khalifa', 'The Eiffel Tower', 'The Shanghai Tower', 'One World Trade Center', 'A', 'The Burj Khalifa in Dubai, standing 828 meters tall, has been the world''s tallest completed building since 2010.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'As of the mid-2020s, what is the tallest completed man-made building in the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'medium', 'How many time zones does mainland China officially observe, despite spanning a geographic width that would traditionally cover about five?', 'One', 'Five', 'Three', 'Two', 'A', 'Mainland China officially observes a single time zone nationwide, China Standard Time, despite its wide east-west span.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'How many time zones does mainland China officially observe, despite spanning a geographic width that would traditionally cover about five?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'medium', 'What is the most spoken native language in the world by number of native speakers?', 'Mandarin Chinese', 'English', 'Spanish', 'Hindi', 'A', 'Mandarin Chinese has the largest number of native speakers of any language in the world.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'What is the most spoken native language in the world by number of native speakers?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'hard', 'Which of these is the only mammal capable of true, sustained flight?', 'The bat', 'The flying squirrel', 'The colugo', 'The flying fish', 'A', 'Bats are the only mammals capable of true, sustained flight; flying squirrels and colugos only glide.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'Which of these is the only mammal capable of true, sustained flight?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'hard', 'What is the smallest prime number?', '2', '1', '3', '0', 'A', '2 is the smallest prime number, and the only even prime number, since 1 is not considered prime.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'What is the smallest prime number?'
);
