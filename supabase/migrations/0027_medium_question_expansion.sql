-- Pinoy Quiz -- 0026: medium-difficulty question expansion (Phase 18)
--
-- Tops up every category to 20 medium-difficulty questions. Prior to this
-- migration, medium-question counts per category ranged from 3 (e.g. animals,
-- arts, computer_science) to 30 (history); 9 categories (culture, entertainment,
-- food, geography, history, medical, science, sports, trivia) were already at or
-- above 20 and receive no new rows here. This migration adds exactly the number
-- of new medium questions needed to bring each of the remaining 35 categories up
-- to 20, for 563 new rows total. No existing rows are modified, removed, or
-- duplicated -- this migration only adds new rows.
--
-- Correct-answer letters are shuffled across A/B/C/D per question to avoid the
-- answer-distribution skew documented as a known issue in the original 80-
-- question set (same approach used in 0025 for the hard-difficulty expansion).
--
-- Idempotency: same NOT EXISTS guard per row (matching on category +
-- prompt) as every prior question migration, so this is safe to re-run.

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'medium', 'Which large cat species is the only one that lives and hunts in large family groups called prides?', 'Tiger', 'Leopard', 'Jaguar', 'Lion', 'D', 'Lions are unique among big cats for living in social groups called prides, typically consisting of related females, their cubs, and a small number of males.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'Which large cat species is the only one that lives and hunts in large family groups called prides?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'medium', 'What is the primary diet of the giant panda, despite belonging to the order Carnivora?', 'Fish', 'Insects', 'Bamboo', 'Small mammals', 'C', 'Giant pandas primarily eat bamboo, making up the vast majority of their diet, despite being classified within the order Carnivora.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'What is the primary diet of the giant panda, despite belonging to the order Carnivora?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'medium', 'Which marine mammal is known as the largest animal to have ever lived on Earth?', 'Blue whale', 'Sperm whale', 'Orca', 'Humpback whale', 'A', 'The blue whale is the largest animal known to have ever existed, larger than any dinosaur, reaching lengths of up to 30 meters.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'Which marine mammal is known as the largest animal to have ever lived on Earth?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'medium', 'What is the fastest land animal in the world, capable of reaching speeds up to 70 mph?', 'Lion', 'Cheetah', 'Pronghorn antelope', 'Greyhound', 'B', 'The cheetah is the fastest land animal, capable of short bursts of speed reaching up to 70 miles per hour while hunting prey.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'What is the fastest land animal in the world, capable of reaching speeds up to 70 mph?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'medium', 'Which bird species is known for its ability to mimic human speech and other sounds?', 'Parrot', 'Eagle', 'Owl', 'Pelican', 'A', 'Parrots are well known for their ability to mimic human speech and various environmental sounds, a skill linked to their vocal learning abilities.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'Which bird species is known for its ability to mimic human speech and other sounds?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'medium', 'What is the name for a baby kangaroo, typically carried in its mother''s pouch after birth?', 'Cub', 'Kit', 'Calf', 'Joey', 'D', 'A baby kangaroo is called a joey, and it continues developing in its mother''s pouch for several months after birth.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'What is the name for a baby kangaroo, typically carried in its mother''s pouch after birth?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'medium', 'Which reptile is known for changing the color of its skin to match its surroundings or express emotion?', 'Iguana', 'Chameleon', 'Gecko', 'Monitor lizard', 'B', 'Chameleons are famous for their ability to change skin color, which they use for camouflage, temperature regulation, and communication.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'Which reptile is known for changing the color of its skin to match its surroundings or express emotion?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'medium', 'What is the collective term for a group of wolves that live and hunt together?', 'A pack', 'A pride', 'A herd', 'A flock', 'A', 'A group of wolves is called a pack, typically consisting of a family unit that hunts and lives together.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'What is the collective term for a group of wolves that live and hunt together?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'medium', 'Which insect is known for its highly organized colonies, division of labor, and production of honey?', 'Ant', 'Honeybee', 'Termite', 'Wasp', 'B', 'Honeybees live in highly organized colonies with clear division of labor and are well known for producing and storing honey.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'Which insect is known for its highly organized colonies, division of labor, and production of honey?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'medium', 'What is the term for animals, like bears, that experience a state of prolonged sleep during winter to conserve energy?', 'Hibernation', 'Migration', 'Estivation', 'Torpor (a related but shorter-term state)', 'A', 'Hibernation is a state of extended dormancy that certain animals, like bears, enter during winter to conserve energy when food is scarce.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'What is the term for animals, like bears, that experience a state of prolonged sleep during winter to conserve energy?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'medium', 'Which large flightless bird, native to Africa, is the largest living bird species in the world?', 'Emu', 'Cassowary', 'Rhea', 'Ostrich', 'D', 'The ostrich, native to Africa, is the largest living bird species, known for its speed on land and inability to fly.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'Which large flightless bird, native to Africa, is the largest living bird species in the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'medium', 'What is the primary method by which dolphins navigate and locate prey underwater?', 'Magnetoreception', 'Chemoreception', 'Echolocation', 'Vision alone', 'C', 'Dolphins use echolocation, emitting sound waves and interpreting their echoes, to navigate and locate prey in the water.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'What is the primary method by which dolphins navigate and locate prey underwater?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'medium', 'Which big cat species has the loudest roar, audible from several kilometers away?', 'Lion', 'Tiger', 'Jaguar', 'Leopard', 'A', 'The lion''s roar is among the loudest of any big cat, audible up to 8 kilometers away under the right conditions.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'Which big cat species has the loudest roar, audible from several kilometers away?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'medium', 'What is the name for the thick layer of fat that helps marine mammals like whales and seals stay warm?', 'Fur', 'Cartilage', 'Blubber', 'Keratin', 'C', 'Blubber is a thick layer of fat beneath the skin of marine mammals, providing insulation against cold water temperatures.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'What is the name for the thick layer of fat that helps marine mammals like whales and seals stay warm?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'medium', 'Which snake species, found in Southeast Asia and Africa, is known for spitting venom at the eyes of threats from a distance?', 'King cobra', 'Black mamba', 'Reticulated python', 'Spitting cobra', 'D', 'Spitting cobras can accurately eject venom toward the eyes of a perceived threat from a distance, causing pain and potential blindness.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'Which snake species, found in Southeast Asia and Africa, is known for spitting venom at the eyes of threats from a distance?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'medium', 'What is the term for animals that primarily eat both plants and meat?', 'Herbivore', 'Carnivore', 'Omnivore', 'Insectivore', 'C', 'Omnivores consume both plant and animal matter as part of their regular diet, unlike herbivores or carnivores which specialize in one type.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'What is the term for animals that primarily eat both plants and meat?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'medium', 'Which large African mammal is known for having the longest neck of any living animal, used to reach high tree foliage?', 'Elephant', 'Giraffe', 'Rhinoceros', 'Hippopotamus', 'B', 'The giraffe has the longest neck of any living animal, an adaptation that allows it to feed on foliage high in trees other animals cannot reach.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'Which large African mammal is known for having the longest neck of any living animal, used to reach high tree foliage?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'medium', 'Which Italian Renaissance artist painted the ceiling of the Sistine Chapel?', 'Leonardo da Vinci', 'Raphael', 'Michelangelo', 'Donatello', 'C', 'Michelangelo famously painted the ceiling of the Sistine Chapel between 1508 and 1512, depicting scenes from the Book of Genesis.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'Which Italian Renaissance artist painted the ceiling of the Sistine Chapel?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'medium', 'What art movement, associated with Salvador Dali and Rene Magritte, explores dreamlike and irrational imagery?', 'Cubism', 'Impressionism', 'Fauvism', 'Surrealism', 'D', 'Surrealism, championed by artists like Salvador Dali and Rene Magritte, explores dreamlike, irrational, and subconscious imagery.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'What art movement, associated with Salvador Dali and Rene Magritte, explores dreamlike and irrational imagery?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'medium', 'Which famous painting by Leonardo da Vinci is renowned for its subject''s enigmatic smile?', 'Mona Lisa', 'The Last Supper', 'Vitruvian Man', 'Lady with an Ermine', 'A', 'The Mona Lisa, painted by Leonardo da Vinci, is world-famous for its subject''s mysterious, enigmatic expression.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'Which famous painting by Leonardo da Vinci is renowned for its subject''s enigmatic smile?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'medium', 'What is the term for a three-dimensional work of art created by carving, modeling, or casting?', 'Painting', 'Printmaking', 'Photography', 'Sculpture', 'D', 'Sculpture refers to three-dimensional artworks created through techniques like carving, modeling, casting, or assembling materials.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'What is the term for a three-dimensional work of art created by carving, modeling, or casting?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'medium', 'Which art movement, developed in France in the late 19th century, focused on capturing fleeting light and everyday scenes?', 'Cubism', 'Impressionism', 'Expressionism', 'Realism', 'B', 'Impressionism, pioneered by artists like Monet and Renoir, emphasized capturing the fleeting effects of light and color in everyday scenes.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'Which art movement, developed in France in the late 19th century, focused on capturing fleeting light and everyday scenes?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'medium', 'What is the primary medium used in traditional watercolor painting?', 'Oil-based pigments', 'Wax-based pigments', 'Water-based pigments', 'Acrylic polymer', 'C', 'Watercolor painting uses pigments suspended in a water-based solution, known for its transparency and fluid application.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'What is the primary medium used in traditional watercolor painting?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'medium', 'Which Dutch painter is famous for ''The Starry Night'' and cutting off part of his own ear?', 'Vincent van Gogh', 'Rembrandt van Rijn', 'Johannes Vermeer', 'Pieter Bruegel', 'A', 'Vincent van Gogh painted ''The Starry Night'' and is famously known for the incident in which he cut off part of his ear.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'Which Dutch painter is famous for ''The Starry Night'' and cutting off part of his own ear?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'medium', 'What is the term for an artist''s preliminary drawing or outline made before creating a final artwork?', 'Sketch', 'Silhouette', 'Etching', 'Engraving', 'A', 'A sketch is a rough, preliminary drawing artists use to plan composition and details before producing a finished artwork.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'What is the term for an artist''s preliminary drawing or outline made before creating a final artwork?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'medium', 'Which sculptor created the famous marble statue of ''David,'' depicting the biblical hero?', 'Donatello', 'Gian Lorenzo Bernini', 'Michelangelo', 'Auguste Rodin', 'C', 'Michelangelo sculpted the iconic marble statue of David between 1501 and 1504, depicting the biblical hero before his battle with Goliath.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'Which sculptor created the famous marble statue of ''David,'' depicting the biblical hero?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'medium', 'What is the term for artwork made by cutting and pasting various materials like paper, fabric, or photographs onto a surface?', 'Mosaic', 'Assemblage', 'Decoupage', 'Collage', 'D', 'Collage involves assembling various materials, such as paper or fabric, onto a surface to create a new artistic composition.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'What is the term for artwork made by cutting and pasting various materials like paper, fabric, or photographs onto a surface?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'medium', 'Which art style, associated with artists like Piet Mondrian, uses simple geometric shapes and primary colors?', 'Cubism', 'Neoplasticism (De Stijl)', 'Fauvism', 'Constructivism', 'B', 'Neoplasticism, developed by Piet Mondrian and the De Stijl movement, emphasized simplicity through geometric shapes and primary colors.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'Which art style, associated with artists like Piet Mondrian, uses simple geometric shapes and primary colors?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'medium', 'What is the term for the study and creation of beautiful, stylized handwriting or lettering?', 'Calligraphy', 'Typography', 'Illumination', 'Engraving', 'A', 'Calligraphy is the artistic practice of creating decorative, stylized handwriting or lettering.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'What is the term for the study and creation of beautiful, stylized handwriting or lettering?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'medium', 'Which famous fresco by Michelangelo depicts the Last Judgment on the altar wall of the Sistine Chapel?', 'The Creation of Adam', 'The Last Judgment', 'The Last Supper', 'The School of Athens', 'B', 'Michelangelo painted ''The Last Judgment'' on the altar wall of the Sistine Chapel years after completing the ceiling frescoes.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'Which famous fresco by Michelangelo depicts the Last Judgment on the altar wall of the Sistine Chapel?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'medium', 'What is the term for a self-portrait created by an artist depicting their own likeness?', 'Self-portrait', 'Portrait', 'Bust', 'Effigy', 'A', 'A self-portrait is an artwork in which the artist depicts their own likeness, a practice used throughout art history for self-reflection and study.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'What is the term for a self-portrait created by an artist depicting their own likeness?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'medium', 'Which art technique involves printing an image from a carved or etched surface onto paper or another material?', 'Painting', 'Sculpting', 'Weaving', 'Printmaking', 'D', 'Printmaking involves transferring an image from a prepared surface, such as a woodblock or etched plate, onto paper or another material.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'Which art technique involves printing an image from a carved or etched surface onto paper or another material?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'medium', 'What is the term for the artistic style that emerged in the 1960s, using bold, everyday imagery from advertising and popular culture?', 'Op Art', 'Pop Art', 'Minimalism', 'Abstract Expressionism', 'B', 'Pop Art emerged in the 1950s-60s, drawing bold imagery from advertising, comic books, and consumer culture.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'What is the term for the artistic style that emerged in the 1960s, using bold, everyday imagery from advertising and popular culture?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'medium', 'Which term describes a painting depicting an arrangement of inanimate objects, such as fruit or flowers?', 'Landscape', 'Portrait', 'Still life', 'Genre painting', 'C', 'A still life depicts an arrangement of inanimate objects, commonly items like fruit, flowers, or household objects.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'Which term describes a painting depicting an arrangement of inanimate objects, such as fruit or flowers?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'medium', 'What is the term for the total value of all goods and services a country produces, commonly used to measure economic size?', 'Net National Income', 'Consumer Price Index', 'Gross Domestic Product (GDP)', 'Trade balance', 'C', 'GDP measures the total monetary value of goods and services produced within a country over a given time period, a common indicator of economic size.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'What is the term for the total value of all goods and services a country produces, commonly used to measure economic size?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'medium', 'Which economic term describes the general rise in prices of goods and services over time, reducing purchasing power?', 'Deflation', 'Inflation', 'Recession', 'Stagnation', 'B', 'Inflation refers to the general rise in prices over time, which reduces the purchasing power of money.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'Which economic term describes the general rise in prices of goods and services over time, reducing purchasing power?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'medium', 'What is the term for a business owned and controlled by a single individual, who is personally liable for all debts?', 'Partnership', 'Sole proprietorship', 'Corporation', 'Cooperative', 'B', 'A sole proprietorship is a business owned by one individual, who bears full personal liability for the business''s debts and obligations.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'What is the term for a business owned and controlled by a single individual, who is personally liable for all debts?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'medium', 'Which economic system is characterized by private ownership of resources and production, driven by market forces of supply and demand?', 'Socialism', 'Communism', 'Feudalism', 'Capitalism', 'D', 'Capitalism is an economic system based on private ownership of resources and production, with prices largely determined by market supply and demand.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'Which economic system is characterized by private ownership of resources and production, driven by market forces of supply and demand?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'medium', 'What is the term for a legal business structure that limits owners'' personal liability for business debts, distinct from the owners themselves?', 'Sole proprietorship', 'Corporation', 'General partnership', 'Cooperative', 'B', 'A corporation is a legal entity separate from its owners, providing limited liability protection against the business''s debts and legal obligations.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'What is the term for a legal business structure that limits owners'' personal liability for business debts, distinct from the owners themselves?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'medium', 'Which financial term describes money invested in a business with the expectation of generating income or profit?', 'Investment', 'Expense', 'Liability', 'Revenue', 'A', 'Investment refers to money committed to a business or asset with the expectation of generating future income or profit.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'Which financial term describes money invested in a business with the expectation of generating income or profit?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'medium', 'What is the term for the practice of a business selling products directly to consumers, rather than through intermediaries?', 'Wholesale', 'Business-to-business (B2B)', 'Franchising', 'Direct-to-consumer (retail) sales', 'D', 'Direct-to-consumer, or retail, sales involve businesses selling products directly to end customers without going through wholesale intermediaries.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'What is the term for the practice of a business selling products directly to consumers, rather than through intermediaries?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'medium', 'Which term describes the amount of money a company has left after subtracting all its expenses from its total revenue?', 'Gross revenue', 'Operating expenses', 'Net profit', 'Total assets', 'C', 'Net profit represents the amount remaining after all business expenses, taxes, and costs are subtracted from total revenue.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'Which term describes the amount of money a company has left after subtracting all its expenses from its total revenue?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'medium', 'What is the term for a period of significant decline in economic activity, typically marked by falling GDP and rising unemployment?', 'Inflation', 'Expansion', 'Recession', 'Stagflation', 'C', 'A recession is a period of significant economic decline, typically characterized by falling GDP, rising unemployment, and reduced spending.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'What is the term for a period of significant decline in economic activity, typically marked by falling GDP and rising unemployment?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'medium', 'Which economic concept describes the relationship between the price of a good and the quantity consumers are willing to buy?', 'Demand', 'Supply', 'Elasticity (a related but distinct measure)', 'Equilibrium (the point where they meet)', 'A', 'Demand describes the relationship between a good''s price and the quantity consumers are willing and able to purchase at that price.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'Which economic concept describes the relationship between the price of a good and the quantity consumers are willing to buy?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'medium', 'What is the term for the money a business earns from selling goods or services before expenses are deducted?', 'Net profit', 'Equity', 'Revenue', 'Liability', 'C', 'Revenue refers to the total income a business generates from its sales activities before any expenses are subtracted.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'What is the term for the money a business earns from selling goods or services before expenses are deducted?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'medium', 'Which term describes a company''s plan to combine with or purchase another company to expand its market presence?', 'Diversification', 'Franchising', 'Outsourcing', 'Merger and acquisition (M&A)', 'D', 'Mergers and acquisitions describe corporate strategies of combining with or purchasing other companies to expand market share or capabilities.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'Which term describes a company''s plan to combine with or purchase another company to expand its market presence?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'medium', 'What is the term for the total amount of money a business owes to creditors and other parties?', 'Assets', 'Liabilities', 'Equity', 'Revenue', 'B', 'Liabilities represent a business''s financial obligations or debts owed to creditors, lenders, or other parties.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'What is the term for the total amount of money a business owes to creditors and other parties?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'medium', 'Which term describes a temporary reduction in a product''s price intended to boost sales or attract new customers?', 'Discount (promotional pricing)', 'Markup', 'Margin', 'Surcharge', 'A', 'A discount is a temporary price reduction offered to boost sales, clear inventory, or attract new customers.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'Which term describes a temporary reduction in a product''s price intended to boost sales or attract new customers?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'medium', 'What is the term for a worker''s regular payment for labor, typically calculated hourly, weekly, or as an annual salary?', 'Dividend', 'Interest', 'Royalty', 'Wage (or salary)', 'D', 'A wage or salary is the regular compensation paid to a worker in exchange for their labor or services.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'What is the term for a worker''s regular payment for labor, typically calculated hourly, weekly, or as an annual salary?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'medium', 'Which term describes the practice of setting aside a portion of income for future use rather than spending it immediately?', 'Saving', 'Investing (a related but distinct concept)', 'Budgeting (the planning process, not the act itself)', 'Borrowing', 'A', 'Saving refers to setting aside a portion of current income for future use, distinct from investing, which involves risk in pursuit of returns.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'Which term describes the practice of setting aside a portion of income for future use rather than spending it immediately?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'medium', 'What is the term for a document outlining a company''s goals, strategies, and financial projections, often used to secure funding?', 'Business plan', 'Balance sheet', 'Income statement', 'Annual report', 'A', 'A business plan outlines a company''s goals, strategies, market analysis, and financial projections, commonly used to attract investors or secure loans.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'What is the term for a document outlining a company''s goals, strategies, and financial projections, often used to secure funding?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'medium', 'Which Filipino singer, known as the ''Concert King,'' is celebrated for his powerful vocals and decades-long music career?', 'Gary Valenciano', 'Jose Mari Chan', 'Ogie Alcasid', 'Martin Nievera', 'D', 'Martin Nievera is popularly known as the ''Concert King'' of Philippine music, celebrated for his powerful vocal performances over a long career.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipino singer, known as the ''Concert King,'' is celebrated for his powerful vocals and decades-long music career?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'medium', 'Which Filipina actress is known as the ''Megastar'' of Philippine cinema, recognized for her versatility across drama and comedy?', 'Vilma Santos', 'Nora Aunor', 'Judy Ann Santos', 'Sharon Cuneta', 'D', 'Sharon Cuneta is popularly known as the ''Megastar'' of Philippine cinema and television, celebrated for her broad appeal and versatility.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipina actress is known as the ''Megastar'' of Philippine cinema, recognized for her versatility across drama and comedy?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'medium', 'Which Filipino performer is often called the ''Total Performer'' for his singing, dancing, and acting talents?', 'Gary Valenciano', 'Martin Nievera', 'Ogie Alcasid', 'Erik Santos', 'A', 'Gary Valenciano is known as the ''Total Performer'' in Philippine entertainment, recognized for his singing, dancing, and acting abilities.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipino performer is often called the ''Total Performer'' for his singing, dancing, and acting talents?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'medium', 'Which Filipino boxer is widely regarded as one of the greatest professional boxers of all time, with a career spanning multiple weight classes?', 'Nonito Donaire', 'Gerry Peñalosa', 'Rey Bautista', 'Manny Pacquiao', 'D', 'Manny Pacquiao is widely regarded as one of the greatest boxers of all time, having won world titles across an unprecedented eight weight divisions.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipino boxer is widely regarded as one of the greatest professional boxers of all time, with a career spanning multiple weight classes?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'medium', 'Which Filipino talk show host and comedian has hosted numerous long-running television programs in the Philippines?', 'Kris Aquino', 'Boy Abunda', 'Vice Ganda', 'Willie Revillame', 'C', 'Vice Ganda is a prominent Filipino comedian and television host known for hosting long-running programs including ''It''s Showtime.'''
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipino talk show host and comedian has hosted numerous long-running television programs in the Philippines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'medium', 'Which Filipina actress and singer became internationally known for her role in the Broadway and film versions of ''Miss Saigon''?', 'Regine Velasquez', 'Sarah Geronimo', 'Lea Salonga', 'Charice Pempengco', 'C', 'Lea Salonga achieved international fame for originating the lead role of Kim in the musical ''Miss Saigon'' on stage.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipina actress and singer became internationally known for her role in the Broadway and film versions of ''Miss Saigon''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'medium', 'Which Filipina singer, discovered through television talent competitions, later achieved international success and performed with global artists?', 'Charice Pempengco (now known as Jake Zyrus)', 'Regine Velasquez', 'Sarah Geronimo', 'Kyla', 'A', 'Charice Pempengco, now known as Jake Zyrus, gained international recognition after appearing on television talent shows and performing with prominent global artists.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipina singer, discovered through television talent competitions, later achieved international success and performed with global artists?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'medium', 'Which Filipino basketball player is considered one of the greatest players in Philippine Basketball Association history?', 'June Mar Fajardo', 'Robert Jaworski', 'Allan Caidic', 'Ramon Fernandez', 'B', 'Robert Jaworski is widely regarded as one of the most legendary figures in Philippine basketball, both as a player and later as a coach.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipino basketball player is considered one of the greatest players in Philippine Basketball Association history?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'medium', 'Which Filipina beauty queen won the Miss Universe title in 2015, marking the country''s third Miss Universe crown?', 'Catriona Gray', 'Megan Young', 'Pia Wurtzbach', 'Janine Tugonon', 'C', 'Pia Wurtzbach won the Miss Universe title in 2015, her country''s third overall Miss Universe crown.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipina beauty queen won the Miss Universe title in 2015, marking the country''s third Miss Universe crown?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'medium', 'Which Filipino actor is known for his roles in numerous action films and later became a prominent politician?', 'Fernando Poe Jr.', 'Ramon Revilla Sr.', 'Robin Padilla', 'Joseph Estrada', 'C', 'Robin Padilla built a career as a prominent Filipino action film actor before later becoming an active figure in Philippine politics.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipino actor is known for his roles in numerous action films and later became a prominent politician?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'medium', 'Which Filipino singer-songwriter is known for hit ballads such as ''Kailangan Kita'' and a long career in Original Pilipino Music (OPM)?', 'Ogie Alcasid', 'Gary Valenciano', 'Martin Nievera', 'Jose Mari Chan', 'A', 'Ogie Alcasid is a well-known Filipino singer-songwriter recognized for hit ballads including ''Kailangan Kita'' across a long OPM career.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipino singer-songwriter is known for hit ballads such as ''Kailangan Kita'' and a long career in Original Pilipino Music (OPM)?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'medium', 'Which Filipino actor won critical acclaim and international recognition for his role in the film ''Metro Manila'' (2013)?', 'Jake Macapagal', 'John Arcilla', 'Piolo Pascual', 'Coco Martin', 'A', 'Jake Macapagal starred in and received critical acclaim for his lead performance in the internationally recognized film ''Metro Manila.'''
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipino actor won critical acclaim and international recognition for his role in the film ''Metro Manila'' (2013)?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'medium', 'Which Filipino singer is known as ''Asia''s Songbird'' and has represented the Philippines in various international music events?', 'Lea Salonga', 'Regine Velasquez', 'Sarah Geronimo', 'KZ Tandingan', 'B', 'Regine Velasquez is known as ''Asia''s Songbird,'' celebrated for her exceptional vocal range and numerous international performances.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipino singer is known as ''Asia''s Songbird'' and has represented the Philippines in various international music events?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'medium', 'Which Filipino chess player became the country''s first-ever Grandmaster, achieving the title in 1974?', 'Wesley So', 'Eugenio Torre', 'Mark Paragua', 'Rogelio Antonio Jr.', 'B', 'Eugenio Torre became the Philippines'' first Grandmaster in 1974, a milestone achievement in Philippine chess history.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipino chess player became the country''s first-ever Grandmaster, achieving the title in 1974?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'medium', 'Which Filipina actress and singer is popularly known as the ''Pop Princess'' of the Philippines?', 'Regine Velasquez', 'Sarah Geronimo', 'Kyla', 'KZ Tandingan', 'B', 'Sarah Geronimo is widely known as the ''Pop Princess'' of Philippine music and entertainment, having risen to fame through a television talent competition.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipina actress and singer is popularly known as the ''Pop Princess'' of the Philippines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'medium', 'What does the acronym ''CPU'' stand for, referring to a computer''s primary processing hardware?', 'Computer Processing Utility', 'Central Processing Unit', 'Core Processing Unit', 'Central Program Unit', 'B', 'CPU stands for Central Processing Unit, the primary component of a computer responsible for executing instructions.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'What does the acronym ''CPU'' stand for, referring to a computer''s primary processing hardware?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'medium', 'Which programming concept refers to a self-contained block of code that performs a specific task and can be reused?', 'Function', 'Variable', 'Loop', 'Array', 'A', 'A function is a reusable, self-contained block of code designed to perform a specific task, callable multiple times within a program.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'Which programming concept refers to a self-contained block of code that performs a specific task and can be reused?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'medium', 'What is the term for a computer network that connects devices within a limited geographic area, such as an office or home?', 'Local Area Network (LAN)', 'Wide Area Network (WAN)', 'Metropolitan Area Network (MAN)', 'Personal Area Network (PAN)', 'A', 'A Local Area Network (LAN) connects devices within a limited area, such as a home, office, or single building.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'What is the term for a computer network that connects devices within a limited geographic area, such as an office or home?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'medium', 'Which type of software is designed specifically to detect, prevent, and remove malicious programs from a computer?', 'Operating system', 'Compiler', 'Firmware', 'Antivirus software', 'D', 'Antivirus software is designed to detect, prevent, and remove malicious software, such as viruses and malware, from a computer system.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'Which type of software is designed specifically to detect, prevent, and remove malicious programs from a computer?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'medium', 'What is the term for a variable''s type of data, such as integer, string, or boolean, in programming?', 'Data structure', 'Data value', 'Data type', 'Data class', 'C', 'A data type defines the kind of value a variable can hold, such as an integer, string, or boolean, and how it can be manipulated.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'What is the term for a variable''s type of data, such as integer, string, or boolean, in programming?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'medium', 'Which computer input device is used to convert physical documents or images into digital format?', 'Scanner', 'Printer', 'Keyboard', 'Monitor', 'A', 'A scanner converts physical documents, photos, or images into digital files that can be stored and edited on a computer.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'Which computer input device is used to convert physical documents or images into digital format?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'medium', 'What is the term for the process of finding and fixing errors or bugs within computer software?', 'Compiling', 'Refactoring (a related but distinct process)', 'Debugging', 'Testing (a related but broader process)', 'C', 'Debugging is the process of identifying and correcting errors, or ''bugs,'' within a computer program''s code.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'What is the term for the process of finding and fixing errors or bugs within computer software?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'medium', 'Which type of computer memory permanently stores data even when power is turned off, such as a hard drive?', 'Volatile memory', 'Non-volatile memory', 'Cache memory', 'Register memory', 'B', 'Non-volatile memory retains its stored data even after power is removed, unlike volatile memory such as RAM.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'Which type of computer memory permanently stores data even when power is turned off, such as a hard drive?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'medium', 'What is the term for a set of rules governing how data is formatted and transmitted over a network?', 'Interface', 'Algorithm', 'Protocol', 'Framework', 'C', 'A protocol is a set of rules that governs how data is formatted, transmitted, and received across a computer network.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'What is the term for a set of rules governing how data is formatted and transmitted over a network?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'medium', 'Which popular version control system, widely used by software developers, was created by Linus Torvalds in 2005?', 'Subversion (SVN)', 'Git', 'Mercurial', 'CVS', 'B', 'Git, created by Linus Torvalds in 2005, is a widely used distributed version control system for tracking changes in source code.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'Which popular version control system, widely used by software developers, was created by Linus Torvalds in 2005?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'medium', 'What is the term for software specifically designed to run on and manage a computer''s hardware and other software?', 'Application software', 'Firmware (a more limited, device-specific type)', 'Middleware', 'Operating system', 'D', 'An operating system manages a computer''s hardware resources and provides a platform for running other application software.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'What is the term for software specifically designed to run on and manage a computer''s hardware and other software?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'medium', 'Which programming structure allows a set of instructions to be repeated multiple times until a condition is met?', 'Function', 'Loop', 'Array', 'Conditional statement', 'B', 'A loop is a programming structure that repeats a set of instructions multiple times, continuing until a specified condition is met.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'Which programming structure allows a set of instructions to be repeated multiple times until a condition is met?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'medium', 'What is the term for a website''s underlying code and structure that is not visible to users, handling data processing and storage?', 'Front-end', 'Middleware', 'Back-end', 'API (a related, but not identical, layer)', 'C', 'The back-end refers to the server-side code and infrastructure of a website or application, handling data processing, storage, and logic not visible to users.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'What is the term for a website''s underlying code and structure that is not visible to users, handling data processing and storage?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'medium', 'Which technology allows different software applications to communicate and share data with one another?', 'Application Programming Interface (API)', 'Operating system', 'Database management system', 'Compiler', 'A', 'An Application Programming Interface (API) allows different software applications to communicate and exchange data with one another.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'Which technology allows different software applications to communicate and share data with one another?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'medium', 'What is the term for a collection of organized data stored electronically, typically managed through specialized software?', 'Spreadsheet', 'Directory', 'Archive', 'Database', 'D', 'A database is an organized collection of electronically stored data, typically managed and accessed through specialized database management software.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'What is the term for a collection of organized data stored electronically, typically managed through specialized software?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'medium', 'Which type of computer virus disguises itself as legitimate software to trick users into installing it?', 'Worm', 'Spyware (a related but distinct category)', 'Adware (a related but distinct category)', 'Trojan horse', 'D', 'A Trojan horse disguises itself as legitimate or useful software to trick users into installing it, after which it can perform malicious actions.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'Which type of computer virus disguises itself as legitimate software to trick users into installing it?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'medium', 'What is the term for a technology that connects everyday physical devices to the internet, enabling them to send and receive data?', 'Internet of Things (IoT)', 'Cloud computing', 'Edge computing', 'Artificial intelligence', 'A', 'The Internet of Things (IoT) refers to the network of physical devices connected to the internet, enabling them to collect and exchange data.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'What is the term for a technology that connects everyday physical devices to the internet, enabling them to send and receive data?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'medium', 'What is the term for the study of how individuals, businesses, and governments allocate scarce resources?', 'Economics', 'Accounting', 'Finance', 'Statistics', 'A', 'Economics is the social science that studies how individuals, businesses, and governments allocate scarce resources to satisfy needs and wants.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'What is the term for the study of how individuals, businesses, and governments allocate scarce resources?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'medium', 'Which term describes the total amount of goods and services that producers are willing to offer at a given price?', 'Demand', 'Supply', 'Equilibrium', 'Surplus', 'B', 'Supply refers to the total quantity of a good or service that producers are willing and able to offer at various price levels.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'Which term describes the total amount of goods and services that producers are willing to offer at a given price?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'medium', 'What is the term for a country''s economic system in which the government owns and controls most means of production?', 'Market economy', 'Mixed economy', 'Command economy (socialism/communism)', 'Traditional economy', 'C', 'A command economy, associated with socialist or communist systems, involves significant government ownership and control over production and resource allocation.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'What is the term for a country''s economic system in which the government owns and controls most means of production?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'medium', 'Which term describes a business that operates across multiple countries, with operations and sales in more than one nation?', 'Domestic corporation', 'Sole proprietorship', 'Cooperative', 'Multinational corporation', 'D', 'A multinational corporation operates in multiple countries, managing production, sales, or other operations across international borders.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'Which term describes a business that operates across multiple countries, with operations and sales in more than one nation?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'medium', 'What is the term for the percentage of a company''s earnings paid out to shareholders as a return on their investment?', 'Interest', 'Dividend', 'Capital gain', 'Yield (a related but broader financial term)', 'B', 'A dividend is a portion of a company''s earnings distributed to shareholders, typically on a regular basis, as a return on their investment.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'What is the term for the percentage of a company''s earnings paid out to shareholders as a return on their investment?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'medium', 'Which term describes the practice of borrowing money that must be repaid, typically with interest, over a specified period?', 'Loan', 'Grant', 'Investment', 'Donation', 'A', 'A loan involves borrowing a sum of money that must be repaid, usually with interest, over an agreed period of time.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'Which term describes the practice of borrowing money that must be repaid, typically with interest, over a specified period?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'medium', 'What is the term for the study and management of an individual''s or organization''s money, investments, and other financial assets?', 'Economics', 'Accounting', 'Finance', 'Marketing', 'C', 'Finance involves the management of money, investments, credit, and other financial assets by individuals, businesses, or governments.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'What is the term for the study and management of an individual''s or organization''s money, investments, and other financial assets?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'medium', 'Which term describes the amount by which a business''s expenses exceed its revenue during a given period?', 'A profit', 'A surplus', 'A loss (net loss)', 'A dividend', 'C', 'A loss, or net loss, occurs when a business''s total expenses exceed its total revenue over a given accounting period.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'Which term describes the amount by which a business''s expenses exceed its revenue during a given period?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'medium', 'What is the term for goods and services bought from other countries and brought into a domestic market?', 'Exports', 'Tariffs', 'Subsidies', 'Imports', 'D', 'Imports refer to goods and services purchased from foreign countries and brought into a domestic market for sale or use.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'What is the term for goods and services bought from other countries and brought into a domestic market?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'medium', 'Which term describes goods and services produced domestically and sold to other countries?', 'Imports', 'Exports', 'Trade deficit', 'Trade surplus', 'B', 'Exports refer to goods and services produced within a country and sold to buyers in other countries.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'Which term describes goods and services produced domestically and sold to other countries?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'medium', 'What is the term for a tax imposed by a government on imported goods, often used to protect domestic industries?', 'Tariff', 'Subsidy', 'Excise tax', 'Value-added tax (VAT)', 'A', 'A tariff is a tax imposed on imported goods, often intended to make foreign products more expensive and protect domestic industries.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'What is the term for a tax imposed by a government on imported goods, often used to protect domestic industries?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'medium', 'Which term describes a company''s total assets minus its total liabilities, representing its net worth?', 'Equity (net worth)', 'Revenue', 'Profit margin', 'Cash flow', 'A', 'Equity, or net worth, represents the value remaining for owners after subtracting a company''s total liabilities from its total assets.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'Which term describes a company''s total assets minus its total liabilities, representing its net worth?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'medium', 'What is the term for financial support provided by a government to businesses or industries to encourage production or lower prices?', 'Tariff', 'Grant (a related but broader term)', 'Loan', 'Subsidy', 'D', 'A subsidy is financial assistance provided by a government to businesses or industries, often to encourage production or make goods more affordable.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'What is the term for financial support provided by a government to businesses or industries to encourage production or lower prices?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'medium', 'Which economic term describes the situation when the amount of a good supplied equals the amount demanded at a given price?', 'Market surplus', 'Market shortage', 'Market equilibrium', 'Market failure', 'C', 'Market equilibrium occurs when the quantity of a good supplied exactly matches the quantity demanded at a specific price point.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'Which economic term describes the situation when the amount of a good supplied equals the amount demanded at a given price?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'medium', 'What is the term for a formal agreement between a buyer and seller establishing the terms of a business transaction?', 'Invoice', 'Receipt', 'Proposal', 'Contract', 'D', 'A contract is a formal, legally binding agreement between parties establishing the terms and conditions of a transaction or relationship.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'What is the term for a formal agreement between a buyer and seller establishing the terms of a business transaction?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'medium', 'Which term describes the process by which a business raises funds by selling shares of ownership to the public?', 'Merger', 'Initial Public Offering (IPO)', 'Acquisition', 'Franchising', 'B', 'An Initial Public Offering (IPO) is the process through which a private company offers shares to the public for the first time, raising capital.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'Which term describes the process by which a business raises funds by selling shares of ownership to the public?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'medium', 'Which Philippine festival, held in Cebu every January, is one of the largest and most colorful religious celebrations in the country?', 'Pahiyas Festival', 'MassKara Festival', 'Sinulog Festival', 'Panagbenga Festival', 'C', 'The Sinulog Festival, held annually in Cebu every January, is one of the Philippines'' largest and most vibrant religious celebrations, honoring the Santo Niño.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'Which Philippine festival, held in Cebu every January, is one of the largest and most colorful religious celebrations in the country?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'medium', 'What is the primary purpose of the Kadayawan Festival, celebrated annually in Davao City?', 'A thanksgiving celebration for a bountiful harvest', 'A religious pilgrimage', 'A commemoration of a historic battle', 'A celebration of the founding of the city', 'A', 'Kadayawan Festival is a thanksgiving celebration honoring Davao''s bountiful harvest, flowers, and cultural heritage.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'What is the primary purpose of the Kadayawan Festival, celebrated annually in Davao City?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'medium', 'Which Philippine festival, held in Baguio City every February, celebrates the blooming of flowers in the region?', 'Panagbenga Festival', 'Sinulog Festival', 'Pahiyas Festival', 'Ati-Atihan Festival', 'A', 'Panagbenga Festival, held every February in Baguio City, celebrates the blooming of flowers and is also known as the Flower Festival.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'Which Philippine festival, held in Baguio City every February, celebrates the blooming of flowers in the region?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'medium', 'What is the traditional highlight of the Pahiyas Festival in Lucban, Quezon, involving colorful decorations on houses?', 'Parading giant paper-mache figures', 'Performing masked street dances', 'Holding a boat race on the local river', 'Decorating houses with agricultural produce and rice wafers', 'D', 'The Pahiyas Festival is known for decorating houses with colorful agricultural produce and rice wafers called kiping, thanking San Isidro Labrador for a good harvest.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'What is the traditional highlight of the Pahiyas Festival in Lucban, Quezon, involving colorful decorations on houses?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'medium', 'Which festival, celebrated in Kalibo, Aklan, is known for its street dancing performed in tribal costumes and painted faces?', 'Ati-Atihan Festival', 'Dinagyang Festival', 'Sinulog Festival', 'MassKara Festival', 'A', 'The Ati-Atihan Festival features vibrant street dancing performed by participants in tribal-inspired costumes and painted faces, honoring the Santo Niño.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'Which festival, celebrated in Kalibo, Aklan, is known for its street dancing performed in tribal costumes and painted faces?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'medium', 'What is the name of the festival in Bacolod City that is famously known as the ''Festival of Smiles''?', 'Dinagyang Festival', 'MassKara Festival', 'Ati-Atihan Festival', 'Sinulog Festival', 'B', 'MassKara Festival in Bacolod City is famously called the ''Festival of Smiles,'' featuring participants wearing colorful, smiling masks.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'What is the name of the festival in Bacolod City that is famously known as the ''Festival of Smiles''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'medium', 'Which Philippine festival, celebrated in Iloilo City, developed in connection with a devotion to the Santo Niño, similar to Ati-Atihan?', 'Pahiyas Festival', 'Panagbenga Festival', 'Dinagyang Festival', 'Kadayawan Festival', 'C', 'The Dinagyang Festival in Iloilo City is a lively celebration honoring the Santo Niño, sharing historical roots with the Ati-Atihan Festival.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'Which Philippine festival, celebrated in Iloilo City, developed in connection with a devotion to the Santo Niño, similar to Ati-Atihan?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'medium', 'What is the main theme celebrated during the annual Higantes Festival in Angono, Rizal?', 'The blooming of flowers', 'Giant paper-mache figures honoring patron saints', 'A bountiful harvest of rice', 'The founding of the town', 'B', 'The Higantes Festival features giant paper-mache figures paraded through the streets in honor of the town''s patron saints, San Clemente and San Isidro.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'What is the main theme celebrated during the annual Higantes Festival in Angono, Rizal?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'medium', 'Which annual celebration in Naga City honors the Virgin Mary through one of the largest Marian devotions in the Philippines?', 'Peñafrancia Festival', 'Flores de Mayo', 'Santacruzan', 'Simbang Gabi', 'A', 'The Peñafrancia Festival in Naga City is one of the largest and oldest Marian devotions in the Philippines, honoring Our Lady of Peñafrancia.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'Which annual celebration in Naga City honors the Virgin Mary through one of the largest Marian devotions in the Philippines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'medium', 'What is the name of the Zamboanga City festival that includes a colorful sailing regatta as one of its highlights?', 'Fiesta Pilar', 'Zamboanga Hermosa Festival', 'Festival del Mar', 'Regatta Festival', 'B', 'The Zamboanga Hermosa Festival celebrates the city''s heritage and founding, featuring the Regatta de Zamboanga sailing event as a highlight.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'What is the name of the Zamboanga City festival that includes a colorful sailing regatta as one of its highlights?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'medium', 'Which Philippine festival in Marinduque reenacts the biblical story of a Roman soldier''s conversion, with participants wearing distinctive masks?', 'Turumba Festival', 'Higantes Festival', 'Ati-Atihan Festival', 'Moriones Festival', 'D', 'The Moriones Festival in Marinduque reenacts the story of Longinus, featuring participants wearing elaborate Roman soldier masks.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'Which Philippine festival in Marinduque reenacts the biblical story of a Roman soldier''s conversion, with participants wearing distinctive masks?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'medium', 'What is the name of the festival celebrated in Obando, Bulacan, traditionally associated with fertility prayers through dance?', 'Turumba Festival', 'Santacruzan', 'Obando Fertility Rites', 'Flores de Mayo', 'C', 'The Obando Fertility Rites are a traditional dance festival where couples pray for fertility, honoring three patron saints of the town.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'What is the name of the festival celebrated in Obando, Bulacan, traditionally associated with fertility prayers through dance?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'medium', 'Which festival, held annually in Koronadal City, celebrates the T''boli tribe''s traditional weaving art?', 'Kaamulan Festival', 'Kadayawan Festival', 'Panagbenga Festival', 'T''nalak Festival', 'D', 'The T''nalak Festival celebrates the T''boli tribe''s traditional weaving of T''nalak cloth, a sacred art passed down through generations.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'Which festival, held annually in Koronadal City, celebrates the T''boli tribe''s traditional weaving art?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'medium', 'What does the Kaamulan Festival in Malaybalay, Bukidnon, primarily celebrate?', 'A bountiful harvest of pineapple', 'The cultural heritage of Bukidnon''s indigenous tribes', 'A Spanish colonial battle victory', 'A religious pilgrimage', 'B', 'The Kaamulan Festival celebrates the traditions, rituals, and cultural heritage of Bukidnon''s indigenous tribal groups.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'What does the Kaamulan Festival in Malaybalay, Bukidnon, primarily celebrate?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'medium', 'Which festival, celebrated in Iligan City, highlights the region''s numerous scenic waterfalls?', 'Sinag Festival', 'Bugsay Festival', 'Kaamulan Festival', 'Diyandi Festival', 'D', 'The Diyandi Festival in Iligan City celebrates the city''s cultural heritage and its identity as the ''City of Majestic Waterfalls.'''
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'Which festival, celebrated in Iligan City, highlights the region''s numerous scenic waterfalls?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'medium', 'What is the main religious focus of the annual Feast of the Black Nazarene, held in Quiapo, Manila?', 'Honoring the Virgin Mary', 'Celebrating the harvest season', 'Venerating a centuries-old image of Jesus Christ carrying the cross', 'Commemorating a national hero', 'C', 'The Feast of the Black Nazarene centers on the veneration of a centuries-old image of Jesus Christ carrying the cross, drawing massive crowds of devotees.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'What is the main religious focus of the annual Feast of the Black Nazarene, held in Quiapo, Manila?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'medium', 'Which language is spoken by the most people worldwide when counting both native and second-language speakers combined?', 'English', 'Mandarin Chinese', 'Hindi', 'Spanish', 'A', 'English has the largest total number of speakers worldwide when combining both native speakers and those who speak it as a second language.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'Which language is spoken by the most people worldwide when counting both native and second-language speakers combined?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'medium', 'What is the term for a word that has the same or nearly the same meaning as another word in a given language?', 'Antonym', 'Synonym', 'Homonym', 'Homophone', 'B', 'A synonym is a word that shares the same or a very similar meaning to another word in the same language.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'What is the term for a word that has the same or nearly the same meaning as another word in a given language?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'medium', 'Which alphabet, used to write English and many other European languages, originated with the ancient Romans?', 'The Latin alphabet', 'The Greek alphabet', 'The Cyrillic alphabet', 'The Phoenician alphabet', 'A', 'The Latin alphabet, originating with the ancient Romans, forms the basis for the writing systems of English and many other European languages.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'Which alphabet, used to write English and many other European languages, originated with the ancient Romans?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'medium', 'What is the term for two words that sound the same but have different meanings and often different spellings?', 'Synonyms', 'Antonyms', 'Homographs', 'Homophones', 'D', 'Homophones are words that sound identical but differ in meaning and often in spelling, such as ''their'' and ''there.'''
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'What is the term for two words that sound the same but have different meanings and often different spellings?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'medium', 'Which language is the official language of Brazil, distinguishing it from most other South American countries?', 'Spanish', 'Portuguese', 'French', 'Italian', 'B', 'Portuguese is the official language of Brazil, setting it apart from most other South American nations, which predominantly speak Spanish.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'Which language is the official language of Brazil, distinguishing it from most other South American countries?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'medium', 'What is the term for the grammatical rules governing how words are combined to form sentences in a language?', 'Semantics', 'Phonetics', 'Syntax', 'Morphology', 'C', 'Syntax refers to the set of grammatical rules governing how words are arranged and combined to form well-structured sentences.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'What is the term for the grammatical rules governing how words are combined to form sentences in a language?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'medium', 'Which sign language, developed primarily in the United States, is used by many Deaf communities across North America?', 'British Sign Language (BSL)', 'International Sign', 'French Sign Language', 'American Sign Language (ASL)', 'D', 'American Sign Language (ASL) is a distinct visual language widely used by Deaf communities primarily in the United States and parts of Canada.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'Which sign language, developed primarily in the United States, is used by many Deaf communities across North America?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'medium', 'What is the term for words that have opposite meanings, such as ''hot'' and ''cold''?', 'Synonyms', 'Antonyms', 'Homonyms', 'Homophones', 'B', 'Antonyms are pairs of words that have opposite or contrasting meanings, such as ''hot'' and ''cold.'''
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'What is the term for words that have opposite meanings, such as ''hot'' and ''cold''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'medium', 'Which is the official language of most countries in Latin America, brought through Spanish colonization?', 'Portuguese', 'French', 'Italian', 'Spanish', 'D', 'Spanish is the official language of the majority of Latin American countries, a legacy of Spanish colonization across the region.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'Which is the official language of most countries in Latin America, brought through Spanish colonization?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'medium', 'What is the term for a single unit of speech sound that distinguishes meaning within a language?', 'Morpheme', 'Syllable', 'Phoneme', 'Grapheme', 'C', 'A phoneme is the smallest distinct unit of sound in a language that can change the meaning of a word.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'What is the term for a single unit of speech sound that distinguishes meaning within a language?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'medium', 'Which language is the most widely spoken official language across the African continent, largely due to colonial history?', 'English', 'Arabic', 'French (though English and Arabic are also very widely spoken)', 'Portuguese', 'C', 'French is spoken as an official language in more African countries than any other European language, a legacy of French colonial history.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'Which language is the most widely spoken official language across the African continent, largely due to colonial history?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'medium', 'What is the term for the study of the sounds used in human speech, including how they are produced and perceived?', 'Phonetics', 'Semantics', 'Syntax', 'Pragmatics', 'A', 'Phonetics is the branch of linguistics focused on the physical properties of speech sounds, including their production and perception.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'What is the term for the study of the sounds used in human speech, including how they are produced and perceived?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'medium', 'Which of these languages uses a writing system read from right to left?', 'English', 'Spanish', 'French', 'Arabic', 'D', 'Arabic is written and read from right to left, unlike most European languages, which are read left to right.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'Which of these languages uses a writing system read from right to left?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'medium', 'What is the term for a person who can speak two languages fluently?', 'Multilingual', 'Polyglot (typically implies more than two)', 'Bilingual', 'Monolingual', 'C', 'A bilingual person is someone who can speak and understand two languages fluently.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'What is the term for a person who can speak two languages fluently?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'medium', 'Which language family includes Spanish, French, Italian, Portuguese, and Romanian, all descended from Latin?', 'Romance languages', 'Germanic languages', 'Slavic languages', 'Celtic languages', 'A', 'Spanish, French, Italian, Portuguese, and Romanian are all Romance languages, descended from Vulgar Latin spoken in the Roman Empire.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'Which language family includes Spanish, French, Italian, Portuguese, and Romanian, all descended from Latin?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'medium', 'What is the term for a person who can speak more than two languages?', 'Bilingual', 'Polyglot (or multilingual)', 'Monolingual', 'Linguist (a related but distinct profession)', 'B', 'A polyglot, or multilingual person, is someone capable of speaking more than two languages.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'What is the term for a person who can speak more than two languages?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'medium', 'Which country has the most official languages recognized at the national level, reflecting its immense linguistic diversity?', 'South Africa (11 official languages)', 'India (numerous recognized languages, though the exact count and status differ)', 'Switzerland (4 official languages)', 'Canada (2 official languages)', 'A', 'South Africa recognizes 11 official languages at the national level, reflecting the country''s rich linguistic and cultural diversity.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'Which country has the most official languages recognized at the national level, reflecting its immense linguistic diversity?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'medium', 'Which season is characterized by falling leaves and cooler temperatures, occurring between summer and winter?', 'Autumn (Fall)', 'Spring', 'Summer', 'Winter', 'A', 'Autumn, or fall, is the season between summer and winter marked by cooling temperatures and the shedding of leaves from deciduous trees.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'Which season is characterized by falling leaves and cooler temperatures, occurring between summer and winter?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'medium', 'What is the term for the layer of gases surrounding the Earth, essential for supporting life?', 'Biosphere', 'Atmosphere', 'Lithosphere', 'Hydrosphere', 'B', 'The atmosphere is the layer of gases surrounding Earth, providing the air necessary for respiration and protecting life from harmful solar radiation.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'What is the term for the layer of gases surrounding the Earth, essential for supporting life?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'medium', 'Which natural process describes the transformation of water from liquid to gas, contributing to cloud formation?', 'Evaporation', 'Condensation', 'Precipitation', 'Sublimation', 'A', 'Evaporation is the process by which liquid water transforms into water vapor, playing a key role in the water cycle and cloud formation.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'Which natural process describes the transformation of water from liquid to gas, contributing to cloud formation?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'medium', 'What is the term for a large community of plants and animals adapted to a specific climate and geography, such as a rainforest or desert?', 'Habitat', 'Ecosystem', 'Biome', 'Population', 'C', 'A biome is a large-scale ecological community characterized by a specific climate, vegetation, and animal life, such as a rainforest or desert.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'What is the term for a large community of plants and animals adapted to a specific climate and geography, such as a rainforest or desert?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'medium', 'Which natural phenomenon occurs when the moon passes between the Earth and the sun, blocking sunlight?', 'A lunar eclipse', 'A supermoon', 'A meteor shower', 'A solar eclipse', 'D', 'A solar eclipse occurs when the moon passes between the Earth and the sun, temporarily blocking sunlight from reaching part of the Earth.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'Which natural phenomenon occurs when the moon passes between the Earth and the sun, blocking sunlight?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'medium', 'What is the term for the process by which plants lose water vapor through small openings in their leaves?', 'Transpiration', 'Photosynthesis', 'Respiration', 'Evaporation', 'A', 'Transpiration is the process by which plants release water vapor into the atmosphere through small pores called stomata in their leaves.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'What is the term for the process by which plants lose water vapor through small openings in their leaves?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'medium', 'Which type of rock is formed from the cooling and solidification of molten magma or lava?', 'Igneous rock', 'Sedimentary rock', 'Metamorphic rock', 'Volcanic rock (a subtype of igneous rock)', 'A', 'Igneous rock forms when molten magma or lava cools and solidifies, either beneath or on the Earth''s surface.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'Which type of rock is formed from the cooling and solidification of molten magma or lava?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'medium', 'What is the term for the largest ocean in the world, covering more area than all of Earth''s continents combined?', 'The Atlantic Ocean', 'The Indian Ocean', 'The Arctic Ocean', 'The Pacific Ocean', 'D', 'The Pacific Ocean is the largest and deepest ocean in the world, covering more surface area than all of Earth''s landmasses combined.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'What is the term for the largest ocean in the world, covering more area than all of Earth''s continents combined?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'medium', 'Which natural disaster is characterized by violently rotating columns of air extending from a thunderstorm to the ground?', 'Tornado', 'Hurricane', 'Earthquake', 'Tsunami', 'A', 'A tornado is a violently rotating column of air that extends from a thunderstorm cloud down to the ground, capable of causing severe destruction.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'Which natural disaster is characterized by violently rotating columns of air extending from a thunderstorm to the ground?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'medium', 'What is the term for the process by which sediment settles and accumulates, eventually forming sedimentary rock layers?', 'Erosion', 'Deposition', 'Weathering', 'Compaction (a related but more specific step)', 'B', 'Deposition is the process by which sediment carried by wind, water, or ice settles and accumulates, forming layers that can become sedimentary rock over time.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'What is the term for the process by which sediment settles and accumulates, eventually forming sedimentary rock layers?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'medium', 'Which term describes a period of unusually low rainfall, leading to water shortages and impacts on agriculture?', 'Monsoon', 'Flood', 'Blizzard', 'Drought', 'D', 'A drought is an extended period of below-average rainfall, often resulting in water shortages and significant impacts on agriculture and ecosystems.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'Which term describes a period of unusually low rainfall, leading to water shortages and impacts on agriculture?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'medium', 'What is the term for organisms, such as bacteria and fungi, that break down dead organic material and return nutrients to the soil?', 'Producers', 'Consumers', 'Decomposers', 'Predators', 'C', 'Decomposers, such as bacteria and fungi, break down dead organic matter, recycling nutrients back into the soil and ecosystem.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'What is the term for organisms, such as bacteria and fungi, that break down dead organic material and return nutrients to the soil?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'medium', 'Which weather phenomenon is a rapidly rotating storm system characterized by a low-pressure center and strong winds, known by different names depending on the region?', 'A tornado', 'A tropical cyclone (called a hurricane or typhoon depending on region)', 'A monsoon', 'A blizzard', 'B', 'Tropical cyclones are known as hurricanes in the Atlantic and typhoons in the Pacific, both referring to the same type of powerful rotating storm system.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'Which weather phenomenon is a rapidly rotating storm system characterized by a low-pressure center and strong winds, known by different names depending on the region?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'medium', 'What is the term for the imaginary line around the Earth''s middle, dividing it into the Northern and Southern Hemispheres?', 'The Prime Meridian', 'The Tropic of Cancer', 'The Equator', 'The Arctic Circle', 'C', 'The Equator is the imaginary line encircling the Earth''s middle, dividing it into the Northern and Southern Hemispheres.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'What is the term for the imaginary line around the Earth''s middle, dividing it into the Northern and Southern Hemispheres?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'medium', 'Which term describes plants and animals native to a specific geographic area and found nowhere else in the world?', 'Invasive species', 'Endemic species', 'Migratory species', 'Domesticated species', 'B', 'Endemic species are native to a specific geographic region and are not naturally found anywhere else in the world.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'Which term describes plants and animals native to a specific geographic area and found nowhere else in the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'medium', 'What is the primary gas that makes up the majority of the Earth''s atmosphere?', 'Oxygen', 'Carbon dioxide', 'Argon', 'Nitrogen', 'D', 'Nitrogen makes up approximately 78% of Earth''s atmosphere, making it the most abundant gas, far ahead of oxygen at about 21%.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'What is the primary gas that makes up the majority of the Earth''s atmosphere?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'medium', 'Which type of tree sheds all its leaves annually, typically in autumn, as opposed to evergreen trees?', 'Coniferous tree', 'Evergreen tree', 'Deciduous tree', 'Tropical tree', 'C', 'Deciduous trees shed all their leaves annually, typically in autumn, as opposed to evergreen trees which retain foliage year-round.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'Which type of tree sheds all its leaves annually, typically in autumn, as opposed to evergreen trees?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'medium', 'Which is the smallest country in the world by land area, located entirely within the city of Rome?', 'Vatican City', 'Monaco', 'San Marino', 'Liechtenstein', 'A', 'Vatican City, located entirely within Rome, is the smallest sovereign country in the world by both land area and population.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'Which is the smallest country in the world by land area, located entirely within the city of Rome?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'medium', 'What is the tallest mountain in the world, measured from sea level, located in the Himalayas?', 'K2', 'Kangchenjunga', 'Mount Everest', 'Lhotse', 'C', 'Mount Everest, located in the Himalayas on the border of Nepal and Tibet, is the tallest mountain in the world measured from sea level.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'What is the tallest mountain in the world, measured from sea level, located in the Himalayas?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'medium', 'Which planet in the solar system is known for its prominent ring system and is the second-largest planet?', 'Saturn', 'Jupiter', 'Uranus', 'Neptune', 'A', 'Saturn, the second-largest planet in the solar system, is famous for its extensive and visually striking ring system.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'Which planet in the solar system is known for its prominent ring system and is the second-largest planet?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'medium', 'What is the largest ocean-dwelling animal known to exist, larger than any dinosaur ever recorded?', 'The sperm whale', 'The blue whale', 'The whale shark', 'The giant squid', 'B', 'The blue whale is the largest animal known to have ever existed, surpassing even the largest known dinosaurs in size.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'What is the largest ocean-dwelling animal known to exist, larger than any dinosaur ever recorded?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'medium', 'Which continent is home to the largest number of countries in the world?', 'Asia', 'Africa', 'Europe', 'South America', 'B', 'Africa has the largest number of countries of any continent, with 54 recognized sovereign nations.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'Which continent is home to the largest number of countries in the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'medium', 'What is the name of the currency used in Japan?', 'Won', 'Yuan', 'Yen', 'Ringgit', 'C', 'The Japanese yen is the official currency of Japan.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'What is the name of the currency used in Japan?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'medium', 'Which famous explorer is credited with leading the first expedition to circumnavigate the globe, though he died partway through the voyage?', 'Christopher Columbus', 'Ferdinand Magellan', 'Vasco da Gama', 'James Cook', 'B', 'Ferdinand Magellan led the expedition that first circumnavigated the globe, though he died in the Philippines before the voyage''s completion.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'Which famous explorer is credited with leading the first expedition to circumnavigate the globe, though he died partway through the voyage?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'medium', 'What is the chemical symbol for oxygen, one of the most abundant elements essential to life?', 'Ox', 'O2', 'Og', 'O', 'D', 'Oxygen''s chemical symbol is simply ''O,'' representing one of the most essential elements for supporting life on Earth.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'What is the chemical symbol for oxygen, one of the most abundant elements essential to life?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'medium', 'Which country is both the most populous in the world and located in Asia, as of recent population estimates?', 'China', 'Indonesia', 'United States', 'India', 'D', 'India surpassed China to become the world''s most populous country according to United Nations estimates released in 2023.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'Which country is both the most populous in the world and located in Asia, as of recent population estimates?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'medium', 'What is the term for a shape with three straight sides and three angles?', 'Quadrilateral', 'Pentagon', 'Hexagon', 'Triangle', 'D', 'A triangle is a polygon defined by three straight sides and three interior angles.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'What is the term for a shape with three straight sides and three angles?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'medium', 'Which famous artist painted the ceiling of the Sistine Chapel in Vatican City?', 'Michelangelo', 'Leonardo da Vinci', 'Raphael', 'Titian', 'A', 'Michelangelo painted the iconic ceiling of the Sistine Chapel, a masterpiece of Renaissance art completed in the early 16th century.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'Which famous artist painted the ceiling of the Sistine Chapel in Vatican City?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'medium', 'What is the longest river in the world, generally considered to be located in Africa?', 'The Amazon River', 'The Yangtze River', 'The Nile River', 'The Mississippi River', 'C', 'The Nile River, flowing through northeastern Africa, is traditionally regarded as the longest river in the world.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'What is the longest river in the world, generally considered to be located in Africa?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'medium', 'Which gas do humans and most animals need to breathe in order to survive?', 'Oxygen', 'Carbon dioxide', 'Nitrogen', 'Hydrogen', 'A', 'Oxygen is essential for human and animal respiration, required for cellular processes that generate energy.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'Which gas do humans and most animals need to breathe in order to survive?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'medium', 'What is the name of the galaxy that contains our solar system?', 'Andromeda', 'The Triangulum Galaxy', 'The Milky Way', 'The Whirlpool Galaxy', 'C', 'Our solar system is located within the Milky Way galaxy, a large barred spiral galaxy.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'What is the name of the galaxy that contains our solar system?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'medium', 'Which sport is traditionally associated with Wimbledon, one of the world''s oldest and most prestigious tournaments?', 'Tennis', 'Golf', 'Cricket', 'Rugby', 'A', 'Wimbledon is one of the oldest and most prestigious tournaments in tennis, held annually in London, England.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'Which sport is traditionally associated with Wimbledon, one of the world''s oldest and most prestigious tournaments?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'medium', 'What is the capital city of Australia, distinct from the country''s largest city, Sydney?', 'Sydney', 'Canberra', 'Melbourne', 'Brisbane', 'B', 'Canberra, not Sydney, is the capital city of Australia, chosen as a compromise between Sydney and Melbourne.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'What is the capital city of Australia, distinct from the country''s largest city, Sydney?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'medium', 'Which natural satellite orbits the Earth and is responsible for causing ocean tides through its gravitational pull?', 'The Sun (a lesser contributor)', 'Mars', 'Venus', 'The Moon', 'D', 'The Moon''s gravitational pull is the primary force responsible for causing Earth''s ocean tides.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'Which natural satellite orbits the Earth and is responsible for causing ocean tides through its gravitational pull?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'medium', 'Which organ in the human body is primarily responsible for pumping blood throughout the circulatory system?', 'The liver', 'The kidneys', 'The lungs', 'The heart', 'D', 'The heart is the muscular organ responsible for pumping blood through the body''s circulatory system, delivering oxygen and nutrients to tissues.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'Which organ in the human body is primarily responsible for pumping blood throughout the circulatory system?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'medium', 'What is the term for the human body''s largest and heaviest internal organ, responsible for detoxification and metabolism?', 'The stomach', 'The liver', 'The kidneys', 'The pancreas', 'B', 'The liver is the largest internal organ in the human body, playing a key role in detoxification, metabolism, and nutrient processing.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'What is the term for the human body''s largest and heaviest internal organ, responsible for detoxification and metabolism?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'medium', 'Which system in the human body is responsible for breaking down food into nutrients the body can absorb and use?', 'The digestive system', 'The respiratory system', 'The circulatory system', 'The nervous system', 'A', 'The digestive system breaks down food into nutrients that the body can absorb and use for energy, growth, and repair.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'Which system in the human body is responsible for breaking down food into nutrients the body can absorb and use?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'medium', 'What is the term for the human body''s skeletal system, providing structure, protection, and support for the body?', 'The muscular system', 'The nervous system', 'The skeletal system', 'The endocrine system', 'C', 'The skeletal system provides the body''s structural framework, protects internal organs, and works with muscles to enable movement.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'What is the term for the human body''s skeletal system, providing structure, protection, and support for the body?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'medium', 'Which organ is primarily responsible for filtering waste products from the blood to produce urine?', 'The liver', 'The bladder', 'The kidneys', 'The pancreas', 'C', 'The kidneys filter waste products and excess substances from the blood, producing urine that is then excreted from the body.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'Which organ is primarily responsible for filtering waste products from the blood to produce urine?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'medium', 'What is the term for the body''s system of glands that produce hormones regulating various bodily functions?', 'The nervous system', 'The circulatory system', 'The lymphatic system', 'The endocrine system', 'D', 'The endocrine system consists of glands that produce hormones, regulating processes like metabolism, growth, and mood.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'What is the term for the body''s system of glands that produce hormones regulating various bodily functions?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'medium', 'Which part of the human eye is responsible for controlling the amount of light that enters?', 'The retina', 'The cornea', 'The iris', 'The lens', 'C', 'The iris, the colored part of the eye, controls the size of the pupil, regulating how much light enters the eye.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'Which part of the human eye is responsible for controlling the amount of light that enters?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'medium', 'What is the term for the network of nerves that carries signals between the brain and the rest of the body?', 'The nervous system', 'The circulatory system', 'The endocrine system', 'The lymphatic system', 'A', 'The nervous system, including the brain, spinal cord, and peripheral nerves, transmits signals throughout the body to coordinate actions and responses.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'What is the term for the network of nerves that carries signals between the brain and the rest of the body?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'medium', 'Which type of blood vessel carries oxygen-rich blood away from the heart to the rest of the body?', 'Veins', 'Capillaries', 'Arteries', 'Venules', 'C', 'Arteries carry oxygen-rich blood away from the heart to the rest of the body, generally under higher pressure than veins.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'Which type of blood vessel carries oxygen-rich blood away from the heart to the rest of the body?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'medium', 'What is the term for the process by which the lungs take in oxygen and expel carbon dioxide?', 'Circulation', 'Digestion', 'Metabolism', 'Respiration (breathing)', 'D', 'Respiration, or breathing, is the process by which the lungs take in oxygen and expel carbon dioxide as a waste product.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'What is the term for the process by which the lungs take in oxygen and expel carbon dioxide?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'medium', 'Which organ produces insulin, a hormone essential for regulating blood sugar levels?', 'The pancreas', 'The liver', 'The kidneys', 'The thyroid gland', 'A', 'The pancreas produces insulin, a hormone crucial for regulating blood sugar levels by facilitating glucose uptake into cells.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'Which organ produces insulin, a hormone essential for regulating blood sugar levels?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'medium', 'What is the term for the outer, protective layer of the human body, also involved in temperature regulation?', 'The muscles', 'The bones', 'The fat tissue', 'The skin', 'D', 'The skin serves as the body''s outer protective barrier, while also playing a key role in regulating body temperature and enabling sensation.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'What is the term for the outer, protective layer of the human body, also involved in temperature regulation?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'medium', 'Which part of the brain is responsible for controlling essential involuntary functions, such as heart rate and breathing?', 'The cerebrum', 'The brainstem', 'The cerebellum', 'The hypothalamus', 'B', 'The brainstem controls essential involuntary functions necessary for survival, including heart rate, breathing, and blood pressure regulation.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'Which part of the brain is responsible for controlling essential involuntary functions, such as heart rate and breathing?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'medium', 'What is the term for the specialized cells in the human body responsible for carrying oxygen throughout the bloodstream?', 'White blood cells', 'Red blood cells', 'Platelets', 'Plasma cells', 'B', 'Red blood cells contain hemoglobin, a protein that binds to oxygen and carries it from the lungs to tissues throughout the body.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'What is the term for the specialized cells in the human body responsible for carrying oxygen throughout the bloodstream?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'medium', 'Which sense organ contains structures responsible for both hearing and maintaining the body''s sense of balance?', 'The ear', 'The eye', 'The nose', 'The skin', 'A', 'The ear contains structures responsible for both hearing and maintaining balance, including the semicircular canals of the inner ear.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'Which sense organ contains structures responsible for both hearing and maintaining the body''s sense of balance?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'medium', 'What is the term for the muscular tube connecting the throat to the stomach, through which food passes during digestion?', 'The trachea', 'The esophagus', 'The intestine', 'The pharynx', 'B', 'The esophagus is the muscular tube that transports food from the throat to the stomach as part of the digestive process.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'What is the term for the muscular tube connecting the throat to the stomach, through which food passes during digestion?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'medium', 'Which body system is responsible for defending the body against infections and foreign invaders?', 'The immune system', 'The endocrine system', 'The digestive system', 'The respiratory system', 'A', 'The immune system defends the body against infections, pathogens, and other foreign invaders through a network of cells, tissues, and organs.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'Which body system is responsible for defending the body against infections and foreign invaders?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'medium', 'Which Filipino invention, patented in 1975, is widely credited as a precursor to modern karaoke technology?', 'The Sound Machine by Gregorio Zara', 'The Music Box by Eduardo San Juan', 'The Audio Player by Diosdado Banatao', 'The Sing-Along System by Roberto del Rosario', 'D', 'Roberto del Rosario patented the Sing Along System in 1975, an early Filipino invention often cited as a precursor to modern karaoke machines.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Which Filipino invention, patented in 1975, is widely credited as a precursor to modern karaoke technology?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'medium', 'What everyday Filipino vehicle, adapted from surplus World War II jeeps, became a colorful, iconic mode of public transportation?', 'The tricycle', 'The jeepney', 'The calesa', 'The habal-habal', 'B', 'The jeepney, created from surplus American military jeeps left after World War II, became a colorful and iconic form of Filipino public transportation.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'What everyday Filipino vehicle, adapted from surplus World War II jeeps, became a colorful, iconic mode of public transportation?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'medium', 'Which Filipino food technologist is credited with inventing banana ketchup during a wartime tomato shortage?', 'Fe del Mundo', 'Josefina Guerrero', 'Maria Orosa', 'Honoria Acosta-Sison', 'C', 'Maria Orosa invented banana ketchup during World War II as a creative substitute when tomatoes were in short supply.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Which Filipino food technologist is credited with inventing banana ketchup during a wartime tomato shortage?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'medium', 'What is the name of the world''s first commercially successful personal computer operating system, developed by Microsoft in 1981?', 'Windows 95', 'MS-DOS', 'Mac OS', 'UNIX', 'B', 'MS-DOS, released by Microsoft in 1981, became one of the first widely adopted operating systems for personal computers.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'What is the name of the world''s first commercially successful personal computer operating system, developed by Microsoft in 1981?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'medium', 'Which inventor is credited with patenting the first practical incandescent light bulb in the late 19th century?', 'Nikola Tesla', 'Alexander Graham Bell', 'Thomas Edison', 'Guglielmo Marconi', 'C', 'Thomas Edison is widely credited with developing and patenting the first commercially practical incandescent light bulb in 1879.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Which inventor is credited with patenting the first practical incandescent light bulb in the late 19th century?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'medium', 'What is the name of the technology, first demonstrated by Alexander Graham Bell in 1876, that allows voice communication over long distances?', 'The telegraph', 'The telephone', 'The radio', 'The phonograph', 'B', 'Alexander Graham Bell is credited with inventing the telephone, patented in 1876, revolutionizing long-distance voice communication.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'What is the name of the technology, first demonstrated by Alexander Graham Bell in 1876, that allows voice communication over long distances?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'medium', 'Which Filipino scientist invented an early video telephone system in 1955, decades before video calling became common?', 'Gregorio Zara', 'Eduardo San Juan', 'Diosdado Banatao', 'Roberto del Rosario', 'A', 'Gregorio Zara, a National Scientist of the Philippines, invented a two-way video telephone in 1955.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Which Filipino scientist invented an early video telephone system in 1955, decades before video calling became common?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'medium', 'What is the name of the printing technology, invented by Johannes Gutenberg in the 15th century, that revolutionized the spread of information?', 'The typewriter', 'The lithograph', 'The engraving press', 'The printing press', 'D', 'Johannes Gutenberg''s invention of the movable-type printing press in the 15th century revolutionized how information could be produced and distributed.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'What is the name of the printing technology, invented by Johannes Gutenberg in the 15th century, that revolutionized the spread of information?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'medium', 'Which invention, developed by the Wright brothers in 1903, marked the first successful powered, controlled flight of an aircraft?', 'The airplane', 'The hot air balloon', 'The helicopter', 'The glider (a related, unpowered predecessor)', 'A', 'The Wright brothers achieved the first successful powered, controlled flight of an airplane in 1903 near Kitty Hawk, North Carolina.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Which invention, developed by the Wright brothers in 1903, marked the first successful powered, controlled flight of an aircraft?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'medium', 'What is the term for the technology, pioneered by Alexander Fleming''s discovery in 1928, that revolutionized the treatment of bacterial infections?', 'Vaccination', 'Anesthesia', 'X-ray imaging', 'Penicillin (the first widely used antibiotic)', 'D', 'Alexander Fleming''s 1928 discovery of penicillin led to the development of antibiotics, revolutionizing the treatment of bacterial infections.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'What is the term for the technology, pioneered by Alexander Fleming''s discovery in 1928, that revolutionized the treatment of bacterial infections?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'medium', 'Which Filipino engineer contributed to the design of the lunar roving vehicle used during NASA''s Apollo missions to the Moon?', 'Gregorio Zara', 'Diosdado Banatao', 'Eduardo San Juan', 'Roberto del Rosario', 'C', 'Eduardo San Juan, a Filipino engineer working with General Motors, contributed to the design of NASA''s Lunar Roving Vehicle.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Which Filipino engineer contributed to the design of the lunar roving vehicle used during NASA''s Apollo missions to the Moon?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'medium', 'What is the name of the technology developed in the mid-20th century that allows information to be stored and processed using transistors, replacing vacuum tubes?', 'The vacuum tube (the earlier technology it replaced)', 'The microchip (a later development building on transistors)', 'The punch card (an earlier data storage method)', 'The transistor (leading to modern computing)', 'D', 'The invention of the transistor in the late 1940s revolutionized electronics, eventually replacing bulkier vacuum tubes and enabling modern computing.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'What is the name of the technology developed in the mid-20th century that allows information to be stored and processed using transistors, replacing vacuum tubes?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'medium', 'Which invention, credited to Tim Berners-Lee in 1989, established the foundational technology for the World Wide Web?', 'Email', 'Hypertext Transfer Protocol (HTTP) and related web technologies', 'The internet itself (a broader, earlier infrastructure)', 'The search engine', 'B', 'Tim Berners-Lee developed the foundational technologies, including HTTP and HTML, that established the World Wide Web in 1989.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Which invention, credited to Tim Berners-Lee in 1989, established the foundational technology for the World Wide Web?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'medium', 'What is the name of the vaccine, developed by Edward Jenner in 1796, considered the first successful vaccine in medical history?', 'The polio vaccine', 'The measles vaccine', 'The smallpox vaccine', 'The rabies vaccine', 'C', 'Edward Jenner developed the smallpox vaccine in 1796, widely regarded as the first successful vaccine in medical history.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'What is the name of the vaccine, developed by Edward Jenner in 1796, considered the first successful vaccine in medical history?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'medium', 'Which invention, developed in Sweden and patented by Alfred Nobel in 1867, revolutionized construction and mining through controlled explosions?', 'Dynamite', 'Gunpowder (a much earlier invention)', 'TNT (a related but distinct explosive)', 'Nitroglycerin (the precursor compound, not Nobel''s stabilized invention)', 'A', 'Alfred Nobel patented dynamite in 1867, a stabilized and safer explosive that transformed construction, mining, and demolition industries.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Which invention, developed in Sweden and patented by Alfred Nobel in 1867, revolutionized construction and mining through controlled explosions?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'medium', 'What is the name of the medical imaging technology, developed in the early 1970s, that uses X-rays to create detailed cross-sectional images of the body?', 'Computed Tomography (CT scan)', 'Magnetic Resonance Imaging (MRI)', 'Ultrasound', 'Positron Emission Tomography (PET scan)', 'A', 'Computed Tomography, or CT scanning, developed in the early 1970s, uses X-rays to produce detailed cross-sectional images of the body.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'What is the name of the medical imaging technology, developed in the early 1970s, that uses X-rays to create detailed cross-sectional images of the body?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'medium', 'Which historic walled city in Manila served as the center of Spanish colonial government for over 300 years?', 'Fort Santiago (a specific fort within Intramuros)', 'Binondo', 'Intramuros', 'Malacañang', 'C', 'Intramuros, meaning ''within the walls,'' was the fortified heart of Spanish colonial administration in Manila for over three centuries.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'Which historic walled city in Manila served as the center of Spanish colonial government for over 300 years?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'medium', 'What is the name of the historic rice terraces in Ifugao, often called the ''Eighth Wonder of the World''?', 'The Banaue Rice Terraces', 'The Chocolate Hills', 'The Taal Volcano', 'The Puerto Princesa Underground River', 'A', 'The Banaue Rice Terraces, carved into the mountains of Ifugao over centuries, are often referred to as the ''Eighth Wonder of the World.'''
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'What is the name of the historic rice terraces in Ifugao, often called the ''Eighth Wonder of the World''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'medium', 'Which UNESCO World Heritage town in Ilocos Sur is known for its well-preserved Spanish colonial architecture?', 'Vigan', 'Taal', 'Silay', 'Iloilo City', 'A', 'Vigan, in Ilocos Sur, is a UNESCO World Heritage Site celebrated for its remarkably preserved Spanish colonial townscape.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'Which UNESCO World Heritage town in Ilocos Sur is known for its well-preserved Spanish colonial architecture?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'medium', 'What is the name of the official residence and workplace of the President of the Philippines?', 'Rizal Park', 'Malacañang Palace', 'Fort Santiago', 'Manila Cathedral', 'B', 'Malacañang Palace, located along the Pasig River, has served as the official residence and workplace of Philippine presidents.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'What is the name of the official residence and workplace of the President of the Philippines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'medium', 'Which famous natural attraction in Palawan is a UNESCO World Heritage Site and one of the New7Wonders of Nature?', 'Puerto Princesa Subterranean River', 'The Chocolate Hills', 'Taal Volcano', 'Mount Mayon', 'A', 'The Puerto Princesa Subterranean River in Palawan is a UNESCO World Heritage Site and one of the officially declared New7Wonders of Nature.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'Which famous natural attraction in Palawan is a UNESCO World Heritage Site and one of the New7Wonders of Nature?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'medium', 'What is the name of the historic park in Manila where national hero Jose Rizal was executed in 1896?', 'Intramuros', 'Paco Park', 'Rizal Park (Luneta)', 'Fort Santiago', 'C', 'Rizal Park, also known as Luneta, is the historic site where national hero Jose Rizal was executed by Spanish colonial authorities in 1896.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'What is the name of the historic park in Manila where national hero Jose Rizal was executed in 1896?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'medium', 'Which unusual geological formation in Bohol consists of numerous cone-shaped hills that turn brown during the dry season?', 'The Banaue Rice Terraces', 'The Chocolate Hills', 'Taal Volcano', 'Mount Pulag', 'B', 'The Chocolate Hills in Bohol are unusual cone-shaped limestone formations that turn brown during the dry season, giving them their distinctive name.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'Which unusual geological formation in Bohol consists of numerous cone-shaped hills that turn brown during the dry season?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'medium', 'What is the name of the volcanic lake island landmark located in Batangas province?', 'Mount Mayon', 'Mount Pinatubo', 'Mount Apo', 'Taal Volcano', 'D', 'Taal Volcano, situated within Taal Lake in Batangas, is one of the world''s smallest active volcanoes and a popular tourist destination.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'What is the name of the volcanic lake island landmark located in Batangas province?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'medium', 'Which historic fort in Cebu City is considered the oldest and smallest Spanish-built fort in the Philippines?', 'Fort Santiago', 'Fort Pilar', 'Fort Bonifacio', 'Fort San Pedro', 'D', 'Fort San Pedro in Cebu City is recognized as the oldest and smallest Spanish-built fort in the Philippines.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'Which historic fort in Cebu City is considered the oldest and smallest Spanish-built fort in the Philippines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'medium', 'What is the name of the group of coral reef islands in the Sulu Sea recognized for extraordinary marine biodiversity?', 'Apo Reef Natural Park', 'El Nido Marine Reserve', 'Coron Reef', 'Tubbataha Reefs Natural Park', 'D', 'Tubbataha Reefs Natural Park, a UNESCO World Heritage Site in the Sulu Sea, is renowned worldwide for its pristine coral reef biodiversity.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'What is the name of the group of coral reef islands in the Sulu Sea recognized for extraordinary marine biodiversity?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'medium', 'Which centuries-old Catholic church in Manila, part of a UNESCO World Heritage listing, is the oldest stone church in the Philippines?', 'Manila Cathedral', 'Quiapo Church', 'San Agustin Church', 'Binondo Church', 'C', 'San Agustin Church in Intramuros is the oldest stone church in the Philippines and part of the UNESCO-listed Baroque Churches of the Philippines.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'Which centuries-old Catholic church in Manila, part of a UNESCO World Heritage listing, is the oldest stone church in the Philippines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'medium', 'What is the name of the historic district in Manila considered the oldest Chinatown in the world?', 'Divisoria', 'Quiapo', 'Binondo', 'Escolta', 'C', 'Binondo, established in 1594, is recognized as the oldest continuously operating Chinatown in the world.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'What is the name of the historic district in Manila considered the oldest Chinatown in the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'medium', 'Which historic fort on an island at the entrance of Manila Bay played a key defensive role during World War II?', 'Corregidor', 'Fort Santiago', 'Fort San Pedro', 'Fort Bonifacio', 'A', 'Corregidor Island, situated at the entrance of Manila Bay, was a crucial defensive fortress during World War II, site of significant battles.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'Which historic fort on an island at the entrance of Manila Bay played a key defensive role during World War II?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'medium', 'What is the name of the highest mountain in the Philippines, located in Mindanao?', 'Mount Pulag', 'Mount Apo', 'Mount Mayon', 'Mount Kanlaon', 'B', 'Mount Apo, located in Mindanao, is the highest mountain peak in the Philippines.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'What is the name of the highest mountain in the Philippines, located in Mindanao?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'medium', 'Which historic heritage town in Batangas is known for its well-preserved ancestral houses and grand basilica?', 'Vigan', 'Taal', 'Silay', 'Iloilo City', 'B', 'Taal, Batangas, is renowned for its well-preserved Spanish-era ancestral houses and the Taal Basilica, one of the largest churches in Asia.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'Which historic heritage town in Batangas is known for its well-preserved ancestral houses and grand basilica?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'medium', 'Which historic bridge in Manila, near Intramuros, is one of the city''s most iconic crossings over the Pasig River?', 'MacArthur Bridge', 'Ayala Bridge', 'Quezon Bridge', 'Jones Bridge', 'D', 'Jones Bridge, spanning the Pasig River near Intramuros, is one of Manila''s most iconic and historic bridges.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'Which historic bridge in Manila, near Intramuros, is one of the city''s most iconic crossings over the Pasig River?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'medium', 'Which Philippine language, spoken predominantly in Cebu and other Visayan islands, has the second-most native speakers in the country?', 'Ilocano', 'Hiligaynon', 'Waray', 'Cebuano', 'D', 'Cebuano is spoken widely across Cebu and other Visayan islands and has the second-highest number of native speakers among Philippine languages.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'Which Philippine language, spoken predominantly in Cebu and other Visayan islands, has the second-most native speakers in the country?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'medium', 'What is the national and official language of the Philippines, based primarily on Tagalog?', 'English', 'Tagalog (the base language, distinct from the official standard)', 'Cebuano', 'Filipino', 'D', 'Filipino, based largely on Tagalog, is the national and one of the two official languages of the Philippines, alongside English.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'What is the national and official language of the Philippines, based primarily on Tagalog?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'medium', 'Which language, alongside Filipino, is designated as an official language of the Philippines, widely used in government and education?', 'Spanish', 'Chinese', 'Malay', 'English', 'D', 'English is designated as an official language of the Philippines alongside Filipino, widely used in government, business, and education.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'Which language, alongside Filipino, is designated as an official language of the Philippines, widely used in government and education?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'medium', 'What is the term for the widespread Filipino practice of mixing Filipino and English words within the same conversation?', 'Chavacano', 'Baybayin', 'Taglish', 'Konyo (a related but more specific sociolect)', 'C', 'Taglish refers to the common practice of blending Filipino and English within everyday Philippine conversation.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'What is the term for the widespread Filipino practice of mixing Filipino and English words within the same conversation?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'medium', 'Which regional Philippine language is spoken primarily in the Ilocos Region of northern Luzon?', 'Kapampangan', 'Pangasinan', 'Ilocano', 'Ibanag', 'C', 'Ilocano is the major regional language spoken throughout the Ilocos Region of northern Luzon.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'Which regional Philippine language is spoken primarily in the Ilocos Region of northern Luzon?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'medium', 'What is the pre-colonial Filipino writing system, largely replaced by the Latin alphabet during Spanish colonization?', 'Kanji', 'Baybayin', 'Hangul', 'Devanagari', 'B', 'Baybayin was the pre-colonial writing system used by Tagalog speakers before being largely supplanted by the Latin alphabet under Spanish rule.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'What is the pre-colonial Filipino writing system, largely replaced by the Latin alphabet during Spanish colonization?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'medium', 'Which Visayan language, spoken in Panay Island and Negros Occidental, is also commonly known as Ilonggo?', 'Hiligaynon', 'Cebuano', 'Waray', 'Aklanon', 'A', 'Hiligaynon, commonly called Ilonggo, is the major regional language of Panay Island and Negros Occidental.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'Which Visayan language, spoken in Panay Island and Negros Occidental, is also commonly known as Ilonggo?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'medium', 'What language family do the vast majority of Philippine languages, including Tagalog and Cebuano, belong to?', 'Sino-Tibetan', 'Indo-European', 'Austronesian', 'Afro-Asiatic', 'C', 'The vast majority of Philippine languages, including Tagalog and Cebuano, belong to the Austronesian language family.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'What language family do the vast majority of Philippine languages, including Tagalog and Cebuano, belong to?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'medium', 'Which Philippine language, spoken primarily in Eastern Visayas including Samar and Leyte, is also known as Waray-Waray?', 'Waray', 'Hiligaynon', 'Cebuano', 'Boholano', 'A', 'Waray, or Waray-Waray, is the major regional language spoken across Eastern Visayas, including Samar and Leyte.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'Which Philippine language, spoken primarily in Eastern Visayas including Samar and Leyte, is also known as Waray-Waray?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'medium', 'What is the term for the Spanish-based creole language spoken in Zamboanga City, one of few such creoles in Asia?', 'Taglish', 'Chavacano', 'Baybayin', 'Konyo', 'B', 'Chavacano, spoken in Zamboanga, is a Spanish-based creole language, notable for being among the few such languages found in Asia.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'What is the term for the Spanish-based creole language spoken in Zamboanga City, one of few such creoles in Asia?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'medium', 'Which Philippine language is spoken primarily in Pampanga province, also known as Pampango?', 'Ilocano', 'Pangasinan', 'Kapampangan', 'Sambal', 'C', 'Kapampangan, also called Pampango, is the regional language spoken primarily in Pampanga province.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'Which Philippine language is spoken primarily in Pampanga province, also known as Pampango?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'medium', 'What is the estimated number of distinct languages spoken across the Philippine archipelago, reflecting its linguistic diversity?', 'Around 130 to 180 languages', 'About 20 languages', 'Roughly 50 languages', 'Over 300 languages', 'A', 'The Philippines is home to an estimated 130 to 180 distinct languages, reflecting the country''s remarkable linguistic diversity.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'What is the estimated number of distinct languages spoken across the Philippine archipelago, reflecting its linguistic diversity?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'medium', 'Which language, spoken by the indigenous people of Batanes, is notable for its distinct vocabulary compared to mainland Philippine languages?', 'Kapampangan', 'Ivatan', 'Pangasinan', 'Sambal', 'B', 'Ivatan, spoken in Batanes, has a distinct vocabulary and structure that sets it apart from many mainland Philippine languages.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'Which language, spoken by the indigenous people of Batanes, is notable for its distinct vocabulary compared to mainland Philippine languages?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'medium', 'What is the term for the standardized variety of Filipino most commonly used in national broadcast media?', 'Manila Tagalog (Metro Manila Filipino)', 'Batangas Tagalog', 'Marinduque Tagalog', 'Southern Tagalog', 'A', 'Manila Tagalog, or Metro Manila Filipino, is the standardized variety most commonly used in national television, radio, and formal media.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'What is the term for the standardized variety of Filipino most commonly used in national broadcast media?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'medium', 'Which Philippine regional language is spoken primarily in the Bicol Region, distinct from Tagalog and Bisaya languages?', 'Hiligaynon', 'Waray', 'Kapampangan', 'Bikol (Bicolano)', 'D', 'Bikol, or Bicolano, is the major regional language of the Bicol Region, distinct from both Tagalog and the various Visayan languages.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'Which Philippine regional language is spoken primarily in the Bicol Region, distinct from Tagalog and Bisaya languages?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'medium', 'What is the term used to describe a language variety spoken in a specific region, differing in some ways from the standard form of the language?', 'Creole', 'Dialect', 'Pidgin', 'Sociolect', 'B', 'A dialect is a regional variety of a language, differing in pronunciation, vocabulary, or grammar from the standard form.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'What is the term used to describe a language variety spoken in a specific region, differing in some ways from the standard form of the language?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'medium', 'Which Jose Rizal novel exposed the abuses of Spanish colonial rule and is credited with fueling Filipino nationalism?', 'El Filibusterismo', 'Mi Ultimo Adios', 'Noli Me Tangere', 'Makamisa', 'C', 'Noli Me Tangere, written by Jose Rizal in 1887, exposed Spanish colonial abuses and helped ignite Filipino nationalist sentiment.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'Which Jose Rizal novel exposed the abuses of Spanish colonial rule and is credited with fueling Filipino nationalism?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'medium', 'What is the title of Jose Rizal''s farewell poem, written the night before his execution in 1896?', 'Noli Me Tangere', 'El Filibusterismo', 'Mi Ultimo Adios', 'Sa Aking Mga Kabata', 'C', '''Mi Ultimo Adios,'' written by Jose Rizal the night before his execution, remains one of the most celebrated poems in Philippine literature.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'What is the title of Jose Rizal''s farewell poem, written the night before his execution in 1896?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'medium', 'Which Filipino epic, associated with the Ilocano people, recounts the adventures of a legendary hero?', 'Hinilawod', 'Ibalong', 'Biag ni Lam-ang', 'Darangen', 'C', 'Biag ni Lam-ang, an Ilocano epic, recounts the extraordinary adventures of its legendary hero, Lam-ang.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'Which Filipino epic, associated with the Ilocano people, recounts the adventures of a legendary hero?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'medium', 'What is the title of Nick Joaquin''s celebrated short story exploring themes of Filipino identity through the Marasigan family?', 'The Woman Who Had Two Navels (a novel, though ''A Portrait of the Artist as Filipino'' is another key work)', 'Tropical Gothic', 'Cave and Shadows', 'Prose and Poems', 'A', 'Nick Joaquin, a National Artist for Literature, is known for major works exploring Filipino identity, including his novel ''The Woman Who Had Two Navels.'''
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'What is the title of Nick Joaquin''s celebrated short story exploring themes of Filipino identity through the Marasigan family?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'medium', 'Which Filipino novel by Lualhati Bautista portrays a family''s experiences during the martial law era under Ferdinand Marcos?', 'Bata, Bata... Pa''no Ka Ginawa?', 'Dekada ''70', 'Gapo', 'Desaparecidos', 'B', '''Dekada ''70,'' by Lualhati Bautista, portrays a middle-class Filipino family''s experiences and struggles during the martial law period.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'Which Filipino novel by Lualhati Bautista portrays a family''s experiences during the martial law era under Ferdinand Marcos?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'medium', 'What is the name of the character created by Mars Ravelo, considered one of the most iconic Filipino superheroines in komiks history?', 'Darna', 'Zsazsa Zaturnnah', 'Lastikman', 'Captain Barbell', 'A', 'Darna, created by Mars Ravelo, is one of the most enduring and iconic superheroines in Philippine komiks and popular culture.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'What is the name of the character created by Mars Ravelo, considered one of the most iconic Filipino superheroines in komiks history?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'medium', 'Which literary work is considered the national epic of the Ilocano people, recounting the life of the hero Lam-ang from birth to adulthood?', 'Biag ni Lam-ang', 'Hinilawod', 'Darangen', 'Ibalong', 'A', 'Biag ni Lam-ang, meaning ''The Life of Lam-ang,'' is the celebrated Ilocano epic chronicling its hero''s life from a miraculous birth through his many adventures.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'Which literary work is considered the national epic of the Ilocano people, recounting the life of the hero Lam-ang from birth to adulthood?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'medium', 'What is the title of Carlos Bulosan''s autobiographical novel depicting Filipino immigrant workers'' experiences in America?', 'The Cry and the Dedication', 'America Is in the Heart', 'The Laughter of My Father', 'If You Want to Know What We Are', 'B', '''America Is in the Heart,'' by Carlos Bulosan, is a landmark autobiographical work depicting the hardships faced by Filipino immigrant laborers in the United States.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'What is the title of Carlos Bulosan''s autobiographical novel depicting Filipino immigrant workers'' experiences in America?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'medium', 'Which National Artist for Literature is known for pioneering modernist poetry in the Philippines, often writing in English?', 'Nick Joaquin', 'F. Sionil Jose', 'Bienvenido Lumbera', 'Jose Garcia Villa', 'D', 'Jose Garcia Villa, a National Artist for Literature, pioneered modernist poetry in the Philippines, gaining international recognition for his innovative verse.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'Which National Artist for Literature is known for pioneering modernist poetry in the Philippines, often writing in English?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'medium', 'What is the term for traditional Filipino narrative poems, often adapted from European tales, exemplified by ''Ibong Adarna''?', 'Kundiman', 'Balagtasan', 'Dalit', 'Awit and korido (metrical romances)', 'D', '''Awit'' and ''korido'' refer to traditional Filipino metrical romances, narrative poems often based on or inspired by European chivalric tales.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'What is the term for traditional Filipino narrative poems, often adapted from European tales, exemplified by ''Ibong Adarna''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'medium', 'Which short story writer is known for ''The Mats,'' a widely studied story depicting family memory and loss?', 'Manuel Arguilla', 'Francisco Arcellana', 'N.V.M. Gonzalez', 'Nick Joaquin', 'B', 'Francisco Arcellana wrote ''The Mats,'' a widely anthologized short story known for its poignant portrayal of family memory and loss.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'Which short story writer is known for ''The Mats,'' a widely studied story depicting family memory and loss?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'medium', 'What is the name of the Filipino writer known for ''How My Brother Leon Brought Home a Wife,'' exploring rural life and family?', 'Francisco Arcellana', 'N.V.M. Gonzalez', 'Manuel Arguilla', 'Nick Joaquin', 'C', 'Manuel Arguilla wrote ''How My Brother Leon Brought Home a Wife,'' a celebrated short story exploring family dynamics and rural Filipino life.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'What is the name of the Filipino writer known for ''How My Brother Leon Brought Home a Wife,'' exploring rural life and family?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'medium', 'Which Filipino National Artist for Literature wrote the acclaimed ''Rosales Saga,'' a five-novel cycle spanning generations of Filipino history?', 'Nick Joaquin', 'Bienvenido Santos', 'N.V.M. Gonzalez', 'F. Sionil Jose', 'D', 'F. Sionil Jose''s Rosales Saga, comprising five novels, traces generations of a Filipino family across major historical periods.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'Which Filipino National Artist for Literature wrote the acclaimed ''Rosales Saga,'' a five-novel cycle spanning generations of Filipino history?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'medium', 'What is the term for a formal Filipino poetic debate performed extemporaneously between two or more poets?', 'Balagtasan', 'Duplo', 'Karagatan', 'Bugtong', 'A', 'The Balagtasan is a traditional Filipino poetic joust or debate, performed extemporaneously and named in honor of the poet Francisco Balagtas.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'What is the term for a formal Filipino poetic debate performed extemporaneously between two or more poets?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'medium', 'Which Filipino poem is traditionally attributed to a young Jose Rizal, though its authorship has been debated by scholars?', 'Mi Ultimo Adios', 'A la Juventud Filipina', 'Himno al Trabajo', 'Sa Aking Mga Kabata', 'D', '''Sa Aking Mga Kabata'' is a poem traditionally attributed to Jose Rizal as a child, though modern scholars debate its true authorship.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'Which Filipino poem is traditionally attributed to a young Jose Rizal, though its authorship has been debated by scholars?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'medium', 'Which epic Bicolano tale recounts mythological origins, including the story of the region''s volcanoes?', 'Hinilawod', 'Ibalong', 'Darangen', 'Biag ni Lam-ang', 'B', 'Ibalong is the Bicolano epic recounting mythological heroes and the origins of the region''s notable geographic features, including its volcanoes.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'Which epic Bicolano tale recounts mythological origins, including the story of the region''s volcanoes?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'medium', 'What is the term for a type of reasoning that moves from general principles to specific conclusions?', 'Inductive reasoning', 'Deductive reasoning', 'Abductive reasoning', 'Analogical reasoning', 'B', 'Deductive reasoning starts with general principles or premises and applies them to reach specific, logically certain conclusions.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'What is the term for a type of reasoning that moves from general principles to specific conclusions?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'medium', 'Which logical fallacy occurs when someone attacks the person making an argument rather than addressing the argument itself?', 'Straw man', 'Red herring', 'Ad hominem', 'Slippery slope', 'C', 'An ad hominem fallacy involves attacking the character or personal traits of the person making an argument, rather than the argument''s actual content.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'Which logical fallacy occurs when someone attacks the person making an argument rather than addressing the argument itself?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'medium', 'What is the term for a statement or claim that is logically true under all possible circumstances?', 'A contradiction', 'A hypothesis', 'A tautology', 'A premise', 'C', 'A tautology is a statement that is true by necessity or by its logical structure, regardless of the truth values of its components.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'What is the term for a statement or claim that is logically true under all possible circumstances?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'medium', 'Which type of reasoning involves drawing broad general conclusions from specific individual observations?', 'Deductive reasoning', 'Inductive reasoning', 'Abductive reasoning', 'Circular reasoning', 'B', 'Inductive reasoning involves drawing general conclusions based on a series of specific observations, though such conclusions are not guaranteed to be true.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'Which type of reasoning involves drawing broad general conclusions from specific individual observations?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'medium', 'What is the term for a logical fallacy in which someone assumes that because two events occurred together, one must have caused the other?', 'False cause (correlation-causation fallacy)', 'False dilemma', 'Hasty generalization', 'Circular reasoning', 'A', 'The false cause fallacy occurs when someone incorrectly assumes causation simply because two events are correlated or occur together.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'What is the term for a logical fallacy in which someone assumes that because two events occurred together, one must have caused the other?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'medium', 'Which logical structure consists of two premises and a conclusion, forming the basis of classical deductive logic?', 'A hypothesis', 'An axiom', 'A postulate', 'A syllogism', 'D', 'A syllogism is a logical structure consisting of a major premise, a minor premise, and a conclusion drawn from them.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'Which logical structure consists of two premises and a conclusion, forming the basis of classical deductive logic?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'medium', 'What is the term for presenting only two choices in an argument when, in reality, more options exist?', 'Straw man', 'Ad hominem', 'Slippery slope', 'False dilemma (false dichotomy)', 'D', 'A false dilemma incorrectly limits an argument to only two possible outcomes or choices when additional options actually exist.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'What is the term for presenting only two choices in an argument when, in reality, more options exist?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'medium', 'Which logical fallacy involves misrepresenting someone''s argument to make it easier to refute?', 'Ad hominem', 'Red herring', 'Straw man', 'Appeal to authority', 'C', 'A straw man fallacy distorts or oversimplifies an opponent''s actual argument, creating a weaker version that is easier to attack.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'Which logical fallacy involves misrepresenting someone''s argument to make it easier to refute?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'medium', 'What is the term for a puzzle or scenario requiring logical deduction to determine an unknown outcome from given clues?', 'A paradox', 'A riddle (a related but distinct form)', 'A logic puzzle', 'An enigma (a related but distinct form)', 'C', 'A logic puzzle requires the solver to use deductive reasoning and given clues to determine an unknown fact or outcome.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'What is the term for a puzzle or scenario requiring logical deduction to determine an unknown outcome from given clues?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'medium', 'Which term describes an argument in which the conclusion necessarily follows from true premises?', 'A sound argument (requires both validity and true premises)', 'A fallacious argument', 'An invalid argument', 'A valid argument', 'D', 'A valid argument is one where the conclusion logically follows from the premises, regardless of whether the premises themselves are actually true.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'Which term describes an argument in which the conclusion necessarily follows from true premises?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'medium', 'What is the term for reasoning that draws an inference to the most plausible explanation for an observation?', 'Abductive reasoning', 'Deductive reasoning', 'Inductive reasoning', 'Circular reasoning', 'A', 'Abductive reasoning seeks the most likely or plausible explanation to account for a given set of observations.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'What is the term for reasoning that draws an inference to the most plausible explanation for an observation?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'medium', 'Which cognitive bias describes the tendency to overestimate the likelihood of events that are more memorable or recent?', 'Confirmation bias', 'Availability heuristic', 'Anchoring bias', 'Hindsight bias', 'B', 'The availability heuristic describes the tendency to judge the likelihood of an event based on how easily examples come to mind, often skewed toward recent or memorable events.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'Which cognitive bias describes the tendency to overestimate the likelihood of events that are more memorable or recent?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'medium', 'What is the term for a logical fallacy that assumes a claim is true simply because it has not been proven false?', 'False cause', 'Appeal to ignorance', 'Hasty generalization', 'Slippery slope', 'B', 'The appeal to ignorance fallacy assumes a claim must be true simply because it has not been disproven, or false because it hasn''t been proven.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'What is the term for a logical fallacy that assumes a claim is true simply because it has not been proven false?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'medium', 'Which term describes the logical process of testing a hypothesis against evidence to determine its validity?', 'The scientific method (hypothesis testing)', 'Deductive proof', 'Circular verification', 'Empirical assumption', 'A', 'The scientific method involves systematically testing a hypothesis against gathered evidence to determine whether it holds true.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'Which term describes the logical process of testing a hypothesis against evidence to determine its validity?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'medium', 'What is the term for a fallacy in which someone argues that a claim must be true because many people believe it?', 'Bandwagon fallacy (appeal to popularity)', 'Appeal to authority', 'False cause', 'Straw man', 'A', 'The bandwagon fallacy, or appeal to popularity, incorrectly argues that a claim is true simply because many people believe or accept it.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'What is the term for a fallacy in which someone argues that a claim must be true because many people believe it?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'medium', 'Which logical argument form states: if P then Q; P is true; therefore Q must be true?', 'Modus ponens', 'Modus tollens', 'Disjunctive syllogism', 'Hypothetical syllogism', 'A', 'Modus ponens is a valid deductive argument form: if P implies Q, and P is true, then Q must logically follow as true.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'Which logical argument form states: if P then Q; P is true; therefore Q must be true?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'medium', 'What is the term for a logical fallacy that assumes a small first step will inevitably lead to a chain of increasingly negative events?', 'False dilemma', 'Straw man', 'Hasty generalization', 'Slippery slope', 'D', 'The slippery slope fallacy assumes, without sufficient justification, that a small first step will inevitably lead to a chain of significant negative consequences.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'What is the term for a logical fallacy that assumes a small first step will inevitably lead to a chain of increasingly negative events?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'medium', 'What is the value of pi, rounded to two decimal places, representing the ratio of a circle''s circumference to its diameter?', '3.41', '3.14', '3.12', '3.24', 'B', 'Pi, the ratio of a circle''s circumference to its diameter, is approximately 3.14 when rounded to two decimal places.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'What is the value of pi, rounded to two decimal places, representing the ratio of a circle''s circumference to its diameter?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'medium', 'Which basic arithmetic operation is represented by the multiplication symbol (× or *)?', 'Multiplication', 'Division', 'Addition', 'Subtraction', 'A', 'The multiplication symbol represents the arithmetic operation of repeated addition, combining quantities to find their product.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'Which basic arithmetic operation is represented by the multiplication symbol (× or *)?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'medium', 'What is the term for a number that is the result of multiplying a number by itself?', 'A cube number', 'A prime number', 'A square number', 'A composite number', 'C', 'A square number is the result of multiplying an integer by itself, such as 4 (2×2) or 9 (3×3).'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'What is the term for a number that is the result of multiplying a number by itself?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'medium', 'Which geometric shape has exactly four equal sides and four right angles?', 'A square', 'A rectangle', 'A rhombus', 'A trapezoid', 'A', 'A square is a quadrilateral with four equal sides and four right angles, making it a special case of both a rectangle and a rhombus.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'Which geometric shape has exactly four equal sides and four right angles?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'medium', 'What is the term for the longest side of a right triangle, opposite the right angle?', 'The hypotenuse', 'The adjacent side', 'The opposite side', 'The base', 'A', 'The hypotenuse is the longest side of a right triangle, always located opposite the triangle''s right angle.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'What is the term for the longest side of a right triangle, opposite the right angle?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'medium', 'Which mathematical operation finds the total when two or more numbers are combined?', 'Addition', 'Subtraction', 'Multiplication', 'Division', 'A', 'Addition is the arithmetic operation that combines two or more numbers to find their total sum.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'Which mathematical operation finds the total when two or more numbers are combined?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'medium', 'What is the term for a fraction where the numerator is larger than the denominator?', 'A proper fraction', 'An improper fraction', 'A mixed number', 'A unit fraction', 'B', 'An improper fraction has a numerator larger than or equal to its denominator, representing a value equal to or greater than one whole.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'What is the term for a fraction where the numerator is larger than the denominator?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'medium', 'Which number is considered neither prime nor composite, serving as the multiplicative identity?', '0 (zero)', '2 (two)', '-1 (negative one)', '1 (one)', 'D', 'The number 1 is unique in that it is classified as neither prime nor composite, and serves as the multiplicative identity in arithmetic.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'Which number is considered neither prime nor composite, serving as the multiplicative identity?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'medium', 'What is the term for the result obtained when dividing one number by another?', 'The quotient', 'The dividend', 'The divisor', 'The remainder', 'A', 'The quotient is the result obtained from dividing one number, the dividend, by another number, the divisor.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'What is the term for the result obtained when dividing one number by another?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'medium', 'Which type of angle measures exactly 90 degrees?', 'An acute angle', 'An obtuse angle', 'A straight angle', 'A right angle', 'D', 'A right angle measures exactly 90 degrees, commonly seen at the corners of squares and rectangles.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'Which type of angle measures exactly 90 degrees?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'medium', 'What is the term for the average of a set of numbers, calculated by summing all values and dividing by the count?', 'The median', 'The mean', 'The mode', 'The range', 'B', 'The mean, or average, is calculated by summing all values in a data set and dividing by the total number of values.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'What is the term for the average of a set of numbers, calculated by summing all values and dividing by the count?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'medium', 'Which shape is defined as a three-sided polygon with three angles that sum to 180 degrees?', 'A quadrilateral', 'A pentagon', 'A triangle', 'A hexagon', 'C', 'A triangle is a three-sided polygon whose interior angles always sum to exactly 180 degrees.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'Which shape is defined as a three-sided polygon with three angles that sum to 180 degrees?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'medium', 'What is the term for a number multiplied by itself twice, such as 2 to the power of 3?', 'A square (or squared number)', 'A root', 'A cube (or cubed number)', 'A factor', 'C', 'A cubed number results from multiplying a number by itself twice, or raising it to the power of 3, such as 2³ = 8.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'What is the term for a number multiplied by itself twice, such as 2 to the power of 3?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'medium', 'Which term describes numbers that can be evenly divided by 2 without leaving a remainder?', 'Odd numbers', 'Prime numbers', 'Composite numbers', 'Even numbers', 'D', 'Even numbers are integers that can be divided evenly by 2, leaving no remainder, such as 2, 4, 6, and 8.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'Which term describes numbers that can be evenly divided by 2 without leaving a remainder?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'medium', 'What is the term for the point where two lines or line segments meet, forming an angle?', 'A midpoint', 'An intercept', 'A vertex', 'An axis', 'C', 'A vertex is the point where two lines, rays, or line segments meet to form an angle.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'What is the term for the point where two lines or line segments meet, forming an angle?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'medium', 'Which measurement unit is commonly used to express the area of a two-dimensional shape?', 'Cubic units', 'Square units (such as square meters)', 'Linear units', 'Angular units', 'B', 'Area is measured in square units, such as square meters or square feet, reflecting the two-dimensional space a shape covers.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'Which measurement unit is commonly used to express the area of a two-dimensional shape?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'medium', 'What is the term for a number''s distance from zero on a number line, always expressed as a non-negative value?', 'Reciprocal', 'Exponent', 'Coefficient', 'Absolute value', 'D', 'The absolute value of a number represents its distance from zero on a number line, always expressed as a non-negative value.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'What is the term for a number''s distance from zero on a number line, always expressed as a non-negative value?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'medium', 'Which 1997 film, directed by James Cameron, became one of the highest-grossing films of all time, centered on a doomed ocean liner?', 'Titanic', 'Avatar', 'The Terminator', 'Aliens', 'A', '''Titanic'' (1997), directed by James Cameron, became one of the highest-grossing films in history, depicting the tragic sinking of the RMS Titanic.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'Which 1997 film, directed by James Cameron, became one of the highest-grossing films of all time, centered on a doomed ocean liner?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'medium', 'What is the name of the fictional wizarding school attended by Harry Potter in the popular book and film series?', 'Hogwarts', 'Beauxbatons', 'Durmstrang', 'Ilvermorny', 'A', 'Hogwarts School of Witchcraft and Wizardry is the fictional institution central to the Harry Potter book and film series.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'What is the name of the fictional wizarding school attended by Harry Potter in the popular book and film series?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'medium', 'Which animated Disney film tells the story of a young lion prince who must reclaim his kingdom from his uncle Scar?', 'Aladdin', 'Beauty and the Beast', 'Tarzan', 'The Lion King', 'D', '''The Lion King'' follows Simba, a young lion prince, as he journeys to reclaim his rightful place as king from his uncle Scar.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'Which animated Disney film tells the story of a young lion prince who must reclaim his kingdom from his uncle Scar?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'medium', 'What is the name of the long-running animated television series set in the fictional town of Springfield?', 'The Simpsons', 'Family Guy', 'South Park', 'King of the Hill', 'A', '''The Simpsons,'' set in the fictional town of Springfield, is one of the longest-running animated television series in history.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'What is the name of the long-running animated television series set in the fictional town of Springfield?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'medium', 'Which 2009 film, directed by James Cameron, became the highest-grossing film of all time upon its release, set on the moon Pandora?', 'Titanic', 'Avatar', 'The Avengers', 'Star Wars: The Force Awakens', 'B', '''Avatar'' (2009), directed by James Cameron and set on the fictional moon Pandora, became the highest-grossing film of all time upon release.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'Which 2009 film, directed by James Cameron, became the highest-grossing film of all time upon its release, set on the moon Pandora?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'medium', 'What is the name of the fictional superhero team featured in Marvel films, including characters like Iron Man, Captain America, and Thor?', 'The Justice League', 'The X-Men', 'The Avengers', 'The Fantastic Four', 'C', 'The Avengers is Marvel''s flagship superhero team, featuring characters including Iron Man, Captain America, and Thor across numerous films.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'What is the name of the fictional superhero team featured in Marvel films, including characters like Iron Man, Captain America, and Thor?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'medium', 'Which popular animated film series follows a green ogre and his friends on various adventures?', 'Madagascar', 'Ice Age', 'Kung Fu Panda', 'Shrek', 'D', 'The Shrek film series follows the adventures of a grumpy but good-hearted green ogre and his colorful group of friends.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'Which popular animated film series follows a green ogre and his friends on various adventures?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'medium', 'What is the name of the popular streaming series depicting a group of kids in a small town facing supernatural events?', 'The Umbrella Academy', 'Stranger Things', 'Locke & Key', 'Chilling Adventures of Sabrina', 'B', '''Stranger Things,'' set in the fictional town of Hawkins, follows a group of kids confronting supernatural events and government conspiracies.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'What is the name of the popular streaming series depicting a group of kids in a small town facing supernatural events?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'medium', 'Which classic film trilogy follows Luke Skywalker''s journey to become a Jedi Knight, set in a galaxy far, far away?', 'The Lord of the Rings', 'Indiana Jones', 'Star Wars (original trilogy)', 'Back to the Future', 'C', 'The original Star Wars trilogy follows Luke Skywalker''s journey to become a Jedi Knight amid a galactic conflict against the Empire.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'Which classic film trilogy follows Luke Skywalker''s journey to become a Jedi Knight, set in a galaxy far, far away?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'medium', 'What is the name of the popular animated film about a group of talking cars living in a small desert town?', 'Turbo', 'Wreck-It Ralph', 'Planes', 'Cars', 'D', 'Pixar''s ''Cars'' follows a hotshot race car who learns valuable life lessons after becoming stranded in a small desert town.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'What is the name of the popular animated film about a group of talking cars living in a small desert town?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'medium', 'Which television series follows the personal and professional lives of doctors working at a fictional Seattle hospital?', 'ER', 'House', 'Chicago Med', 'Grey''s Anatomy', 'D', '''Grey''s Anatomy'' follows the personal and professional lives of surgeons at the fictional Grey Sloan Memorial Hospital in Seattle.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'Which television series follows the personal and professional lives of doctors working at a fictional Seattle hospital?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'medium', 'What is the name of the popular animated film about a fish named Nemo who gets separated from his father?', 'The Little Mermaid', 'Finding Nemo', 'Shark Tale', 'Moana', 'B', 'Pixar''s ''Finding Nemo'' follows a clownfish father''s journey to find his son Nemo after the young fish is separated from him.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'What is the name of the popular animated film about a fish named Nemo who gets separated from his father?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'medium', 'Which long-running crime drama television series follows detectives investigating cases in New York City?', 'CSI', 'NCIS', 'Law & Order', 'Criminal Minds', 'C', '''Law & Order'' is a long-running television franchise following police investigations and prosecutions of crimes in New York City.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'Which long-running crime drama television series follows detectives investigating cases in New York City?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'medium', 'What is the name of the popular Disney Pixar film about emotions personified inside the mind of a young girl?', 'Soul', 'Inside Out', 'Coco', 'Luca', 'B', '''Inside Out'' personifies emotions like Joy, Sadness, and Anger as characters living inside the mind of a young girl named Riley.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'What is the name of the popular Disney Pixar film about emotions personified inside the mind of a young girl?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'medium', 'Which television series, based on a series of fantasy novels, follows political intrigue among noble families in a fictional realm?', 'Game of Thrones', 'The Witcher', 'Vikings', 'The Last Kingdom', 'A', '''Game of Thrones,'' based on George R.R. Martin''s novels, follows the political intrigue and power struggles among noble families in the fictional Seven Kingdoms.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'Which television series, based on a series of fantasy novels, follows political intrigue among noble families in a fictional realm?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'medium', 'Which television series follows the character Michael Scott and his employees at a paper company branch office?', 'Parks and Recreation', '30 Rock', 'The Office', 'Brooklyn Nine-Nine', 'C', '"The Office" is a mockumentary-style sitcom following the daily lives of employees at the Scranton branch of a paper company.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'Which television series follows the character Michael Scott and his employees at a paper company branch office?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'medium', 'Which musical instrument has 88 keys and is played by pressing keys to produce sound?', 'Violin', 'Piano', 'Guitar', 'Trumpet', 'B', 'The piano typically has 88 keys, played by pressing them to strike internal strings and produce sound.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'Which musical instrument has 88 keys and is played by pressing keys to produce sound?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'medium', 'What is the term for a group of singers performing together, typically in multiple vocal parts?', 'An orchestra', 'A band', 'An ensemble (a broader, related term)', 'A choir', 'D', 'A choir is a group of singers who perform together, typically singing in multiple harmonizing vocal parts.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'What is the term for a group of singers performing together, typically in multiple vocal parts?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'medium', 'Which genre of Filipino traditional love songs is known for its slow, romantic melodies from the early 20th century?', 'Harana (the serenading practice, related but distinct)', 'Balitaw', 'Kundiman', 'Rondalla music', 'C', 'Kundiman is a genre of traditional Filipino love songs characterized by slow, romantic, and often melancholic melodies.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'Which genre of Filipino traditional love songs is known for its slow, romantic melodies from the early 20th century?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'medium', 'What is the term for a musical instrument played by blowing air across or into it, such as a flute or trumpet?', 'A wind instrument', 'A string instrument', 'A percussion instrument', 'A keyboard instrument', 'A', 'Wind instruments produce sound through the vibration of air, either blown across an opening or through a reed or mouthpiece.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'What is the term for a musical instrument played by blowing air across or into it, such as a flute or trumpet?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'medium', 'Which musical genre, originating among African-American communities, is characterized by blue notes, syncopation, and improvisation?', 'Blues (a closely related but distinct genre)', 'Gospel', 'Jazz', 'Ragtime (a related precursor genre)', 'C', 'Jazz, originating in African-American communities in the early 20th century, is characterized by improvisation, syncopation, and expressive blue notes.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'Which musical genre, originating among African-American communities, is characterized by blue notes, syncopation, and improvisation?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'medium', 'What is the term for the speed or pace at which a piece of music is played?', 'Tempo', 'Rhythm', 'Melody', 'Harmony', 'A', 'Tempo refers to the speed or pace at which a musical piece is performed, often indicated in beats per minute.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'What is the term for the speed or pace at which a piece of music is played?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'medium', 'Which musical instrument, featuring strings and a bow, is the smallest and highest-pitched member of its family?', 'Viola', 'Violin', 'Cello', 'Double bass', 'B', 'The violin is the smallest and highest-pitched instrument in the string family, commonly featured as a solo and orchestral instrument.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'Which musical instrument, featuring strings and a bow, is the smallest and highest-pitched member of its family?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'medium', 'What is the term for a musical composition written for a large ensemble of instruments, typically in multiple movements?', 'A concerto', 'A sonata', 'A symphony', 'A suite', 'C', 'A symphony is an extended musical composition typically written for a full orchestra, usually structured in several distinct movements.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'What is the term for a musical composition written for a large ensemble of instruments, typically in multiple movements?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'medium', 'Which musical instrument, popular in Hawaiian and folk music, is a small, four-stringed instrument resembling a small guitar?', 'Mandolin', 'Ukulele', 'Banjo', 'Bandurria', 'B', 'The ukulele is a small, four-stringed instrument closely associated with Hawaiian music, though it is used across many musical traditions.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'Which musical instrument, popular in Hawaiian and folk music, is a small, four-stringed instrument resembling a small guitar?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'medium', 'What is the term for the combination of musical notes played or sung simultaneously to create a pleasing sound?', 'Melody', 'Rhythm', 'Harmony', 'Tempo', 'C', 'Harmony refers to the combination of different musical notes played or sung together, creating chords and a fuller musical texture.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'What is the term for the combination of musical notes played or sung simultaneously to create a pleasing sound?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'medium', 'Which musical genre, characterized by a strong beat and often social commentary, emerged from New York City in the 1970s?', 'Disco', 'Hip hop', 'Punk rock', 'Funk', 'B', 'Hip hop emerged from New York City in the 1970s, characterized by rhythmic beats, rapping, and often socially conscious lyrics.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'Which musical genre, characterized by a strong beat and often social commentary, emerged from New York City in the 1970s?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'medium', 'What is the term for a musical scale consisting of eight notes, returning to the starting note an octave higher?', 'A pentatonic scale', 'A chromatic scale', 'A diatonic scale', 'An octave scale', 'D', 'An octave scale spans eight notes, beginning and ending on the same note name, with the final note pitched an octave higher.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'What is the term for a musical scale consisting of eight notes, returning to the starting note an octave higher?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'medium', 'Which percussion instrument, consisting of tuned metal bars struck with mallets, is commonly used in orchestras and bands?', 'Xylophone', 'Timpani', 'Snare drum', 'Triangle', 'A', 'The xylophone consists of tuned wooden or metal bars struck with mallets to produce distinct musical pitches.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'Which percussion instrument, consisting of tuned metal bars struck with mallets, is commonly used in orchestras and bands?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'medium', 'What is the term for the written or printed representation of musical sounds using symbols on a staff?', 'Sheet music (musical notation)', 'A libretto', 'A score (a related, often orchestral-specific term)', 'A tablature (a related but distinct system)', 'A', 'Sheet music, or musical notation, is the written representation of musical sounds using symbols placed on a staff.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'What is the term for the written or printed representation of musical sounds using symbols on a staff?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'medium', 'Which classical music composer, deaf later in life, composed famous works including the Fifth Symphony and ''Moonlight Sonata''?', 'Wolfgang Amadeus Mozart', 'Johann Sebastian Bach', 'Franz Schubert', 'Ludwig van Beethoven', 'D', 'Ludwig van Beethoven, who became increasingly deaf later in life, composed enduring masterworks including his Fifth Symphony and ''Moonlight Sonata.'''
where not exists (
  select 1 from questions where category = 'music' and prompt = 'Which classical music composer, deaf later in life, composed famous works including the Fifth Symphony and ''Moonlight Sonata''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'medium', 'Which orchestral percussion instrument consists of large, tunable copper bowls played with mallets?', 'Xylophone', 'Snare drum', 'Cymbals', 'Timpani', 'D', 'Timpani, also called kettledrums, are large copper bowls with adjustable pitch, played with mallets and commonly featured in orchestras.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'Which orchestral percussion instrument consists of large, tunable copper bowls played with mallets?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'medium', 'Which shapeshifting Filipino creature is known for its ability to transform into various animals, most commonly a large dog or bird?', 'Tikbalang', 'Aswang', 'Kapre', 'Duwende', 'B', 'The aswang is a shapeshifting creature in Filipino folklore, often able to transform into animals like dogs, birds, or pigs.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'Which shapeshifting Filipino creature is known for its ability to transform into various animals, most commonly a large dog or bird?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'medium', 'What is the term for the small, dwarf-like creatures in Filipino folklore said to live in trees, anthills, or under the ground?', 'Diwata', 'Duwende', 'Engkanto', 'Kapre', 'B', 'Duwende are small, dwarf-like creatures in Filipino folklore believed to inhabit anthills, gardens, or hidden places around homes.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'What is the term for the small, dwarf-like creatures in Filipino folklore said to live in trees, anthills, or under the ground?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'medium', 'Which mythical Filipino creature is depicted as a tall, dark, tree-dwelling giant who smokes tobacco?', 'Tikbalang', 'Sigbin', 'Amomongo', 'Kapre', 'D', 'The kapre is depicted in Filipino folklore as a tall, dark-skinned giant who lives in large trees and is often seen smoking a large tobacco pipe.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'Which mythical Filipino creature is depicted as a tall, dark, tree-dwelling giant who smokes tobacco?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'medium', 'What is the name of the Greek god of the sea, often depicted holding a trident?', 'Zeus', 'Hades', 'Poseidon', 'Apollo', 'C', 'Poseidon, the Greek god of the sea, is traditionally depicted holding a trident and ruling over the waters and earthquakes.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'What is the name of the Greek god of the sea, often depicted holding a trident?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'medium', 'Which mythical creature, common in European folklore, is a winged horse said to have sprung from Medusa''s blood in Greek mythology?', 'Unicorn', 'Griffin', 'Pegasus', 'Centaur', 'C', 'Pegasus is a winged horse in Greek mythology, said to have sprung from the blood of the slain gorgon Medusa.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'Which mythical creature, common in European folklore, is a winged horse said to have sprung from Medusa''s blood in Greek mythology?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'medium', 'What is the name of the supreme deity in pre-colonial Tagalog mythology, believed to have created the world?', 'Bathala', 'Bulan', 'Amanikable', 'Mayari', 'A', 'Bathala was the supreme deity in pre-colonial Tagalog mythology, believed to reside in the sky and oversee the creation of the world.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'What is the name of the supreme deity in pre-colonial Tagalog mythology, believed to have created the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'medium', 'Which Norse mythological figure is the god of thunder, wielding a powerful hammer named Mjolnir?', 'Odin', 'Loki', 'Baldur', 'Thor', 'D', 'Thor is the Norse god of thunder, famously associated with his powerful hammer Mjolnir.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'Which Norse mythological figure is the god of thunder, wielding a powerful hammer named Mjolnir?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'medium', 'What is the name of the mythical Filipino creature with the head and legs of a horse and the body of a man, said to mislead travelers?', 'Kapre', 'Sigbin', 'Tikbalang', 'Amomongo', 'C', 'The tikbalang is a Filipino mythological creature with a horse''s head and legs, said to lead travelers astray in forests.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'What is the name of the mythical Filipino creature with the head and legs of a horse and the body of a man, said to mislead travelers?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'medium', 'Which Egyptian mythological figure is depicted with the head of a jackal and is associated with mummification and the afterlife?', 'Anubis', 'Osiris', 'Horus', 'Ra', 'A', 'Anubis, depicted with the head of a jackal, is the ancient Egyptian god associated with mummification and guiding souls to the afterlife.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'Which Egyptian mythological figure is depicted with the head of a jackal and is associated with mummification and the afterlife?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'medium', 'What is the term for the Filipino belief in mysterious nature spirits believed to inhabit specific trees, rocks, or other natural landmarks?', 'Engkanto', 'Duwende', 'Diwata', 'Multo', 'A', 'Engkanto refers to nature spirits in Filipino folklore, often depicted as beautiful beings inhabiting specific natural landmarks.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'What is the term for the Filipino belief in mysterious nature spirits believed to inhabit specific trees, rocks, or other natural landmarks?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'medium', 'Which mythical creature from Filipino folklore is a vampire-like being able to separate its upper torso and fly at night?', 'Tikbalang', 'Kapre', 'Sigbin', 'Manananggal', 'D', 'The manananggal is a vampire-like creature in Filipino folklore known for its ability to detach its upper torso and fly in search of victims.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'Which mythical creature from Filipino folklore is a vampire-like being able to separate its upper torso and fly at night?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'medium', 'What is the name of the Greek hero known for his twelve labors, including slaying the Nemean lion?', 'Achilles', 'Perseus', 'Theseus', 'Heracles (Hercules)', 'D', 'Heracles, known to the Romans as Hercules, is famous in Greek mythology for completing twelve extraordinarily difficult labors.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'What is the name of the Greek hero known for his twelve labors, including slaying the Nemean lion?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'medium', 'Which mythical creature, common in Filipino folklore, disguises itself as a crying infant to lure victims?', 'Duwende', 'Tiyanak', 'Nuno sa Punso', 'Engkanto', 'B', 'The tiyanak disguises itself as an abandoned crying baby to lure unsuspecting victims before revealing its true monstrous form.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'Which mythical creature, common in Filipino folklore, disguises itself as a crying infant to lure victims?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'medium', 'What is the name of the beautiful nature spirits or fairies in Filipino mythology, often depicted as guardians of forests and rivers?', 'Aswang', 'Manananggal', 'Diwata', 'Kapre', 'C', 'Diwata are nature spirits or deities in Filipino mythology, typically depicted as beautiful guardians of forests, rivers, and mountains.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'What is the name of the beautiful nature spirits or fairies in Filipino mythology, often depicted as guardians of forests and rivers?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'medium', 'Which Greek mythological figure is known for flying too close to the sun with wings made of feathers and wax?', 'Icarus', 'Prometheus', 'Sisyphus', 'Tantalus', 'A', 'Icarus, in Greek mythology, flew too close to the sun with wax-and-feather wings, causing them to melt and leading to his fall.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'Which Greek mythological figure is known for flying too close to the sun with wings made of feathers and wax?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'medium', 'Which Roman god of war is often associated with his Greek counterpart Ares?', 'Jupiter', 'Mars', 'Neptune', 'Vulcan', 'B', 'Mars is the Roman god of war, closely associated with the Greek god Ares, though Mars held a more prominent, revered role in Roman culture.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'Which Roman god of war is often associated with his Greek counterpart Ares?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'medium', 'Which Philippine bird species, the national bird, is one of the largest and most powerful eagles in the world?', 'Philippine Eagle-Owl', 'Rufous Hornbill', 'Palawan Peacock-Pheasant', 'Philippine Eagle', 'D', 'The Philippine Eagle is the national bird of the Philippines and one of the largest and most powerful eagles in the world.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'Which Philippine bird species, the national bird, is one of the largest and most powerful eagles in the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'medium', 'What is the name of the small, nocturnal primate native to the Philippines known for its very large eyes?', 'Philippine flying lemur', 'Palawan bearcat', 'Philippine tarsier', 'Philippine slow loris', 'C', 'The Philippine tarsier is a small, nocturnal primate found mainly in Bohol, well known for its disproportionately large eyes.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'What is the name of the small, nocturnal primate native to the Philippines known for its very large eyes?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'medium', 'Which large reptile species, found in Philippine waters, is the largest living reptile in the world?', 'Komodo dragon', 'Green sea turtle', 'Reticulated python', 'Saltwater crocodile', 'D', 'The saltwater crocodile, found in parts of Philippine waters, is the largest living reptile species in the world.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'Which large reptile species, found in Philippine waters, is the largest living reptile in the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'medium', 'What is the name of the coral reef marine protected area in the Sulu Sea, recognized for its extraordinary biodiversity?', 'Tubbataha Reefs Natural Park', 'Apo Reef Natural Park', 'El Nido Marine Reserve', 'Coron Bay', 'A', 'Tubbataha Reefs Natural Park is a UNESCO World Heritage marine protected area renowned for its rich coral reef biodiversity.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'What is the name of the coral reef marine protected area in the Sulu Sea, recognized for its extraordinary biodiversity?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'medium', 'Which large flying mammal, native to the Philippines, is among the largest bat species in the world?', 'Philippine tube-nosed bat', 'Giant golden-crowned flying fox', 'Common fruit bat', 'Philippine pygmy fruit bat', 'B', 'The giant golden-crowned flying fox, native to the Philippines, is among the largest bat species in the world by wingspan.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'Which large flying mammal, native to the Philippines, is among the largest bat species in the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'medium', 'What is the term for animals that are active mainly at night, sleeping during the day?', 'Diurnal', 'Nocturnal', 'Crepuscular', 'Cathemeral', 'B', 'Nocturnal animals are primarily active at night and rest during the day, an adaptation seen in many species to avoid predators or heat.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'What is the term for animals that are active mainly at night, sleeping during the day?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'medium', 'Which endangered Philippine mammal, sometimes called a ''warty pig,'' is native to the Visayan islands?', 'Philippine deer', 'Philippine mouse-deer', 'Visayan warty pig', 'Palawan bearcat', 'C', 'The Visayan warty pig is a critically endangered wild pig species native to the Visayan islands, threatened by habitat loss and hunting.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'Which endangered Philippine mammal, sometimes called a ''warty pig,'' is native to the Visayan islands?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'medium', 'What is the largest species of shark in the world, feeding primarily on plankton despite its immense size?', 'Great white shark', 'Whale shark', 'Tiger shark', 'Hammerhead shark', 'B', 'The whale shark, despite its enormous size, is a filter feeder that primarily consumes plankton rather than hunting larger prey.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'What is the largest species of shark in the world, feeding primarily on plankton despite its immense size?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'medium', 'Which term describes species that are not native to a particular ecosystem and can cause significant ecological harm?', 'Endemic species', 'Invasive species', 'Keystone species', 'Migratory species', 'B', 'Invasive species are organisms introduced to an ecosystem where they are not native, often causing significant ecological or economic harm.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'Which term describes species that are not native to a particular ecosystem and can cause significant ecological harm?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'medium', 'What is the name of the underground river system in Palawan, recognized as one of the New7Wonders of Nature?', 'Hinatuan Enchanted River', 'Loboc River', 'Pagsanjan Falls', 'Puerto Princesa Subterranean River', 'D', 'The Puerto Princesa Subterranean River in Palawan is a UNESCO World Heritage Site and one of the officially recognized New7Wonders of Nature.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'What is the name of the underground river system in Palawan, recognized as one of the New7Wonders of Nature?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'medium', 'Which animal is known for having the longest neck of any land mammal, native to the African savanna?', 'Giraffe', 'Elephant', 'Zebra', 'Rhinoceros', 'A', 'The giraffe has the longest neck of any land mammal, an adaptation allowing it to reach foliage high in trees on the African savanna.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'Which animal is known for having the longest neck of any land mammal, native to the African savanna?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'medium', 'What is the primary threat facing the Philippine eagle''s population, contributing to its critically endangered status?', 'Habitat loss due to deforestation', 'Overfishing', 'Ocean pollution', 'Climate-driven droughts', 'A', 'The Philippine eagle''s population is primarily threatened by extensive habitat loss caused by deforestation across its forest range.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'What is the primary threat facing the Philippine eagle''s population, contributing to its critically endangered status?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'medium', 'Which large marine mammal, known for its songs, is famous for undertaking one of the longest annual migrations of any mammal?', 'Blue whale', 'Sperm whale', 'Humpback whale', 'Orca', 'C', 'Humpback whales are known for their complex songs and undertake some of the longest annual migrations of any mammal species.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'Which large marine mammal, known for its songs, is famous for undertaking one of the longest annual migrations of any mammal?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'medium', 'What is the term for a species whose presence is critical to maintaining the structure of an entire ecological community?', 'An indicator species', 'An invasive species', 'A keystone species', 'An endemic species', 'C', 'A keystone species has a disproportionately large impact on its ecosystem relative to its abundance, and its removal can dramatically alter the habitat.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'What is the term for a species whose presence is critical to maintaining the structure of an entire ecological community?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'medium', 'Which endangered Philippine bird species, found only on Palawan, is known for the male''s colorful, iridescent feathers?', 'Palawan Peacock-Pheasant', 'Philippine Eagle', 'Rufous Hornbill', 'Mindanao Bleeding-heart', 'A', 'The Palawan Peacock-Pheasant, endemic to Palawan, is known for the male''s striking, iridescent plumage used in courtship displays.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'Which endangered Philippine bird species, found only on Palawan, is known for the male''s colorful, iridescent feathers?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'medium', 'Which large African mammal is known for its thick, armored skin and single or double horn, and is critically endangered due to poaching?', 'Hippopotamus', 'Elephant', 'Water buffalo', 'Rhinoceros', 'D', 'Rhinoceroses are known for their thick, armored skin and prominent horn, with several species critically endangered primarily due to poaching for their horns.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'Which large African mammal is known for its thick, armored skin and single or double horn, and is critically endangered due to poaching?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'medium', 'Which branch of the Philippine government is responsible for making and passing laws?', 'The Executive branch', 'The Legislative branch (Congress)', 'The Judicial branch', 'The Constitutional Commissions', 'B', 'The Legislative branch, composed of the Senate and House of Representatives, is primarily responsible for creating and passing laws in the Philippines.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'Which branch of the Philippine government is responsible for making and passing laws?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'medium', 'What is the term of office for members of the Philippine House of Representatives under the 1987 Constitution?', 'Three years', 'Four years', 'Six years', 'Two years', 'A', 'Members of the Philippine House of Representatives serve three-year terms, with the possibility of reelection for up to three consecutive terms.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'What is the term of office for members of the Philippine House of Representatives under the 1987 Constitution?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'medium', 'Which Philippine government official serves as the head of state and head of government simultaneously?', 'The Vice President', 'The President', 'The Senate President', 'The Speaker of the House', 'B', 'The President of the Philippines serves as both the head of state and head of government under the country''s presidential system.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'Which Philippine government official serves as the head of state and head of government simultaneously?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'medium', 'What is the name of the basic political unit in the Philippines, smaller than a municipality or city?', 'The province', 'The region', 'The barangay', 'The district', 'C', 'The barangay is the smallest local government unit in the Philippines, serving as the basic level of local governance.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'What is the name of the basic political unit in the Philippines, smaller than a municipality or city?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'medium', 'Which body of the Philippine government is responsible for administering and enforcing election laws?', 'The Commission on Audit', 'The Civil Service Commission', 'The Department of Justice', 'The Commission on Elections (COMELEC)', 'D', 'The Commission on Elections (COMELEC) administers and enforces laws governing national and local elections in the Philippines.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'Which body of the Philippine government is responsible for administering and enforcing election laws?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'medium', 'What is the minimum voting age for Philippine citizens to participate in national elections?', '21 years old', '16 years old', '18 years old', '20 years old', 'C', 'Filipino citizens must be at least 18 years old to be eligible to vote in national and local elections.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'What is the minimum voting age for Philippine citizens to participate in national elections?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'medium', 'Which house of the Philippine Congress represents specific legislative districts across the country?', 'The Senate', 'The Sangguniang Panlalawigan', 'The House of Representatives', 'The Sangguniang Bayan', 'C', 'The House of Representatives is composed of members elected to represent specific legislative districts throughout the Philippines.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'Which house of the Philippine Congress represents specific legislative districts across the country?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'medium', 'What is the term for the highest court in the Philippine judicial system, with final authority over legal disputes?', 'The Court of Appeals', 'The Sandiganbayan', 'The Regional Trial Court', 'The Supreme Court', 'D', 'The Supreme Court is the highest judicial body in the Philippines, with final authority over legal disputes and constitutional matters.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'What is the term for the highest court in the Philippine judicial system, with final authority over legal disputes?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'medium', 'Which government agency in the Philippines is responsible for collecting national taxes?', 'Bureau of Customs', 'Department of Finance (the overseeing department, not the collecting agency)', 'Commission on Audit', 'Bureau of Internal Revenue (BIR)', 'D', 'The Bureau of Internal Revenue (BIR) is the primary government agency responsible for assessing and collecting national internal revenue taxes.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'Which government agency in the Philippines is responsible for collecting national taxes?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'medium', 'What is the term for the head of a Philippine province, elected to oversee its local government?', 'Mayor', 'Governor', 'Barangay Captain', 'Congressman', 'B', 'The governor is the elected official who heads the provincial government, overseeing administration and local policy at the provincial level.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'What is the term for the head of a Philippine province, elected to oversee its local government?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'medium', 'Which term refers to the head of a Philippine city or municipality''s local government?', 'Mayor', 'Governor', 'Vice Mayor', 'Barangay Captain', 'A', 'The mayor is the elected official who heads the local government of a Philippine city or municipality.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'Which term refers to the head of a Philippine city or municipality''s local government?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'medium', 'What is the term for the elected leader of a barangay, the Philippines'' smallest local government unit?', 'Barangay Councilor', 'Sangguniang Kabataan Chairman', 'Barangay Captain (Punong Barangay)', 'Barangay Secretary', 'C', 'The Barangay Captain, also called Punong Barangay, is the elected head of a barangay, the country''s smallest local government unit.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'What is the term for the elected leader of a barangay, the Philippines'' smallest local government unit?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'medium', 'Which document serves as the supreme law of the Philippines, establishing its government structure and fundamental rights?', 'The 1987 Constitution', 'The Local Government Code', 'The Civil Code', 'The Revised Penal Code', 'A', 'The 1987 Constitution is the supreme law of the Philippines, establishing the structure of government and enshrining fundamental rights.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'Which document serves as the supreme law of the Philippines, establishing its government structure and fundamental rights?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'medium', 'What is the term for the process by which citizens directly vote on a proposed law or constitutional amendment?', 'An impeachment', 'A plebiscite', 'A special election', 'A recall election', 'B', 'A plebiscite is a direct vote by citizens on a proposed law or constitutional amendment submitted for their approval.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'What is the term for the process by which citizens directly vote on a proposed law or constitutional amendment?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'medium', 'Which independent Philippine constitutional body audits the accounts and expenditures of all government agencies?', 'Commission on Audit (COA)', 'Commission on Elections (COMELEC)', 'Civil Service Commission (CSC)', 'Office of the Ombudsman', 'A', 'The Commission on Audit (COA) is the constitutional body responsible for examining and auditing the accounts of all Philippine government agencies.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'Which independent Philippine constitutional body audits the accounts and expenditures of all government agencies?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'medium', 'Which province is home to the historic city of Vigan, known for its well-preserved Spanish colonial architecture?', 'Ilocos Norte', 'Ilocos Sur', 'La Union', 'Pangasinan', 'B', 'Vigan, a UNESCO World Heritage Site celebrated for its Spanish colonial architecture, is located in Ilocos Sur province.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'Which province is home to the historic city of Vigan, known for its well-preserved Spanish colonial architecture?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'medium', 'What is the capital city of the Philippines, serving as the seat of the national government?', 'Manila', 'Quezon City', 'Makati', 'Pasig', 'A', 'Manila is the official capital of the Philippines, though Metro Manila as a whole includes several other highly urbanized cities.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'What is the capital city of the Philippines, serving as the seat of the national government?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'medium', 'Which province is home to Mount Mayon, famous for its symmetrical volcanic cone?', 'Camarines Sur', 'Albay', 'Sorsogon', 'Catanduanes', 'B', 'Mount Mayon, renowned for its nearly perfect cone shape, is located in Albay province in the Bicol Region.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'Which province is home to Mount Mayon, famous for its symmetrical volcanic cone?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'medium', 'What is the largest city in the Philippines by population, part of Metro Manila?', 'Manila', 'Caloocan', 'Quezon City', 'Davao City', 'C', 'Quezon City is the most populous city in the Philippines, forming a major part of Metro Manila.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'What is the largest city in the Philippines by population, part of Metro Manila?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'medium', 'Which province in Mindanao is known as the country''s top producer of durian and other tropical fruits?', 'Davao del Norte (or the broader Davao Region)', 'Bukidnon', 'Cotabato', 'Zamboanga del Sur', 'A', 'The Davao Region, particularly Davao del Norte, is well known as a major producer of durian and other tropical fruits.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'Which province in Mindanao is known as the country''s top producer of durian and other tropical fruits?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'medium', 'What is the capital of Cebu province, recognized as the oldest city in the Philippines?', 'Mandaue City', 'Lapu-Lapu City', 'Talisay City', 'Cebu City', 'D', 'Cebu City, founded in 1565, is recognized as the oldest city in the Philippines and serves as the capital of Cebu province.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'What is the capital of Cebu province, recognized as the oldest city in the Philippines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'medium', 'Which province is home to the Chocolate Hills, a famous geological rock formation?', 'Cebu', 'Negros Oriental', 'Bohol', 'Siquijor', 'C', 'The Chocolate Hills, a distinctive karst rock formation, are located in Bohol province in the Visayas.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'Which province is home to the Chocolate Hills, a famous geological rock formation?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'medium', 'What is the name of the smallest province in the Philippines, both in land area and population?', 'Camiguin', 'Siquijor', 'Batanes', 'Guimaras', 'C', 'Batanes, located at the northernmost tip of the Philippines, is the country''s smallest province in both land area and population.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'What is the name of the smallest province in the Philippines, both in land area and population?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'medium', 'Which city in Mindanao is the largest by land area in the Philippines?', 'General Santos City', 'Zamboanga City', 'Davao City', 'Cagayan de Oro City', 'C', 'Davao City is the largest city in the Philippines by land area, encompassing a wide expanse of urban and rural territory.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'Which city in Mindanao is the largest by land area in the Philippines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'medium', 'What is the capital of Iloilo province, known for its heritage sites and culinary traditions?', 'Iloilo City', 'Passi City', 'Oton', 'Jaro', 'A', 'Iloilo City is the capital of Iloilo province, known for its Spanish-era heritage architecture and rich culinary traditions.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'What is the capital of Iloilo province, known for its heritage sites and culinary traditions?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'medium', 'Which province is famous for the Hundred Islands National Park, a popular tourist destination?', 'Zambales', 'La Union', 'Bataan', 'Pangasinan', 'D', 'Pangasinan is home to the Hundred Islands National Park, a scenic marine park comprising over a hundred small islands.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'Which province is famous for the Hundred Islands National Park, a popular tourist destination?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'medium', 'What is the capital city of Negros Occidental, historically known as the ''Sugarbowl of the Philippines''?', 'Silay City', 'Talisay City', 'Bago City', 'Bacolod City', 'D', 'Bacolod City, capital of Negros Occidental, is historically associated with the province''s dominant sugarcane industry.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'What is the capital city of Negros Occidental, historically known as the ''Sugarbowl of the Philippines''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'medium', 'Which region of the Philippines is composed mainly of Metro Manila and is the smallest region by land area?', 'National Capital Region (NCR)', 'CALABARZON', 'Central Luzon', 'MIMAROPA', 'A', 'The National Capital Region (NCR), encompassing Metro Manila, is the smallest region in the Philippines by land area.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'Which region of the Philippines is composed mainly of Metro Manila and is the smallest region by land area?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'medium', 'What is the capital of Pampanga province, often referred to as the ''Culinary Capital of the Philippines''?', 'Angeles City', 'San Fernando', 'Mabalacat', 'Guagua', 'B', 'San Fernando is the capital of Pampanga, a province widely recognized as the culinary capital of the Philippines.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'What is the capital of Pampanga province, often referred to as the ''Culinary Capital of the Philippines''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'medium', 'Which island province is home to the Puerto Princesa Subterranean River National Park?', 'Occidental Mindoro', 'Palawan', 'Romblon', 'Antique', 'B', 'The Puerto Princesa Subterranean River National Park is located in Palawan, on the island''s western coast.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'Which island province is home to the Puerto Princesa Subterranean River National Park?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'medium', 'Which religious tradition, predominant in the Philippines, was introduced by Spanish colonizers beginning in the 16th century?', 'Roman Catholicism', 'Islam', 'Buddhism', 'Protestantism', 'A', 'Roman Catholicism was introduced by Spanish colonizers in the 16th century and remains the dominant religion in the Philippines today.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'Which religious tradition, predominant in the Philippines, was introduced by Spanish colonizers beginning in the 16th century?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'medium', 'What is the name of the nine-day series of dawn masses observed in the Philippines before Christmas Day?', 'Flores de Mayo', 'Panunuluyan', 'Salubong', 'Simbang Gabi', 'D', 'Simbang Gabi is a cherished Filipino Catholic tradition of attending nine consecutive dawn masses in the days leading up to Christmas.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'What is the name of the nine-day series of dawn masses observed in the Philippines before Christmas Day?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'medium', 'Which Filipino Catholic tradition involves visiting seven churches, commonly practiced during Holy Week?', 'Pabasa', 'Senakulo', 'Visita Iglesia', 'Panata', 'C', 'Visita Iglesia is the tradition of visiting seven churches, typically observed on Maundy Thursday during Holy Week.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'Which Filipino Catholic tradition involves visiting seven churches, commonly practiced during Holy Week?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'medium', 'What is the name of the traditional Filipino star-shaped lantern used as a Christmas decoration?', 'Parol', 'Belen', 'Farol', 'Lucero', 'A', 'The parol is a traditional Filipino star-shaped lantern symbolizing the Star of Bethlehem, widely used as a Christmas decoration.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'What is the name of the traditional Filipino star-shaped lantern used as a Christmas decoration?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'medium', 'Which major world religion is predominant in the southern Philippines, particularly in parts of Mindanao?', 'Islam', 'Buddhism', 'Hinduism', 'Sikhism', 'A', 'Islam is the predominant religion in parts of Mindanao and the Sulu Archipelago, with roots predating Spanish colonization.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'Which major world religion is predominant in the southern Philippines, particularly in parts of Mindanao?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'medium', 'What is the term for the Filipino Nativity scene, typically displayed in homes and churches during Christmas?', 'Parol', 'Belen', 'Pesebre (used interchangeably in some regions)', 'Cuna', 'B', 'The ''Belen,'' named after Bethlehem, is the traditional Filipino Nativity scene depicting the birth of Jesus, commonly displayed at Christmas.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'What is the term for the Filipino Nativity scene, typically displayed in homes and churches during Christmas?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'medium', 'Which Filipino Catholic devotion honors the Virgin Mary through daily flower offerings throughout the month of May?', 'Simbang Gabi', 'Santacruzan (the concluding procession)', 'Salubong', 'Flores de Mayo', 'D', 'Flores de Mayo is a month-long Marian devotion held throughout May, involving daily flower offerings in honor of the Virgin Mary.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'Which Filipino Catholic devotion honors the Virgin Mary through daily flower offerings throughout the month of May?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'medium', 'What is the term for the grand procession that concludes the Flores de Mayo celebrations in the Philippines?', 'Panunuluyan', 'Salubong', 'Santacruzan', 'Visita Iglesia', 'C', 'The Santacruzan is a grand procession concluding Flores de Mayo, featuring participants representing figures from biblical and Philippine history.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'What is the term for the grand procession that concludes the Flores de Mayo celebrations in the Philippines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'medium', 'Which annual Catholic devotion held in Quiapo, Manila, involves millions of devotees seeking to touch a revered image of Jesus Christ?', 'The Feast of the Santo Niño', 'The Feast of the Black Nazarene', 'The Feast of Our Lady of Peñafrancia', 'The Feast of Our Lady of Manaoag', 'B', 'The annual Traslacion procession of the Black Nazarene in Quiapo draws millions of devotees seeking blessings by touching the venerated image.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'Which annual Catholic devotion held in Quiapo, Manila, involves millions of devotees seeking to touch a revered image of Jesus Christ?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'medium', 'What is the term for a personal vow made to a saint in Filipino Catholic tradition, often fulfilled through acts of devotion or penance?', 'Pabasa', 'Novena', 'Panata', 'Bendisyon', 'C', 'A panata is a personal vow or devotional promise made to a saint, often fulfilled through acts like pilgrimage or lifelong devotion.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'What is the term for a personal vow made to a saint in Filipino Catholic tradition, often fulfilled through acts of devotion or penance?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'medium', 'Which Filipino Holy Week tradition involves chanting or singing the story of Christ''s Passion, often for many continuous hours?', 'Senakulo', 'Salubong', 'Visita Iglesia', 'Pabasa', 'D', 'The Pabasa is the traditional chanting or singing of the Pasyon, an epic poem recounting the life, passion, and death of Jesus Christ.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'Which Filipino Holy Week tradition involves chanting or singing the story of Christ''s Passion, often for many continuous hours?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'medium', 'What is the name of the Easter Sunday tradition reenacting the joyful meeting between the Risen Christ and the Virgin Mary?', 'Panunuluyan', 'Salubong', 'Pabasa', 'Senakulo', 'B', 'The Salubong is an Easter Sunday ritual reenacting the joyful meeting of the Risen Christ and his mother Mary, often performed before dawn.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'What is the name of the Easter Sunday tradition reenacting the joyful meeting between the Risen Christ and the Virgin Mary?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'medium', 'Which indigenous religious tradition, distinct from Christianity and Islam, continues to be practiced by various highland tribal groups in the Philippines?', 'Theravada Buddhism', 'Sikhism', 'Indigenous animist traditions', 'Zoroastrianism', 'C', 'Various indigenous Philippine groups continue to practice traditional animist belief systems, honoring ancestral and nature spirits.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'Which indigenous religious tradition, distinct from Christianity and Islam, continues to be practiced by various highland tribal groups in the Philippines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'medium', 'What is the name of the traditional reenactment of Mary and Joseph''s search for lodging, often performed on Christmas Eve in the Philippines?', 'Panunuluyan', 'Salubong', 'Pastores', 'Belen tradition', 'A', 'The Panunuluyan is a traditional reenactment of Mary and Joseph''s search for shelter before Jesus''s birth, often performed on Christmas Eve.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'What is the name of the traditional reenactment of Mary and Joseph''s search for lodging, often performed on Christmas Eve in the Philippines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'medium', 'Which Filipino Holy Week tradition involves acts of penance, including self-flagellation, notably practiced in parts of Pampanga?', 'Pabasa', 'Penitensya', 'Senakulo', 'Visita Iglesia', 'B', 'Penitensya refers to acts of penance during Holy Week, including self-flagellation, notably practiced in towns like San Fernando, Pampanga.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'Which Filipino Holy Week tradition involves acts of penance, including self-flagellation, notably practiced in parts of Pampanga?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'medium', 'What is the term for the large annual Marian procession in Naga City featuring a fluvial parade along the Bicol River?', 'The Salubong Procession', 'The Santacruzan', 'The Traslacion', 'The Peñafrancia Fluvial Procession', 'D', 'The Peñafrancia Fluvial Procession is one of the largest Marian devotions in the Philippines, featuring a river procession honoring Our Lady of Peñafrancia.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'What is the term for the large annual Marian procession in Naga City featuring a fluvial parade along the Bicol River?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'slang', 'medium', 'What does the Filipino slang term ''kilig'' describe?', 'Extreme anger', 'A fluttery, romantic excitement or thrill', 'Deep exhaustion', 'Boredom', 'B', '''Kilig'' describes the fluttery, giddy feeling of romantic excitement, often experienced watching a romantic moment or being with a crush.'
where not exists (
  select 1 from questions where category = 'slang' and prompt = 'What does the Filipino slang term ''kilig'' describe?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'slang', 'medium', 'In Filipino slang, what does ''basta'' generally mean when used dismissively in conversation?', '''Please wait''', '''I agree completely''', '''Just because'' or ''never mind the reason''', '''Thank you very much''', 'C', '''Basta'' is used to dismiss further explanation, roughly meaning ''just because'' or ''that''s just how it is.'''
where not exists (
  select 1 from questions where category = 'slang' and prompt = 'In Filipino slang, what does ''basta'' generally mean when used dismissively in conversation?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'slang', 'medium', 'What does the Filipino term ''edi wow'' sarcastically express?', 'Sarcastic indifference or unimpressed reaction to a boastful statement', 'Genuine amazement', 'A greeting', 'A request for help', 'A', '''Edi wow'' is a sarcastic phrase used to mock someone''s boastful or self-important statement.'
where not exists (
  select 1 from questions where category = 'slang' and prompt = 'What does the Filipino term ''edi wow'' sarcastically express?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'medium', 'Which planet is closest to the sun in our solar system?', 'Mercury', 'Venus', 'Earth', 'Mars', 'A', 'Mercury is the closest planet to the sun, completing an orbit in just 88 Earth days.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'Which planet is closest to the sun in our solar system?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'medium', 'What is the name of the natural satellite that orbits Earth and influences ocean tides?', 'Mars', 'Venus', 'Phobos (a moon of Mars, not Earth)', 'The Moon', 'D', 'The Moon is Earth''s only natural satellite, and its gravitational pull is the primary cause of ocean tides.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'What is the name of the natural satellite that orbits Earth and influences ocean tides?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'medium', 'Which planet is known as the ''Red Planet'' due to its rust-colored, iron-oxide-rich surface?', 'Mars', 'Venus', 'Jupiter', 'Mercury', 'A', 'Mars is called the ''Red Planet'' because of the iron oxide, or rust, that gives its surface a reddish hue.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'Which planet is known as the ''Red Planet'' due to its rust-colored, iron-oxide-rich surface?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'medium', 'What is the term for a large, glowing ball of gas that generates energy through nuclear fusion, such as our sun?', 'A planet', 'A comet', 'A star', 'An asteroid', 'C', 'A star is a massive, luminous ball of gas that generates energy through nuclear fusion occurring in its core.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'What is the term for a large, glowing ball of gas that generates energy through nuclear fusion, such as our sun?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'medium', 'Which is the largest planet in our solar system by both mass and volume?', 'Saturn', 'Neptune', 'Uranus', 'Jupiter', 'D', 'Jupiter is the largest planet in the solar system, both in terms of mass and physical volume.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'Which is the largest planet in our solar system by both mass and volume?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'medium', 'What is the name of the galaxy that contains Earth and our solar system?', 'The Milky Way', 'Andromeda', 'The Triangulum Galaxy', 'The Whirlpool Galaxy', 'A', 'Our solar system is located within the Milky Way galaxy, a large barred spiral galaxy.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'What is the name of the galaxy that contains Earth and our solar system?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'medium', 'Which space agency successfully landed the first humans on the Moon in 1969?', 'ESA', 'Roscosmos', 'NASA', 'JAXA', 'C', 'NASA, the U.S. space agency, achieved the historic first crewed Moon landing with the Apollo 11 mission in July 1969.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'Which space agency successfully landed the first humans on the Moon in 1969?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'medium', 'What is the term for a small, rocky object orbiting the sun, typically found in a belt between Mars and Jupiter?', 'A comet', 'A meteoroid', 'A dwarf planet', 'An asteroid', 'D', 'Asteroids are small, rocky objects orbiting the sun, with a large concentration found in the asteroid belt between Mars and Jupiter.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'What is the term for a small, rocky object orbiting the sun, typically found in a belt between Mars and Jupiter?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'medium', 'Which planet in our solar system has the most extensive ring system, easily visible with a small telescope?', 'Jupiter', 'Uranus', 'Saturn', 'Neptune', 'C', 'Saturn is famous for its extensive and visually striking ring system, composed primarily of ice and rock particles.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'Which planet in our solar system has the most extensive ring system, easily visible with a small telescope?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'medium', 'What is the term for the path an object, such as a planet, follows as it travels around another object in space?', 'An orbit', 'A trajectory (a related but more general term)', 'A rotation', 'An axis', 'A', 'An orbit is the curved path an object follows as it travels around another object due to gravitational forces, such as a planet orbiting a star.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'What is the term for the path an object, such as a planet, follows as it travels around another object in space?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'medium', 'Which spacecraft mission was the first to successfully land humans on the Moon''s surface?', 'Apollo 13', 'Apollo 11', 'Gemini 8', 'Mercury-Atlas 9', 'B', 'Apollo 11, launched by NASA in 1969, was the mission that first successfully landed humans on the surface of the Moon.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'Which spacecraft mission was the first to successfully land humans on the Moon''s surface?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'medium', 'What is the term for a streak of light seen in the sky caused by debris burning up as it enters Earth''s atmosphere?', 'A comet', 'A meteor (shooting star)', 'An asteroid', 'A satellite', 'B', 'A meteor, commonly called a shooting star, is the visible streak of light produced when debris burns up entering Earth''s atmosphere.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'What is the term for a streak of light seen in the sky caused by debris burning up as it enters Earth''s atmosphere?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'medium', 'Which planet in our solar system is famous for having a prominent, giant storm called the Great Red Spot?', 'Jupiter', 'Saturn', 'Neptune', 'Mars', 'A', 'Jupiter is known for its Great Red Spot, a massive, long-lasting storm larger than Earth that has been observed for centuries.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'Which planet in our solar system is famous for having a prominent, giant storm called the Great Red Spot?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'medium', 'What is the name of the reusable spacecraft program developed by SpaceX that has significantly reduced the cost of space launches?', 'Space Shuttle (a NASA program, not SpaceX)', 'Ariane (a European program, not SpaceX)', 'Falcon (Falcon 9 and Falcon Heavy)', 'Soyuz (a Russian program, not SpaceX)', 'C', 'SpaceX''s Falcon rocket family, including the reusable Falcon 9, has significantly reduced the cost of launching payloads into space.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'What is the name of the reusable spacecraft program developed by SpaceX that has significantly reduced the cost of space launches?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'medium', 'Which term describes the point at which a planet''s orbit brings it closest to the sun?', 'Aphelion', 'Perihelion', 'Perigee', 'Apogee', 'B', 'Perihelion refers to the point in a planet''s elliptical orbit where it comes closest to the sun.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'Which term describes the point at which a planet''s orbit brings it closest to the sun?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'medium', 'Which dwarf planet, located in the Kuiper Belt, was reclassified from full planet status in 2006?', 'Eris', 'Ceres', 'Makemake', 'Pluto', 'D', 'Pluto was reclassified as a dwarf planet in 2006 after the International Astronomical Union established a formal definition excluding it from full planet status.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'Which dwarf planet, located in the Kuiper Belt, was reclassified from full planet status in 2006?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'medium', 'Which term describes the apparent bending of a star''s light as it passes near a massive object, predicted by general relativity?', 'Redshift', 'Gravitational lensing', 'Refraction', 'Diffraction', 'B', 'Gravitational lensing occurs when light from a distant object bends around a massive foreground object, a direct consequence of Einstein''s general relativity.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'Which term describes the apparent bending of a star''s light as it passes near a massive object, predicted by general relativity?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'medium', 'Which technology company developed the iPhone, first released in 2007?', 'Samsung', 'Google', 'Microsoft', 'Apple', 'D', 'Apple developed and released the first iPhone in 2007, a device that significantly reshaped the smartphone industry.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'Which technology company developed the iPhone, first released in 2007?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'medium', 'What is the term for a network of interconnected computers that allows devices to share information globally?', 'An intranet', 'The Internet', 'A local area network (LAN)', 'The World Wide Web (a related but distinct part of the internet)', 'B', 'The Internet is a vast global network of interconnected computers that enables the sharing of information worldwide.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'What is the term for a network of interconnected computers that allows devices to share information globally?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'medium', 'Which technology allows users to store and access data over the internet rather than on a local device?', 'USB storage', 'Hard drive storage', 'RAM storage', 'Cloud storage', 'D', 'Cloud storage allows users to save and access data remotely over the internet rather than relying solely on local physical storage devices.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'Which technology allows users to store and access data over the internet rather than on a local device?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'medium', 'What is the term for a software program designed to browse and display content from the World Wide Web?', 'An operating system', 'A search engine (a related but distinct tool)', 'A web browser', 'An application programming interface', 'C', 'A web browser is software specifically designed to access, retrieve, and display content from the World Wide Web.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'What is the term for a software program designed to browse and display content from the World Wide Web?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'medium', 'Which social media platform, launched in 2004, was originally created for college students before expanding globally?', 'Facebook', 'Twitter (now X)', 'Instagram', 'LinkedIn', 'A', 'Facebook was launched in 2004, originally intended for college students, before expanding into one of the world''s largest social media platforms.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'Which social media platform, launched in 2004, was originally created for college students before expanding globally?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'medium', 'What is the term for unwanted, unsolicited digital messages, often sent in bulk via email?', 'Malware', 'Spam', 'Phishing (a specific malicious subset)', 'Cache', 'B', 'Spam refers to unwanted, unsolicited digital messages, often sent in bulk, most commonly through email.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'What is the term for unwanted, unsolicited digital messages, often sent in bulk via email?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'medium', 'Which technology allows a smartphone to determine its precise location using satellite signals?', 'Wi-Fi', 'GPS (Global Positioning System)', 'Bluetooth', 'NFC', 'B', 'GPS (Global Positioning System) uses satellite signals to determine a device''s precise geographic location.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'Which technology allows a smartphone to determine its precise location using satellite signals?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'medium', 'What is the term for software or hardware designed to protect a computer system from unauthorized access or attacks?', 'An antivirus program (a related but distinct type of protection)', 'A VPN (a related but distinct technology)', 'A router (primarily a networking device, not a security tool)', 'A firewall', 'D', 'A firewall is a security system that monitors and controls network traffic to protect a computer or network from unauthorized access.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'What is the term for software or hardware designed to protect a computer system from unauthorized access or attacks?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'medium', 'Which video-sharing platform, launched in 2005, became one of the most popular websites for uploading and watching videos?', 'YouTube', 'Vimeo', 'TikTok', 'Twitch', 'A', 'YouTube, launched in 2005, became one of the world''s most popular platforms for uploading and watching video content.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'Which video-sharing platform, launched in 2005, became one of the most popular websites for uploading and watching videos?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'medium', 'What is the term for a digital currency that operates independently of a central bank, using cryptographic security?', 'Digital wallet', 'Stock', 'Cryptocurrency', 'Bond', 'C', 'Cryptocurrency is a form of digital currency secured through cryptography, operating independently of traditional central banking systems.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'What is the term for a digital currency that operates independently of a central bank, using cryptographic security?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'medium', 'Which company developed the widely used Android operating system for mobile devices?', 'Apple', 'Microsoft', 'Samsung', 'Google', 'D', 'Google developed the Android operating system, which has become one of the most widely used mobile operating systems in the world.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'Which company developed the widely used Android operating system for mobile devices?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'medium', 'What is the term for the technology that enables voice-activated virtual assistants, such as Siri or Alexa, to understand spoken commands?', 'Machine learning (a broader related field)', 'Natural language processing (a closely related field)', 'Speech recognition', 'Text-to-speech (a related but different technology)', 'C', 'Speech recognition technology allows virtual assistants to convert spoken words into text or commands that a computer system can process and act upon.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'What is the term for the technology that enables voice-activated virtual assistants, such as Siri or Alexa, to understand spoken commands?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'medium', 'Which term describes the practice of using electronic devices to communicate and conduct business over long distances?', 'Broadcasting', 'Networking (a related but narrower term)', 'Telecommunications', 'Data transmission (a related but more technical term)', 'C', 'Telecommunications refers broadly to the use of electronic devices and systems to communicate over long distances.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'Which term describes the practice of using electronic devices to communicate and conduct business over long distances?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'medium', 'What is the term for a computer program designed to automatically perform repetitive tasks, often used in customer service chat systems?', 'A chatbot (or bot)', 'A virus', 'A firewall', 'An algorithm (a related but broader concept)', 'A', 'A chatbot, or bot, is a computer program designed to simulate conversation and automate repetitive tasks, commonly used in customer service.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'What is the term for a computer program designed to automatically perform repetitive tasks, often used in customer service chat systems?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'medium', 'Which technology, popularized by Bitcoin, uses a decentralized, distributed ledger to securely record transactions?', 'Cloud computing', 'Blockchain', 'Artificial intelligence', 'Virtual reality', 'B', 'Blockchain technology, underpinning Bitcoin, uses a decentralized and distributed ledger to securely record transactions across a network of computers.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'Which technology, popularized by Bitcoin, uses a decentralized, distributed ledger to securely record transactions?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'medium', 'What is the term for technology that enables computers to learn from data and improve performance without explicit programming?', 'Machine learning', 'Cloud computing', 'Cybersecurity', 'Virtualization', 'A', 'Machine learning enables computer systems to learn patterns from data and improve their performance over time without being explicitly programmed for every scenario.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'What is the term for technology that enables computers to learn from data and improve performance without explicit programming?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'medium', 'Which Italian dish consists of a flat bread topped with tomato sauce, cheese, and various toppings, baked in an oven?', 'Focaccia', 'Calzone', 'Pizza', 'Panzerotti', 'C', 'Pizza, originating in Naples, Italy, consists of a flat bread base topped with tomato sauce, cheese, and various other ingredients.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'Which Italian dish consists of a flat bread topped with tomato sauce, cheese, and various toppings, baked in an oven?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'medium', 'What is the name of the traditional Mexican dish consisting of a folded tortilla filled with meat, cheese, and vegetables?', 'Burrito', 'Enchilada', 'Quesadilla', 'Taco', 'D', 'A taco is a traditional Mexican dish made from a folded or hard-shelled tortilla filled with meat, cheese, vegetables, and various toppings.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'What is the name of the traditional Mexican dish consisting of a folded tortilla filled with meat, cheese, and vegetables?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'medium', 'Which French pastry, known for its flaky, buttery layers, is commonly eaten for breakfast?', 'Baguette', 'Croissant', 'Macaron', 'Éclair', 'B', 'The croissant is a flaky, buttery French pastry, traditionally shaped in a crescent and commonly enjoyed for breakfast.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'Which French pastry, known for its flaky, buttery layers, is commonly eaten for breakfast?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'medium', 'What is the name of the traditional Japanese dish consisting of vinegared rice combined with raw fish or other ingredients?', 'Sashimi', 'Tempura', 'Ramen', 'Sushi', 'D', 'Sushi refers to Japanese dishes featuring vinegared rice combined with various ingredients, often including raw or cooked seafood.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'What is the name of the traditional Japanese dish consisting of vinegared rice combined with raw fish or other ingredients?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'medium', 'Which Indian dish consists of a spiced, slow-cooked stew, often featuring chicken or lamb in a creamy tomato-based sauce?', 'Biryani', 'Naan (a bread, not a stew)', 'Curry (such as butter chicken)', 'Samosa (a fried pastry, not a stew)', 'C', 'Curry, encompassing many regional variations, refers to spiced dishes typically featuring meat or vegetables in a flavorful, often tomato-based sauce.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'Which Indian dish consists of a spiced, slow-cooked stew, often featuring chicken or lamb in a creamy tomato-based sauce?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'medium', 'What is the name of the traditional Korean side dish made from fermented, spiced cabbage?', 'Kimchi', 'Bulgogi', 'Bibimbap', 'Japchae', 'A', 'Kimchi is a traditional Korean fermented dish, most commonly made from napa cabbage seasoned with chili pepper and garlic.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'What is the name of the traditional Korean side dish made from fermented, spiced cabbage?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'medium', 'Which Chinese dish consists of thin strips of dough cooked in boiling water or broth, often served with meat and vegetables?', 'Noodles', 'Dumplings', 'Fried rice', 'Spring rolls', 'A', 'Noodles are a staple of Chinese cuisine, prepared in numerous regional styles and typically served with meat, vegetables, or in soups.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'Which Chinese dish consists of thin strips of dough cooked in boiling water or broth, often served with meat and vegetables?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'medium', 'What is the name of the classic American sandwich consisting of ground beef patty served on a bun with toppings?', 'Hamburger', 'Hot dog', 'Sub sandwich', 'Club sandwich', 'A', 'The hamburger, a ground beef patty served on a bun, is one of the most iconic dishes in American cuisine.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'What is the name of the classic American sandwich consisting of ground beef patty served on a bun with toppings?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'medium', 'Which German dish consists of sausages, typically served with mustard and often accompanied by sauerkraut?', 'Schnitzel', 'Spaetzle', 'Bratwurst', 'Pretzel', 'C', 'Bratwurst is a traditional German sausage, commonly grilled or pan-fried and served with mustard, often alongside sauerkraut.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'Which German dish consists of sausages, typically served with mustard and often accompanied by sauerkraut?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'medium', 'What is the name of the Spanish dish made of rice cooked with saffron, vegetables, and often seafood or meat?', 'Paella', 'Tapas (small dishes, not a single rice dish)', 'Gazpacho (a cold soup, not a rice dish)', 'Tortilla española (an omelet, not a rice dish)', 'A', 'Paella, originally from Valencia, Spain, is a rice dish typically flavored with saffron and cooked with vegetables, seafood, or meat.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'What is the name of the Spanish dish made of rice cooked with saffron, vegetables, and often seafood or meat?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'medium', 'Which Thai dish is a stir-fried noodle dish commonly made with rice noodles, shrimp or chicken, and peanuts?', 'Tom Yum (a soup, not a noodle dish)', 'Pad Thai', 'Green curry (a curry dish, not noodles)', 'Massaman curry (a curry dish, not noodles)', 'B', 'Pad Thai is a popular Thai stir-fried noodle dish, typically featuring rice noodles, protein, peanuts, and a tangy tamarind-based sauce.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'Which Thai dish is a stir-fried noodle dish commonly made with rice noodles, shrimp or chicken, and peanuts?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'medium', 'What is the term for the traditional English breakfast, typically including eggs, bacon, sausages, and baked beans?', 'High tea (an afternoon meal tradition, not breakfast)', 'Sunday roast (a dinner tradition, not breakfast)', 'Ploughman''s lunch (a lunch tradition, not breakfast)', 'A full English breakfast', 'D', 'A full English breakfast is a traditional hearty meal typically including eggs, bacon, sausages, baked beans, and toast.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'What is the term for the traditional English breakfast, typically including eggs, bacon, sausages, and baked beans?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'medium', 'Which Vietnamese dish is a noodle soup typically made with beef or chicken broth, rice noodles, and fresh herbs?', 'Banh mi (a sandwich, not a soup)', 'Spring rolls (an appetizer, not a soup)', 'Pho', 'Bun cha (a noodle salad, not a soup)', 'C', 'Pho is a traditional Vietnamese noodle soup, typically made with a flavorful broth, rice noodles, herbs, and beef or chicken.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'Which Vietnamese dish is a noodle soup typically made with beef or chicken broth, rice noodles, and fresh herbs?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'medium', 'What is the name of the traditional Swiss dish made by melting cheese and dipping bread into it?', 'Fondue', 'Raclette (a related but distinct melted cheese dish)', 'Rösti (a potato dish, not melted cheese)', 'Muesli (a breakfast cereal, unrelated)', 'A', 'Fondue is a traditional Swiss dish in which melted cheese is served in a communal pot, into which bread pieces are dipped.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'What is the name of the traditional Swiss dish made by melting cheese and dipping bread into it?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'medium', 'Which Greek dish consists of layers of eggplant, ground meat, and béchamel sauce, baked together?', 'Souvlaki (a grilled meat dish, not layered)', 'Tzatziki (a sauce, not a baked dish)', 'Spanakopita (a spinach pastry, not layered with meat)', 'Moussaka', 'D', 'Moussaka is a traditional Greek baked dish featuring layers of eggplant, spiced ground meat, and creamy béchamel sauce.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'Which Greek dish consists of layers of eggplant, ground meat, and béchamel sauce, baked together?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'medium', 'What is the term for the traditional British dish of battered and deep-fried fish served with chips (fries)?', 'Bangers and mash', 'Fish and chips', 'Shepherd''s pie', 'Toad in the hole', 'B', 'Fish and chips, consisting of battered deep-fried fish served with thick-cut fries, is one of Britain''s most iconic traditional dishes.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'What is the term for the traditional British dish of battered and deep-fried fish served with chips (fries)?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'medium', 'Which Middle Eastern dip is made primarily from mashed chickpeas, tahini, olive oil, and garlic?', 'Baba ghanoush', 'Hummus', 'Tzatziki', 'Muhammara', 'B', 'Hummus is a popular Middle Eastern dip made primarily from mashed chickpeas, tahini, olive oil, lemon juice, and garlic.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'Which Middle Eastern dip is made primarily from mashed chickpeas, tahini, olive oil, and garlic?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'medium', 'Which continent is the largest in the world by both land area and population?', 'Asia', 'Africa', 'North America', 'Europe', 'A', 'Asia is the largest continent by both land area and population, home to over half the world''s total population.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'Which continent is the largest in the world by both land area and population?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'medium', 'What is the name of the largest ocean in the world, covering more area than any other?', 'The Atlantic Ocean', 'The Indian Ocean', 'The Pacific Ocean', 'The Arctic Ocean', 'C', 'The Pacific Ocean is the largest and deepest ocean in the world, covering roughly a third of the Earth''s total surface.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'What is the name of the largest ocean in the world, covering more area than any other?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'medium', 'Which country has the largest population in the world, as of recent estimates?', 'China', 'United States', 'Indonesia', 'India', 'D', 'India surpassed China to become the world''s most populous country according to United Nations population estimates released in 2023.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'Which country has the largest population in the world, as of recent estimates?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'medium', 'What is the name of the longest river in Africa, traditionally considered the longest river in the world?', 'The Congo River', 'The Nile', 'The Niger River', 'The Zambezi River', 'B', 'The Nile River, flowing through northeastern Africa, is traditionally regarded as the longest river in the world.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'What is the name of the longest river in Africa, traditionally considered the longest river in the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'medium', 'Which mountain range separates Europe from Asia, running through Russia?', 'The Ural Mountains', 'The Alps', 'The Caucasus Mountains', 'The Carpathian Mountains', 'A', 'The Ural Mountains, running north to south through Russia, are traditionally considered the geographic boundary between Europe and Asia.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'Which mountain range separates Europe from Asia, running through Russia?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'medium', 'What is the name of the largest country in the world by total land area?', 'Canada', 'China', 'United States', 'Russia', 'D', 'Russia is the largest country in the world by land area, spanning across both Europe and Asia.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'What is the name of the largest country in the world by total land area?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'medium', 'Which desert, located in northern Africa, is the largest hot desert in the world?', 'The Sahara Desert', 'The Arabian Desert', 'The Gobi Desert', 'The Kalahari Desert', 'A', 'The Sahara Desert, spanning much of northern Africa, is the largest hot desert in the world by area.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'Which desert, located in northern Africa, is the largest hot desert in the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'medium', 'What is the tallest mountain in the world, located in the Himalayas on the border of Nepal and Tibet?', 'K2', 'Mount Everest', 'Kangchenjunga', 'Denali', 'B', 'Mount Everest, standing at 8,849 meters, is the tallest mountain in the world above sea level.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'What is the tallest mountain in the world, located in the Himalayas on the border of Nepal and Tibet?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'medium', 'Which country is both an island and a continent, located in the Southern Hemisphere?', 'New Zealand', 'Papua New Guinea', 'Madagascar', 'Australia', 'D', 'Australia is unique in being classified as both a continent and an island nation, located entirely within the Southern Hemisphere.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'Which country is both an island and a continent, located in the Southern Hemisphere?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'medium', 'What is the name of the sea located between Europe and Africa, connected to the Atlantic Ocean via the Strait of Gibraltar?', 'The Red Sea', 'The Black Sea', 'The Mediterranean Sea', 'The Caspian Sea', 'C', 'The Mediterranean Sea lies between Europe and Africa, connected to the Atlantic Ocean through the narrow Strait of Gibraltar.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'What is the name of the sea located between Europe and Africa, connected to the Atlantic Ocean via the Strait of Gibraltar?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'medium', 'Which South American country is home to the majority of the Amazon Rainforest?', 'Peru', 'Colombia', 'Brazil', 'Venezuela', 'C', 'Brazil contains the largest portion of the Amazon Rainforest, the world''s largest tropical rainforest.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'Which South American country is home to the majority of the Amazon Rainforest?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'medium', 'What is the name of the imaginary line at zero degrees latitude that divides the Earth into Northern and Southern Hemispheres?', 'The Prime Meridian', 'The Tropic of Cancer', 'The Arctic Circle', 'The Equator', 'D', 'The Equator is the imaginary line encircling the Earth at zero degrees latitude, dividing it into the Northern and Southern Hemispheres.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'What is the name of the imaginary line at zero degrees latitude that divides the Earth into Northern and Southern Hemispheres?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'medium', 'Which country is home to the ancient city of Machu Picchu, a famous Incan archaeological site?', 'Bolivia', 'Peru', 'Ecuador', 'Chile', 'B', 'Machu Picchu, a renowned Incan citadel, is located high in the Andes Mountains of Peru.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'Which country is home to the ancient city of Machu Picchu, a famous Incan archaeological site?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'medium', 'What is the name of the largest island in the world by land area?', 'Greenland', 'New Guinea', 'Borneo', 'Madagascar', 'A', 'Greenland is the largest island in the world by land area, though it is far less populated than most other large landmasses.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'What is the name of the largest island in the world by land area?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'medium', 'Which African country is home to the ancient pyramids of Giza, one of the world''s most iconic archaeological sites?', 'Sudan', 'Libya', 'Egypt', 'Ethiopia', 'C', 'Egypt is home to the ancient pyramids of Giza, among the most iconic and well-preserved archaeological sites in the world.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'Which African country is home to the ancient pyramids of Giza, one of the world''s most iconic archaeological sites?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'medium', 'What is the name of the strait separating Europe and Africa at the western entrance to the Mediterranean Sea?', 'The Strait of Gibraltar', 'The Bosphorus Strait', 'The Strait of Hormuz', 'The Dardanelles', 'A', 'The Strait of Gibraltar separates Europe and Africa, connecting the Atlantic Ocean to the Mediterranean Sea.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'What is the name of the strait separating Europe and Africa at the western entrance to the Mediterranean Sea?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'medium', 'Which country contains the geographic South Pole, located on the continent of Antarctica?', 'Chile', 'No country claims sovereignty recognized internationally over the South Pole; it lies within Antarctica, governed by the Antarctic Treaty System', 'Argentina', 'Norway', 'B', 'The South Pole lies within Antarctica, a continent governed collectively under the Antarctic Treaty System rather than claimed by a single recognized sovereign nation.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'Which country contains the geographic South Pole, located on the continent of Antarctica?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'medium', 'Which ancient civilization is credited with building the pyramids of Giza and developing hieroglyphic writing?', 'Ancient Greece', 'Ancient Rome', 'Ancient Egypt', 'The Indus Valley Civilization', 'C', 'Ancient Egypt is renowned for constructing the pyramids of Giza and developing hieroglyphics, one of the earliest known writing systems.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'Which ancient civilization is credited with building the pyramids of Giza and developing hieroglyphic writing?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'medium', 'What was the name of the massive world war fought from 1939 to 1945, involving most of the world''s nations?', 'World War I', 'The Cold War', 'The Korean War', 'World War II', 'D', 'World War II, fought from 1939 to 1945, was a global conflict involving the majority of the world''s nations and resulting in immense loss of life.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'What was the name of the massive world war fought from 1939 to 1945, involving most of the world''s nations?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'medium', 'Which ancient empire, centered in Rome, once controlled vast territories across Europe, North Africa, and the Middle East?', 'The Byzantine Empire', 'The Ottoman Empire', 'The Roman Empire', 'The Persian Empire', 'C', 'The Roman Empire, at its height, controlled vast territories spanning Europe, North Africa, and the Middle East.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'Which ancient empire, centered in Rome, once controlled vast territories across Europe, North Africa, and the Middle East?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'medium', 'What was the name of the 14th-century pandemic that killed millions across Europe and Asia?', 'The Black Death', 'The Spanish Flu', 'The Plague of Justinian', 'Cholera pandemic', 'A', 'The Black Death, a devastating bubonic plague pandemic, killed millions of people across Europe and Asia during the 14th century.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'What was the name of the 14th-century pandemic that killed millions across Europe and Asia?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'medium', 'Which American document, adopted in 1776, formally declared the thirteen colonies'' independence from Britain?', 'The Constitution', 'The Bill of Rights', 'The Articles of Confederation', 'The Declaration of Independence', 'D', 'The Declaration of Independence, adopted in 1776, formally announced the thirteen American colonies'' break from British rule.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'Which American document, adopted in 1776, formally declared the thirteen colonies'' independence from Britain?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'medium', 'What was the name of the ancient trade route network connecting China to the Mediterranean world?', 'The Spice Route', 'The Amber Road', 'The Incense Route', 'The Silk Road', 'D', 'The Silk Road was an extensive network of trade routes connecting China to the Mediterranean, facilitating exchange of goods and ideas for centuries.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'What was the name of the ancient trade route network connecting China to the Mediterranean world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'medium', 'Which 1789 event marked the beginning of a major political revolution in France, overthrowing the monarchy?', 'The French Revolution', 'The Storming of the Bastille (a specific event within it)', 'The Reign of Terror (a later phase of it)', 'Napoleon''s coronation (a later event)', 'A', 'The French Revolution, beginning in 1789, led to the overthrow of the French monarchy and dramatically reshaped the country''s political system.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'Which 1789 event marked the beginning of a major political revolution in France, overthrowing the monarchy?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'medium', 'What was the name of the wall built to divide East and West Berlin during the Cold War, standing from 1961 to 1989?', 'The Berlin Wall', 'Hadrian''s Wall', 'The Great Wall of China', 'The Iron Curtain (a broader conceptual term, not a physical wall)', 'A', 'The Berlin Wall physically divided East and West Berlin from 1961 until its fall in 1989, becoming a powerful symbol of the Cold War.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'What was the name of the wall built to divide East and West Berlin during the Cold War, standing from 1961 to 1989?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'medium', 'Which ancient Greek city-state is credited with developing one of history''s earliest forms of democracy?', 'Sparta', 'Corinth', 'Athens', 'Thebes', 'C', 'Athens is credited with developing one of the earliest known forms of democratic governance in the 5th century BCE.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'Which ancient Greek city-state is credited with developing one of history''s earliest forms of democracy?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'medium', 'What was the name of the massive empire built by Genghis Khan and his successors, becoming the largest contiguous land empire in history?', 'The Ottoman Empire', 'The British Empire', 'The Roman Empire', 'The Mongol Empire', 'D', 'The Mongol Empire, founded by Genghis Khan, grew to become the largest contiguous land empire in world history.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'What was the name of the massive empire built by Genghis Khan and his successors, becoming the largest contiguous land empire in history?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'medium', 'Which 1917 event led to the establishment of the world''s first communist government in Russia?', 'The October Manifesto', 'The Decembrist Revolt', 'The Russian Revolution', 'The Bolshevik Uprising (essentially the same event, part of the Revolution)', 'C', 'The Russian Revolution of 1917 led to the overthrow of the Tsarist government and the eventual establishment of the world''s first communist state.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'Which 1917 event led to the establishment of the world''s first communist government in Russia?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'medium', 'What was the name of the period in European history marked by renewed interest in classical art, science, and learning?', 'The Enlightenment', 'The Renaissance', 'The Reformation', 'The Middle Ages (the preceding period)', 'B', 'The Renaissance was a period of renewed cultural, artistic, and scientific interest in Europe, beginning in Italy around the 14th century.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'What was the name of the period in European history marked by renewed interest in classical art, science, and learning?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'medium', 'Which ancient civilization, located in present-day Peru, built an extensive network of roads across the Andes Mountains?', 'The Aztec Empire', 'The Inca Empire', 'The Maya civilization', 'The Olmec civilization', 'B', 'The Inca Empire constructed an extensive network of roads across the rugged Andes, connecting their vast territory without the use of wheeled vehicles.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'Which ancient civilization, located in present-day Peru, built an extensive network of roads across the Andes Mountains?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'medium', 'What was the name of the historic voyage in 1492 in which Christopher Columbus reached the Americas?', 'Columbus''s first voyage to the New World', 'The Mayflower voyage', 'Magellan''s circumnavigation', 'The voyage of the Santa Maria (the specific ship, part of the same voyage)', 'A', 'Christopher Columbus''s 1492 voyage, sponsored by Spain, resulted in his arrival in the Americas, a pivotal moment in world history.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'What was the name of the historic voyage in 1492 in which Christopher Columbus reached the Americas?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'medium', 'Which ancient wonder of the world was a massive statue that once stood at the harbor entrance of the Greek island of Rhodes?', 'The Lighthouse of Alexandria', 'The Colossus of Rhodes', 'The Statue of Zeus at Olympia', 'The Hanging Gardens of Babylon', 'B', 'The Colossus of Rhodes, a giant statue of the sun god Helios, once stood near the harbor entrance of the ancient city of Rhodes.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'Which ancient wonder of the world was a massive statue that once stood at the harbor entrance of the Greek island of Rhodes?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'medium', 'What was the name of the 1969 event in which American astronauts became the first humans to walk on the Moon?', 'Apollo 11 Moon Landing', 'Apollo 13 mission', 'Sputnik launch', 'The Space Race (the broader competition, not a single event)', 'A', 'The Apollo 11 mission in 1969 marked the first time humans successfully walked on the surface of the Moon.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'What was the name of the 1969 event in which American astronauts became the first humans to walk on the Moon?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'medium', 'Which ancient Chinese wall, extended and fortified over many centuries, was built to protect against northern invasions?', 'Hadrian''s Wall', 'The Great Wall of China', 'The Berlin Wall', 'The Western Wall', 'B', 'The Great Wall of China was built and expanded over centuries by successive dynasties to defend against invasions from northern nomadic groups.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'Which ancient Chinese wall, extended and fortified over many centuries, was built to protect against northern invasions?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'medium', 'Which British author created the detective character Sherlock Holmes, known for extraordinary powers of observation and deduction?', 'Arthur Conan Doyle', 'Agatha Christie', 'Charles Dickens', 'H.G. Wells', 'A', 'Arthur Conan Doyle created the iconic detective Sherlock Holmes, renowned for his sharp powers of observation and logical deduction.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'Which British author created the detective character Sherlock Holmes, known for extraordinary powers of observation and deduction?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'medium', 'What is the title of William Shakespeare''s tragedy about a Danish prince seeking revenge for his father''s murder?', 'Macbeth', 'Othello', 'Hamlet', 'King Lear', 'C', '''Hamlet,'' one of Shakespeare''s most famous tragedies, follows a Danish prince seeking revenge for his father''s murder.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'What is the title of William Shakespeare''s tragedy about a Danish prince seeking revenge for his father''s murder?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'medium', 'Which American author wrote ''The Adventures of Huckleberry Finn,'' a classic novel of American literature?', 'Mark Twain', 'Herman Melville', 'Nathaniel Hawthorne', 'Edgar Allan Poe', 'A', 'Mark Twain wrote ''The Adventures of Huckleberry Finn,'' widely regarded as one of the great works of American literature.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'Which American author wrote ''The Adventures of Huckleberry Finn,'' a classic novel of American literature?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'medium', 'What is the title of George Orwell''s novel depicting a farm where animals overthrow their human owners, only to fall under new tyranny?', '1984', 'Animal Farm', 'Down and Out in Paris and London', 'Homage to Catalonia', 'B', '''Animal Farm,'' by George Orwell, is an allegorical novel depicting farm animals who overthrow their human owner, only to fall under a new form of tyranny.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'What is the title of George Orwell''s novel depicting a farm where animals overthrow their human owners, only to fall under new tyranny?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'medium', 'Which Russian author wrote ''War and Peace,'' an epic novel exploring Russian society during the Napoleonic era?', 'Fyodor Dostoevsky', 'Leo Tolstoy', 'Anton Chekhov', 'Nikolai Gogol', 'B', 'Leo Tolstoy wrote ''War and Peace,'' a sweeping epic exploring Russian society and the impact of the Napoleonic Wars.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'Which Russian author wrote ''War and Peace,'' an epic novel exploring Russian society during the Napoleonic era?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'medium', 'What is the title of Charles Dickens'' novel following an orphan boy navigating hardship in Victorian London?', 'Oliver Twist', 'Great Expectations', 'David Copperfield', 'A Tale of Two Cities', 'A', '''Oliver Twist,'' by Charles Dickens, follows an orphan boy''s struggles and hardships navigating the streets of Victorian London.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'What is the title of Charles Dickens'' novel following an orphan boy navigating hardship in Victorian London?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'medium', 'Which author wrote the fantasy series ''The Lord of the Rings,'' set in the fictional world of Middle-earth?', 'C.S. Lewis', 'J.R.R. Tolkien', 'George R.R. Martin', 'Terry Pratchett', 'B', 'J.R.R. Tolkien authored ''The Lord of the Rings,'' a landmark fantasy series set in the richly detailed fictional world of Middle-earth.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'Which author wrote the fantasy series ''The Lord of the Rings,'' set in the fictional world of Middle-earth?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'medium', 'What is the title of Jane Austen''s novel centering on the relationship between Elizabeth Bennet and Mr. Darcy?', 'Sense and Sensibility', 'Emma', 'Pride and Prejudice', 'Mansfield Park', 'C', '''Pride and Prejudice,'' by Jane Austen, follows the evolving relationship between the spirited Elizabeth Bennet and the initially proud Mr. Darcy.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'What is the title of Jane Austen''s novel centering on the relationship between Elizabeth Bennet and Mr. Darcy?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'medium', 'Which author created the fictional detective Hercule Poirot, featured in numerous mystery novels?', 'Arthur Conan Doyle', 'Dorothy L. Sayers', 'Raymond Chandler', 'Agatha Christie', 'D', 'Agatha Christie created the meticulous Belgian detective Hercule Poirot, who appears in dozens of her acclaimed mystery novels.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'Which author created the fictional detective Hercule Poirot, featured in numerous mystery novels?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'medium', 'What is the title of Mary Shelley''s novel about a scientist who creates a living creature, often considered an early work of science fiction?', 'Frankenstein', 'Dracula', 'The Strange Case of Dr. Jekyll and Mr. Hyde', 'The Island of Doctor Moreau', 'A', '''Frankenstein,'' by Mary Shelley, tells the story of a scientist whose creation of a living creature leads to tragic consequences, and is considered an early landmark of science fiction.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'What is the title of Mary Shelley''s novel about a scientist who creates a living creature, often considered an early work of science fiction?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'medium', 'Which American author wrote ''To Kill a Mockingbird,'' addressing themes of racial injustice in the American South?', 'Toni Morrison', 'John Steinbeck', 'William Faulkner', 'Harper Lee', 'D', 'Harper Lee wrote ''To Kill a Mockingbird,'' a classic novel addressing racial injustice and moral growth in the American South.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'Which American author wrote ''To Kill a Mockingbird,'' addressing themes of racial injustice in the American South?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'medium', 'What is the title of J.K. Rowling''s book series following a young wizard and his friends at a magical school?', 'Percy Jackson', 'Harry Potter', 'His Dark Materials', 'Chronicles of Narnia', 'B', 'J.K. Rowling''s Harry Potter series follows a young wizard and his friends as they attend Hogwarts School of Witchcraft and Wizardry.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'What is the title of J.K. Rowling''s book series following a young wizard and his friends at a magical school?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'medium', 'Which Colombian author wrote ''One Hundred Years of Solitude,'' a landmark work of magical realism?', 'Isabel Allende', 'Jorge Luis Borges', 'Mario Vargas Llosa', 'Gabriel Garcia Marquez', 'D', 'Gabriel Garcia Marquez wrote ''One Hundred Years of Solitude,'' a foundational work of magical realism chronicling generations of a Colombian family.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'Which Colombian author wrote ''One Hundred Years of Solitude,'' a landmark work of magical realism?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'medium', 'What is the title of Homer''s epic poem recounting the events of the Trojan War?', 'The Odyssey', 'The Aeneid', 'The Iliad', 'Metamorphoses', 'C', 'The Iliad, attributed to the ancient Greek poet Homer, recounts key events of the Trojan War, including the wrath of Achilles.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'What is the title of Homer''s epic poem recounting the events of the Trojan War?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'medium', 'Which author wrote the classic novel ''Moby-Dick,'' centered on a sea captain''s obsessive hunt for a white whale?', 'Herman Melville', 'Mark Twain', 'Nathaniel Hawthorne', 'Edgar Allan Poe', 'A', 'Herman Melville wrote ''Moby-Dick,'' a classic American novel following Captain Ahab''s obsessive pursuit of the great white whale.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'Which author wrote the classic novel ''Moby-Dick,'' centered on a sea captain''s obsessive hunt for a white whale?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'medium', 'What is the title of Victor Hugo''s novel following the story of an ex-convict seeking redemption amid social upheaval in France?', 'The Hunchback of Notre-Dame', 'Ninety-Three', 'Les Miserables', 'Toilers of the Sea', 'C', '''Les Miserables,'' by Victor Hugo, follows the story of Jean Valjean''s redemption against a backdrop of social injustice in 19th-century France.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'What is the title of Victor Hugo''s novel following the story of an ex-convict seeking redemption amid social upheaval in France?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'medium', 'Which German author wrote "Faust," a tragic play in which a scholar makes a deal with the devil for knowledge and pleasure?', 'Friedrich Schiller', 'Thomas Mann', 'Franz Kafka', 'Johann Wolfgang von Goethe', 'D', '"Faust," by Johann Wolfgang von Goethe, tells the story of a scholar who trades his soul to the devil, Mephistopheles, for unlimited knowledge and worldly pleasure.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'Which German author wrote "Faust," a tragic play in which a scholar makes a deal with the devil for knowledge and pleasure?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'medium', 'Which Japanese animation studio, founded by Hayao Miyazaki, is known for films like ''Spirited Away'' and ''My Neighbor Totoro''?', 'Studio Ghibli', 'Toei Animation', 'Madhouse', 'Production I.G', 'A', 'Studio Ghibli, co-founded by Hayao Miyazaki, is celebrated for beloved animated films including ''Spirited Away'' and ''My Neighbor Totoro.'''
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Which Japanese animation studio, founded by Hayao Miyazaki, is known for films like ''Spirited Away'' and ''My Neighbor Totoro''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'medium', 'What is the name of the acclaimed South Korean film that won the Academy Award for Best Picture in 2020?', 'Oldboy', 'Parasite', 'The Handmaiden', 'Train to Busan', 'B', '''Parasite,'' directed by Bong Joon-ho, made history by winning the Academy Award for Best Picture in 2020, the first non-English-language film to do so.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'What is the name of the acclaimed South Korean film that won the Academy Award for Best Picture in 2020?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'medium', 'Which British television series follows a time-traveling alien known simply as ''the Doctor''?', 'Doctor Who', 'Sherlock', 'Black Mirror', 'Torchwood', 'A', '''Doctor Who'' follows the adventures of a time-traveling alien known as the Doctor, and is among the longest-running science fiction series in television history.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Which British television series follows a time-traveling alien known simply as ''the Doctor''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'medium', 'What is the name of the Indian film industry based in Mumbai, known for producing a huge volume of musical films annually?', 'Tollywood', 'Kollywood', 'Lollywood', 'Bollywood', 'D', 'Bollywood, based in Mumbai, is the largest film industry in the world by volume, known especially for musical and dance-driven films.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'What is the name of the Indian film industry based in Mumbai, known for producing a huge volume of musical films annually?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'medium', 'Which acclaimed television series follows a family running a criminal drug empire in New Mexico?', 'The Sopranos', 'Ozark', 'Breaking Bad', 'Narcos', 'C', '''Breaking Bad'' follows a high school chemistry teacher''s transformation into a powerful methamphetamine manufacturer in New Mexico.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Which acclaimed television series follows a family running a criminal drug empire in New Mexico?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'medium', 'What is the name of the popular South Korean survival drama series that became a global phenomenon on Netflix in 2021?', 'Sweet Home', 'Kingdom', 'All of Us Are Dead', 'Squid Game', 'D', '''Squid Game'' became a massive global phenomenon after its 2021 Netflix release, depicting a deadly survival competition.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'What is the name of the popular South Korean survival drama series that became a global phenomenon on Netflix in 2021?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'medium', 'Which Japanese director is known for iconic films like ''Seven Samurai'' and ''Rashomon''?', 'Yasujiro Ozu', 'Hayao Miyazaki', 'Akira Kurosawa', 'Takeshi Kitano', 'C', 'Akira Kurosawa, director of ''Seven Samurai'' and ''Rashomon,'' is widely regarded as one of the most influential filmmakers in cinema history.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Which Japanese director is known for iconic films like ''Seven Samurai'' and ''Rashomon''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'medium', 'What is the name of the popular fantasy television series based on George R.R. Martin''s novels, known for its political intrigue?', 'The Witcher', 'Vikings', 'The Last Kingdom', 'Game of Thrones', 'D', '''Game of Thrones,'' adapted from George R.R. Martin''s novels, became a global phenomenon known for its intricate political intrigue and drama.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'What is the name of the popular fantasy television series based on George R.R. Martin''s novels, known for its political intrigue?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'medium', 'Which acclaimed British crime drama, set in a small coastal town, follows the investigation into a young boy''s murder?', 'Broadchurch', 'Line of Duty', 'Sherlock', 'Luther', 'A', '''Broadchurch'' is a British crime drama centered on the investigation into a young boy''s murder in a close-knit coastal community.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Which acclaimed British crime drama, set in a small coastal town, follows the investigation into a young boy''s murder?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'medium', 'What is the name of the animated Japanese film franchise about a boy who transforms into a powerful warrior to fight for Earth?', 'Dragon Ball', 'Naruto', 'One Piece', 'Attack on Titan', 'A', 'Dragon Ball, created by Akira Toriyama, follows characters who train and battle as powerful warriors, becoming a global anime phenomenon.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'What is the name of the animated Japanese film franchise about a boy who transforms into a powerful warrior to fight for Earth?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'medium', 'Which streaming series follows a group of teenagers who discover supernatural events happening in their small town?', 'The Umbrella Academy', 'Dark', 'Stranger Things', 'Locke & Key', 'C', '''Stranger Things'' follows a group of kids in the fictional town of Hawkins confronting supernatural events and government secrets.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Which streaming series follows a group of teenagers who discover supernatural events happening in their small town?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'medium', 'What is the name of the acclaimed Mexican director who won Academy Awards for both ''Gravity'' and ''Roma''?', 'Alfonso Cuaron', 'Guillermo del Toro', 'Alejandro Gonzalez Inarritu', 'Carlos Reygadas', 'A', 'Alfonso Cuaron won Academy Awards for directing both ''Gravity'' and ''Roma,'' among other critically acclaimed films.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'What is the name of the acclaimed Mexican director who won Academy Awards for both ''Gravity'' and ''Roma''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'medium', 'Which iconic British television franchise follows a secret agent with the codename 007?', 'Mission: Impossible (an American franchise, not British)', 'James Bond', 'The Man from U.N.C.L.E. (an American franchise, not British)', 'Kingsman (a later, distinct franchise)', 'B', 'The James Bond film franchise, based on Ian Fleming''s novels, follows a British secret agent known by his codename, 007.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Which iconic British television franchise follows a secret agent with the codename 007?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'medium', 'What is the name of the long-running British science fiction and mystery series that follows a consulting detective in modern-day London?', 'Doctor Who', 'Sherlock', 'Luther', 'Broadchurch', 'B', '''Sherlock'' reimagines Arthur Conan Doyle''s famous detective in a modern-day London setting.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'What is the name of the long-running British science fiction and mystery series that follows a consulting detective in modern-day London?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'medium', 'Which animated film franchise, produced by Studio Ghibli, follows a young girl who works in a magical bathhouse for spirits?', 'My Neighbor Totoro', 'Princess Mononoke', 'Spirited Away', 'Howl''s Moving Castle', 'C', '''Spirited Away,'' directed by Hayao Miyazaki, follows a young girl who becomes trapped working in a magical bathhouse for spirits.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Which animated film franchise, produced by Studio Ghibli, follows a young girl who works in a magical bathhouse for spirits?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'medium', 'Which Italian director, known for "8 1/2" and "La Dolce Vita," is celebrated for his distinctive style blending fantasy and reality?', 'Michelangelo Antonioni', 'Federico Fellini', 'Vittorio De Sica', 'Roberto Rossellini', 'B', 'Federico Fellini, celebrated for films like "8 1/2" and "La Dolce Vita," developed a distinctive cinematic style blending fantastical imagery with realism.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Which Italian director, known for "8 1/2" and "La Dolce Vita," is celebrated for his distinctive style blending fantasy and reality?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'medium', 'Which acclaimed television series, created by Vince Gilligan, follows a lawyer character before the events of "Breaking Bad"?', 'Ozark', 'The Wire', 'Narcos', 'Better Call Saul', 'D', '"Better Call Saul" is a prequel spin-off of "Breaking Bad," focusing on the character Jimmy McGill before he becomes Saul Goodman.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Which acclaimed television series, created by Vince Gilligan, follows a lawyer character before the events of "Breaking Bad"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'medium', 'Which musical genre, originating in Jamaica, is closely associated with artists like Bob Marley?', 'Ska', 'Dancehall', 'Dub', 'Reggae', 'D', 'Reggae, popularized globally by artists like Bob Marley, originated in Jamaica and is known for its distinctive rhythm and often socially conscious lyrics.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'Which musical genre, originating in Jamaica, is closely associated with artists like Bob Marley?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'medium', 'What is the term for the Argentine dance and music style characterized by passionate, close embraces?', 'Tango', 'Salsa', 'Bachata', 'Merengue', 'A', 'Tango, both a music genre and dance style, originated in Buenos Aires, Argentina, known for its passionate and dramatic close embrace.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'What is the term for the Argentine dance and music style characterized by passionate, close embraces?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'medium', 'Which musical genre, blending pop, hip-hop, and electronic influences, achieved massive global popularity from South Korea?', 'J-pop', 'K-pop', 'C-pop', 'Mandopop', 'B', 'K-pop, originating from South Korea, achieved unprecedented global popularity, propelled by groups like BTS and BLACKPINK.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'Which musical genre, blending pop, hip-hop, and electronic influences, achieved massive global popularity from South Korea?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'medium', 'What is the name of the traditional Spanish musical and dance art form associated with the Andalusian region?', 'Tango', 'Salsa', 'Flamenco', 'Fado', 'C', 'Flamenco, originating in Andalusia, Spain, combines passionate singing, guitar playing, and dance in a highly expressive traditional art form.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'What is the name of the traditional Spanish musical and dance art form associated with the Andalusian region?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'medium', 'Which Brazilian musical genre, with syncopated rhythms, is closely associated with the country''s annual Carnival celebrations?', 'Bossa Nova', 'Forro', 'MPB', 'Samba', 'D', 'Samba, with its distinctive syncopated rhythms, is deeply associated with Brazil''s Carnival celebrations and Brazilian cultural identity.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'Which Brazilian musical genre, with syncopated rhythms, is closely associated with the country''s annual Carnival celebrations?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'medium', 'What is the term for a group of musicians playing together, typically featuring string, wind, brass, and percussion instruments?', 'An orchestra', 'A choir', 'A band', 'An ensemble', 'A', 'An orchestra is a large group of musicians playing together, typically featuring string, wind, brass, and percussion sections.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'What is the term for a group of musicians playing together, typically featuring string, wind, brass, and percussion instruments?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'medium', 'Which German composer, one of the most influential in Western classical music, composed the Brandenburg Concertos?', 'Ludwig van Beethoven', 'Wolfgang Amadeus Mozart', 'Johann Sebastian Bach', 'Johannes Brahms', 'C', 'Johann Sebastian Bach, a towering figure of the Baroque era, composed the celebrated Brandenburg Concertos.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'Which German composer, one of the most influential in Western classical music, composed the Brandenburg Concertos?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'medium', 'What is the term for the traditional Hawaiian musical instrument, a small four-stringed instrument resembling a small guitar?', 'Mandolin', 'Banjo', 'Bandurria', 'Ukulele', 'D', 'The ukulele is a small, four-stringed instrument closely associated with Hawaiian music and culture.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'What is the term for the traditional Hawaiian musical instrument, a small four-stringed instrument resembling a small guitar?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'medium', 'Which musical genre, characterized by its strong beat and social commentary, originated in New York City in the 1970s?', 'Hip hop', 'Disco', 'Punk rock', 'Funk', 'A', 'Hip hop emerged from New York City in the 1970s, characterized by rhythmic beats, rapping, and often socially conscious lyrics.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'Which musical genre, characterized by its strong beat and social commentary, originated in New York City in the 1970s?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'medium', 'What is the term for traditional Indian classical music primarily practiced in northern India?', 'Hindustani classical music', 'Carnatic music', 'Qawwali', 'Bhangra', 'A', 'Hindustani classical music is the primary classical music tradition of northern India, distinct from the Carnatic tradition of South India.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'What is the term for traditional Indian classical music primarily practiced in northern India?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'medium', 'Which Austrian composer, a child prodigy, composed over 600 works including symphonies, operas, and chamber music?', 'Wolfgang Amadeus Mozart', 'Ludwig van Beethoven', 'Franz Schubert', 'Joseph Haydn', 'A', 'Wolfgang Amadeus Mozart, a prodigious composer from Austria, produced over 600 works across nearly every genre of classical music.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'Which Austrian composer, a child prodigy, composed over 600 works including symphonies, operas, and chamber music?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'medium', 'What is the term for the traditional Scottish and Irish wind instrument featuring a bag, chanter, and drone pipes?', 'Fiddle', 'Bagpipes', 'Tin whistle', 'Bodhran', 'B', 'Bagpipes, featuring a bag, chanter, and drone pipes, are iconic instruments closely associated with Scottish and Irish musical traditions.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'What is the term for the traditional Scottish and Irish wind instrument featuring a bag, chanter, and drone pipes?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'medium', 'Which Nigerian musical genre, pioneered by Fela Kuti, blends jazz, funk, and traditional Yoruba music?', 'Highlife', 'Juju music', 'Afrobeat', 'Fuji music', 'C', 'Afrobeat, pioneered by Fela Kuti, blends jazz, funk, and traditional Yoruba musical elements, often carrying political and social commentary.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'Which Nigerian musical genre, pioneered by Fela Kuti, blends jazz, funk, and traditional Yoruba music?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'medium', 'What is the term for a piece of music performed by a single vocalist without any instrumental accompaniment?', 'Falsetto', 'Vibrato', 'Recitative', 'A cappella', 'D', 'A cappella refers to vocal music performed entirely without instrumental accompaniment.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'What is the term for a piece of music performed by a single vocalist without any instrumental accompaniment?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'medium', 'Which iconic British rock band, formed in Liverpool in 1960, became one of the most influential groups in music history?', 'The Rolling Stones', 'The Beatles', 'Queen', 'Pink Floyd', 'B', 'The Beatles, formed in Liverpool in 1960, became one of the most commercially successful and influential bands in the history of popular music.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'Which iconic British rock band, formed in Liverpool in 1960, became one of the most influential groups in music history?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'medium', 'Which West African hand drum, played with bare hands, is central to traditional music in countries like Guinea and Mali?', 'Kora', 'Balafon', 'Djembe', 'Talking drum', 'C', 'The djembe, a goblet-shaped hand drum, is a central instrument in traditional West African music, particularly in Guinea and Mali.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'Which West African hand drum, played with bare hands, is central to traditional music in countries like Guinea and Mali?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'medium', 'Which Portuguese musical genre is characterized by melancholic melodies and themes of longing, tied to the concept of "saudade"?', 'Flamenco', 'Fado', 'Tango', 'Rebetiko', 'B', 'Fado, a traditional Portuguese musical genre, is characterized by its melancholic tone and themes of longing, deeply connected to the concept of "saudade."'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'Which Portuguese musical genre is characterized by melancholic melodies and themes of longing, tied to the concept of "saudade"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'medium', 'Which country has won the most FIFA World Cup titles in men''s football, with five championships?', 'Brazil', 'Germany', 'Italy', 'Argentina', 'A', 'Brazil has won the FIFA World Cup a record five times, more than any other national team.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'Which country has won the most FIFA World Cup titles in men''s football, with five championships?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'medium', 'Which term describes a tie score in association football, where neither team wins?', 'A forfeit', 'A bye', 'A draw', 'A rematch', 'C', 'A draw occurs in football when both teams finish a match with an equal score, resulting in neither side winning.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'Which term describes a tie score in association football, where neither team wins?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'medium', 'Which sport is played at the Wimbledon Championships, one of the oldest and most prestigious tournaments in the world?', 'Tennis', 'Golf', 'Cricket', 'Rugby', 'A', 'Wimbledon is one of the oldest and most prestigious tournaments in tennis, held annually in London, England.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'Which sport is played at the Wimbledon Championships, one of the oldest and most prestigious tournaments in the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'medium', 'What is the maximum number of players allowed on a basketball court for one team during active play?', 'Six', 'Seven', 'Five', 'Eleven', 'C', 'In basketball, each team is allowed a maximum of five players on the court at any given time during active play.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'What is the maximum number of players allowed on a basketball court for one team during active play?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'medium', 'Which country''s national rugby team is known by the nickname ''the All Blacks''?', 'Australia', 'South Africa', 'England', 'New Zealand', 'D', 'New Zealand''s national rugby union team, the All Blacks, is one of the most successful and recognizable teams in international rugby.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'Which country''s national rugby team is known by the nickname ''the All Blacks''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'medium', 'What is the term for a boxing match victory achieved by rendering an opponent unable to continue, whether by knockout or stoppage?', 'A win by decision', 'A win by knockout (KO) or technical knockout (TKO)', 'A draw', 'A disqualification', 'B', 'A knockout victory occurs when an opponent is rendered unable to continue the match, either through a full knockout or a referee-stopped technical knockout.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'What is the term for a boxing match victory achieved by rendering an opponent unable to continue, whether by knockout or stoppage?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'medium', 'Which cycling race, held annually since 1903, is considered the most prestigious multi-stage race in the sport?', 'The Giro d''Italia', 'The Vuelta a España', 'Paris-Roubaix', 'The Tour de France', 'D', 'The Tour de France, first held in 1903, is widely regarded as cycling''s most prestigious and demanding annual multi-stage race.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'Which cycling race, held annually since 1903, is considered the most prestigious multi-stage race in the sport?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'medium', 'What is the term for the position in American football responsible for throwing passes and directing the offense?', 'Running back', 'Wide receiver', 'Tight end', 'Quarterback', 'D', 'The quarterback is the offensive player primarily responsible for throwing passes and directing the team''s offensive strategy.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'What is the term for the position in American football responsible for throwing passes and directing the offense?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'medium', 'Which sport features events such as the 100-meter dash, marathon, and long jump, commonly held at the Olympics?', 'Swimming', 'Track and field (athletics)', 'Gymnastics', 'Cycling', 'B', 'Track and field, also called athletics, encompasses events including sprints, distance running, and jumping competitions, a core part of the Olympic Games.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'Which sport features events such as the 100-meter dash, marathon, and long jump, commonly held at the Olympics?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'medium', 'What is the term for cricket''s rare achievement of a bowler dismissing three batsmen with three consecutive deliveries?', 'A century', 'A hat-trick', 'A maiden over', 'A duck', 'B', 'A hat-trick in cricket occurs when a bowler dismisses three batsmen with three consecutive deliveries, a rare and celebrated feat.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'What is the term for cricket''s rare achievement of a bowler dismissing three batsmen with three consecutive deliveries?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'medium', 'Which country has historically dominated Olympic gymnastics, amassing more medals in the sport than any other nation?', 'China', 'Romania', 'United States', 'Russia (and formerly the Soviet Union)', 'D', 'The Soviet Union, and later Russia, has historically dominated Olympic gymnastics, winning more medals in the sport than any other nation.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'Which country has historically dominated Olympic gymnastics, amassing more medals in the sport than any other nation?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'medium', 'What is the term for the position in association football responsible for preventing goals using their hands within the penalty area?', 'Defender', 'Midfielder', 'Goalkeeper', 'Forward', 'C', 'The goalkeeper is the only player on a football team permitted to use their hands within the penalty area, tasked with preventing goals.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'What is the term for the position in association football responsible for preventing goals using their hands within the penalty area?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'medium', 'Which martial art, originating in Japan, emphasizes throws and grappling techniques, and is an Olympic sport?', 'Karate', 'Taekwondo', 'Judo', 'Aikido', 'C', 'Judo, originating in Japan, emphasizes throws and grappling techniques and has been a mainstay Olympic sport since 1964.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'Which martial art, originating in Japan, emphasizes throws and grappling techniques, and is an Olympic sport?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'medium', 'What is the term for a perfect score of 300 in ten-pin bowling, achieved through twelve consecutive strikes?', 'A perfect game', 'A turkey', 'A spare', 'A split', 'A', 'A perfect game in ten-pin bowling requires twelve consecutive strikes, resulting in the maximum possible score of 300.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'What is the term for a perfect score of 300 in ten-pin bowling, achieved through twelve consecutive strikes?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'medium', 'Which Grand Slam tennis tournament is played on clay courts in Paris, France?', 'Wimbledon', 'The French Open (Roland Garros)', 'The US Open', 'The Australian Open', 'B', 'The French Open, held at Roland Garros in Paris, is the only Grand Slam tennis tournament played on clay courts.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'Which Grand Slam tennis tournament is played on clay courts in Paris, France?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'medium', 'What is the term for a swimming stroke featuring a whip-like kick and simultaneous arm movements, generally the slowest of the competitive strokes?', 'Breaststroke', 'Butterfly', 'Freestyle', 'Backstroke', 'A', 'Breaststroke, featuring simultaneous frog-like arm and leg movements, is generally the slowest of the four competitive swimming strokes.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'What is the term for a swimming stroke featuring a whip-like kick and simultaneous arm movements, generally the slowest of the competitive strokes?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'medium', 'Which country won the first-ever Cricket World Cup, held in 1975?', 'The West Indies', 'England', 'Australia', 'India', 'A', 'The West Indies won the inaugural Cricket World Cup in 1975, establishing themselves as an early dominant force in the sport.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'Which country won the first-ever Cricket World Cup, held in 1975?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'medium', 'Which American company, founded by Steve Jobs and Steve Wozniak, developed the iPhone and Macintosh computers?', 'Apple', 'Microsoft', 'Google', 'IBM', 'A', 'Apple, co-founded by Steve Jobs and Steve Wozniak, developed iconic products including the iPhone and the Macintosh line of computers.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'Which American company, founded by Steve Jobs and Steve Wozniak, developed the iPhone and Macintosh computers?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'medium', 'What is the name of the South Korean company that is the world''s largest manufacturer of smartphones and memory chips?', 'LG Electronics', 'Samsung Electronics', 'SK Hynix', 'Hyundai', 'B', 'Samsung Electronics is the world''s largest manufacturer of memory chips and has for years led global smartphone shipments.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'What is the name of the South Korean company that is the world''s largest manufacturer of smartphones and memory chips?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'medium', 'Which technology company developed the widely used Windows operating system for personal computers?', 'Microsoft', 'Apple', 'Google', 'IBM', 'A', 'Microsoft developed the Windows operating system, which has become one of the most widely used operating systems for personal computers worldwide.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'Which technology company developed the widely used Windows operating system for personal computers?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'medium', 'What is the name of the Chinese short-video social media app that became a global cultural phenomenon in the late 2010s?', 'WeChat', 'Weibo', 'Kuaishou', 'TikTok', 'D', 'TikTok, developed by the Chinese company ByteDance, became a massive global cultural phenomenon, especially among younger users.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'What is the name of the Chinese short-video social media app that became a global cultural phenomenon in the late 2010s?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'medium', 'Which company, founded by Jeff Bezos in 1994, began as an online bookstore before becoming one of the world''s largest e-commerce companies?', 'Amazon', 'eBay', 'Alibaba', 'Walmart', 'A', 'Amazon, founded by Jeff Bezos in 1994, began as an online bookstore before growing into one of the world''s largest e-commerce and technology companies.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'Which company, founded by Jeff Bezos in 1994, began as an online bookstore before becoming one of the world''s largest e-commerce companies?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'medium', 'What is the name of the search engine company founded in 1998 that later became one of the world''s most valuable technology companies?', 'Google', 'Yahoo', 'Bing', 'AltaVista', 'A', 'Google was founded in 1998 as a search engine and grew into one of the world''s most valuable and influential technology companies.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'What is the name of the search engine company founded in 1998 that later became one of the world''s most valuable technology companies?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'medium', 'Which technology company developed the Android operating system, widely used on smartphones around the world?', 'Apple', 'Samsung', 'Microsoft', 'Google', 'D', 'Google developed the Android operating system, which has become one of the most widely used mobile operating systems globally.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'Which technology company developed the Android operating system, widely used on smartphones around the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'medium', 'What is the name of the social media platform, launched in 2004, that was originally created exclusively for college students?', 'Facebook', 'Twitter (now X)', 'Instagram', 'LinkedIn', 'A', 'Facebook launched in 2004 as a platform originally restricted to college students before expanding into a global social network.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'What is the name of the social media platform, launched in 2004, that was originally created exclusively for college students?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'medium', 'Which company, founded in China by Jack Ma, became one of the largest e-commerce and technology conglomerates in the world?', 'Tencent', 'Baidu', 'Alibaba', 'JD.com', 'C', 'Alibaba, founded by Jack Ma in 1999, grew into one of the largest e-commerce and technology conglomerates in the world.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'Which company, founded in China by Jack Ma, became one of the largest e-commerce and technology conglomerates in the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'medium', 'What is the name of the video-sharing platform, launched in 2005, that became one of the most popular websites for watching and uploading videos?', 'Vimeo', 'YouTube', 'Twitch', 'Dailymotion', 'B', 'YouTube, launched in 2005, became one of the most popular platforms in the world for uploading and watching video content.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'What is the name of the video-sharing platform, launched in 2005, that became one of the most popular websites for watching and uploading videos?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'medium', 'Which Taiwanese company is the world''s largest dedicated semiconductor manufacturer, producing chips for companies like Apple and Nvidia?', 'MediaTek', 'TSMC (Taiwan Semiconductor Manufacturing Company)', 'Foxconn', 'UMC', 'B', 'TSMC is the world''s largest dedicated semiconductor foundry, manufacturing chips designed by companies including Apple, Nvidia, and AMD.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'Which Taiwanese company is the world''s largest dedicated semiconductor manufacturer, producing chips for companies like Apple and Nvidia?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'medium', 'What is the name of the ride-sharing and delivery technology company, founded in 2009, that pioneered the modern app-based rideshare industry?', 'Lyft', 'Grab', 'Uber', 'DiDi', 'C', 'Uber, founded in 2009, pioneered the modern app-based rideshare industry and later expanded into food delivery and other services.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'What is the name of the ride-sharing and delivery technology company, founded in 2009, that pioneered the modern app-based rideshare industry?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'medium', 'Which technology company, known for its social media platform, owns Instagram and WhatsApp?', 'Google (Alphabet)', 'Microsoft', 'Meta (formerly Facebook)', 'Twitter (X)', 'C', 'Meta, formerly known as Facebook, owns and operates several major platforms including Instagram and WhatsApp.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'Which technology company, known for its social media platform, owns Instagram and WhatsApp?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'medium', 'What is the name of the electric vehicle and clean energy company founded by Elon Musk, known for its Model 3 and Model Y vehicles?', 'Rivian', 'Lucid Motors', 'NIO', 'Tesla', 'D', 'Tesla, founded and led by Elon Musk, is a prominent electric vehicle and clean energy company known for models including the Model 3 and Model Y.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'What is the name of the electric vehicle and clean energy company founded by Elon Musk, known for its Model 3 and Model Y vehicles?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'medium', 'Which term describes the technology enabling computers and smartphones to connect wirelessly to the internet using radio waves?', 'Bluetooth', 'NFC', 'Cellular data', 'Wi-Fi', 'D', 'Wi-Fi is a wireless networking technology that allows devices to connect to the internet using radio waves within a local area.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'Which term describes the technology enabling computers and smartphones to connect wirelessly to the internet using radio waves?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'medium', 'What is the name of the streaming service, launched in 2007, that transitioned from DVD rentals to become a global leader in online video streaming?', 'Hulu', 'Amazon Prime Video', 'Netflix', 'Disney+', 'C', 'Netflix transitioned from its original DVD rental business to become a global leader in online video streaming, beginning in 2007.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'What is the name of the streaming service, launched in 2007, that transitioned from DVD rentals to become a global leader in online video streaming?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'medium', 'Which Dutch company is the world''s leading manufacturer of photolithography machines essential for producing advanced semiconductor chips?', 'NXP Semiconductors', 'ASML', 'Philips', 'Besi', 'B', 'ASML, based in the Netherlands, is the world''s leading manufacturer of the extreme ultraviolet lithography machines essential for producing the most advanced semiconductor chips.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'Which Dutch company is the world''s leading manufacturer of photolithography machines essential for producing advanced semiconductor chips?'
);
