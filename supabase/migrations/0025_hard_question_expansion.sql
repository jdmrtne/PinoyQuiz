-- Pinoy Quiz — 0025: hard-difficulty question expansion (Phase 17)
--
-- Tops up every category to 20 hard-difficulty questions. Prior to this
-- migration, hard-question counts per category ranged from 1 (provinces_cities)
-- to 15 (science); this migration adds exactly the number of new hard
-- questions needed to bring each of the 44 existing categories up to 20,
-- for 707 new rows total. No existing rows are modified, removed, or
-- duplicated -- this migration only adds new rows.
--
-- Correct-answer letters are shuffled across A/B/C/D per question (not
-- left defaulted to 'A') to avoid reintroducing the answer-distribution
-- skew documented as a known issue in the original 80-question set.
--
-- Idempotency: same NOT EXISTS guard per row (matching on category +
-- prompt) as every prior question migration, so this is safe to re-run.

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'hard', 'Which animal is known for having a bite force strong enough to crush turtle shells, and is the largest living reptile?', 'Komodo dragon', 'Green anaconda', 'American alligator', 'Saltwater crocodile', 'D', 'The saltwater crocodile has the strongest bite force of any living animal and is the largest living reptile species.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'Which animal is known for having a bite force strong enough to crush turtle shells, and is the largest living reptile?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'hard', 'What is the only mammal capable of true sustained flight?', 'Bat', 'Flying squirrel', 'Sugar glider', 'Colugo', 'A', 'Bats are the only mammals capable of true, sustained, powered flight, unlike gliding mammals such as flying squirrels.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'What is the only mammal capable of true sustained flight?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'hard', 'Which animal has a gestation period of about 22 months, the longest of any land mammal?', 'African elephant', 'Blue whale', 'Giraffe', 'Rhinoceros', 'A', 'The African elephant has a gestation period of roughly 22 months, the longest of any land mammal.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'Which animal has a gestation period of about 22 months, the longest of any land mammal?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'hard', 'What is the term for a group of crows, notably associated with omens in folklore?', 'A parliament', 'A murder', 'A gaggle', 'A charm', 'B', 'A group of crows is traditionally called a ''murder,'' a term with roots in old folklore associating crows with death.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'What is the term for a group of crows, notably associated with omens in folklore?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'hard', 'Which shark species is known to be warm-blooded (endothermic), unlike most fish?', 'Whale shark', 'Nurse shark', 'Great white shark', 'Hammerhead shark', 'C', 'The great white shark is partially endothermic, able to maintain a body temperature higher than the surrounding water, unlike most fish.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'Which shark species is known to be warm-blooded (endothermic), unlike most fish?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'hard', 'What is unique about the axolotl''s biological ability that makes it a subject of regenerative medicine research?', 'It can change gender at will', 'It can regenerate entire limbs, its spinal cord, and even parts of its brain', 'It can survive freezing solid', 'It can regrow its entire digestive system only', 'B', 'Axolotls have remarkable regenerative abilities, able to regrow limbs, spinal cord tissue, and even portions of their brain and heart.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'What is unique about the axolotl''s biological ability that makes it a subject of regenerative medicine research?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'hard', 'Which bird is known for the male building elaborate structures decorated with colorful objects to attract mates?', 'Peacock', 'Bowerbird', 'Bird of paradise', 'Weaver bird', 'B', 'Male bowerbirds construct and decorate elaborate structures called bowers using colorful objects to attract females.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'Which bird is known for the male building elaborate structures decorated with colorful objects to attract mates?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'hard', 'What is the term for animals that are active primarily during twilight hours, like dawn and dusk?', 'Crepuscular', 'Nocturnal', 'Diurnal', 'Cathemeral', 'A', 'Crepuscular animals are most active during the twilight periods of dawn and dusk.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'What is the term for animals that are active primarily during twilight hours, like dawn and dusk?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'hard', 'Which large cat species is the only big cat that cannot roar, instead purring like domestic cats?', 'Tiger', 'Cougar (mountain lion)', 'Jaguar', 'Snow leopard', 'B', 'The cougar lacks the specialized larynx structure needed to roar and instead produces sounds like purring, similar to smaller cats.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'Which large cat species is the only big cat that cannot roar, instead purring like domestic cats?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'hard', 'What is the primary reason octopuses are considered highly intelligent despite having a short lifespan?', 'They live in large, complex social colonies', 'They have the largest brain-to-body ratio of any animal', 'They have a highly distributed nervous system with neurons in their arms enabling complex problem-solving', 'They can communicate through a spoken language', 'C', 'Octopuses possess a unique distributed nervous system, with roughly two-thirds of their neurons located in their arms, enabling remarkable problem-solving.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'What is the primary reason octopuses are considered highly intelligent despite having a short lifespan?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'hard', 'Which animal''s heart rate can drop to just a few beats per minute during deep dives to conserve oxygen?', 'Elephant', 'Ostrich', 'Kangaroo', 'Sperm whale (and other diving mammals)', 'D', 'Diving mammals like sperm whales exhibit a dramatic slowing of heart rate, called bradycardia, to conserve oxygen during deep dives.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'Which animal''s heart rate can drop to just a few beats per minute during deep dives to conserve oxygen?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'hard', 'What is the term for the process by which some animal species can change their biological sex during their lifetime?', 'Sequential hermaphroditism', 'Parthenogenesis', 'Diapause', 'Metamorphosis', 'A', 'Sequential hermaphroditism describes species, like certain fish, that change sex at some point during their life cycle.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'What is the term for the process by which some animal species can change their biological sex during their lifetime?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'hard', 'Which animal is famous for possessing venom potent enough to be among the most toxic of any land animal, despite its small size?', 'King cobra', 'Black mamba', 'Gaboon viper', 'Inland taipan', 'D', 'The inland taipan possesses the most toxic venom of any land snake based on LD50 measurements, though it''s a shy, non-aggressive species.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'Which animal is famous for possessing venom potent enough to be among the most toxic of any land animal, despite its small size?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'hard', 'What is the term for the specialized organ some snakes use to detect infrared radiation from warm-blooded prey?', 'Jacobson''s organ', 'Pit organ (loreal pit)', 'Lateral line', 'Ampullae of Lorenzini', 'B', 'Pit vipers possess heat-sensing pit organs that detect infrared radiation, helping them locate warm-blooded prey in darkness.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'What is the term for the specialized organ some snakes use to detect infrared radiation from warm-blooded prey?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'hard', 'Which bird species undertakes the longest known migration of any animal, flying from the Arctic to Antarctica annually?', 'Bar-tailed godwit', 'Sooty shearwater', 'Arctic skua', 'Arctic tern', 'D', 'The Arctic tern holds the record for the longest annual migration of any animal, traveling from Arctic breeding grounds to Antarctic waters.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'Which bird species undertakes the longest known migration of any animal, flying from the Arctic to Antarctica annually?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'hard', 'What sensory system do sharks use to detect the faint electrical fields generated by other animals'' muscle contractions?', 'Ampullae of Lorenzini', 'Lateral line system', 'Jacobson''s organ', 'Pit organs', 'A', 'Sharks possess electroreceptor organs called the ampullae of Lorenzini, which detect minute electrical fields produced by other animals.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'What sensory system do sharks use to detect the faint electrical fields generated by other animals'' muscle contractions?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'hard', 'Which mammal holds the record for the longest gestation period of any mammal, at approximately 22 months?', 'Blue whale', 'Giraffe', 'African elephant', 'Sperm whale', 'C', 'The African elephant has the longest gestation period of any mammal, lasting approximately 22 months.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'Which mammal holds the record for the longest gestation period of any mammal, at approximately 22 months?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'animals', 'hard', 'What is the term for an animal''s ability to detect the Earth''s magnetic field for navigation, seen in birds and sea turtles?', 'Echolocation', 'Thermoreception', 'Magnetoreception', 'Chemoreception', 'C', 'Magnetoreception is the sense that allows certain animals, including migratory birds and sea turtles, to detect the Earth''s magnetic field for navigation.'
where not exists (
  select 1 from questions where category = 'animals' and prompt = 'What is the term for an animal''s ability to detect the Earth''s magnetic field for navigation, seen in birds and sea turtles?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'hard', 'Which art movement, pioneered by Pablo Picasso and Georges Braque, depicted subjects from multiple viewpoints simultaneously?', 'Cubism', 'Fauvism', 'Surrealism', 'Expressionism', 'A', 'Cubism, developed by Picasso and Braque in the early 20th century, fragmented subjects into geometric forms shown from multiple angles at once.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'Which art movement, pioneered by Pablo Picasso and Georges Braque, depicted subjects from multiple viewpoints simultaneously?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'hard', 'What technique, pioneered during the Renaissance, uses gradual transitions between light and shadow to create the illusion of three-dimensional form?', 'Chiaroscuro', 'Impasto', 'Grisaille', 'Sfumato', 'D', 'Sfumato, notably used by Leonardo da Vinci, blends tones and colors so subtly that there are no harsh edges, giving a soft, smoky effect.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'What technique, pioneered during the Renaissance, uses gradual transitions between light and shadow to create the illusion of three-dimensional form?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'hard', 'Which art movement, emerging in the 1950s, emphasized flat areas of color and hard edges, minimizing gestural brushwork?', 'Abstract Expressionism', 'Pop Art', 'Color Field painting', 'Minimalism', 'C', 'Color Field painting focused on large expanses of flat, solid color, contrasting with the gestural energy of Abstract Expressionism.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'Which art movement, emerging in the 1950s, emphasized flat areas of color and hard edges, minimizing gestural brushwork?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'hard', 'What is the term for a painting technique involving the application of paint in thick layers, creating visible brush or palette knife strokes?', 'Impasto', 'Sfumato', 'Glazing', 'Scumbling', 'A', 'Impasto refers to paint applied thickly enough to retain visible brush or knife marks, adding texture and dimensionality.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'What is the term for a painting technique involving the application of paint in thick layers, creating visible brush or palette knife strokes?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'hard', 'Which Baroque painter is renowned for dramatic use of light and shadow known as tenebrism, seen in works like ''The Calling of St. Matthew''?', 'Caravaggio', 'Rembrandt', 'Peter Paul Rubens', 'Diego Velazquez', 'A', 'Caravaggio pioneered tenebrism, an extreme form of chiaroscuro with dramatic, high-contrast lighting, influencing generations of Baroque painters.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'Which Baroque painter is renowned for dramatic use of light and shadow known as tenebrism, seen in works like ''The Calling of St. Matthew''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'hard', 'What is the term for a sculptural technique of removing material, as opposed to modeling by adding material?', 'Casting', 'Carving (subtractive sculpture)', 'Assemblage', 'Additive sculpture', 'B', 'Carving is a subtractive process where material like stone or wood is removed to reveal the final form, contrasting with additive modeling.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'What is the term for a sculptural technique of removing material, as opposed to modeling by adding material?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'hard', 'Which art historical period, following the Renaissance, is characterized by dramatic movement, rich color, and intense light and dark contrasts?', 'Rococo', 'Neoclassicism', 'Mannerism', 'Baroque', 'D', 'The Baroque period, roughly 1600-1750, emphasized drama, grandeur, movement, and strong contrasts of light and shadow.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'Which art historical period, following the Renaissance, is characterized by dramatic movement, rich color, and intense light and dark contrasts?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'hard', 'What is the name of the art movement that emerged in reaction to Impressionism, using systematic dots of color, pioneered by Georges Seurat?', 'Post-Impressionism broadly', 'Divisionism as a separate school', 'Pointillism (Neo-Impressionism)', 'Fauvism', 'C', 'Pointillism, developed by Seurat, applied small, distinct dots of color that blend visually from a distance, a technique also called Divisionism.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'What is the name of the art movement that emerged in reaction to Impressionism, using systematic dots of color, pioneered by Georges Seurat?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'hard', 'Which term describes a painting or artwork''s overall arrangement of visual elements, including balance, contrast, and emphasis?', 'Perspective', 'Composition', 'Proportion', 'Iconography', 'B', 'Composition refers to how visual elements are arranged within an artwork to create balance, unity, and visual interest.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'Which term describes a painting or artwork''s overall arrangement of visual elements, including balance, contrast, and emphasis?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'hard', 'What is the name of the art movement that rejected traditional aesthetics, embracing chance, absurdity, and anti-art sentiment after World War I?', 'Surrealism', 'Dadaism', 'Futurism', 'Constructivism', 'B', 'Dadaism arose as a reaction to the horrors of World War I, rejecting logic and traditional aesthetics in favor of absurdity and chance.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'What is the name of the art movement that rejected traditional aesthetics, embracing chance, absurdity, and anti-art sentiment after World War I?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'hard', 'Which technique involves applying thin, translucent layers of paint over a dried layer to modify color and add depth?', 'Glazing', 'Impasto', 'Scumbling', 'Underpainting', 'A', 'Glazing involves applying transparent layers of paint over dried underlayers, subtly altering color and adding luminous depth.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'Which technique involves applying thin, translucent layers of paint over a dried layer to modify color and add depth?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'hard', 'What is the term for the golden ratio''s application in art and architecture to achieve aesthetically pleasing proportions?', 'The Rule of Thirds', 'The Fibonacci Spiral exclusively', 'The Vitruvian Ratio', 'The Golden Section (or Divine Proportion)', 'D', 'The Golden Section, an irrational proportion roughly 1:1.618, has long been used by artists and architects for aesthetically balanced compositions.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'What is the term for the golden ratio''s application in art and architecture to achieve aesthetically pleasing proportions?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'hard', 'Which 20th-century art movement, associated with Andy Warhol, drew imagery from mass media and consumer culture?', 'Op Art', 'Pop Art', 'Minimalism', 'Conceptual Art', 'B', 'Pop Art, championed by figures like Andy Warhol, incorporated imagery from advertising, comic books, and mass-produced consumer goods.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'Which 20th-century art movement, associated with Andy Warhol, drew imagery from mass media and consumer culture?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'hard', 'What is the term for artwork created directly on a wall or ceiling using pigment applied to wet plaster?', 'Fresco', 'Tempera', 'Mural (general term)', 'Encaustic', 'A', 'Fresco painting involves applying pigment to wet plaster, allowing the paint to become part of the wall as it dries, famously used by Michelangelo.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'What is the term for artwork created directly on a wall or ceiling using pigment applied to wet plaster?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'hard', 'Which art movement, led by artists like Wassily Kandinsky, is credited as among the first to fully abandon representational subject matter?', 'Cubism', 'Fauvism', 'Abstract art (early 20th-century pioneers)', 'Futurism', 'C', 'Wassily Kandinsky is often credited as a pioneer of fully non-representational abstract art in the early 20th century.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'Which art movement, led by artists like Wassily Kandinsky, is credited as among the first to fully abandon representational subject matter?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'hard', 'What is the term for a preliminary sketch or drawing made in preparation for a larger artwork, especially in fresco painting?', 'Study', 'Maquette', 'Cartoon (from Italian ''cartone'')', 'Underdrawing', 'C', 'A ''cartoon,'' from the Italian ''cartone,'' refers to a full-size preparatory drawing, historically used to transfer designs onto walls or canvases for frescoes.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'What is the term for a preliminary sketch or drawing made in preparation for a larger artwork, especially in fresco painting?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'hard', 'Which Dutch Golden Age painter is best known for intimate domestic scenes and masterful use of light, as in ''Girl with a Pearl Earring''?', 'Rembrandt van Rijn', 'Frans Hals', 'Jan Steen', 'Johannes Vermeer', 'D', 'Johannes Vermeer is renowned for his luminous, intimate domestic scenes, most famously ''Girl with a Pearl Earring.'''
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'Which Dutch Golden Age painter is best known for intimate domestic scenes and masterful use of light, as in ''Girl with a Pearl Earring''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'arts', 'hard', 'What is the term for a three-dimensional artwork made by assembling found or everyday objects, associated with artists like Robert Rauschenberg?', 'Collage', 'Assemblage', 'Installation', 'Readymade', 'B', 'Assemblage art involves constructing three-dimensional works from found objects and materials, distinct from flat collage.'
where not exists (
  select 1 from questions where category = 'arts' and prompt = 'What is the term for a three-dimensional artwork made by assembling found or everyday objects, associated with artists like Robert Rauschenberg?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'hard', 'What economic term describes a situation where a single seller dominates a market, controlling supply and pricing?', 'Oligopoly', 'Monopoly', 'Monopsony', 'Duopoly', 'B', 'A monopoly exists when a single firm dominates an entire market, having significant control over price and supply.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'What economic term describes a situation where a single seller dominates a market, controlling supply and pricing?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'hard', 'Which economic indicator measures the total value of goods and services produced within a country''s borders in a given period?', 'Gross National Product (GNP)', 'Gross Domestic Product (GDP)', 'Consumer Price Index (CPI)', 'Purchasing Power Parity (PPP)', 'B', 'GDP measures the total monetary value of all goods and services produced within a country''s borders during a specific period.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'Which economic indicator measures the total value of goods and services produced within a country''s borders in a given period?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'hard', 'What term describes a market structure where a small number of firms dominate, often leading to interdependent pricing decisions?', 'Oligopoly', 'Monopoly', 'Perfect competition', 'Monopsony', 'A', 'An oligopoly is a market dominated by a small number of large firms, whose pricing and output decisions are often interdependent.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'What term describes a market structure where a small number of firms dominate, often leading to interdependent pricing decisions?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'hard', 'Which economic theory suggests that government spending and tax policies can be used to influence economic performance, associated with John Maynard Keynes?', 'Keynesian economics', 'Monetarism', 'Supply-side economics', 'Classical economics', 'A', 'Keynesian economics argues that active government intervention, through fiscal policy, can help stabilize economic output and employment.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'Which economic theory suggests that government spending and tax policies can be used to influence economic performance, associated with John Maynard Keynes?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'hard', 'What is the term for the situation in which a currency''s value is allowed to fluctuate freely based on market forces?', 'Floating exchange rate', 'Fixed exchange rate', 'Pegged exchange rate', 'Managed float exclusively', 'A', 'A floating exchange rate is determined by supply and demand in the foreign exchange market without direct government intervention.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'What is the term for the situation in which a currency''s value is allowed to fluctuate freely based on market forces?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'hard', 'Which concept describes the additional satisfaction a consumer gains from consuming one more unit of a good, generally decreasing with each unit?', 'Opportunity cost', 'Marginal utility', 'Consumer surplus', 'Elasticity of demand', 'B', 'Marginal utility refers to the extra satisfaction gained from consuming an additional unit of a good, typically diminishing as consumption increases.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'Which concept describes the additional satisfaction a consumer gains from consuming one more unit of a good, generally decreasing with each unit?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'hard', 'What economic term refers to the value of the next best alternative that must be forgone when making a choice?', 'Sunk cost', 'Opportunity cost', 'Marginal cost', 'Fixed cost', 'B', 'Opportunity cost represents the value of the best alternative forgone when a particular choice is made.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'What economic term refers to the value of the next best alternative that must be forgone when making a choice?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'hard', 'Which type of unemployment results from the natural time it takes for workers to find new jobs matching their skills?', 'Structural unemployment', 'Cyclical unemployment', 'Frictional unemployment', 'Seasonal unemployment', 'C', 'Frictional unemployment arises from the normal time lag between jobs, as workers search for positions that match their skills.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'Which type of unemployment results from the natural time it takes for workers to find new jobs matching their skills?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'hard', 'What is the term for a central bank''s policy of buying government securities to increase money supply and stimulate the economy?', 'Fiscal stimulus', 'Currency devaluation', 'Austerity', 'Quantitative easing', 'D', 'Quantitative easing involves a central bank purchasing financial assets, typically government bonds, to inject liquidity and stimulate economic activity.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'What is the term for a central bank''s policy of buying government securities to increase money supply and stimulate the economy?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'hard', 'Which economic term describes a sustained increase in the general price level of goods and services over time?', 'Deflation', 'Stagflation', 'Inflation', 'Disinflation', 'C', 'Inflation refers to a general and sustained rise in the price level of goods and services in an economy over time.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'Which economic term describes a sustained increase in the general price level of goods and services over time?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'hard', 'What is the term for a scenario combining stagnant economic growth with high inflation and high unemployment?', 'Recession', 'Stagflation', 'Depression', 'Deflation', 'B', 'Stagflation describes the unusual combination of slow economic growth, high unemployment, and high inflation occurring simultaneously.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'What is the term for a scenario combining stagnant economic growth with high inflation and high unemployment?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'hard', 'Which business strategy involves a company acquiring a supplier or a distributor to control more of its supply chain?', 'Vertical integration', 'Horizontal integration', 'Diversification', 'Conglomeration', 'A', 'Vertical integration occurs when a company expands by acquiring businesses at different stages of the same supply chain, such as suppliers or distributors.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'Which business strategy involves a company acquiring a supplier or a distributor to control more of its supply chain?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'hard', 'What is the term for the accounting principle requiring revenue to be recorded when earned, not necessarily when cash is received?', 'Cash accounting', 'Matching principle exclusively', 'Realization principle exclusively', 'Accrual accounting', 'D', 'Accrual accounting recognizes revenue when it is earned and expenses when incurred, regardless of when cash actually changes hands.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'What is the term for the accounting principle requiring revenue to be recorded when earned, not necessarily when cash is received?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'hard', 'Which economic measure adjusts nominal GDP for price changes to reflect the actual volume of goods and services produced?', 'Nominal GDP', 'Potential GDP', 'Real GDP', 'GDP per capita', 'C', 'Real GDP adjusts for inflation, providing a more accurate measure of an economy''s actual output over time compared to nominal GDP.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'Which economic measure adjusts nominal GDP for price changes to reflect the actual volume of goods and services produced?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'hard', 'What term describes a firm''s ability to influence market price due to lacking perfect competition, common in monopolistic competition?', 'Market equilibrium', 'Consumer surplus', 'Market power', 'Elastic demand', 'C', 'Market power refers to a firm''s ability to raise prices above competitive levels due to imperfect competition in its market.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'What term describes a firm''s ability to influence market price due to lacking perfect competition, common in monopolistic competition?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'hard', 'Which financial term refers to the risk that a borrower will fail to meet their debt obligations?', 'Market risk', 'Liquidity risk', 'Operational risk', 'Credit risk (default risk)', 'D', 'Credit risk, or default risk, refers to the possibility that a borrower will fail to make required debt payments.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'Which financial term refers to the risk that a borrower will fail to meet their debt obligations?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'hard', 'What economic principle states that as more of a variable input is added to fixed inputs, the additional output eventually declines?', 'The law of diminishing marginal returns', 'The law of supply', 'The law of demand', 'Say''s Law', 'A', 'The law of diminishing marginal returns states that adding more of one input while holding others fixed eventually yields smaller increases in output.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'What economic principle states that as more of a variable input is added to fixed inputs, the additional output eventually declines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'business_economics', 'hard', 'Which term describes the total amount of money a country owes to external creditors, including foreign governments and institutions?', 'Internal debt', 'Public debt (domestic)', 'Fiscal deficit', 'External debt', 'D', 'External debt refers to the portion of a country''s total debt that is owed to creditors outside the country.'
where not exists (
  select 1 from questions where category = 'business_economics' and prompt = 'Which term describes the total amount of money a country owes to external creditors, including foreign governments and institutions?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'hard', 'Which Filipino actress and singer is known as the ''Star for All Seasons'' and has had a decades-long career spanning film, music, and politics?', 'Vilma Santos', 'Nora Aunor', 'Sharon Cuneta', 'Gloria Diaz', 'A', 'Vilma Santos is popularly known as the ''Star for All Seasons,'' recognized for her versatility across acting, singing, and later politics.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipino actress and singer is known as the ''Star for All Seasons'' and has had a decades-long career spanning film, music, and politics?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'hard', 'Which Filipino-American celebrity chef became the first Filipino to win the James Beard Award for Best Chef, awarded in 2018?', 'Nicole Ponseca', 'Bad Saint''s chef Tom Cunanan (technically for the restaurant)', 'Chele Gonzalez', 'Rob Pengson', 'B', 'Tom Cunanan of Bad Saint restaurant won the James Beard Award for Best Chef: Mid-Atlantic in 2018, a milestone for Filipino-American cuisine.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipino-American celebrity chef became the first Filipino to win the James Beard Award for Best Chef, awarded in 2018?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'hard', 'Which Filipina became the first Miss Universe titleholder from the Philippines, winning in 1969?', 'Margarita Moran', 'Pia Wurtzbach', 'Gloria Diaz', 'Catriona Gray', 'C', 'Gloria Diaz became the Philippines'' first Miss Universe titleholder in 1969, a landmark moment for the country in international pageantry.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipina became the first Miss Universe titleholder from the Philippines, winning in 1969?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'hard', 'Which Filipino boxer-turned-politician served as a Philippine senator while continuing his professional boxing career?', 'Nonito Donaire', 'Manny Pacquiao', 'Gerry Peñalosa', 'Rey Bautista', 'B', 'Manny Pacquiao served as a Philippine senator from 2016 to 2022, continuing to box professionally during parts of his political tenure.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipino boxer-turned-politician served as a Philippine senator while continuing his professional boxing career?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'hard', 'Which Filipino singer, known as the ''Asia''s Songbird,'' has had major international success including performances at Wimbledon and for popes?', 'Lea Salonga', 'Sarah Geronimo', 'Regine Velasquez', 'Kyla', 'C', 'Regine Velasquez, dubbed ''Asia''s Songbird,'' is renowned for her vocal range and has performed at prestigious international events.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipino singer, known as the ''Asia''s Songbird,'' has had major international success including performances at Wimbledon and for popes?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'hard', 'Which Filipina actress won a Tony Award for originating the role of Kim in the musical ''Miss Saigon''?', 'Lea Salonga', 'Vilma Santos', 'Nora Aunor', 'Charo Santos-Concio', 'A', 'Lea Salonga won a Tony Award for Best Actress in a Musical for originating the role of Kim in ''Miss Saigon'' on Broadway.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipina actress won a Tony Award for originating the role of Kim in the musical ''Miss Saigon''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'hard', 'Which Filipino director and actor won recognition as the first Southeast Asian to win the Cannes Best Director award, in 2009?', 'Lav Diaz', 'Erik Matti', 'Jerrold Tarog', 'Brillante Mendoza', 'D', 'Brillante Mendoza won the Best Director award at Cannes in 2009 for ''Kinatay,'' a first for a Filipino director at the festival.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipino director and actor won recognition as the first Southeast Asian to win the Cannes Best Director award, in 2009?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'hard', 'Which Filipino-American mixed martial artist became a multiple-time heavyweight champion of ONE Championship?', 'Eduard Folayang', 'Brandon Vera', 'Kevin Belingon', 'Meiraren Soriano', 'B', 'Brandon Vera, a Filipino-American fighter, held the ONE Championship heavyweight title multiple times over his career.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipino-American mixed martial artist became a multiple-time heavyweight champion of ONE Championship?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'hard', 'Which Filipina, crowned Miss Universe 2018, is also a licensed nurse and became a global advocate for HIV/AIDS awareness?', 'Pia Wurtzbach', 'Catriona Gray', 'Megan Young', 'Janine Tugonon', 'B', 'Catriona Gray, Miss Universe 2018, has used her platform to raise awareness about HIV/AIDS and support underprivileged communities in the Philippines.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipina, crowned Miss Universe 2018, is also a licensed nurse and became a global advocate for HIV/AIDS awareness?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'hard', 'Which Filipino composer and conductor is renowned for compositions blending traditional Filipino elements with Western classical music?', 'Levi Celerio', 'Ryan Cayabyab (National Artist for Music)', 'Antonio Molina', 'Lucio San Pedro', 'B', 'Ryan Cayabyab, a National Artist for Music, is celebrated for his work blending Filipino musical traditions with contemporary and classical styles.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipino composer and conductor is renowned for compositions blending traditional Filipino elements with Western classical music?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'hard', 'As of the mid-2020s, has any Filipino athlete won an Olympic medal in pole vault?', 'Yes, EJ Obiena won bronze at Tokyo 2020', 'Yes, EJ Obiena won silver at Paris 2024', 'Yes, EJ Obiena won gold at Tokyo 2020', 'No — EJ Obiena remains the country''s top pole vaulter without an Olympic medal in the event', 'D', 'Despite setting multiple Asian records, EJ Obiena had not won an Olympic medal in pole vault as of the mid-2020s.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'As of the mid-2020s, has any Filipino athlete won an Olympic medal in pole vault?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'hard', 'Which Filipino chess prodigy became the youngest Grandmaster from the Philippines in the 21st century?', 'Wesley So (achieved GM status at 14)', 'Eugenio Torre', 'Mark Paragua', 'John Paul Gomez', 'A', 'Wesley So achieved the Grandmaster title at just 14 years old, becoming one of the youngest Filipino Grandmasters in history.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipino chess prodigy became the youngest Grandmaster from the Philippines in the 21st century?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'hard', 'Which Filipino actor won the Best Actor award at the Venice Film Festival for the film ''On the Job: The Missing 8'' in 2021?', 'Piolo Pascual', 'Robin Padilla', 'John Arcilla', 'Joel Torre', 'C', 'John Arcilla won the Volpi Cup for Best Actor at the 2021 Venice Film Festival for his role in ''On the Job: The Missing 8.'''
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipino actor won the Best Actor award at the Venice Film Festival for the film ''On the Job: The Missing 8'' in 2021?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'hard', 'Which Filipino singer-songwriter is known for hits like ''Kathang Isip'' and represents a prominent voice in modern OPM (original Pilipino music)?', 'Moira dela Torre', 'Zack Tabudlo', 'IV of Spades', 'Ben&Ben (as a group) is commonly cited for that song', 'D', '''Kathang Isip'' is a well-known song by the Filipino folk-pop band Ben&Ben, prominent in the modern OPM scene.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipino singer-songwriter is known for hits like ''Kathang Isip'' and represents a prominent voice in modern OPM (original Pilipino music)?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'hard', 'Which Filipino-American basketball player played in the NBA and has Filipino heritage through his mother?', 'Jordan Clarkson', 'Kyle Kuzma', 'Kyrie Irving', 'Klay Thompson', 'A', 'Jordan Clarkson, who has played in the NBA, has Filipino heritage through his mother and has represented the Philippine national basketball team internationally.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipino-American basketball player played in the NBA and has Filipino heritage through his mother?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'hard', 'Which Filipino writer, author of the acclaimed novel ''Ilustrado,'' is not (as of the mid-2020s) a National Artist for Literature?', 'Miguel Syjuco', 'F. Sionil Jose', 'Nick Joaquin', 'Bienvenido Santos', 'A', 'Miguel Syjuco, author of ''Ilustrado,'' has not been conferred the National Artist for Literature award, unlike F. Sionil Jose, Nick Joaquin, and Bienvenido Santos.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipino writer, author of the acclaimed novel ''Ilustrado,'' is not (as of the mid-2020s) a National Artist for Literature?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'hard', 'Which Filipina boxer won the silver medal in women''s featherweight boxing at the Tokyo 2020 Olympics?', 'Irish Magno', 'Josie Gabuco', 'Nesthy Petecio', 'Ana Julaton', 'C', 'Nesthy Petecio won the silver medal in women''s featherweight boxing at the Tokyo 2020 Olympics.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipina boxer won the silver medal in women''s featherweight boxing at the Tokyo 2020 Olympics?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'celebrities', 'hard', 'Which Filipino pole vaulter has repeatedly broken the Asian pole vault record over his career?', 'Carlos Yulo', 'Kristina Knott', 'Robyn Brown', 'EJ Obiena', 'D', 'EJ Obiena has repeatedly broken and reset the Asian pole vault record throughout his athletic career.'
where not exists (
  select 1 from questions where category = 'celebrities' and prompt = 'Which Filipino pole vaulter has repeatedly broken the Asian pole vault record over his career?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'hard', 'What is the term for a graph traversal algorithm that explores as far as possible along each branch before backtracking?', 'Breadth-first search (BFS)', 'Depth-first search (DFS)', 'Dijkstra''s algorithm', 'A* search', 'B', 'Depth-first search explores a graph by going as deep as possible along each branch before backtracking to explore other paths.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'What is the term for a graph traversal algorithm that explores as far as possible along each branch before backtracking?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'hard', 'Which data structure uses a Last-In-First-Out (LIFO) principle for adding and removing elements?', 'Queue', 'Stack', 'Linked list', 'Heap', 'B', 'A stack follows the Last-In-First-Out principle, where the most recently added element is the first to be removed.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'Which data structure uses a Last-In-First-Out (LIFO) principle for adding and removing elements?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'hard', 'What does the acronym ''ACID'' stand for in the context of database transactions?', 'Availability, Consistency, Integrity, Durability', 'Atomicity, Concurrency, Isolation, Durability', 'Accuracy, Consistency, Isolation, Durability', 'Atomicity, Consistency, Isolation, Durability', 'D', 'ACID stands for Atomicity, Consistency, Isolation, and Durability—properties that guarantee reliable database transactions.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'What does the acronym ''ACID'' stand for in the context of database transactions?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'hard', 'Which sorting algorithm has an average and worst-case time complexity of O(n log n) and works by dividing the array into halves recursively?', 'Bubble sort', 'Insertion sort', 'Merge sort', 'Selection sort', 'C', 'Merge sort divides the array recursively and merges sorted halves, achieving O(n log n) time complexity in both average and worst cases.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'Which sorting algorithm has an average and worst-case time complexity of O(n log n) and works by dividing the array into halves recursively?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'hard', 'What is the term for a programming paradigm that treats computation as the evaluation of mathematical functions, avoiding state and mutable data?', 'Functional programming', 'Object-oriented programming', 'Procedural programming', 'Imperative programming', 'A', 'Functional programming emphasizes pure functions and avoids changing state or mutable data, treating computation as function evaluation.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'What is the term for a programming paradigm that treats computation as the evaluation of mathematical functions, avoiding state and mutable data?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'hard', 'Which type of computer network attack overwhelms a target system with excessive traffic to make it unavailable to legitimate users?', 'Man-in-the-middle attack', 'Denial-of-Service (DoS) attack', 'SQL injection', 'Phishing attack', 'B', 'A Denial-of-Service attack floods a target system with traffic, overwhelming its resources and denying access to legitimate users.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'Which type of computer network attack overwhelms a target system with excessive traffic to make it unavailable to legitimate users?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'hard', 'What is the term for a hash table collision resolution technique where colliding elements are stored in a linked list at the same index?', 'Open addressing', 'Linear probing', 'Separate chaining', 'Double hashing', 'C', 'Separate chaining resolves hash collisions by storing multiple colliding elements as a linked list (or similar structure) at the same bucket index.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'What is the term for a hash table collision resolution technique where colliding elements are stored in a linked list at the same index?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'hard', 'Which design pattern ensures a class has only one instance and provides a global point of access to it?', 'Factory pattern', 'Singleton pattern', 'Observer pattern', 'Decorator pattern', 'B', 'The Singleton pattern restricts a class to a single instance and provides a global access point to that instance.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'Which design pattern ensures a class has only one instance and provides a global point of access to it?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'hard', 'What is the term for the process of converting high-level source code into machine-readable object code before program execution?', 'Interpretation', 'Assembly', 'Transpilation', 'Compilation', 'D', 'Compilation translates high-level source code into machine code ahead of time, as opposed to interpretation which executes code line by line at runtime.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'What is the term for the process of converting high-level source code into machine-readable object code before program execution?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'hard', 'Which computer science concept describes a problem that cannot be solved by any algorithm in a finite amount of time, exemplified by the Halting Problem?', 'Undecidability', 'NP-completeness', 'Intractability', 'Non-determinism', 'A', 'Undecidability refers to problems, like the Halting Problem, for which no algorithm can determine a correct yes-or-no answer for all possible inputs.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'Which computer science concept describes a problem that cannot be solved by any algorithm in a finite amount of time, exemplified by the Halting Problem?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'hard', 'What is the term for a class of problems for which a solution can be verified quickly, but no known algorithm can solve them quickly?', 'NP (Nondeterministic Polynomial time)', 'P (Polynomial time)', 'PSPACE', 'EXPTIME', 'A', 'NP problems have solutions verifiable in polynomial time, though no polynomial-time algorithm is known to solve all of them.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'What is the term for a class of problems for which a solution can be verified quickly, but no known algorithm can solve them quickly?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'hard', 'Which networking protocol is responsible for translating human-readable domain names into IP addresses?', 'DHCP', 'TCP', 'DNS (Domain Name System)', 'FTP', 'C', 'The Domain Name System (DNS) translates human-readable domain names, like example.com, into machine-readable IP addresses.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'Which networking protocol is responsible for translating human-readable domain names into IP addresses?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'hard', 'What is the term for a self-balancing binary search tree that maintains O(log n) height through rotations, named after its inventors?', 'B-tree', 'Red-black tree (a related but distinct structure)', 'Splay tree', 'AVL tree', 'D', 'The AVL tree, named after inventors Adelson-Velsky and Landis, is a self-balancing binary search tree that maintains balance through rotations.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'What is the term for a self-balancing binary search tree that maintains O(log n) height through rotations, named after its inventors?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'hard', 'Which cryptographic technique uses a pair of mathematically linked keys, one public and one private, for secure communication?', 'Asymmetric (public-key) cryptography', 'Symmetric cryptography', 'Hash-based cryptography', 'Steganography', 'A', 'Asymmetric cryptography uses a public key for encryption and a corresponding private key for decryption, enabling secure communication without sharing secret keys.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'Which cryptographic technique uses a pair of mathematically linked keys, one public and one private, for secure communication?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'hard', 'What is the term for a software vulnerability where an attacker injects malicious SQL statements into an application''s input fields?', 'SQL injection', 'Cross-site scripting (XSS)', 'Buffer overflow', 'Cross-site request forgery (CSRF)', 'A', 'SQL injection occurs when an attacker inserts malicious SQL code into input fields, potentially manipulating or accessing a database improperly.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'What is the term for a software vulnerability where an attacker injects malicious SQL statements into an application''s input fields?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'hard', 'Which computer architecture principle separates instruction and data memory, allowing simultaneous access to both?', 'Von Neumann architecture', 'RISC architecture', 'Harvard architecture', 'CISC architecture', 'C', 'Harvard architecture uses separate memory storage and pathways for instructions and data, unlike Von Neumann architecture which shares them.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'Which computer architecture principle separates instruction and data memory, allowing simultaneous access to both?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'hard', 'What is the term for a technique in machine learning where a model is trained on one task and then reused as the starting point for a related task?', 'Reinforcement learning', 'Supervised learning', 'Unsupervised learning', 'Transfer learning', 'D', 'Transfer learning leverages knowledge gained from training on one task to improve learning performance on a related, often smaller, task.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'What is the term for a technique in machine learning where a model is trained on one task and then reused as the starting point for a related task?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'computer_science', 'hard', 'Which algorithmic technique solves complex problems by breaking them into overlapping subproblems and storing results to avoid redundant computation?', 'Greedy algorithms', 'Dynamic programming', 'Divide and conquer', 'Backtracking', 'B', 'Dynamic programming solves problems by breaking them into overlapping subproblems and caching results, avoiding redundant recomputation.'
where not exists (
  select 1 from questions where category = 'computer_science' and prompt = 'Which algorithmic technique solves complex problems by breaking them into overlapping subproblems and storing results to avoid redundant computation?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'culture', 'hard', 'Which pre-colonial Filipino writing system, believed to have Brahmic origins, is inscribed on the Laguna Copperplate?', 'Alibata Latin hybrid', 'Tagbanwa runes', 'Baybayin (Kawi-derived script)', 'Sanskrit Devanagari', 'C', 'The Laguna Copperplate Inscription is written in a Kawi-derived script related to the ancient Baybayin writing system.'
where not exists (
  select 1 from questions where category = 'culture' and prompt = 'Which pre-colonial Filipino writing system, believed to have Brahmic origins, is inscribed on the Laguna Copperplate?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'culture', 'hard', 'What is the traditional Filipino practice of communal unity and cooperation called, often seen in community projects?', 'Pakikisama', 'Bayanihan', 'Utang na loob', 'Damayan', 'B', 'Bayanihan refers to the spirit of communal unity and cooperation, famously depicted by neighbors carrying a house together.'
where not exists (
  select 1 from questions where category = 'culture' and prompt = 'What is the traditional Filipino practice of communal unity and cooperation called, often seen in community projects?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'culture', 'hard', 'Which pre-colonial social class held hereditary noble rank in traditional Visayan and Tagalog society?', 'Maginoo', 'Timawa', 'Alipin', 'Datu-alipin', 'A', 'The maginoo were the noble class in pre-colonial Tagalog society, distinct from the freemen (timawa) and dependents (alipin).'
where not exists (
  select 1 from questions where category = 'culture' and prompt = 'Which pre-colonial social class held hereditary noble rank in traditional Visayan and Tagalog society?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'culture', 'hard', 'What is the term for the Filipino value of reciprocal debt of gratitude, often cited as a core social obligation?', 'Hiya', 'Amor propio', 'Pakikipagkapwa', 'Utang na loob', 'D', 'Utang na loob describes an internal debt of gratitude owed for a favor received, a deeply rooted Filipino value.'
where not exists (
  select 1 from questions where category = 'culture' and prompt = 'What is the term for the Filipino value of reciprocal debt of gratitude, often cited as a core social obligation?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'culture', 'hard', 'Which historic 1521 event marked the first Catholic Mass celebrated in the Philippines, per most accounts?', 'The Mass at Cebu City proper', 'The Mass at Limasawa', 'The Mass at Butuan', 'The Mass at Manila', 'B', 'Most historical accounts and the National Historical Commission identify Limasawa Island as the site of the first Mass in 1521.'
where not exists (
  select 1 from questions where category = 'culture' and prompt = 'Which historic 1521 event marked the first Catholic Mass celebrated in the Philippines, per most accounts?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'culture', 'hard', 'What pre-colonial contract bound a debtor into service to a creditor, forming a distinct social class?', 'Alipin sa pananampalataya (debt bondage)', 'Datu tribute system', 'Sandugo blood compact', 'Bayan cooperative', 'A', 'Debt bondage, or alipin sa pananampalataya, created a class of dependents who worked to pay off debts owed to a patron.'
where not exists (
  select 1 from questions where category = 'culture' and prompt = 'What pre-colonial contract bound a debtor into service to a creditor, forming a distinct social class?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'culture', 'hard', 'Which term describes the indigenous pre-Hispanic Filipino belief in nature spirits and ancestral spirits?', 'Bathalismo', 'Anitism', 'Diwatismo', 'Katutubong Islam', 'B', 'Anitism refers to the animistic belief system of pre-colonial Filipinos, centered on anito, or ancestral and nature spirits.'
where not exists (
  select 1 from questions where category = 'culture' and prompt = 'Which term describes the indigenous pre-Hispanic Filipino belief in nature spirits and ancestral spirits?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'culture', 'hard', 'What is the name of the 19th-century Filipino secret society founded by Andres Bonifacio to seek independence from Spain?', 'Katipunan', 'La Liga Filipina', 'Cuerpo de Compromisarios', 'Comite de Propaganda', 'A', 'The Katipunan, founded in 1892 by Andres Bonifacio, was a secret revolutionary society aimed at gaining independence from Spain.'
where not exists (
  select 1 from questions where category = 'culture' and prompt = 'What is the name of the 19th-century Filipino secret society founded by Andres Bonifacio to seek independence from Spain?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'culture', 'hard', 'Which term refers to the Filipino concept of smooth interpersonal relationships and avoiding conflict?', 'Hiya', 'Bahala na', 'Pakikisama', 'Kapwa', 'C', 'Pakikisama refers to the value of getting along with others and maintaining group harmony, even at some personal cost.'
where not exists (
  select 1 from questions where category = 'culture' and prompt = 'Which term refers to the Filipino concept of smooth interpersonal relationships and avoiding conflict?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'culture', 'hard', 'What pre-colonial Visayan practice involved filing and blackening teeth as a sign of beauty and status?', 'Batok tattooing', 'Bagobo scarification', 'Kulam ritual marking', 'Pangisi (teeth blackening)', 'D', 'Pangisi, the filing and blackening of teeth, was a beauty practice among pre-colonial Visayans, described in early Spanish accounts like the Boxer Codex.'
where not exists (
  select 1 from questions where category = 'culture' and prompt = 'What pre-colonial Visayan practice involved filing and blackening teeth as a sign of beauty and status?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'hard', 'What is the term for a business strategy of setting a low introductory price to gain market share quickly, before raising it later?', 'Price skimming', 'Penetration pricing', 'Cost-plus pricing', 'Value-based pricing', 'B', 'Penetration pricing sets an initially low price to attract customers and gain market share, with prices often rising once established.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'What is the term for a business strategy of setting a low introductory price to gain market share quickly, before raising it later?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'hard', 'Which financial statement summarizes a company''s revenues, expenses, and profits over a specific period?', 'Income statement', 'Balance sheet', 'Cash flow statement', 'Statement of retained earnings', 'A', 'The income statement, also called the profit and loss statement, summarizes revenues, expenses, and net income over a defined period.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'Which financial statement summarizes a company''s revenues, expenses, and profits over a specific period?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'hard', 'What is the term for a company''s strategy of selling products below cost temporarily to drive competitors out of the market?', 'Predatory pricing', 'Penetration pricing', 'Dumping', 'Loss leader strategy', 'A', 'Predatory pricing involves setting prices deliberately low, often below cost, to eliminate competition, after which prices are typically raised.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'What is the term for a company''s strategy of selling products below cost temporarily to drive competitors out of the market?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'hard', 'Which business metric measures the percentage of customers who stop using a company''s product or service over a given period?', 'Conversion rate', 'Retention rate (inverse concept)', 'Bounce rate', 'Churn rate', 'D', 'Churn rate measures the percentage of customers lost over a specific time period, a key metric for subscription-based businesses.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'Which business metric measures the percentage of customers who stop using a company''s product or service over a given period?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'hard', 'What is the term for a merger between two companies operating in completely unrelated industries?', 'Conglomerate merger', 'Horizontal merger', 'Vertical merger', 'Market-extension merger', 'A', 'A conglomerate merger combines companies from entirely different, unrelated business sectors, often for diversification purposes.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'What is the term for a merger between two companies operating in completely unrelated industries?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'hard', 'Which accounting method values inventory based on the assumption that the most recently purchased items are sold first?', 'LIFO (Last In, First Out)', 'FIFO (First In, First Out)', 'Weighted average cost', 'Specific identification', 'A', 'LIFO assumes that the most recently acquired inventory items are the first to be sold, affecting reported cost of goods sold and profit.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'Which accounting method values inventory based on the assumption that the most recently purchased items are sold first?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'hard', 'What is the term for the total market value of a company''s outstanding shares of stock?', 'Enterprise value', 'Market capitalization', 'Book value', 'Par value', 'B', 'Market capitalization is calculated by multiplying a company''s share price by its total number of outstanding shares.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'What is the term for the total market value of a company''s outstanding shares of stock?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'hard', 'Which business term describes the practice of a company outsourcing part of its production process to another country to reduce costs?', 'Outsourcing (domestic)', 'Reshoring', 'Nearshoring', 'Offshoring', 'D', 'Offshoring refers to relocating a business process or production to another country, typically to take advantage of lower costs.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'Which business term describes the practice of a company outsourcing part of its production process to another country to reduce costs?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'hard', 'What is the term for the minimum amount of sales a business must achieve to cover all its costs, resulting in neither profit nor loss?', 'Margin of safety', 'Break-even point', 'Contribution margin', 'Operating leverage', 'B', 'The break-even point is the sales level at which total revenues equal total costs, resulting in zero net profit or loss.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'What is the term for the minimum amount of sales a business must achieve to cover all its costs, resulting in neither profit nor loss?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'hard', 'Which corporate governance term refers to a hostile takeover defense where a target company makes itself less attractive to an acquirer?', 'Poison pill', 'Golden parachute', 'White knight', 'Greenmail', 'A', 'A poison pill is a defensive strategy that makes a company less attractive or more costly to acquire, typically by diluting shares.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'Which corporate governance term refers to a hostile takeover defense where a target company makes itself less attractive to an acquirer?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'hard', 'What is the term for a financial ratio that measures a company''s ability to pay short-term obligations using its most liquid assets?', 'Current ratio', 'Quick ratio (acid-test ratio)', 'Debt-to-equity ratio', 'Return on assets', 'B', 'The quick ratio, or acid-test ratio, measures a firm''s ability to meet short-term obligations using its most liquid assets, excluding inventory.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'What is the term for a financial ratio that measures a company''s ability to pay short-term obligations using its most liquid assets?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'hard', 'Which business concept refers to the additional value created when two companies combine, resulting in performance greater than the sum of their parts?', 'Economies of scale', 'Diversification', 'Synergy', 'Leverage', 'C', 'Synergy refers to the added value generated when combined entities perform better together than they would separately.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'Which business concept refers to the additional value created when two companies combine, resulting in performance greater than the sum of their parts?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'hard', 'What is the term for a company''s strategy of offering a basic product free while charging for premium features?', 'Loss leader model', 'Subscription model', 'Bundling', 'Freemium model', 'D', 'The freemium model offers a basic version of a product for free while charging for additional premium features or functionality.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'What is the term for a company''s strategy of offering a basic product free while charging for premium features?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'hard', 'Which economic term describes companies that produce complementary or supporting goods and services surrounding a core industry?', 'Vertical integration', 'Cluster economies', 'Ancillary industries (or a business ecosystem)', 'Externalities', 'C', 'Ancillary or supporting industries provide complementary goods and services that enable and enhance a core industry''s operations.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'Which economic term describes companies that produce complementary or supporting goods and services surrounding a core industry?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'hard', 'What is the term for the strategic decision of a business to produce goods domestically that were previously manufactured overseas?', 'Offshoring', 'Nearshoring', 'Outsourcing', 'Reshoring', 'D', 'Reshoring refers to the practice of bringing manufacturing or business processes back to a company''s home country from overseas.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'What is the term for the strategic decision of a business to produce goods domestically that were previously manufactured overseas?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'hard', 'Which valuation metric compares a company''s stock price to its earnings per share, commonly used to assess if a stock is over or undervalued?', 'Price-to-book ratio', 'Dividend yield', 'Price-to-earnings (P/E) ratio', 'Earnings yield', 'C', 'The price-to-earnings ratio compares a company''s current share price to its earnings per share, widely used in stock valuation.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'Which valuation metric compares a company''s stock price to its earnings per share, commonly used to assess if a stock is over or undervalued?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'hard', 'What is the term for a business combination where a company acquires another company that operates at a different stage of the same production process?', 'Horizontal merger', 'Vertical merger', 'Conglomerate merger', 'Concentric merger', 'B', 'A vertical merger combines companies at different stages of the same supply chain, such as a manufacturer acquiring a supplier.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'What is the term for a business combination where a company acquires another company that operates at a different stage of the same production process?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'economy_business', 'hard', 'Which term describes a company''s ability to increase output without a proportional increase in costs, often due to specialization and scale?', 'Diminishing returns', 'Diseconomies of scale', 'Economies of scale', 'Marginal cost pricing', 'C', 'Economies of scale occur when increased production leads to lower per-unit costs, often due to specialization, bulk purchasing, and spread fixed costs.'
where not exists (
  select 1 from questions where category = 'economy_business' and prompt = 'Which term describes a company''s ability to increase output without a proportional increase in costs, often due to specialization and scale?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'entertainment', 'hard', 'Which 1976 Filipino film by Lino Brocka is considered a landmark of Philippine cinema and social realism?', 'Insiang', 'Himala', 'Oro, Plata, Mata', 'Manila in the Claws of Light', 'A', 'Insiang (1976), directed by Lino Brocka, was the first Filipino film selected for the Cannes Film Festival and is regarded as a landmark of social realist cinema.'
where not exists (
  select 1 from questions where category = 'entertainment' and prompt = 'Which 1976 Filipino film by Lino Brocka is considered a landmark of Philippine cinema and social realism?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'entertainment', 'hard', 'Who directed the 1982 Filipino film ''Himala,'' widely regarded as one of the greatest Filipino films of all time?', 'Lino Brocka', 'Ishmael Bernal', 'Mike de Leon', 'Marilou Diaz-Abaya', 'B', 'Ishmael Bernal directed Himala (1982), starring Nora Aunor, often cited as one of the greatest Filipino films ever made.'
where not exists (
  select 1 from questions where category = 'entertainment' and prompt = 'Who directed the 1982 Filipino film ''Himala,'' widely regarded as one of the greatest Filipino films of all time?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'entertainment', 'hard', 'Which long-running Philippine noontime variety show, first aired in 1979, remains one of the country''s most-watched programs?', 'It''s Showtime', 'Eat Bulaga!', 'ASAP', 'Wowowin', 'B', 'Eat Bulaga!, which premiered in 1979, is one of the longest-running noontime variety shows in Philippine television history.'
where not exists (
  select 1 from questions where category = 'entertainment' and prompt = 'Which long-running Philippine noontime variety show, first aired in 1979, remains one of the country''s most-watched programs?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'entertainment', 'hard', 'Which 1982 Filipino film, directed by Ishmael Bernal, was the Philippines'' official submission to the Academy Awards for Best Foreign Language Film?', 'Oro, Plata, Mata', 'Insiang', 'Himala', 'Manila in the Claws of Light', 'C', 'Himala (1982) was submitted by the Philippines for Academy Award consideration in the Best Foreign Language Film category.'
where not exists (
  select 1 from questions where category = 'entertainment' and prompt = 'Which 1982 Filipino film, directed by Ishmael Bernal, was the Philippines'' official submission to the Academy Awards for Best Foreign Language Film?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'entertainment', 'hard', 'Which Filipino actress is known as the ''Superstar'' and is considered one of the most awarded actresses in Philippine cinema history?', 'Vilma Santos', 'Sharon Cuneta', 'Nora Aunor', 'Susan Roces', 'C', 'Nora Aunor, dubbed the ''Superstar,'' has received numerous critical accolades and is widely regarded as one of the finest actresses in Philippine film history.'
where not exists (
  select 1 from questions where category = 'entertainment' and prompt = 'Which Filipino actress is known as the ''Superstar'' and is considered one of the most awarded actresses in Philippine cinema history?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'entertainment', 'hard', 'What is the name of the iconic Filipino komiks character created by Mars Ravelo, later adapted into numerous films as a superheroine?', 'Captain Barbell', 'Lastikman', 'Zsazsa Zaturnnah', 'Darna', 'D', 'Darna, created by Mars Ravelo, is one of the most enduring Filipino superheroine characters, adapted across decades of film and television.'
where not exists (
  select 1 from questions where category = 'entertainment' and prompt = 'What is the name of the iconic Filipino komiks character created by Mars Ravelo, later adapted into numerous films as a superheroine?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'entertainment', 'hard', 'Which Filipino film won the Palme d''Or-adjacent Un Certain Regard or major Cannes recognition, directed by Brillante Mendoza in 2009?', 'Serbis', 'Lola', 'Kinatay (Best Director at Cannes)', 'Thy Womb', 'C', 'Brillante Mendoza won the Best Director award at the 2009 Cannes Film Festival for Kinatay.'
where not exists (
  select 1 from questions where category = 'entertainment' and prompt = 'Which Filipino film won the Palme d''Or-adjacent Un Certain Regard or major Cannes recognition, directed by Brillante Mendoza in 2009?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'entertainment', 'hard', 'What is the term for the Philippine film genre blending horror, comedy, and folklore creatures like aswang and kapre?', 'Bakya films', 'Bomba films', 'Pito-pito films', 'Horror-komedya (or ''Shake, Rattle & Roll''-style horror anthology)', 'D', 'Philippine horror-comedy, often anthologized in franchises like ''Shake, Rattle & Roll,'' blends folklore monsters with comedic elements.'
where not exists (
  select 1 from questions where category = 'entertainment' and prompt = 'What is the term for the Philippine film genre blending horror, comedy, and folklore creatures like aswang and kapre?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'entertainment', 'hard', 'Which Filipino director is known for the internationally acclaimed slow-cinema epic ''Norte, the End of History'' and long-duration films?', 'Erik Matti', 'Lav Diaz', 'Jerrold Tarog', 'Antoinette Jadaone', 'B', 'Lav Diaz is internationally recognized for his slow-cinema style, often featuring films that run many hours long, including ''Norte, the End of History.'''
where not exists (
  select 1 from questions where category = 'entertainment' and prompt = 'Which Filipino director is known for the internationally acclaimed slow-cinema epic ''Norte, the End of History'' and long-duration films?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'entertainment', 'hard', 'Which Filipino actress won the Best Actress award at the 2016 Cannes Film Festival for her role in "Ma'' Rosa"?', 'Jaclyn Jose', 'Nora Aunor', 'Vilma Santos', 'Angel Aquino', 'A', 'Jaclyn Jose won the Best Actress award at the 2016 Cannes Film Festival for her performance in Brillante Mendoza''s "Ma'' Rosa."'
where not exists (
  select 1 from questions where category = 'entertainment' and prompt = 'Which Filipino actress won the Best Actress award at the 2016 Cannes Film Festival for her role in "Ma'' Rosa"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'entertainment', 'hard', 'Which Filipino actor won Best Actor at a major international film festival for his role in the 2016 film ''Ma'' Rosa''?', 'Jaclyn Jose', 'Jaclyn Jose won Best Actress at Cannes 2016 for Ma'' Rosa', 'John Arcilla', 'Nora Aunor', 'A', 'Jaclyn Jose won the Best Actress award at the 2016 Cannes Film Festival for her role in Brillante Mendoza''s ''Ma'' Rosa.'''
where not exists (
  select 1 from questions where category = 'entertainment' and prompt = 'Which Filipino actor won Best Actor at a major international film festival for his role in the 2016 film ''Ma'' Rosa''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'hard', 'Which festival in Kalibo, Aklan is considered the ''Mother of All Philippine Festivals,'' honoring the Santo Niño with tribal dances?', 'Ati-Atihan Festival', 'Sinulog Festival', 'Dinagyang Festival', 'Panagbenga Festival', 'A', 'The Ati-Atihan Festival in Kalibo is often called the ''Mother of All Philippine Festivals,'' featuring tribal-style dancing in honor of the Santo Niño.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'Which festival in Kalibo, Aklan is considered the ''Mother of All Philippine Festivals,'' honoring the Santo Niño with tribal dances?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'hard', 'What does the Cebu Sinulog Festival''s ritual dance movement, from which the festival gets its name, imitate?', 'The flow of a river (a two-steps-forward, one-step-back movement)', 'The flight of a bird', 'The crashing of ocean waves', 'The swaying of rice stalks', 'A', '''Sinulog'' derives from the Cebuano word for a water current''s movement, reflected in the dance''s characteristic forward-and-backward steps.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'What does the Cebu Sinulog Festival''s ritual dance movement, from which the festival gets its name, imitate?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'hard', 'Which festival, held in Baguio City, celebrates the blooming of flowers and is known as the ''Flower Festival''?', 'Pahiyas Festival', 'Panagbenga Festival', 'MassKara Festival', 'Kadayawan Festival', 'B', 'Panagbenga, meaning ''season of blooming'' in the local Kankanaey language, is Baguio''s annual flower festival held every February.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'Which festival, held in Baguio City, celebrates the blooming of flowers and is known as the ''Flower Festival''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'hard', 'What is the primary theme of Davao City''s Kadayawan Festival, held every August?', 'A religious pilgrimage in honor of a patron saint', 'A commemoration of a historic battle', 'A trade fair for regional exports', 'A thanksgiving celebration for a bountiful harvest and the region''s ethnic heritage', 'D', 'Kadayawan Festival is a thanksgiving celebration for the bountiful harvest, flowers, and rich cultural heritage of Davao and its ethnic tribes.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'What is the primary theme of Davao City''s Kadayawan Festival, held every August?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'hard', 'Which Bacolod City festival, known as the ''Festival of Smiles,'' originated in the 1980s partly as a response to an economic and social crisis?', 'Sinulog Festival', 'MassKara Festival', 'Ati-Atihan Festival', 'Dinagyang Festival', 'B', 'The MassKara Festival began in 1980, with masked, smiling faces meant to uplift spirits during a period of economic difficulty and tragedy in Bacolod.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'Which Bacolod City festival, known as the ''Festival of Smiles,'' originated in the 1980s partly as a response to an economic and social crisis?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'hard', 'What unique feature distinguishes the Pahiyas Festival in Lucban, Quezon, held in honor of San Isidro Labrador?', 'Streets are covered entirely in flower petals', 'Participants wear elaborate mask costumes representing ancestral spirits', 'Houses are decorated with colorful agricultural produce, including rice wafers called ''kiping''', 'A grand parade of decorated boats occurs on a local river', 'C', 'The Pahiyas Festival is famous for houses adorned with harvest produce and kiping, decorative rice wafers, thanking San Isidro Labrador for a good harvest.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'What unique feature distinguishes the Pahiyas Festival in Lucban, Quezon, held in honor of San Isidro Labrador?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'hard', 'Which Iloilo City festival, held in honor of the Santo Niño, developed partly in friendly rivalry with Kalibo''s Ati-Atihan?', 'Sinulog Festival', 'Pintados Festival', 'Dinagyang Festival', 'Kalibo Festival', 'C', 'The Dinagyang Festival in Iloilo City developed as a Santo Niño celebration with roots connected to, and in friendly rivalry with, Kalibo''s Ati-Atihan.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'Which Iloilo City festival, held in honor of the Santo Niño, developed partly in friendly rivalry with Kalibo''s Ati-Atihan?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'hard', 'What does the Tacloban City Pintados-Kasadyaan Festival commemorate, referencing pre-colonial body art traditions?', 'The arrival of Ferdinand Magellan', 'A local harvest of pineapple fiber', 'The founding of the Katipunan in the Visayas', 'The ancient Visayan practice of tattooing the body, as observed by early Spanish chroniclers', 'D', 'The Pintados Festival references the pre-colonial Visayan tradition of full-body tattooing, described by early Spanish explorers who called them ''os pintados'' (the painted ones).'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'What does the Tacloban City Pintados-Kasadyaan Festival commemorate, referencing pre-colonial body art traditions?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'hard', 'Which Zamboanga City festival celebrates the city''s founding and features the Regatta de Zamboanga sailing event?', 'Fiesta Pilar', 'Zamboanga Hermosa Festival', 'Hermosa de Zamboanga (an alternate name used historically)', 'Festival del Mar', 'B', 'The Zamboanga Hermosa Festival celebrates the city''s founding anniversary and religious heritage, including the Regatta de Zamboanga.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'Which Zamboanga City festival celebrates the city''s founding and features the Regatta de Zamboanga sailing event?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'hard', 'What is the primary purpose of the Obando Fertility Rites, held annually in Obando, Bulacan?', 'A ritual dance performed by couples hoping to conceive children, honoring three patron saints', 'A celebration marking the start of the planting season', 'A commemoration of the town''s liberation from colonial rule', 'A trade festival for regional handicrafts', 'A', 'The Obando Fertility Rites involve dancing in honor of San Pascual, Santa Clara, and Nuestra Señora de Salambao, traditionally sought by couples wishing to conceive.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'What is the primary purpose of the Obando Fertility Rites, held annually in Obando, Bulacan?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'hard', 'Which festival in Marinduque reenacts the story of a Roman centurion converting to Christianity, featuring masked participants representing Roman soldiers?', 'Moriones Festival', 'Ati-Atihan Festival', 'Higantes Festival', 'Turumba Festival', 'A', 'The Moriones Festival reenacts the story of Longinus, the Roman centurion who converted to Christianity, with participants wearing elaborate Roman soldier masks.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'Which festival in Marinduque reenacts the story of a Roman centurion converting to Christianity, featuring masked participants representing Roman soldiers?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'hard', 'What historical event does the Sublian Festival in Batangas commemorate, involving a devotion to the Santo Niño?', 'The signing of the Treaty of Biak-na-Bato', 'A local uprising against Spanish tax collectors', 'The founding of Batangas as a province', 'A traditional ritual dance devotion to the Santo Niño, brought via the galleon trade era', 'D', 'The Sublian Festival in Batangas is a ritual dance tradition devoted to the Santo Niño, with roots tracing back centuries.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'What historical event does the Sublian Festival in Batangas commemorate, involving a devotion to the Santo Niño?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'hard', 'Which festival, held in Angono, Rizal, celebrates patron saints San Clemente and San Isidro Labrador with elaborately decorated giant paper-mache figures?', 'Pahiyas Festival', 'Higantes Festival', 'Turumba Festival', 'Panagbenga Festival', 'B', 'The Higantes Festival in Angono features giant paper-mache figures paraded through the streets in honor of San Clemente and San Isidro Labrador.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'Which festival, held in Angono, Rizal, celebrates patron saints San Clemente and San Isidro Labrador with elaborately decorated giant paper-mache figures?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'hard', 'What does the term ''Pasayaw'' refer to within the context of the Ati-Atihan and Dinagyang street dance competitions?', 'A specific solo dance performed only by tribal chieftains', 'The closing ceremony ritual', 'A type of traditional drum used in the parade', 'A term broadly referring to the choreographed group street-dancing performance itself', 'D', '''Pasayaw'' broadly refers to the energetic street-dancing performances central to festivals like Ati-Atihan and Dinagyang.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'What does the term ''Pasayaw'' refer to within the context of the Ati-Atihan and Dinagyang street dance competitions?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'hard', 'Which Naga City festival, one of the oldest Marian festivals in the country, honors Our Lady of Peñafrancia?', 'Peñafrancia Voyadores Festival (an alternate reference to the same event)', 'Bicol Marian Festival', 'Peñafrancia Festival', 'Kagayan Festival', 'C', 'The Peñafrancia Festival in Naga City is among the oldest and largest Marian devotions in the Philippines, featuring a fluvial procession.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'Which Naga City festival, one of the oldest Marian festivals in the country, honors Our Lady of Peñafrancia?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'hard', 'What natural resource does the annual T''nalak Festival in Koronadal City celebrate, tied to T''boli weaving traditions?', 'Abaca-based woven cloth (T''nalak) production', 'Rice terracing techniques', 'Pearl diving traditions', 'Coconut oil production', 'A', 'The T''nalak Festival celebrates the T''boli tribe''s traditional weaving of T''nalak cloth from abaca fibers, considered a sacred art form.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'What natural resource does the annual T''nalak Festival in Koronadal City celebrate, tied to T''boli weaving traditions?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'hard', 'Which Iligan City festival celebrates the region''s numerous waterfalls, giving the city its nickname ''City of Majestic Waterfalls''?', 'Kaamulan Festival', 'Diyandi Festival', 'Bugsay Festival', 'Sinag Festival', 'B', 'The Diyandi Festival in Iligan City celebrates the city''s cultural heritage and its renown as the ''City of Majestic Waterfalls.'''
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'Which Iligan City festival celebrates the region''s numerous waterfalls, giving the city its nickname ''City of Majestic Waterfalls''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'festivals', 'hard', 'What is the central cultural focus of the Kaamulan Festival held in Malaybalay, Bukidnon?', 'A harvest festival for pineapple plantations', 'A commemoration of a Spanish colonial battle', 'A gathering celebrating the traditions of Bukidnon''s seven indigenous tribes', 'A trade fair for regional coffee production', 'C', 'The Kaamulan Festival is an ethnic celebration honoring the traditions, rituals, and heritage of Bukidnon''s seven indigenous tribal groups.'
where not exists (
  select 1 from questions where category = 'festivals' and prompt = 'What is the central cultural focus of the Kaamulan Festival held in Malaybalay, Bukidnon?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'food', 'hard', 'Which fermented Filipino condiment made from anchovies or shrimp is used to flavor dishes like pinakbet?', 'Bagoong', 'Patis', 'Toyo', 'Suka', 'A', 'Bagoong is a fermented fish or shrimp paste central to Filipino cooking, especially in dishes like pinakbet and kare-kare.'
where not exists (
  select 1 from questions where category = 'food' and prompt = 'Which fermented Filipino condiment made from anchovies or shrimp is used to flavor dishes like pinakbet?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'food', 'hard', 'What is the term for the traditional Filipino method of cooking meat or seafood slowly in vinegar, garlic, and spices for preservation?', 'Sinigang', 'Adobo', 'Paksiw', 'Kinilaw', 'B', 'Adobo''s use of vinegar and salt as preservatives, alongside garlic and spices, was originally a method of preserving food in a hot, humid climate.'
where not exists (
  select 1 from questions where category = 'food' and prompt = 'What is the term for the traditional Filipino method of cooking meat or seafood slowly in vinegar, garlic, and spices for preservation?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'food', 'hard', 'Which Visayan soup dish is distinguished from Tagalog sinigang by commonly using batwan fruit instead of tamarind for sourness?', 'Bulalo', 'Sinigang na Baboy sa Batwan (Ilonggo-style)', 'Pochero', 'Nilagang Baka', 'B', 'In Western Visayas, particularly Iloilo, sinigang is often soured with batwan fruit rather than tamarind, giving it a distinct flavor profile.'
where not exists (
  select 1 from questions where category = 'food' and prompt = 'Which Visayan soup dish is distinguished from Tagalog sinigang by commonly using batwan fruit instead of tamarind for sourness?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'food', 'hard', 'What is ''kilawin'' or ''kinilaw'' primarily distinguished by as a cooking technique?', 'Slow-braising in coconut milk', 'Deep-frying in banana leaf wrap', 'Steaming over rice wine', 'Curing raw fish or meat in vinegar or citrus without heat', 'D', 'Kinilaw is a Filipino dish where fish or meat is ''cooked'' through the acidity of vinegar or citrus juice rather than heat, similar to ceviche.'
where not exists (
  select 1 from questions where category = 'food' and prompt = 'What is ''kilawin'' or ''kinilaw'' primarily distinguished by as a cooking technique?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'food', 'hard', 'Which region of the Philippines is traditionally credited as the origin of the dish ''La Paz batchoy''?', 'Batangas', 'Bacolod', 'Iloilo City (La Paz district)', 'Zamboanga', 'C', 'La Paz Batchoy, a noodle soup with pork offal and crushed chicharon, originated in the La Paz district of Iloilo City.'
where not exists (
  select 1 from questions where category = 'food' and prompt = 'Which region of the Philippines is traditionally credited as the origin of the dish ''La Paz batchoy''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'food', 'hard', 'What distinguishes ''humba'' from standard adobo in Visayan cuisine?', 'The addition of fermented black beans, brown sugar, and banana blossoms', 'The exclusive use of chicken instead of pork', 'The absence of vinegar entirely', 'The use of raw egg as a binder', 'A', 'Humba is a sweeter, richer variant of adobo distinguished by tausi (fermented black beans), brown sugar, and often dried banana blossoms.'
where not exists (
  select 1 from questions where category = 'food' and prompt = 'What distinguishes ''humba'' from standard adobo in Visayan cuisine?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'food', 'hard', 'Which Filipino dessert is made by layering crushed ice with sweetened beans, fruits, and evaporated milk, with ''halo-halo'' meaning what in Tagalog?', 'Sweet ice', 'Cold treat', 'Rainbow bowl', 'Mix-mix', 'D', '''Halo-halo'' literally translates to ''mix-mix'' in Tagalog, referring to how the layered ingredients are stirred together before eating.'
where not exists (
  select 1 from questions where category = 'food' and prompt = 'Which Filipino dessert is made by layering crushed ice with sweetened beans, fruits, and evaporated milk, with ''halo-halo'' meaning what in Tagalog?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'food', 'hard', 'What is the primary difference between ''tinola'' and ''sinampalukang manok''?', 'Tinola always uses beef instead of chicken', 'Sinampalukang manok is soured with tamarind while tinola uses ginger and green papaya without souring', 'Sinampalukang manok is a dry dish, not a soup', 'Tinola is exclusively a dessert dish', 'B', 'Tinola is a ginger-based chicken soup with green papaya, while sinampalukang manok is a sour chicken soup flavored with tamarind.'
where not exists (
  select 1 from questions where category = 'food' and prompt = 'What is the primary difference between ''tinola'' and ''sinampalukang manok''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'food', 'hard', 'Which fermented rice cake, wrapped in banana leaves, is closely associated with the province of Pampanga and Bulacan?', 'Puto Bumbong', 'Bibingka', 'Suman', 'Kutsinta', 'C', 'Suman, made from glutinous rice steamed in banana or buri leaves, has notable regional variants across Pampanga, Bulacan, and other provinces.'
where not exists (
  select 1 from questions where category = 'food' and prompt = 'Which fermented rice cake, wrapped in banana leaves, is closely associated with the province of Pampanga and Bulacan?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'food', 'hard', 'What gives ''kare-kare'' its distinctive thick, nutty sauce?', 'Ground peanuts and toasted rice or achuete', 'Coconut cream reduction alone', 'Reduced soy sauce and vinegar', 'Mashed sweet potato', 'A', 'Kare-kare''s signature sauce is made from ground peanuts thickened with toasted rice flour, colored with achuete (annatto).'
where not exists (
  select 1 from questions where category = 'food' and prompt = 'What gives ''kare-kare'' its distinctive thick, nutty sauce?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'hard', 'Which language family does English belong to, alongside German, Dutch, and the Scandinavian languages?', 'Romance', 'Germanic (Indo-European)', 'Slavic', 'Celtic', 'B', 'English belongs to the Germanic branch of the Indo-European language family, related to German, Dutch, and Scandinavian languages.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'Which language family does English belong to, alongside German, Dutch, and the Scandinavian languages?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'hard', 'What is the term for a language that has no known living relatives, forming its own independent language family?', 'Creole language', 'Pidgin language', 'Dead language', 'Language isolate', 'D', 'A language isolate, such as Basque, has no demonstrable genealogical relationship to any other known language.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'What is the term for a language that has no known living relatives, forming its own independent language family?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'hard', 'Which writing system uses logographic characters, where a single symbol can represent an entire word or morpheme, as used in Chinese?', 'Alphabetic system', 'Logographic system', 'Syllabary system', 'Abjad system', 'B', 'A logographic writing system, like Chinese characters, uses symbols that represent words or morphemes rather than individual sounds.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'Which writing system uses logographic characters, where a single symbol can represent an entire word or morpheme, as used in Chinese?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'hard', 'What linguistic term describes a language that combines features of two or more languages, typically developing among groups without a common language?', 'Pidgin', 'Creole', 'Dialect', 'Lingua franca', 'A', 'A pidgin is a simplified language that develops as a means of communication between groups without a common language, often for trade.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'What linguistic term describes a language that combines features of two or more languages, typically developing among groups without a common language?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'hard', 'Which of these is classified as a tonal language, where pitch changes can alter a word''s meaning?', 'Spanish', 'German', 'Mandarin Chinese', 'Arabic', 'C', 'Mandarin Chinese is a tonal language, where the pitch contour used to pronounce a syllable can completely change its meaning.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'Which of these is classified as a tonal language, where pitch changes can alter a word''s meaning?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'hard', 'What is the term for the smallest unit of meaning in a language, which cannot be divided further without losing meaning?', 'Morpheme', 'Phoneme', 'Lexeme', 'Grapheme', 'A', 'A morpheme is the smallest grammatical unit in a language that carries meaning, such as a root word or an affix.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'What is the term for the smallest unit of meaning in a language, which cannot be divided further without losing meaning?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'hard', 'Which language is the most widely spoken by number of native speakers globally, as of recent estimates?', 'English', 'Mandarin Chinese', 'Spanish', 'Hindi', 'B', 'Mandarin Chinese has the largest number of native speakers of any language in the world.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'Which language is the most widely spoken by number of native speakers globally, as of recent estimates?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'hard', 'What is the term for a writing system, like Japanese hiragana, in which each character represents a syllable rather than a single sound?', 'Abjad', 'Syllabary', 'Abugida', 'Logography', 'B', 'A syllabary is a set of written symbols representing syllables, as seen in Japanese hiragana and katakana.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'What is the term for a writing system, like Japanese hiragana, in which each character represents a syllable rather than a single sound?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'hard', 'Which branch of linguistics studies the meaning of words, phrases, and sentences?', 'Syntax', 'Phonetics', 'Semantics', 'Morphology', 'C', 'Semantics is the branch of linguistics concerned with meaning in language, at the level of words, phrases, and sentences.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'Which branch of linguistics studies the meaning of words, phrases, and sentences?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'hard', 'What is the term for a language variety that has both social and political recognition as a distinct language, often tied to a specific standardized form?', 'Dialect', 'Sociolect', 'Idiolect', 'Standard language', 'D', 'A standard language is a variety that has been codified and is recognized as the formal or official form used in education, media, and government.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'What is the term for a language variety that has both social and political recognition as a distinct language, often tied to a specific standardized form?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'hard', 'Which family of languages includes Tagalog, Malay, and Hawaiian, spread across a vast maritime region?', 'Sino-Tibetan', 'Austronesian', 'Niger-Congo', 'Trans-New Guinea', 'B', 'Tagalog, Malay, and Hawaiian all belong to the Austronesian language family, one of the most geographically widespread in the world.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'Which family of languages includes Tagalog, Malay, and Hawaiian, spread across a vast maritime region?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'hard', 'What is the term for the study of how words are formed and structured from smaller meaningful units?', 'Syntax', 'Phonology', 'Morphology', 'Etymology', 'C', 'Morphology is the branch of linguistics that studies the internal structure of words and how they are formed from morphemes.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'What is the term for the study of how words are formed and structured from smaller meaningful units?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'hard', 'Which term describes a language''s set of distinct speech sounds that distinguish meaning, such as the difference between ''p'' and ''b'' in English?', 'Phonemes', 'Morphemes', 'Allophones', 'Graphemes', 'A', 'Phonemes are the smallest units of sound in a language that can distinguish one word from another, such as ''p'' versus ''b.'''
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'Which term describes a language''s set of distinct speech sounds that distinguish meaning, such as the difference between ''p'' and ''b'' in English?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'hard', 'What is the term for a language that has died out, with no living native speakers, such as Latin in its classical form?', 'Extinct (dead) language', 'Endangered language', 'Moribund language', 'Sleeping language', 'A', 'An extinct or dead language has no remaining living native speakers, though it may still be studied or used in specialized contexts like liturgy.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'What is the term for a language that has died out, with no living native speakers, such as Latin in its classical form?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'hard', 'Which linguistic phenomenon describes borrowing words from one language into another, such as English ''sushi'' from Japanese?', 'Calque', 'Code-switching', 'Loanword (lexical borrowing)', 'Diglossia', 'C', 'A loanword is a term adopted from a foreign language with little or no modification, such as ''sushi'' borrowed into English from Japanese.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'Which linguistic phenomenon describes borrowing words from one language into another, such as English ''sushi'' from Japanese?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'hard', 'What term describes a society or community in which two distinct language varieties are used in different social contexts, one formal and one everyday?', 'Diglossia', 'Bilingualism', 'Multilingualism', 'Code-switching', 'A', 'Diglossia refers to a situation where two language varieties coexist in a community, each serving distinct formal and informal functions.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'What term describes a society or community in which two distinct language varieties are used in different social contexts, one formal and one everyday?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'hard', 'Which of these language families includes Arabic, Hebrew, and Amharic?', 'Niger-Congo', 'Indo-European', 'Altaic', 'Afro-Asiatic (Semitic branch)', 'D', 'Arabic, Hebrew, and Amharic all belong to the Semitic branch of the Afro-Asiatic language family.'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'Which of these language families includes Arabic, Hebrew, and Amharic?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_language', 'hard', 'What is the term for a figure of speech that combines seemingly contradictory terms, such as "deafening silence"?', 'Metaphor', 'Simile', 'Hyperbole', 'Oxymoron', 'D', 'An oxymoron combines two normally contradictory terms for rhetorical effect, such as "deafening silence" or "bittersweet."'
where not exists (
  select 1 from questions where category = 'general_language' and prompt = 'What is the term for a figure of speech that combines seemingly contradictory terms, such as "deafening silence"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'hard', 'What is the term for the layer of the Earth''s atmosphere where most weather phenomena occur, extending up to about 12 km?', 'Stratosphere', 'Mesosphere', 'Thermosphere', 'Troposphere', 'D', 'The troposphere is the lowest atmospheric layer, extending to roughly 12 kilometers, and is where most weather phenomena take place.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'What is the term for the layer of the Earth''s atmosphere where most weather phenomena occur, extending up to about 12 km?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'hard', 'Which biome is characterized by extremely low precipitation, high biodiversity of specially adapted species, and can be hot or cold?', 'Tundra', 'Taiga', 'Desert', 'Savanna', 'C', 'Deserts are defined primarily by very low precipitation rather than temperature, and can be either hot (like the Sahara) or cold (like Antarctica).'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'Which biome is characterized by extremely low precipitation, high biodiversity of specially adapted species, and can be hot or cold?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'hard', 'What natural process describes the gradual wearing away of rock and soil by wind, water, or ice?', 'Weathering', 'Erosion', 'Deposition', 'Sedimentation', 'B', 'Erosion is the process by which natural forces like wind, water, and ice wear away and transport rock and soil material.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'What natural process describes the gradual wearing away of rock and soil by wind, water, or ice?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'hard', 'Which ecological term describes a relationship where one organism benefits while the other is neither helped nor harmed?', 'Mutualism', 'Commensalism', 'Parasitism', 'Predation', 'B', 'Commensalism describes a relationship where one species benefits while the other experiences no significant effect, positive or negative.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'Which ecological term describes a relationship where one organism benefits while the other is neither helped nor harmed?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'hard', 'What is the term for the boundary zone between two distinct ecosystems, such as where a forest meets a grassland?', 'Ecotone', 'Biome', 'Habitat', 'Niche', 'A', 'An ecotone is a transitional area between two adjacent ecological communities, often containing species from both.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'What is the term for the boundary zone between two distinct ecosystems, such as where a forest meets a grassland?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'hard', 'Which cloud type, characterized by a flat, anvil-shaped top, is typically associated with thunderstorms?', 'Cumulonimbus', 'Cirrus', 'Stratus', 'Altocumulus', 'A', 'Cumulonimbus clouds, with their towering vertical development and anvil-shaped tops, are associated with thunderstorms and severe weather.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'Which cloud type, characterized by a flat, anvil-shaped top, is typically associated with thunderstorms?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'hard', 'What is the term for the natural cycle by which water moves between the atmosphere, land, and oceans?', 'The carbon cycle', 'The nitrogen cycle', 'The water cycle (hydrologic cycle)', 'The rock cycle', 'C', 'The water cycle, or hydrologic cycle, describes the continuous movement of water through evaporation, condensation, precipitation, and runoff.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'What is the term for the natural cycle by which water moves between the atmosphere, land, and oceans?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'hard', 'Which term describes an area''s collection of interacting organisms and their physical environment functioning as a unit?', 'Biosphere', 'Population', 'Community', 'Ecosystem', 'D', 'An ecosystem consists of a community of living organisms interacting with each other and their non-living physical environment.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'Which term describes an area''s collection of interacting organisms and their physical environment functioning as a unit?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'hard', 'What geological process forms mountains through the collision and folding of tectonic plates?', 'Subduction', 'Orogeny', 'Rifting', 'Erosion', 'B', 'Orogeny refers to the geological process of mountain formation, typically resulting from the collision and compression of tectonic plates.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'What geological process forms mountains through the collision and folding of tectonic plates?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'hard', 'Which term describes species that are not native to an ecosystem and cause ecological or economic harm after introduction?', 'Endemic species', 'Keystone species', 'Invasive species', 'Indicator species', 'C', 'Invasive species are non-native organisms introduced to an ecosystem that cause significant ecological or economic damage.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'Which term describes species that are not native to an ecosystem and cause ecological or economic harm after introduction?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'hard', 'What is the name for the phenomenon in which certain trees and plants shed their leaves seasonally to conserve water or survive cold?', 'Dormancy (a related but broader term)', 'Senescence', 'Abscission (the specific shedding mechanism)', 'Deciduousness', 'D', 'Deciduousness refers to plants that seasonally shed leaves, typically to conserve resources during cold or dry seasons.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'What is the name for the phenomenon in which certain trees and plants shed their leaves seasonally to conserve water or survive cold?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'hard', 'Which term describes a species whose presence or absence significantly affects the structure of an entire ecosystem, disproportionate to its abundance?', 'Keystone species', 'Indicator species', 'Invasive species', 'Umbrella species', 'A', 'A keystone species has an outsized effect on its ecosystem relative to its abundance, and its removal can dramatically alter the community structure.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'Which term describes a species whose presence or absence significantly affects the structure of an entire ecosystem, disproportionate to its abundance?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'hard', 'What is the term for the process by which plants convert light energy into chemical energy stored in glucose?', 'Respiration', 'Photosynthesis', 'Transpiration', 'Fermentation', 'B', 'Photosynthesis is the process by which plants use sunlight, water, and carbon dioxide to produce glucose and oxygen.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'What is the term for the process by which plants convert light energy into chemical energy stored in glucose?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'hard', 'Which natural phenomenon describes the periodic rise and fall of sea levels caused by the gravitational pull of the moon and sun?', 'Currents', 'Waves', 'Upwelling', 'Tides', 'D', 'Tides are the regular rise and fall of sea levels caused primarily by the gravitational forces of the moon and, to a lesser extent, the sun.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'Which natural phenomenon describes the periodic rise and fall of sea levels caused by the gravitational pull of the moon and sun?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'hard', 'What is the term for the specific role and position a species occupies within its ecosystem, including its interactions with other organisms?', 'Ecological niche', 'Habitat', 'Biome', 'Trophic level', 'A', 'An ecological niche encompasses a species'' role, resource use, and interactions within its environment, distinct from its physical habitat.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'What is the term for the specific role and position a species occupies within its ecosystem, including its interactions with other organisms?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'hard', 'Which soil horizon, typically the topmost layer, is richest in organic matter and nutrients essential for plant growth?', 'Topsoil (A horizon)', 'Subsoil (B horizon)', 'Bedrock (R horizon)', 'Parent material (C horizon)', 'A', 'The topsoil, or A horizon, is the uppermost soil layer and is typically the richest in organic matter and nutrients.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'Which soil horizon, typically the topmost layer, is richest in organic matter and nutrients essential for plant growth?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'hard', 'What is the term for organisms that can produce their own food from inorganic substances, typically through photosynthesis or chemosynthesis?', 'Heterotrophs', 'Autotrophs', 'Decomposers', 'Detritivores', 'B', 'Autotrophs, such as plants and certain bacteria, produce their own food from inorganic substances via photosynthesis or chemosynthesis.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'What is the term for organisms that can produce their own food from inorganic substances, typically through photosynthesis or chemosynthesis?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_nature', 'hard', 'Which layer of soil, found beneath topsoil, is dense, rich in clay and minerals, but has less organic matter?', 'Topsoil (A horizon)', 'Bedrock (R horizon)', 'Subsoil (B horizon)', 'Humus layer (O horizon)', 'C', 'The subsoil, or B horizon, lies beneath the topsoil and contains more clay and minerals but less organic material.'
where not exists (
  select 1 from questions where category = 'general_nature' and prompt = 'Which layer of soil, found beneath topsoil, is dense, rich in clay and minerals, but has less organic matter?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'hard', 'Which ancient wonder of the world, a massive statue, stood at the entrance of the harbor of Rhodes?', 'The Lighthouse of Alexandria', 'The Colossus of Rhodes', 'The Statue of Zeus at Olympia', 'The Hanging Gardens of Babylon', 'B', 'The Colossus of Rhodes, a giant statue of the sun god Helios, stood near the harbor entrance of the ancient Greek city of Rhodes.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'Which ancient wonder of the world, a massive statue, stood at the entrance of the harbor of Rhodes?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'hard', 'What is the only letter that does not appear in any U.S. state name?', 'Q', 'X', 'Z', 'J', 'A', 'The letter Q is the only letter of the alphabet that does not appear in the name of any U.S. state.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'What is the only letter that does not appear in any U.S. state name?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'hard', 'Which element has the chemical symbol ''Au,'' derived from its Latin name ''aurum''?', 'Silver', 'Aluminum', 'Gold', 'Argon', 'C', 'Gold''s chemical symbol, Au, comes from the Latin word ''aurum,'' meaning ''shining dawn'' or gold.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'Which element has the chemical symbol ''Au,'' derived from its Latin name ''aurum''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'hard', 'What is the term for a group of lions, one of the few big cats that lives in a social group structure?', 'A pride', 'A pack', 'A clan', 'A troop', 'A', 'A group of lions is called a pride, one of the most social living arrangements among big cat species.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'What is the term for a group of lions, one of the few big cats that lives in a social group structure?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'hard', 'Which country is both the largest by land area and spans eleven time zones?', 'Russia', 'Canada', 'China', 'United States', 'A', 'Russia is the largest country in the world by land area and spans eleven time zones, more than any other country.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'Which country is both the largest by land area and spans eleven time zones?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'hard', 'What is the name of the longest wall structure in the world, built over centuries to protect against invasions from the north?', 'Hadrian''s Wall', 'The Berlin Wall', 'The Western Wall', 'The Great Wall of China', 'D', 'The Great Wall of China, built and rebuilt over centuries by various dynasties, is the longest wall structure in the world.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'What is the name of the longest wall structure in the world, built over centuries to protect against invasions from the north?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'hard', 'Which planet in the solar system has the shortest day, completing a full rotation in about 10 hours?', 'Saturn', 'Neptune', 'Jupiter', 'Uranus', 'C', 'Jupiter, despite being the largest planet, has the shortest day of any planet in the solar system, rotating once in about 10 hours.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'Which planet in the solar system has the shortest day, completing a full rotation in about 10 hours?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'hard', 'What is the term for a word that reads the same forwards and backwards, such as ''level'' or ''radar''?', 'Anagram', 'Palindrome', 'Homophone', 'Oxymoron', 'B', 'A palindrome is a word, phrase, or sequence that reads identically forwards and backwards.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'What is the term for a word that reads the same forwards and backwards, such as ''level'' or ''radar''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'hard', 'Which country has the most natural lakes in the world, largely due to glacial activity during the last ice age?', 'Russia', 'Canada', 'Finland', 'United States', 'B', 'Canada has more natural lakes than any other country in the world, a result of extensive glacial activity during past ice ages.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'Which country has the most natural lakes in the world, largely due to glacial activity during the last ice age?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'hard', 'What is the collective term for a group of flamingos, referencing their vivid coloration?', 'A colony', 'A stand', 'A muster', 'A flamboyance', 'D', 'A group of flamingos is called a ''flamboyance,'' a term reflecting their vibrant pink coloration.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'What is the collective term for a group of flamingos, referencing their vivid coloration?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'hard', 'Which organ in the human body is capable of regenerating itself even after up to 70% of its tissue is removed?', 'The kidney', 'The liver', 'The lung', 'The pancreas', 'B', 'The liver has a remarkable ability to regenerate, able to restore its full size and function even after significant portions are removed or damaged.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'Which organ in the human body is capable of regenerating itself even after up to 70% of its tissue is removed?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'hard', 'What is the only mammal known to be naturally immune to snake venom in significant capacity, aside from certain resistant species?', 'The honey badger (among others with partial resistance)', 'The hedgehog', 'The mongoose (as an alternative widely cited example)', 'The opossum', 'C', 'Mongooses possess specialized receptors that make them highly resistant to many snake venoms, a well-documented evolutionary adaptation.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'What is the only mammal known to be naturally immune to snake venom in significant capacity, aside from certain resistant species?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'hard', 'Which desert is the largest hot desert in the world by area?', 'The Arabian Desert', 'The Sahara Desert', 'The Gobi Desert', 'The Kalahari Desert', 'B', 'The Sahara Desert in North Africa is the largest hot desert in the world, though Antarctica and the Arctic are technically larger cold deserts.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'Which desert is the largest hot desert in the world by area?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'hard', 'What is the name for the phenomenon where the sky appears red or orange during sunrise and sunset due to light scattering?', 'Refraction', 'Diffraction', 'Polarization', 'Rayleigh scattering (specifically causing the reddish hues)', 'D', 'The reddish and orange hues at sunrise and sunset result from Rayleigh scattering, where shorter blue wavelengths scatter out, leaving longer red and orange wavelengths visible.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'What is the name for the phenomenon where the sky appears red or orange during sunrise and sunset due to light scattering?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'hard', 'Which country consumes the most coffee per capita in the world, according to widely cited consumption statistics?', 'Finland', 'Brazil', 'Italy', 'United States', 'A', 'Finland consistently ranks as the country with the highest coffee consumption per capita in the world.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'Which country consumes the most coffee per capita in the world, according to widely cited consumption statistics?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'hard', 'What is the term for the imaginary line of zero degrees longitude, from which all other longitudes are measured, passing through Greenwich, England?', 'The Equator', 'The International Date Line', 'The Tropic of Cancer', 'The Prime Meridian', 'D', 'The Prime Meridian, passing through Greenwich, England, is the reference line for zero degrees longitude, from which east and west are measured.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'What is the term for the imaginary line of zero degrees longitude, from which all other longitudes are measured, passing through Greenwich, England?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'hard', 'Which animal has the longest lifespan of any known mammal, with some individuals estimated to live over 200 years?', 'Galapagos tortoise (a reptile, not mammal)', 'Greenland shark (a fish, not mammal)', 'Bowhead whale', 'African elephant', 'C', 'The bowhead whale is the longest-lived mammal known, with some individuals estimated, via eye lens analysis and harpoon evidence, to exceed 200 years.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'Which animal has the longest lifespan of any known mammal, with some individuals estimated to live over 200 years?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'general_trivia', 'hard', 'Which chemical element, with atomic number 79, has been used as currency and jewelry throughout human history due to its resistance to corrosion?', 'Gold', 'Platinum', 'Silver', 'Copper', 'A', 'Gold, atomic number 79, resists corrosion and tarnishing, making it historically prized for currency, jewelry, and decoration.'
where not exists (
  select 1 from questions where category = 'general_trivia' and prompt = 'Which chemical element, with atomic number 79, has been used as currency and jewelry throughout human history due to its resistance to corrosion?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'geography', 'hard', 'Which Philippine mountain range runs along the eastern coast of Luzon and is known as the longest mountain range in the country?', 'Cordillera Central', 'Sierra Madre', 'Zambales Mountains', 'Caraballo Mountains', 'B', 'The Sierra Madre range stretches along the eastern coast of Luzon and is the longest mountain range in the Philippines.'
where not exists (
  select 1 from questions where category = 'geography' and prompt = 'Which Philippine mountain range runs along the eastern coast of Luzon and is known as the longest mountain range in the country?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'geography', 'hard', 'What is the name of the deepest known point in the Philippine Trench, part of the larger Philippine Sea?', 'Emden Deep', 'Challenger Deep', 'Galathea Depth', 'Sirena Deep', 'C', 'The Philippine Trench''s deepest point is known as the Galathea Depth, reaching depths over 10,000 meters.'
where not exists (
  select 1 from questions where category = 'geography' and prompt = 'What is the name of the deepest known point in the Philippine Trench, part of the larger Philippine Sea?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'geography', 'hard', 'Which strait separates the island of Mindoro from Luzon''s Batangas province?', 'Verde Island Passage', 'San Bernardino Strait', 'Surigao Strait', 'Mindoro Strait', 'A', 'The Verde Island Passage, located between Batangas and Mindoro, is recognized as a global center of marine biodiversity.'
where not exists (
  select 1 from questions where category = 'geography' and prompt = 'Which strait separates the island of Mindoro from Luzon''s Batangas province?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'geography', 'hard', 'What is the highest mountain in the Philippines, located in Davao del Sur and Davao Occidental?', 'Mount Pulag', 'Mount Mayon', 'Mount Kanlaon', 'Mount Apo', 'D', 'Mount Apo, standing at 2,954 meters, is the highest mountain in the Philippines, straddling Davao del Sur and Davao Occidental.'
where not exists (
  select 1 from questions where category = 'geography' and prompt = 'What is the highest mountain in the Philippines, located in Davao del Sur and Davao Occidental?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'geography', 'hard', 'Which river, the longest in the Philippines, flows through the Cagayan Valley region?', 'Pasig River', 'Agno River', 'Cagayan River', 'Pampanga River', 'C', 'The Cagayan River, also called the Rio Grande de Cagayan, is the longest river in the Philippines, flowing through the Cagayan Valley.'
where not exists (
  select 1 from questions where category = 'geography' and prompt = 'Which river, the longest in the Philippines, flows through the Cagayan Valley region?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'geography', 'hard', 'What type of geological formation are the Chocolate Hills of Bohol classified as?', 'Karst limestone hills', 'Volcanic cinder cones', 'Coral reef terraces', 'Glacial moraines', 'A', 'The Chocolate Hills are unusual karst formations composed of marine limestone, weathered over time into their distinctive conical shapes.'
where not exists (
  select 1 from questions where category = 'geography' and prompt = 'What type of geological formation are the Chocolate Hills of Bohol classified as?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'geography', 'hard', 'Which body of water separates the island groups of Luzon and Visayas, notably crossed by ferries to Samar?', 'Surigao Strait', 'San Bernardino Strait', 'Verde Island Passage', 'Tañon Strait', 'B', 'The San Bernardino Strait connects the Pacific Ocean and the Sibuyan Sea, separating southern Luzon from Samar.'
where not exists (
  select 1 from questions where category = 'geography' and prompt = 'Which body of water separates the island groups of Luzon and Visayas, notably crossed by ferries to Samar?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'geography', 'hard', 'What is the name of the active volcano in Batangas known for being situated within a lake on an island?', 'Mount Banahaw', 'Mount Makiling', 'Mount Isarog', 'Taal Volcano', 'D', 'Taal Volcano sits on Volcano Island within Taal Lake, itself formed by a much older, larger caldera.'
where not exists (
  select 1 from questions where category = 'geography' and prompt = 'What is the name of the active volcano in Batangas known for being situated within a lake on an island?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'geography', 'hard', 'Which Philippine island is known as the ''Last Frontier'' and has the longest coastline relative to its land area among major islands?', 'Palawan', 'Mindoro', 'Samar', 'Negros', 'A', 'Palawan, dubbed the ''Last Frontier,'' is elongated and narrow, giving it an extensive coastline relative to its land area.'
where not exists (
  select 1 from questions where category = 'geography' and prompt = 'Which Philippine island is known as the ''Last Frontier'' and has the longest coastline relative to its land area among major islands?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'geography', 'hard', 'What is the term for the narrow body of water separating Negros and Cebu islands?', 'Guimaras Strait', 'Tañon Strait', 'Surigao Strait', 'Iloilo Strait', 'B', 'Tañon Strait separates Negros and Cebu and is recognized as a protected seascape rich in marine biodiversity.'
where not exists (
  select 1 from questions where category = 'geography' and prompt = 'What is the term for the narrow body of water separating Negros and Cebu islands?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'history', 'hard', 'Which 1872 event, involving the execution of three Filipino priests, is widely seen as a catalyst for Filipino nationalism?', 'The Cavite Mutiny trial only', 'The Gomburza executions', 'The Battle of Manila Bay', 'The Katipunan discovery', 'B', 'The 1872 execution of priests Gomez, Burgos, and Zamora (Gomburza), following the Cavite Mutiny, galvanized Filipino nationalist sentiment.'
where not exists (
  select 1 from questions where category = 'history' and prompt = 'Which 1872 event, involving the execution of three Filipino priests, is widely seen as a catalyst for Filipino nationalism?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'history', 'hard', 'What was the name of the 1898 agreement in which Spain ceded the Philippines to the United States?', 'Treaty of Biak-na-Bato', 'Pact of Zanjon', 'Treaty of Paris', 'Treaty of Manila', 'C', 'The Treaty of Paris, signed in December 1898, ended the Spanish-American War and transferred the Philippines to the United States for $20 million.'
where not exists (
  select 1 from questions where category = 'history' and prompt = 'What was the name of the 1898 agreement in which Spain ceded the Philippines to the United States?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'history', 'hard', 'Which short-lived agreement in 1897 temporarily ended hostilities between Spanish forces and Filipino revolutionaries, exiling Aguinaldo to Hong Kong?', 'Pact of Biak-na-Bato', 'Treaty of Paris', 'Malolos Constitution', 'Cavite Mutiny accord', 'A', 'The Pact of Biak-na-Bato was a truce between the Spanish colonial government and Filipino revolutionaries, resulting in Aguinaldo''s temporary exile.'
where not exists (
  select 1 from questions where category = 'history' and prompt = 'Which short-lived agreement in 1897 temporarily ended hostilities between Spanish forces and Filipino revolutionaries, exiling Aguinaldo to Hong Kong?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'history', 'hard', 'Who was the first President of the short-lived Malolos Republic, established in 1899?', 'Andres Bonifacio', 'Apolinario Mabini', 'Emilio Aguinaldo', 'Manuel Quezon', 'C', 'Emilio Aguinaldo was inaugurated as the first President of the Malolos Republic, the first constitutional republic in Asia, in January 1899.'
where not exists (
  select 1 from questions where category = 'history' and prompt = 'Who was the first President of the short-lived Malolos Republic, established in 1899?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'history', 'hard', 'Which battle in 1898, largely staged for appearances, ended Spanish colonial rule with minimal actual fighting in Manila?', 'The Battle of Manila Bay', 'The Siege of Baler', 'The Battle of Alapan', 'The Mock Battle of Manila', 'D', 'The so-called Mock Battle of Manila was a prearranged, largely symbolic engagement allowing Spain to surrender to the Americans rather than Filipino revolutionaries.'
where not exists (
  select 1 from questions where category = 'history' and prompt = 'Which battle in 1898, largely staged for appearances, ended Spanish colonial rule with minimal actual fighting in Manila?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'history', 'hard', 'What was the name of the Japanese-sponsored puppet state established in the Philippines during World War II?', 'The Second Philippine Republic', 'The Commonwealth Restoration', 'The Bataan Protectorate', 'The Manila Directorate', 'A', 'The Second Philippine Republic, led by President Jose P. Laurel, was a Japanese-sponsored government during the occupation from 1943 to 1945.'
where not exists (
  select 1 from questions where category = 'history' and prompt = 'What was the name of the Japanese-sponsored puppet state established in the Philippines during World War II?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'history', 'hard', 'Which 1935 document established the Commonwealth of the Philippines as a transitional government before full independence?', 'The Malolos Constitution', 'The Jones Law', 'The Tydings-McDuffie Act (the enabling law, not the constitution)', 'The 1935 Constitution', 'D', 'The 1935 Constitution established the Commonwealth government, a transitional period leading toward full Philippine independence in 1946.'
where not exists (
  select 1 from questions where category = 'history' and prompt = 'Which 1935 document established the Commonwealth of the Philippines as a transitional government before full independence?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'history', 'hard', 'What event in 1521 led to Ferdinand Magellan''s death in the Philippines?', 'The Battle of Manila Bay', 'The Battle of Mactan', 'The Siege of Intramuros', 'The Cebu uprising', 'B', 'Magellan was killed in the Battle of Mactan by forces led by Datu Lapu-Lapu, who resisted Spanish and Christian influence.'
where not exists (
  select 1 from questions where category = 'history' and prompt = 'What event in 1521 led to Ferdinand Magellan''s death in the Philippines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'history', 'hard', 'Which American colonial policy allowed a limited number of Filipinos to pursue government-funded education in the United States starting in 1903?', 'The Pensionado Act', 'The Jones Law', 'The Philippine Organic Act', 'The Payne-Aldrich Tariff', 'A', 'The Pensionado Act of 1903 sent selected young Filipinos to study in American universities, intending to train future civil servants and leaders.'
where not exists (
  select 1 from questions where category = 'history' and prompt = 'Which American colonial policy allowed a limited number of Filipinos to pursue government-funded education in the United States starting in 1903?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'history', 'hard', 'What was the code name for the joint American-Filipino guerrilla resistance network operating in the Philippines during Japanese occupation?', 'Task Force Freedom', 'There was no single unified code name; resistance was organized regionally', 'Operation Bolo', 'Unit Bagong Bayani', 'B', 'Filipino and American guerrilla resistance during the occupation was fragmented into numerous regional units rather than one unified command.'
where not exists (
  select 1 from questions where category = 'history' and prompt = 'What was the code name for the joint American-Filipino guerrilla resistance network operating in the Philippines during Japanese occupation?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'hard', 'Which bone is the longest and strongest bone in the human body?', 'The tibia', 'The femur', 'The humerus', 'The fibula', 'B', 'The femur, or thigh bone, is both the longest and strongest bone in the human body.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'Which bone is the longest and strongest bone in the human body?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'hard', 'What is the term for the body''s main regulatory gland, located at the base of the brain, often called the ''master gland''?', 'The pituitary gland', 'The thyroid gland', 'The adrenal gland', 'The pineal gland', 'A', 'The pituitary gland is called the ''master gland'' because it controls the function of many other endocrine glands throughout the body.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'What is the term for the body''s main regulatory gland, located at the base of the brain, often called the ''master gland''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'hard', 'Which part of the brain is primarily responsible for coordinating balance, posture, and fine motor movements?', 'The cerebellum', 'The cerebrum', 'The medulla oblongata', 'The hypothalamus', 'A', 'The cerebellum, located at the back of the brain, plays a key role in coordinating balance, posture, and precise motor control.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'Which part of the brain is primarily responsible for coordinating balance, posture, and fine motor movements?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'hard', 'What is the name of the protective membrane surrounding the lungs, which reduces friction during breathing?', 'The pericardium', 'The pleura', 'The peritoneum', 'The meninges', 'B', 'The pleura is a double-layered membrane surrounding the lungs, with fluid between the layers reducing friction during breathing.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'What is the name of the protective membrane surrounding the lungs, which reduces friction during breathing?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'hard', 'Which type of blood cell is primarily responsible for fighting infections as part of the immune system?', 'Red blood cells (erythrocytes)', 'White blood cells (leukocytes)', 'Platelets (thrombocytes)', 'Plasma cells (a specific subtype, not a general category)', 'B', 'White blood cells, or leukocytes, are the primary immune cells responsible for defending the body against infections and foreign invaders.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'Which type of blood cell is primarily responsible for fighting infections as part of the immune system?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'hard', 'What is the name of the small, worm-shaped pouch attached to the large intestine, with no confirmed essential digestive function?', 'The cecum', 'The ileum', 'The rectum', 'The appendix', 'D', 'The appendix is a small pouch attached to the large intestine, and although once thought vestigial, it may play a minor role in immune function.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'What is the name of the small, worm-shaped pouch attached to the large intestine, with no confirmed essential digestive function?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'hard', 'Which hormone, produced by the pancreas, regulates blood glucose levels by facilitating cellular glucose uptake?', 'Insulin', 'Glucagon', 'Cortisol', 'Adrenaline', 'A', 'Insulin, produced by the pancreas''s beta cells, lowers blood glucose levels by promoting its uptake into cells for energy or storage.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'Which hormone, produced by the pancreas, regulates blood glucose levels by facilitating cellular glucose uptake?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'hard', 'What is the term for the body''s largest organ, serving as a protective barrier against the external environment?', 'The liver', 'The lungs', 'The skin', 'The intestines', 'C', 'The skin is the largest organ in the human body, providing a protective barrier, regulating temperature, and enabling sensation.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'What is the term for the body''s largest organ, serving as a protective barrier against the external environment?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'hard', 'Which chamber of the human heart receives deoxygenated blood returning from the body via the vena cava?', 'The left atrium', 'The right ventricle', 'The right atrium', 'The left ventricle', 'C', 'The right atrium receives deoxygenated blood returning from the body through the superior and inferior vena cava.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'Which chamber of the human heart receives deoxygenated blood returning from the body via the vena cava?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'hard', 'What is the name for the specialized cells in the retina responsible for color vision, functioning best in bright light?', 'Rods', 'Bipolar cells', 'Ganglion cells', 'Cones', 'D', 'Cone cells in the retina are responsible for color vision and function best under bright light conditions, unlike rods which detect light and dark.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'What is the name for the specialized cells in the retina responsible for color vision, functioning best in bright light?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'hard', 'Which part of the nervous system controls involuntary bodily functions like heart rate, digestion, and respiratory rate?', 'The somatic nervous system', 'The autonomic nervous system', 'The central nervous system (broader category)', 'The peripheral nervous system (broader category)', 'B', 'The autonomic nervous system regulates involuntary functions such as heart rate, digestion, and breathing, without conscious control.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'Which part of the nervous system controls involuntary bodily functions like heart rate, digestion, and respiratory rate?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'hard', 'What is the term for the process by which the body maintains a stable internal environment despite external changes?', 'Metabolism', 'Adaptation', 'Osmoregulation (a specific subset)', 'Homeostasis', 'D', 'Homeostasis refers to the body''s ability to maintain a stable internal environment, such as temperature and pH, despite external fluctuations.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'What is the term for the process by which the body maintains a stable internal environment despite external changes?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'hard', 'Which gland, located in the neck, produces hormones that regulate metabolism throughout the body?', 'The parathyroid gland', 'The pituitary gland', 'The thyroid gland', 'The adrenal gland', 'C', 'The thyroid gland, located in the neck, produces hormones like thyroxine that regulate the body''s overall metabolic rate.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'Which gland, located in the neck, produces hormones that regulate metabolism throughout the body?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'hard', 'What is the name of the fluid-filled sac that cushions and protects the heart within the chest cavity?', 'The pleura', 'The peritoneum', 'The pericardium', 'The meninges', 'C', 'The pericardium is a protective, fluid-filled sac that surrounds and cushions the heart within the chest cavity.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'What is the name of the fluid-filled sac that cushions and protects the heart within the chest cavity?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'hard', 'Which type of muscle tissue is found exclusively in the heart and is both striated and involuntary?', 'Skeletal muscle', 'Cardiac muscle', 'Smooth muscle', 'Visceral muscle (an older, less precise term)', 'B', 'Cardiac muscle is unique in being both striated in appearance and involuntary in control, found exclusively in the heart.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'Which type of muscle tissue is found exclusively in the heart and is both striated and involuntary?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'hard', 'What is the term for the specialized connective tissue that connects muscles to bones?', 'Tendon', 'Ligament', 'Cartilage', 'Fascia', 'A', 'Tendons are tough connective tissue structures that attach muscles to bones, transmitting the force of muscle contraction.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'What is the term for the specialized connective tissue that connects muscles to bones?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'hard', 'Which part of the ear is responsible for converting sound vibrations into electrical signals for the brain to interpret?', 'The cochlea', 'The eardrum (tympanic membrane)', 'The ossicles', 'The auditory canal', 'A', 'The cochlea, a spiral-shaped structure in the inner ear, converts sound vibrations into electrical nerve signals interpreted by the brain.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'Which part of the ear is responsible for converting sound vibrations into electrical signals for the brain to interpret?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'human_body', 'hard', 'What is the name for the process by which the kidneys filter waste products from the blood to form urine?', 'Digestion', 'Respiration', 'Circulation', 'Filtration (as part of the broader process of nephron function)', 'D', 'The kidneys filter blood through structures called nephrons, removing waste products and excess substances to form urine.'
where not exists (
  select 1 from questions where category = 'human_body' and prompt = 'What is the name for the process by which the kidneys filter waste products from the blood to form urine?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'hard', 'Which Filipino engineer is credited with contributing to the design of NASA''s Lunar Roving Vehicle used in the Apollo missions?', 'Diosdado Banatao', 'Roberto del Rosario', 'Gregorio Zara', 'Eduardo San Juan', 'D', 'Eduardo San Juan, a Filipino engineer at General Motors, contributed to the design of the Lunar Roving Vehicle used in NASA''s Apollo missions.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Which Filipino engineer is credited with contributing to the design of NASA''s Lunar Roving Vehicle used in the Apollo missions?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'hard', 'Which Filipino inventor patented the ''Karaoke Sing Along System'' in the Philippines in 1975?', 'Gregorio Zara', 'Eduardo San Juan', 'Roberto del Rosario', 'Fe del Mundo', 'C', 'Roberto del Rosario patented the Karaoke Sing Along System in 1975, an early forerunner of modern karaoke technology.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Which Filipino inventor patented the ''Karaoke Sing Along System'' in the Philippines in 1975?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'hard', 'Which Filipino scientist is credited with inventing a two-way video telephone in 1955, decades before video calling became common?', 'Eduardo San Juan', 'Diosdado Banatao', 'Gregorio Zara', 'Agapito Flores', 'C', 'Gregorio Zara, a National Scientist of the Philippines, is credited with inventing a video telephone in 1955.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Which Filipino scientist is credited with inventing a two-way video telephone in 1955, decades before video calling became common?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'hard', 'Which Filipino engineer, prominent in Silicon Valley, is known for pioneering work on microprocessor and integrated circuit technology?', 'Diosdado Banatao', 'Eduardo San Juan', 'Gregorio Zara', 'Roberto del Rosario', 'A', 'Diosdado Banatao is a Filipino engineer and Silicon Valley entrepreneur known for pioneering key microprocessor and integrated circuit designs.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Which Filipino engineer, prominent in Silicon Valley, is known for pioneering work on microprocessor and integrated circuit technology?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'hard', 'Which Filipino doctor became the first woman admitted to Harvard Medical School and later founded a children''s hospital in the Philippines?', 'Josefina Guerrero', 'Honoria Acosta-Sison', 'Paz Mendoza Guazon', 'Fe del Mundo', 'D', 'Dr. Fe del Mundo became the first woman admitted to Harvard Medical School and later founded the Children''s Medical Center in the Philippines.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Which Filipino doctor became the first woman admitted to Harvard Medical School and later founded a children''s hospital in the Philippines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'hard', 'Which Filipino food technologist invented banana ketchup and the soy-based nutritional drink Soyalac during World War II?', 'Fe del Mundo', 'Maria Orosa', 'Josefina Guerrero', 'Honoria Acosta-Sison', 'B', 'Maria Orosa developed banana ketchup as a tomato substitute and Soyalac, a soy-based nutritional drink, during World War II food shortages.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Which Filipino food technologist invented banana ketchup and the soy-based nutritional drink Soyalac during World War II?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'hard', 'Which Filipino scientist discovered the soil bacterium that led to the development of the antibiotic erythromycin?', 'Abelardo Aguilar', 'Gregorio Zara', 'Fe del Mundo', 'Eduardo San Juan', 'A', 'Abelardo Aguilar, a Filipino scientist, discovered the soil bacterium Streptomyces erythreus, which led to the development of erythromycin.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Which Filipino scientist discovered the soil bacterium that led to the development of the antibiotic erythromycin?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'hard', 'Which Filipino inventor is popularly, though disputedly, credited in folklore with inventing the fluorescent lamp?', 'Roberto del Rosario', 'Agapito Flores', 'Eduardo San Juan', 'Gregorio Zara', 'B', 'Agapito Flores is popularly claimed to have invented the fluorescent lamp, though this claim lacks solid documented patent evidence and is disputed by historians.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Which Filipino inventor is popularly, though disputedly, credited in folklore with inventing the fluorescent lamp?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'hard', 'What iconic Filipino mode of transportation was created by repurposing surplus American military jeeps left after World War II?', 'The jeepney', 'The tricycle', 'The calesa', 'The kuliglig', 'A', 'The jeepney was created by Filipinos who modified and decorated surplus U.S. military jeeps left behind after World War II, becoming a national icon.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'What iconic Filipino mode of transportation was created by repurposing surplus American military jeeps left after World War II?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'hard', 'Dr. Fe del Mundo developed an incubator made from what locally available material, designed for use in rural areas without electricity?', 'Rattan', 'Coconut husk', 'Bamboo', 'Nipa palm', 'C', 'Fe del Mundo developed a bamboo incubator suited for rural hospitals and clinics that lacked reliable access to electricity.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Dr. Fe del Mundo developed an incubator made from what locally available material, designed for use in rural areas without electricity?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'hard', 'Which Filipino National Scientist made foundational contributions to rice genetics and plant breeding that supported agricultural advances in Asia?', 'Dioscoro Umali', 'Gregorio Zara', 'Eduardo Quisumbing', 'Julian Banzon', 'A', 'Dioscoro Umali, a National Scientist, made significant contributions to plant breeding and rice genetics research in the Philippines and across Asia.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Which Filipino National Scientist made foundational contributions to rice genetics and plant breeding that supported agricultural advances in Asia?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'hard', 'Which Filipino chemist and National Scientist pioneered research into producing alternative fuels from coconut and sugarcane?', 'Julian Banzon', 'Dioscoro Umali', 'Eduardo Quisumbing', 'Gregorio Zara', 'A', 'Julian Banzon, a National Scientist, conducted early research into producing alternative fuels from coconut and sugarcane, anticipating modern biofuel development.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Which Filipino chemist and National Scientist pioneered research into producing alternative fuels from coconut and sugarcane?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'hard', 'Which Filipino botanist and National Scientist is known for extensive taxonomic work cataloging Philippine plant species?', 'Dioscoro Umali', 'Eduardo Quisumbing', 'Julian Banzon', 'Gregorio Velasquez', 'B', 'Eduardo Quisumbing, a National Scientist, conducted extensive taxonomic research, cataloging numerous Philippine plant species.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Which Filipino botanist and National Scientist is known for extensive taxonomic work cataloging Philippine plant species?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'hard', 'Which Filipino scientist is recognized as the ''Father of Philippine Algology'' for his pioneering research on algae?', 'Eduardo Quisumbing', 'Julian Banzon', 'Dioscoro Umali', 'Gregorio Velasquez', 'D', 'Gregorio Velasquez is recognized as the ''Father of Philippine Algology'' for his pioneering studies of algae species found in the Philippines.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Which Filipino scientist is recognized as the ''Father of Philippine Algology'' for his pioneering research on algae?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'hard', 'Which Filipino engineer, also a National Scientist, is known for his work in aeronautics and for building the country''s first indigenous aircraft engine?', 'Eduardo San Juan', 'Diosdado Banatao', 'Julian Banzon', 'Gregorio Zara', 'D', 'Gregorio Zara, beyond the video telephone, was also a pioneering aeronautical engineer credited with building an early indigenous airplane engine.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Which Filipino engineer, also a National Scientist, is known for his work in aeronautics and for building the country''s first indigenous aircraft engine?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'hard', 'What is the name of the Philippines'' first indigenously designed and built satellite, launched in 2016 with Japanese assistance?', 'Maya-1', 'Diwata-1', 'Agila-2', 'PHL-Microsat', 'B', 'Diwata-1, launched in 2016, was the first microsatellite designed and built by Filipino engineers and scientists.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'What is the name of the Philippines'' first indigenously designed and built satellite, launched in 2016 with Japanese assistance?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'hard', 'Which Filipino-built microsatellite, developed by students, was deployed from the International Space Station in 2018?', 'Diwata-1', 'Diwata-2', 'Maya-1', 'Agila-2', 'C', 'Maya-1 was a Filipino-developed cube satellite deployed from the International Space Station in 2018, built with contributions from Filipino graduate students.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Which Filipino-built microsatellite, developed by students, was deployed from the International Space Station in 2018?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'innovations', 'hard', 'Which agency oversees the Philippines'' space program and satellite development initiatives, established in 2019?', 'Department of Science and Technology (DOST) exclusively', 'Philippine Space Agency (PhilSA)', 'Advanced Science and Technology Institute (ASTI)', 'National Space Development Office', 'B', 'The Philippine Space Agency (PhilSA) was formally established in 2019 to oversee and coordinate the country''s space program and related research.'
where not exists (
  select 1 from questions where category = 'innovations' and prompt = 'Which agency oversees the Philippines'' space program and satellite development initiatives, established in 2019?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'hard', 'Which UNESCO World Heritage Site in the Philippines consists of four separate baroque churches built during the Spanish colonial era?', 'Historic Town of Vigan', 'Rice Terraces of the Philippine Cordilleras', 'Baroque Churches of the Philippines', 'Tubbataha Reefs Natural Park', 'C', 'The Baroque Churches of the Philippines, a UNESCO World Heritage Site, comprises four churches: San Agustin (Manila), Paoay, Miag-ao, and Santa Maria.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'Which UNESCO World Heritage Site in the Philippines consists of four separate baroque churches built during the Spanish colonial era?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'hard', 'Which historic walled city within Manila served as the seat of Spanish colonial government for over 300 years?', 'Fort Santiago (part of Intramuros)', 'Intramuros', 'Binondo', 'Malacañang Complex', 'B', 'Intramuros, meaning ''within the walls,'' was the fortified center of Spanish colonial power in Manila for over three centuries.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'Which historic walled city within Manila served as the seat of Spanish colonial government for over 300 years?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'hard', 'What is the name of the historic fort within Intramuros associated with Jose Rizal''s imprisonment before his execution?', 'Fort Bonifacio', 'Fort Pilar', 'Fort Santiago', 'Fort San Pedro', 'C', 'Fort Santiago, located within Intramuros, was where national hero Jose Rizal was imprisoned before his execution in 1896.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'What is the name of the historic fort within Intramuros associated with Jose Rizal''s imprisonment before his execution?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'hard', 'Which UNESCO World Heritage-listed rice terraces in Ifugao are often called the ''Eighth Wonder of the World''?', 'The Batad Rice Terraces (a specific cluster, part of the same site)', 'The Banaue-Ifugao Terraces (informal combined name)', 'The Banaue Rice Terraces (part of the Rice Terraces of the Philippine Cordilleras)', 'The Cordillera Rice Steps', 'C', 'The Banaue Rice Terraces, part of the larger UNESCO-listed Rice Terraces of the Philippine Cordilleras, are often called the ''Eighth Wonder of the World.'''
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'Which UNESCO World Heritage-listed rice terraces in Ifugao are often called the ''Eighth Wonder of the World''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'hard', 'Which historic Cebu landmark is believed to be the oldest religious relic in the Philippines, associated with Ferdinand Magellan''s arrival?', 'The Santo Niño de Cebu (housed in the Basilica Minore del Santo Niño)', 'Fort San Pedro', 'The Cebu Metropolitan Cathedral', 'Magellan''s Cross', 'D', 'Magellan''s Cross, planted in Cebu in 1521 to mark the Christianization of the islands, is one of the most historic religious landmarks in the Philippines.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'Which historic Cebu landmark is believed to be the oldest religious relic in the Philippines, associated with Ferdinand Magellan''s arrival?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'hard', 'What is the name of the oldest and smallest fort built by the Spanish in the Philippines, located in Cebu City?', 'Fort Santiago', 'Fort Pilar', 'Fort San Pedro', 'Fort Bonifacio', 'C', 'Fort San Pedro, built in Cebu City, is recognized as the oldest and smallest triangular bastion fort constructed by the Spanish in the Philippines.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'What is the name of the oldest and smallest fort built by the Spanish in the Philippines, located in Cebu City?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'hard', 'Which UNESCO World Heritage town in Ilocos Sur is renowned for its well-preserved Spanish colonial architecture and cobblestone streets?', 'Vigan', 'Taal', 'Silay', 'Iloilo City', 'A', 'Vigan, in Ilocos Sur, is a UNESCO World Heritage Site celebrated for its remarkably preserved Spanish colonial townscape and architecture.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'Which UNESCO World Heritage town in Ilocos Sur is renowned for its well-preserved Spanish colonial architecture and cobblestone streets?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'hard', 'What is the name of the official residence and workplace of the President of the Philippines, located along the Pasig River?', 'Rizal Park (a separate landmark)', 'Malacañang Palace', 'Quirino Grandstand (a separate landmark)', 'Manila Cathedral (a separate landmark)', 'B', 'Malacañang Palace, situated along the Pasig River in Manila, has served as the official residence and workplace of Philippine presidents for generations.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'What is the name of the official residence and workplace of the President of the Philippines, located along the Pasig River?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'hard', 'Which historic park in Manila is the site of Jose Rizal''s execution and now houses his monument?', 'Rizal Park (Luneta)', 'Intramuros', 'Paco Park', 'Fort Santiago', 'A', 'Rizal Park, also known as Luneta, marks the site of Jose Rizal''s execution in 1896 and now houses his monument and remains.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'Which historic park in Manila is the site of Jose Rizal''s execution and now houses his monument?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'hard', 'What is the name of the marine protected area in the Sulu Sea recognized as a UNESCO World Heritage Site for its coral reef biodiversity?', 'Apo Reef Natural Park', 'El Nido Marine Reserve', 'Coron Reef Sanctuary', 'Tubbataha Reefs Natural Park', 'D', 'Tubbataha Reefs Natural Park, in the Sulu Sea, is a UNESCO World Heritage Site renowned for its pristine and biodiverse coral reef ecosystems.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'What is the name of the marine protected area in the Sulu Sea recognized as a UNESCO World Heritage Site for its coral reef biodiversity?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'hard', 'Which historic bridge in Manila, one of the oldest stone bridges in the Philippines, spans the Pasig River near Intramuros?', 'Jones Bridge (though the original stone Puente Grande predates it on a similar site)', 'MacArthur Bridge', 'Ayala Bridge', 'Quezon Bridge', 'A', 'Jones Bridge, spanning the Pasig River near Intramuros, is among Manila''s most historic and iconic bridges, rebuilt several times over the centuries.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'Which historic bridge in Manila, one of the oldest stone bridges in the Philippines, spans the Pasig River near Intramuros?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'hard', 'What is the name of the centuries-old Chinese-Filipino district in Manila, considered the oldest Chinatown in the world?', 'Binondo', 'Divisoria', 'Quiapo', 'Santa Cruz', 'A', 'Binondo, established in 1594, is widely recognized as the oldest continuously operating Chinatown in the world.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'What is the name of the centuries-old Chinese-Filipino district in Manila, considered the oldest Chinatown in the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'hard', 'Which historic Augustinian church in Manila, part of the Baroque Churches UNESCO site, survived the destruction of Intramuros in World War II?', 'Manila Cathedral', 'San Agustin Church', 'Quiapo Church', 'Binondo Church', 'B', 'San Agustin Church, the oldest stone church in the Philippines, remarkably survived the near-total destruction of Intramuros during World War II.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'Which historic Augustinian church in Manila, part of the Baroque Churches UNESCO site, survived the destruction of Intramuros in World War II?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'hard', 'What is the name of the historic lighthouse on Corregidor Island, a key defensive position during World War II battles for Manila Bay?', 'Cape Bojeador Lighthouse', 'Corregidor Lighthouse', 'Capones Island Lighthouse', 'Cape Melville Lighthouse', 'B', 'Corregidor Lighthouse stands on the historic island fortress of Corregidor, which played a critical defensive role during World War II.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'What is the name of the historic lighthouse on Corregidor Island, a key defensive position during World War II battles for Manila Bay?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'hard', 'Which centuries-old lighthouse in Ilocos Norte is considered one of the tallest and oldest surviving lighthouses in the Philippines?', 'Corregidor Lighthouse', 'Cape Bojeador Lighthouse (Burgos Lighthouse)', 'Capones Island Lighthouse', 'Cape Engaño Lighthouse', 'B', 'Cape Bojeador Lighthouse, also known as Burgos Lighthouse, in Ilocos Norte, is one of the oldest and tallest surviving Spanish-era lighthouses in the country.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'Which centuries-old lighthouse in Ilocos Norte is considered one of the tallest and oldest surviving lighthouses in the Philippines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'hard', 'What is the name of the ancestral gateway tower structure found in the historic town of Taal, Batangas, reflecting Spanish colonial urban planning?', 'The Taal Heritage Arch', 'The Taal Belfry', 'The Taal Watchtower', 'The Taal Basilica (Basilica of St. Martin of Tours) is the town''s most iconic structure', 'D', 'The Taal Basilica, one of the largest churches in Asia, stands as the centerpiece of the well-preserved heritage town of Taal, Batangas.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'What is the name of the ancestral gateway tower structure found in the historic town of Taal, Batangas, reflecting Spanish colonial urban planning?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'hard', 'Which historic watchtower in Bantay, Ilocos Sur, was built to warn coastal communities of approaching pirate raids during the Spanish era?', 'Baluarte Watchtower', 'Currimao Tower', 'Paoay Fort', 'Bantay Bell Tower', 'D', 'The Bantay Bell Tower in Ilocos Sur was constructed as a watchtower to warn residents of approaching Moro pirate raids during the Spanish colonial period.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'Which historic watchtower in Bantay, Ilocos Sur, was built to warn coastal communities of approaching pirate raids during the Spanish era?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'landmarks', 'hard', 'Which historic 400-year-old bridge in Ilocos Norte is renowned for having no cement in its original construction, relying instead on egg whites as a binder?', 'Quirino Bridge (Bacarra)', 'Jones Bridge', 'MacArthur Bridge', 'Ayala Bridge', 'A', 'Quirino Bridge in Bacarra, Ilocos Norte, is a centuries-old Spanish-era bridge said to have used egg whites as a binding material in its original construction.'
where not exists (
  select 1 from questions where category = 'landmarks' and prompt = 'Which historic 400-year-old bridge in Ilocos Norte is renowned for having no cement in its original construction, relying instead on egg whites as a binder?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'hard', 'Which Philippine regional language, spoken primarily in the Bicol Region, is distinct from Tagalog and Cebuano?', 'Bikol (Bicolano)', 'Hiligaynon', 'Waray', 'Kapampangan', 'A', 'Bikol, or Bicolano, is the major regional language of the Bicol Region, distinct from Tagalog, Cebuano, and other Philippine languages.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'Which Philippine regional language, spoken primarily in the Bicol Region, is distinct from Tagalog and Cebuano?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'hard', 'What is the term for the official national language of the Philippines, based largely on Tagalog but incorporating other regional influences?', 'Tagalog (the base language, but not identical to the official standard)', 'Pilipino (an older term for the same evolving standard)', 'Manila Tagalog', 'Filipino', 'D', 'Filipino is the constitutionally designated national language, based primarily on Tagalog but intended to incorporate vocabulary from other Philippine languages.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'What is the term for the official national language of the Philippines, based largely on Tagalog but incorporating other regional influences?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'hard', 'Which Philippine language, spoken mainly in Pampanga and Tarlac, is also known as Pampango?', 'Ilocano', 'Kapampangan', 'Pangasinan', 'Sambal', 'B', 'Kapampangan, also called Pampango, is the regional language spoken primarily in Pampanga and parts of Tarlac province.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'Which Philippine language, spoken mainly in Pampanga and Tarlac, is also known as Pampango?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'hard', 'What is the estimated number of distinct indigenous languages spoken across the Philippine archipelago, according to linguistic surveys?', 'Around 130 to 180 languages', 'About 20 languages', 'Roughly 50 languages', 'Over 500 languages', 'A', 'Linguistic surveys estimate the Philippines is home to approximately 130 to 180 distinct indigenous languages, reflecting immense linguistic diversity.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'What is the estimated number of distinct indigenous languages spoken across the Philippine archipelago, according to linguistic surveys?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'hard', 'Which Philippine language is the third most widely spoken as a first language, after Tagalog and Cebuano?', 'Hiligaynon', 'Waray', 'Bikol', 'Ilocano', 'D', 'Ilocano ranks as the third most widely spoken first language in the Philippines, prevalent throughout the Ilocos Region and via migration to other areas.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'Which Philippine language is the third most widely spoken as a first language, after Tagalog and Cebuano?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'hard', 'What is the term for the pre-colonial Filipino script that was largely supplanted by the Latin alphabet under Spanish colonization?', 'Kawi', 'Baybayin', 'Vatteluttu', 'Kulitan (a related but Kapampangan-specific script)', 'B', 'Baybayin was the pre-colonial writing system widely used by Tagalog speakers before being largely replaced by the Latin alphabet under Spanish rule.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'What is the term for the pre-colonial Filipino script that was largely supplanted by the Latin alphabet under Spanish colonization?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'hard', 'Which Visayan language, spoken in Panay and Negros Occidental, is also known as Ilonggo?', 'Hiligaynon', 'Cebuano', 'Waray', 'Aklanon', 'A', 'Hiligaynon, commonly called Ilonggo, is the major regional language of Panay Island and Negros Occidental.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'Which Visayan language, spoken in Panay and Negros Occidental, is also known as Ilonggo?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'hard', 'What is the term for the linguistic phenomenon in the Philippines where speakers fluidly mix Filipino and English within conversations?', 'Pidgin Filipino', 'Taglish (code-switching)', 'Creole Tagalog', 'Diglossic Filipino', 'B', 'Taglish refers to the widespread code-switching between Filipino and English commonly observed in everyday Philippine conversation.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'What is the term for the linguistic phenomenon in the Philippines where speakers fluidly mix Filipino and English within conversations?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'hard', 'Which Philippine language, spoken in Eastern Visayas including Samar and Leyte, is notable for its distinct phonology among Visayan languages?', 'Cebuano', 'Hiligaynon', 'Waray-Waray', 'Boholano (a Cebuano dialect)', 'C', 'Waray-Waray is the major regional language of Eastern Visayas, spoken across Samar and Leyte, with phonological features distinguishing it from other Visayan languages.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'Which Philippine language, spoken in Eastern Visayas including Samar and Leyte, is notable for its distinct phonology among Visayan languages?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'hard', 'What is the term for the specific Cebuano dialect spoken in Bohol, which has notable phonological and lexical differences from mainland Cebu Cebuano?', 'Butuanon', 'Boholano', 'Surigaonon', 'Kamayo', 'B', 'Boholano is the distinct dialect of Cebuano spoken on Bohol island, with recognizable differences in pronunciation and vocabulary.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'What is the term for the specific Cebuano dialect spoken in Bohol, which has notable phonological and lexical differences from mainland Cebu Cebuano?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'hard', 'Which Philippine language family classification do nearly all indigenous Philippine languages, including Tagalog, belong to?', 'Sino-Tibetan', 'Papuan', 'Trans-New Guinea', 'Austronesian (Malayo-Polynesian branch)', 'D', 'Nearly all indigenous Philippine languages, including Tagalog and Cebuano, belong to the Malayo-Polynesian branch of the Austronesian language family.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'Which Philippine language family classification do nearly all indigenous Philippine languages, including Tagalog, belong to?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'hard', 'What is the term for the Chavacano language spoken in Zamboanga, notable for being one of the few Spanish-based creole languages in Asia?', 'Chavacano (Zamboangueño)', 'Ternateño (a related but distinct Chavacano variety)', 'Caviteño (another related Chavacano variety)', 'Ermitaño (a now-extinct Chavacano variety)', 'A', 'Chavacano, particularly the Zamboangueño variety, is a Spanish-based creole language, one of very few such creoles in Asia.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'What is the term for the Chavacano language spoken in Zamboanga, notable for being one of the few Spanish-based creole languages in Asia?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'hard', 'Which Philippine language, spoken primarily in Pangasinan province, is distinct from both Ilocano and Kapampangan despite geographic proximity?', 'Pangasinan (Pangasinense)', 'Sambal', 'Ibanag', 'Ivatan', 'A', 'Pangasinan, or Pangasinense, is a distinct regional language spoken mainly in Pangasinan province, unrelated closely to neighboring Ilocano or Kapampangan.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'Which Philippine language, spoken primarily in Pangasinan province, is distinct from both Ilocano and Kapampangan despite geographic proximity?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'hard', 'What is the term for the language spoken by the indigenous Ivatan people of Batanes, notably distinct from mainland Filipino languages?', 'Itbayat (a closely related dialect of Ivatan)', 'Babuyan', 'Yami (spoken in Taiwan, a related but distinct language)', 'Ivatan', 'D', 'Ivatan is the indigenous language of the Batanes islands, notable for its distinct vocabulary and closer linguistic ties to Taiwanese Austronesian languages than mainland Philippine languages.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'What is the term for the language spoken by the indigenous Ivatan people of Batanes, notably distinct from mainland Filipino languages?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'hard', 'Which endangered Philippine language, spoken by a small population in Zamboanga del Norte, is one of the most critically endangered in the country?', 'Multiple small endangered languages exist across Mindanao (e.g., Inagta Alabat, Villaviciosa Agta) rather than one single canonical example tied specifically to Zamboanga del Norte', 'Kalagan', 'Subanen (spoken in Zamboanga Peninsula, though not critically endangered)', 'Sindangan Subanon', 'C', 'Subanen is the indigenous language of the Subanen people in the Zamboanga Peninsula; while it has fewer speakers than major regional languages, it is not among the most critically endangered.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'Which endangered Philippine language, spoken by a small population in Zamboanga del Norte, is one of the most critically endangered in the country?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'hard', 'What is the term used for the standardized, Manila-based variety of Tagalog often used in national media and formal contexts?', 'Batangas Tagalog', 'Manila Tagalog (or Metro Manila Filipino)', 'Marinduque Tagalog', 'Southern Tagalog', 'B', 'Manila Tagalog, sometimes called Metro Manila Filipino, is the prestige variety most commonly used in national broadcast media and formal communication.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'What is the term used for the standardized, Manila-based variety of Tagalog often used in national media and formal contexts?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'hard', 'Which Philippine language, spoken in Cagayan Valley, is known for its distinct grammar among northern Luzon languages?', 'Ivatan', 'Pangasinan', 'Ibanag', 'Sambal', 'C', 'Ibanag is a regional language spoken primarily in Cagayan Valley, distinguished by grammatical features that set it apart from other northern Luzon languages.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'Which Philippine language, spoken in Cagayan Valley, is known for its distinct grammar among northern Luzon languages?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'languages', 'hard', 'What is the term for the traditional pre-colonial Philippine writing systems collectively, of which Baybayin is the most well-known example?', 'Kawi scripts', 'Jawi scripts', 'Suyat scripts', 'Pallava scripts', 'C', 'Suyat is the collective term for the various indigenous pre-colonial writing systems of the Philippines, of which Baybayin is the most widely recognized.'
where not exists (
  select 1 from questions where category = 'languages' and prompt = 'What is the term for the traditional pre-colonial Philippine writing systems collectively, of which Baybayin is the most well-known example?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'hard', 'Which Jose Rizal novel, written in 1887, is credited with helping ignite the Philippine Revolution against Spain?', 'Noli Me Tangere', 'El Filibusterismo', 'Mi Ultimo Adios', 'Makamisa (unfinished)', 'A', 'Noli Me Tangere, published in 1887, exposed the abuses of Spanish colonial rule and is credited with fueling nationalist sentiment leading to the revolution.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'Which Jose Rizal novel, written in 1887, is credited with helping ignite the Philippine Revolution against Spain?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'hard', 'What is the name of Jose Rizal''s farewell poem, written the night before his execution in 1896?', 'Noli Me Tangere', 'Mi Ultimo Adios', 'El Filibusterismo', 'Sa Aking Mga Kabata', 'B', '''Mi Ultimo Adios'' (''My Last Farewell'') is the poem Rizal wrote the night before his execution, smuggled out and later widely translated.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'What is the name of Jose Rizal''s farewell poem, written the night before his execution in 1896?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'hard', 'Which Filipino epic poem, associated with the Ilocano people, recounts the adventures of a legendary hero named Lam-ang?', 'Hinilawod', 'Ibalong', 'Darangen', 'Biag ni Lam-ang', 'D', 'Biag ni Lam-ang (The Life of Lam-ang) is the celebrated Ilocano epic recounting the extraordinary adventures of its titular hero.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'Which Filipino epic poem, associated with the Ilocano people, recounts the adventures of a legendary hero named Lam-ang?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'hard', 'What is the name of the Maranao epic considered one of the longest and most significant in Philippine indigenous literature?', 'Hinilawod', 'Darangen', 'Ibalong', 'Biag ni Lam-ang', 'B', 'The Darangen is a lengthy Maranao epic, recognized by UNESCO as part of the Intangible Cultural Heritage of Humanity.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'What is the name of the Maranao epic considered one of the longest and most significant in Philippine indigenous literature?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'hard', 'Which Filipino novelist wrote ''Dekada ''70,'' a novel depicting a family''s experiences during martial law under Ferdinand Marcos?', 'Lualhati Bautista', 'Nick Joaquin', 'F. Sionil Jose', 'Bienvenido Santos', 'A', 'Lualhati Bautista wrote ''Dekada ''70,'' a significant Filipino novel portraying a middle-class family''s experiences during the martial law era.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'Which Filipino novelist wrote ''Dekada ''70,'' a novel depicting a family''s experiences during martial law under Ferdinand Marcos?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'hard', 'What is the name of the pioneering Filipino komiks writer credited with creating the character Darna, alongside other iconic superheroes?', 'Francisco Coching', 'Mars Ravelo', 'Carlo J. Caparas', 'Nestor Redondo', 'B', 'Mars Ravelo created Darna and numerous other enduring characters, becoming one of the most influential figures in Filipino komiks history.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'What is the name of the pioneering Filipino komiks writer credited with creating the character Darna, alongside other iconic superheroes?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'hard', 'Which Filipino writer''s ''Rosales Saga'' is a five-novel cycle chronicling generations of a Filipino family across major historical periods?', 'Nick Joaquin', 'Bienvenido Santos', 'F. Sionil Jose', 'N.V.M. Gonzalez', 'C', 'F. Sionil Jose''s Rosales Saga, a cycle of five novels, chronicles generations of Filipino experience through major historical eras.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'Which Filipino writer''s ''Rosales Saga'' is a five-novel cycle chronicling generations of a Filipino family across major historical periods?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'hard', 'What is the name of the Bicolano epic that recounts the region''s mythological origins, including the story of the volcano Mount Isarog?', 'Hinilawod', 'Ibalong', 'Darangen', 'Biag ni Lam-ang', 'B', 'Ibalong is the Bicolano epic recounting mythological heroes and the origins of the Bicol region''s geographic features.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'What is the name of the Bicolano epic that recounts the region''s mythological origins, including the story of the volcano Mount Isarog?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'hard', 'Which Filipino National Artist for Literature wrote ''The Woman Who Had Two Navels'' and is known for blending myth with modern narrative?', 'F. Sionil Jose', 'Bienvenido Santos', 'Carlos Bulosan', 'Nick Joaquin', 'D', 'Nick Joaquin, a National Artist for Literature, wrote ''The Woman Who Had Two Navels,'' notable for its exploration of Filipino identity and myth.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'Which Filipino National Artist for Literature wrote ''The Woman Who Had Two Navels'' and is known for blending myth with modern narrative?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'hard', 'What is the title of Carlos Bulosan''s autobiographical novel depicting the experiences of Filipino immigrant laborers in America?', 'America Is in the Heart', 'The Cry and the Dedication', 'The Laughter of My Father', 'If You Want to Know What We Are', 'A', '''America Is in the Heart'' is Carlos Bulosan''s landmark autobiographical work depicting the hardships of Filipino immigrant laborers in the United States.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'What is the title of Carlos Bulosan''s autobiographical novel depicting the experiences of Filipino immigrant laborers in America?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'hard', 'Which Panay epic, one of the longest in the Philippines, recounts the adventures of heroes Labaw Donggon and his brothers?', 'Ibalong', 'Darangen', 'Biag ni Lam-ang', 'Hinilawod', 'D', 'Hinilawod is a lengthy epic from Panay Island recounting the heroic exploits of Labaw Donggon and his brothers.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'Which Panay epic, one of the longest in the Philippines, recounts the adventures of heroes Labaw Donggon and his brothers?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'hard', 'What is the name of the short poem attributed to Jose Rizal, believed to have been written when he was only eight years old?', 'Sa Aking Mga Kabata', 'Mi Ultimo Adios', 'A la Juventud Filipina', 'Himno al Trabajo', 'A', '''Sa Aking Mga Kabata'' (''To My Fellow Youth'') is a poem traditionally attributed to a young Jose Rizal, though its authorship has been debated by scholars.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'What is the name of the short poem attributed to Jose Rizal, believed to have been written when he was only eight years old?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'hard', 'Which Filipino writer''s short story ''The Mats'' is widely studied for its poignant portrayal of family and loss?', 'Nick Joaquin', 'N.V.M. Gonzalez', 'Manuel Arguilla', 'Francisco Arcellana', 'D', '''The Mats,'' written by Francisco Arcellana, is a widely anthologized short story known for its emotional depiction of family memory and loss.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'Which Filipino writer''s short story ''The Mats'' is widely studied for its poignant portrayal of family and loss?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'hard', 'What is the name of the National Artist for Literature known for the short story ''How My Brother Leon Brought Home a Wife''?', 'Francisco Arcellana', 'N.V.M. Gonzalez', 'Manuel Arguilla', 'Nick Joaquin', 'C', 'Manuel Arguilla wrote ''How My Brother Leon Brought Home a Wife,'' a celebrated short story exploring rural Filipino life and family dynamics.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'What is the name of the National Artist for Literature known for the short story ''How My Brother Leon Brought Home a Wife''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'hard', 'Which Filipino poet and National Artist for Literature is known for pioneering modernist poetry in the Philippines, writing largely in English?', 'Nick Joaquin', 'Jose Garcia Villa', 'Cirilo Bautista', 'Bienvenido Lumbera', 'B', 'Jose Garcia Villa, a National Artist for Literature, was a pioneering modernist poet celebrated internationally for his innovative use of English verse.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'Which Filipino poet and National Artist for Literature is known for pioneering modernist poetry in the Philippines, writing largely in English?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'hard', 'What is the term for the traditional Filipino narrative poem or metrical romance, often depicting the adventures of European-derived characters, such as ''Ibong Adarna''?', 'Kundiman (a song form, not narrative poetry)', 'Balagtasan (a poetic debate form)', 'Awit and korido (metrical romances)', 'Dalit (a devotional poem form)', 'C', '''Awit'' and ''korido'' refer to traditional Filipino metrical romances, narrative poems often adapted from European chivalric tales, exemplified by ''Ibong Adarna.'''
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'What is the term for the traditional Filipino narrative poem or metrical romance, often depicting the adventures of European-derived characters, such as ''Ibong Adarna''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'hard', 'Which Filipino literary form is a formal poetic debate performed extemporaneously by two or more poets, popularized in the early 20th century?', 'Balagtasan', 'Duplo', 'Karagatan', 'Bugtong', 'A', 'The Balagtasan is a traditional Filipino poetic joust or debate, performed extemporaneously, named in honor of the poet Francisco Balagtas.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'Which Filipino literary form is a formal poetic debate performed extemporaneously by two or more poets, popularized in the early 20th century?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'literature', 'hard', 'Which Filipino National Artist for Literature is renowned for pioneering work in Filipino literary criticism and history?', 'Nick Joaquin', 'Jose Garcia Villa', 'Bienvenido Lumbera', 'Cirilo Bautista', 'C', 'Bienvenido Lumbera, a National Artist for Literature, is celebrated for his foundational contributions to Filipino literary criticism and history.'
where not exists (
  select 1 from questions where category = 'literature' and prompt = 'Which Filipino National Artist for Literature is renowned for pioneering work in Filipino literary criticism and history?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'hard', 'In propositional logic, what is the term for a statement that is always true regardless of the truth values of its components?', 'Contradiction', 'Contingency', 'Tautology', 'Fallacy', 'C', 'A tautology is a compound statement that is true under every possible interpretation of its component propositions.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'In propositional logic, what is the term for a statement that is always true regardless of the truth values of its components?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'hard', 'What is the name of the logical fallacy that attacks the character of a person making an argument rather than the argument itself?', 'Straw man', 'Red herring', 'Ad hominem', 'False dilemma', 'C', 'An ad hominem fallacy occurs when someone attacks the character or motives of the person making an argument rather than addressing the argument itself.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'What is the name of the logical fallacy that attacks the character of a person making an argument rather than the argument itself?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'hard', 'Which type of reasoning draws a general conclusion from specific observations, moving from particular instances to broader generalizations?', 'Inductive reasoning', 'Deductive reasoning', 'Abductive reasoning', 'Analogical reasoning', 'A', 'Inductive reasoning involves drawing general conclusions based on specific observed instances, though the conclusion is not guaranteed to be true.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'Which type of reasoning draws a general conclusion from specific observations, moving from particular instances to broader generalizations?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'hard', 'What is the term for a logical fallacy that presents only two options when more possibilities actually exist?', 'Slippery slope', 'Circular reasoning', 'Hasty generalization', 'False dilemma (false dichotomy)', 'D', 'A false dilemma, or false dichotomy, incorrectly presents a situation as having only two possible options when in fact other alternatives exist.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'What is the term for a logical fallacy that presents only two options when more possibilities actually exist?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'hard', 'Which classic logic puzzle type involves determining true statements from a set of people who either always lie or always tell the truth?', 'Sudoku puzzles', 'River crossing puzzles', 'Knights and knaves puzzles', 'Zebra puzzles', 'C', 'Knights and knaves puzzles involve reasoning about statements made by characters who are either always truthful (knights) or always lying (knaves).'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'Which classic logic puzzle type involves determining true statements from a set of people who either always lie or always tell the truth?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'hard', 'What is the term for the logical fallacy in which the conclusion of an argument is assumed within one of its premises?', 'Circular reasoning (begging the question)', 'Slippery slope', 'False cause', 'Appeal to authority', 'A', 'Circular reasoning, or begging the question, occurs when an argument''s conclusion is essentially restated as one of its own premises.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'What is the term for the logical fallacy in which the conclusion of an argument is assumed within one of its premises?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'hard', 'Which formal logical structure consists of a major premise, a minor premise, and a conclusion, as classically formulated by Aristotle?', 'Syllogism', 'Enthymeme', 'Sorites', 'Dilemma', 'A', 'A syllogism is a form of deductive reasoning consisting of a major premise, a minor premise, and a conclusion, central to Aristotelian logic.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'Which formal logical structure consists of a major premise, a minor premise, and a conclusion, as classically formulated by Aristotle?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'hard', 'What is the term for a fallacy that assumes a small first step will inevitably lead to a chain of related, increasingly negative events?', 'False dilemma', 'Slippery slope', 'Straw man', 'Hasty generalization', 'B', 'The slippery slope fallacy assumes, without sufficient justification, that a relatively small first step will inevitably lead to a chain of significant negative consequences.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'What is the term for a fallacy that assumes a small first step will inevitably lead to a chain of related, increasingly negative events?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'hard', 'Which type of reasoning involves inferring the most likely explanation for a set of observations, commonly used in diagnostic reasoning?', 'Deductive reasoning', 'Abductive reasoning', 'Inductive reasoning', 'Analogical reasoning', 'B', 'Abductive reasoning seeks the most plausible explanation for a given set of observations, commonly used in diagnosis and scientific hypothesis formation.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'Which type of reasoning involves inferring the most likely explanation for a set of observations, commonly used in diagnostic reasoning?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'hard', 'What is the term for the logical fallacy of misrepresenting an opponent''s argument to make it easier to attack?', 'Ad hominem', 'Red herring', 'Appeal to ignorance', 'Straw man', 'D', 'A straw man fallacy involves distorting or oversimplifying an opponent''s argument, making it easier to refute than the original position.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'What is the term for the logical fallacy of misrepresenting an opponent''s argument to make it easier to attack?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'hard', 'Which logical fallacy involves introducing an irrelevant topic to divert attention away from the original issue being discussed?', 'Straw man', 'False cause', 'Bandwagon fallacy', 'Red herring', 'D', 'A red herring fallacy diverts attention from the original argument by introducing an irrelevant or tangential topic.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'Which logical fallacy involves introducing an irrelevant topic to divert attention away from the original issue being discussed?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'hard', 'What is the term for a logical argument form stating: if P then Q; P is true; therefore Q is true?', 'Modus ponens', 'Modus tollens', 'Disjunctive syllogism', 'Hypothetical syllogism', 'A', 'Modus ponens is a valid deductive argument form: if P implies Q, and P is true, then Q must also be true.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'What is the term for a logical argument form stating: if P then Q; P is true; therefore Q is true?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'hard', 'Which logical argument form states: if P then Q; Q is false; therefore P is false?', 'Modus ponens', 'Disjunctive syllogism', 'Modus tollens', 'Constructive dilemma', 'C', 'Modus tollens is a valid deductive form: if P implies Q, and Q is false, then P must also be false.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'Which logical argument form states: if P then Q; Q is false; therefore P is false?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'hard', 'What is the term for a fallacy that draws a broad conclusion based on a sample that is too small or unrepresentative?', 'False cause', 'Hasty generalization', 'Slippery slope', 'Appeal to authority', 'B', 'A hasty generalization occurs when a broad conclusion is drawn from insufficient or unrepresentative evidence.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'What is the term for a fallacy that draws a broad conclusion based on a sample that is too small or unrepresentative?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'hard', 'Which cognitive bias describes the tendency to search for, interpret, and recall information that confirms one''s preexisting beliefs?', 'Confirmation bias', 'Anchoring bias', 'Availability heuristic', 'Hindsight bias', 'A', 'Confirmation bias describes the tendency to favor information that confirms existing beliefs while disregarding contradictory evidence.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'Which cognitive bias describes the tendency to search for, interpret, and recall information that confirms one''s preexisting beliefs?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'hard', 'What is the term for the logical fallacy of assuming that because one event followed another, the first event caused the second?', 'Slippery slope', 'Post hoc ergo propter hoc (false cause)', 'Circular reasoning', 'Appeal to ignorance', 'B', '''Post hoc ergo propter hoc,'' or the false cause fallacy, mistakenly assumes causation simply because one event chronologically followed another.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'What is the term for the logical fallacy of assuming that because one event followed another, the first event caused the second?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'hard', 'Which type of argument uses the similarity between two situations to argue that what is true of one is also true of the other?', 'Deductive argument', 'Inductive generalization', 'Abductive inference', 'Argument by analogy', 'D', 'An argument by analogy draws conclusions based on similarities between two comparable situations or cases.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'Which type of argument uses the similarity between two situations to argue that what is true of one is also true of the other?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'logic_reasoning', 'hard', 'What is the term for a valid argument form stating: either P or Q; not P; therefore Q?', 'Modus ponens', 'Disjunctive syllogism', 'Modus tollens', 'Hypothetical syllogism', 'B', 'A disjunctive syllogism follows the form: either P or Q is true; P is false; therefore Q must be true.'
where not exists (
  select 1 from questions where category = 'logic_reasoning' and prompt = 'What is the term for a valid argument form stating: either P or Q; not P; therefore Q?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'hard', 'What is the term for a number that can only be divided evenly by 1 and itself, with exactly two distinct positive divisors?', 'Composite number', 'Prime number', 'Perfect number', 'Irrational number', 'B', 'A prime number has exactly two positive divisors: 1 and itself, making it indivisible by any other whole number.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'What is the term for a number that can only be divided evenly by 1 and itself, with exactly two distinct positive divisors?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'hard', 'Which mathematical constant, approximately equal to 2.71828, is the base of the natural logarithm?', 'Euler''s number (e)', 'Pi (π)', 'The golden ratio (φ)', 'The imaginary unit (i)', 'A', 'Euler''s number, e, approximately 2.71828, is the base of the natural logarithm and appears throughout calculus and exponential growth models.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'Which mathematical constant, approximately equal to 2.71828, is the base of the natural logarithm?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'hard', 'What is the term for a sequence in which each number is the sum of the two preceding ones, starting typically with 0 and 1?', 'Arithmetic sequence', 'Geometric sequence', 'Fibonacci sequence', 'Harmonic sequence', 'C', 'The Fibonacci sequence is defined by each term being the sum of the two preceding terms, famously starting 0, 1, 1, 2, 3, 5, 8...'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'What is the term for a sequence in which each number is the sum of the two preceding ones, starting typically with 0 and 1?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'hard', 'Which branch of mathematics deals with rates of change and the accumulation of quantities, developed independently by Newton and Leibniz?', 'Algebra', 'Topology', 'Calculus', 'Number theory', 'C', 'Calculus, developed independently by Isaac Newton and Gottfried Leibniz, studies rates of change (differentiation) and accumulation (integration).'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'Which branch of mathematics deals with rates of change and the accumulation of quantities, developed independently by Newton and Leibniz?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'hard', 'What is the term for a number that cannot be expressed as a simple fraction of two integers, such as pi or the square root of 2?', 'Irrational number', 'Rational number', 'Complex number', 'Transcendental number (a subset, not synonymous)', 'A', 'An irrational number cannot be written as a ratio of two integers, and its decimal representation is non-terminating and non-repeating.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'What is the term for a number that cannot be expressed as a simple fraction of two integers, such as pi or the square root of 2?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'hard', 'Which theorem states that in a right triangle, the square of the hypotenuse equals the sum of the squares of the other two sides?', 'The Law of Cosines', 'The Binomial theorem', 'Fermat''s Last Theorem', 'The Pythagorean theorem', 'D', 'The Pythagorean theorem, a² + b² = c², relates the lengths of the sides of a right triangle, with c representing the hypotenuse.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'Which theorem states that in a right triangle, the square of the hypotenuse equals the sum of the squares of the other two sides?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'hard', 'What is the term for a matrix that, when multiplied by another matrix, results in the identity matrix?', 'A transpose matrix', 'An inverse matrix', 'A diagonal matrix', 'A symmetric matrix', 'B', 'An inverse matrix, when multiplied by its original matrix, produces the identity matrix, analogous to a reciprocal in scalar arithmetic.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'What is the term for a matrix that, when multiplied by another matrix, results in the identity matrix?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'hard', 'Which branch of mathematics studies shapes, sizes, and properties of space, including points, lines, angles, and surfaces?', 'Algebra', 'Calculus', 'Geometry', 'Statistics', 'C', 'Geometry is the branch of mathematics concerned with the properties and relationships of points, lines, angles, surfaces, and solids.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'Which branch of mathematics studies shapes, sizes, and properties of space, including points, lines, angles, and surfaces?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'hard', 'What is the term for the value that a function approaches as the input approaches a particular point, foundational to calculus?', 'Derivative', 'Integral', 'Asymptote', 'Limit', 'D', 'A limit describes the value a function approaches as its input gets arbitrarily close to a specified point, forming the basis of calculus concepts like derivatives.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'What is the term for the value that a function approaches as the input approaches a particular point, foundational to calculus?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'hard', 'Which famous unsolved problem in mathematics, one of the Millennium Prize Problems, concerns the distribution of prime numbers?', 'The Poincare Conjecture (solved in 2003)', 'The Riemann Hypothesis', 'The P versus NP Problem', 'Goldbach''s Conjecture', 'B', 'The Riemann Hypothesis, one of the seven Millennium Prize Problems, concerns the distribution of prime numbers and remains unsolved.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'Which famous unsolved problem in mathematics, one of the Millennium Prize Problems, concerns the distribution of prime numbers?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'hard', 'What is the term for a number system that uses only two digits, 0 and 1, forming the basis of modern computing?', 'Binary', 'Decimal', 'Hexadecimal', 'Octal', 'A', 'The binary number system uses only two digits, 0 and 1, and underlies the fundamental operation of digital computers.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'What is the term for a number system that uses only two digits, 0 and 1, forming the basis of modern computing?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'hard', 'Which mathematical concept describes a function whose graph is symmetric with respect to the y-axis, satisfying f(-x) = f(x)?', 'An odd function', 'An even function', 'A linear function', 'A periodic function', 'B', 'An even function satisfies f(-x) = f(x), producing a graph that is symmetric about the y-axis.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'Which mathematical concept describes a function whose graph is symmetric with respect to the y-axis, satisfying f(-x) = f(x)?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'hard', 'What is the term for a statistical measure representing the middle value in a data set when arranged in order?', 'The mean', 'The mode', 'The median', 'The range', 'C', 'The median is the middle value of a data set when values are arranged in ascending or descending order.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'What is the term for a statistical measure representing the middle value in a data set when arranged in order?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'hard', 'Which branch of mathematics deals with the study of structures, patterns, and relationships, including groups, rings, and fields?', 'Linear algebra', 'Abstract algebra', 'Number theory', 'Combinatorics', 'B', 'Abstract algebra studies algebraic structures such as groups, rings, and fields, examining their properties and relationships in a general sense.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'Which branch of mathematics deals with the study of structures, patterns, and relationships, including groups, rings, and fields?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'hard', 'What is the term for a proof technique where a statement is shown true for a base case, then shown to hold for the next case assuming it holds for the current one?', 'Proof by contradiction', 'Direct proof', 'Proof by exhaustion', 'Mathematical induction', 'D', 'Mathematical induction proves a statement is true for all natural numbers by establishing a base case and an inductive step.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'What is the term for a proof technique where a statement is shown true for a base case, then shown to hold for the next case assuming it holds for the current one?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'hard', 'Which number, discovered to be irrational by the ancient Greeks, is the ratio of a circle''s circumference to its diameter?', 'Pi (π)', 'Euler''s number (e)', 'The golden ratio (φ)', 'The square root of 2', 'A', 'Pi (π), the ratio of a circle''s circumference to its diameter, was proven irrational, contradicting earlier assumptions of rational proportion.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'Which number, discovered to be irrational by the ancient Greeks, is the ratio of a circle''s circumference to its diameter?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'hard', 'What is the term for a set of numbers that includes all real numbers plus the square roots of negative numbers, using the imaginary unit i?', 'Irrational numbers', 'Rational numbers', 'Natural numbers', 'Complex numbers', 'D', 'Complex numbers extend the real number system by including imaginary numbers, expressed in the form a + bi, where i is the square root of -1.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'What is the term for a set of numbers that includes all real numbers plus the square roots of negative numbers, using the imaginary unit i?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mathematics', 'hard', 'What is the term for a number that is equal to the sum of its proper positive divisors, such as 6 (1+2+3)?', 'A perfect number', 'A prime number', 'An abundant number', 'A composite number', 'A', 'A perfect number equals the sum of its own proper positive divisors; 6 is the smallest example, since 1 + 2 + 3 = 6.'
where not exists (
  select 1 from questions where category = 'mathematics' and prompt = 'What is the term for a number that is equal to the sum of its proper positive divisors, such as 6 (1+2+3)?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'hard', 'Which chamber of the heart pumps oxygenated blood into the aorta?', 'Right ventricle', 'Left ventricle', 'Left atrium', 'Right atrium', 'B', 'The left ventricle has the thickest muscular wall and pumps oxygenated blood through the aorta to the body.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which chamber of the heart pumps oxygenated blood into the aorta?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'hard', 'What condition results from the autoimmune destruction of insulin-producing beta cells in the pancreas?', 'Type 2 diabetes', 'Hypothyroidism', 'Type 1 diabetes', 'Addison''s disease', 'C', 'Type 1 diabetes is caused by the immune system attacking and destroying insulin-producing beta cells in the pancreas.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'What condition results from the autoimmune destruction of insulin-producing beta cells in the pancreas?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'hard', 'Which cranial nerve is primarily responsible for facial movement, including smiling and blinking?', 'Facial nerve (CN VII)', 'Trigeminal nerve (CN V)', 'Vagus nerve (CN X)', 'Optic nerve (CN II)', 'A', 'The facial nerve, cranial nerve VII, controls the muscles of facial expression.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which cranial nerve is primarily responsible for facial movement, including smiling and blinking?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'hard', 'What is the medical term for abnormally low blood sodium levels?', 'Hypernatremia', 'Hypokalemia', 'Hypocalcemia', 'Hyponatremia', 'D', 'Hyponatremia refers to a sodium concentration in the blood that is lower than normal.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'What is the medical term for abnormally low blood sodium levels?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'hard', 'Which class of drugs works by inhibiting the angiotensin-converting enzyme to lower blood pressure?', 'Beta blockers', 'Calcium channel blockers', 'ACE inhibitors', 'Diuretics', 'C', 'ACE inhibitors block the enzyme that converts angiotensin I to angiotensin II, reducing blood vessel constriction and lowering blood pressure.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which class of drugs works by inhibiting the angiotensin-converting enzyme to lower blood pressure?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'hard', 'What is the name of the liver''s functional structural unit?', 'The lobule', 'The nephron', 'The alveolus', 'The follicle', 'A', 'The lobule is the basic functional unit of the liver, organized around a central vein.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'What is the name of the liver''s functional structural unit?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'hard', 'Which vitamin deficiency causes the disease beriberi?', 'Vitamin C', 'Vitamin B1 (thiamine)', 'Vitamin D', 'Vitamin B12', 'B', 'Beriberi results from a deficiency of thiamine (vitamin B1), affecting the nervous and cardiovascular systems.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which vitamin deficiency causes the disease beriberi?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'hard', 'Which 1994 film, directed by Frank Darabont and based on a Stephen King novella, is frequently ranked among the greatest films of all time despite a modest initial box office?', 'The Shawshank Redemption', 'Pulp Fiction', 'Forrest Gump', 'The Green Mile', 'A', 'The Shawshank Redemption underperformed at the box office in 1994 but became a critical and cultural phenomenon through home video and television airings.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'Which 1994 film, directed by Frank Darabont and based on a Stephen King novella, is frequently ranked among the greatest films of all time despite a modest initial box office?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'hard', 'Which HBO series, based on George R.R. Martin''s novels, became one of the most-watched television series in history before concluding in 2019?', 'The Wire', 'Game of Thrones', 'Westworld', 'True Detective', 'B', 'Game of Thrones, adapted from George R.R. Martin''s ''A Song of Ice and Fire'' novels, became a global television phenomenon before its 2019 finale.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'Which HBO series, based on George R.R. Martin''s novels, became one of the most-watched television series in history before concluding in 2019?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'hard', 'What is the name of the fictional research facility central to the Netflix series ''Stranger Things,'' linked to the alternate dimension known as the Upside Down?', 'Site 13', 'The Nexus Facility', 'Black Mesa', 'Hawkins National Laboratory', 'D', 'Hawkins National Laboratory is the fictional government facility in ''Stranger Things'' responsible for experiments that open a gateway to the Upside Down.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'What is the name of the fictional research facility central to the Netflix series ''Stranger Things,'' linked to the alternate dimension known as the Upside Down?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'hard', 'Which director is known for a distinctive visual style featuring symmetrical compositions, seen in films like ''The Grand Budapest Hotel''?', 'Tim Burton', 'Christopher Nolan', 'David Fincher', 'Wes Anderson', 'D', 'Wes Anderson is renowned for his distinctive, meticulously symmetrical visual style, evident throughout films like ''The Grand Budapest Hotel.'''
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'Which director is known for a distinctive visual style featuring symmetrical compositions, seen in films like ''The Grand Budapest Hotel''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'hard', 'What was the name of the fictional advertising agency at the center of the acclaimed television series ''Mad Men''?', 'Draper & Associates', 'Cooper & Sterling', 'Madison Avenue Partners', 'Sterling Cooper (later Sterling Cooper Draper Pryce)', 'D', 'Sterling Cooper, later renamed Sterling Cooper Draper Pryce, was the fictional advertising agency at the heart of ''Mad Men.'''
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'What was the name of the fictional advertising agency at the center of the acclaimed television series ''Mad Men''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'hard', 'Which 2008 film, the first installment of a cinematic universe, starred Robert Downey Jr. as Tony Stark and launched the Marvel Cinematic Universe?', 'Iron Man', 'The Incredible Hulk', 'Thor', 'Captain America: The First Avenger', 'A', 'Iron Man (2008), starring Robert Downey Jr., launched the Marvel Cinematic Universe and redefined superhero filmmaking.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'Which 2008 film, the first installment of a cinematic universe, starred Robert Downey Jr. as Tony Stark and launched the Marvel Cinematic Universe?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'hard', 'What is the term for a television episode or short film released to bridge narrative gaps between seasons or films, often exploring side stories?', 'A pilot episode', 'A special episode or interstitial (sometimes called a ''bridge episode'')', 'A clip show', 'A backdoor pilot', 'B', 'Bridge episodes or specials are used to connect narrative gaps between seasons, providing additional context or side stories.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'What is the term for a television episode or short film released to bridge narrative gaps between seasons or films, often exploring side stories?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'hard', 'Which acclaimed television series, created by Vince Gilligan, follows a high school chemistry teacher turned methamphetamine manufacturer?', 'Breaking Bad', 'Better Call Saul', 'Ozark', 'The Wire', 'A', 'Breaking Bad, created by Vince Gilligan, follows Walter White''s transformation from a chemistry teacher into a powerful drug manufacturer.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'Which acclaimed television series, created by Vince Gilligan, follows a high school chemistry teacher turned methamphetamine manufacturer?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'hard', 'What is the name of the fictional kingdom in Disney''s ''Frozen,'' ruled by Queen Elsa after her coronation?', 'Corona', 'DunBroch', 'Arendelle', 'Motunui', 'C', 'Arendelle is the fictional Scandinavian-inspired kingdom central to Disney''s ''Frozen'' franchise, ruled by Queen Elsa.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'What is the name of the fictional kingdom in Disney''s ''Frozen,'' ruled by Queen Elsa after her coronation?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'hard', 'Which film won the Academy Award for Best Picture in 2020, becoming the first non-English-language film to win the category?', 'Parasite', '1917', 'Joker', 'Once Upon a Time in Hollywood', 'A', 'Parasite, directed by Bong Joon-ho, made history in 2020 as the first non-English-language film to win the Academy Award for Best Picture.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'Which film won the Academy Award for Best Picture in 2020, becoming the first non-English-language film to win the category?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'hard', 'What is the name of the fictional streaming platform parody satirized in the television series ''The Studio,'' or more broadly, which real streaming service produced ''The Crown''?', 'Netflix', 'Amazon Prime Video', 'Hulu', 'Apple TV+', 'A', '''The Crown,'' a lavish historical drama about the British royal family, was produced and released by Netflix.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'What is the name of the fictional streaming platform parody satirized in the television series ''The Studio,'' or more broadly, which real streaming service produced ''The Crown''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'hard', 'Which acclaimed anthology series, created by Charlie Brooker, explores dark and satirical themes about technology''s impact on society?', 'The Twilight Zone (an earlier, separate anthology)', 'American Horror Story', 'Tales from the Crypt', 'Black Mirror', 'D', 'Black Mirror, created by Charlie Brooker, is a dystopian anthology series examining the unsettling consequences of modern technology.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'Which acclaimed anthology series, created by Charlie Brooker, explores dark and satirical themes about technology''s impact on society?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'hard', 'What is the name of the director known for his intricate, nonlinear narrative structures, seen in films like ''Memento'' and ''Inception''?', 'David Fincher', 'Christopher Nolan', 'Denis Villeneuve', 'Darren Aronofsky', 'B', 'Christopher Nolan is celebrated for constructing intricate, often nonlinear narratives, as seen prominently in ''Memento'' and ''Inception.'''
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'What is the name of the director known for his intricate, nonlinear narrative structures, seen in films like ''Memento'' and ''Inception''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'hard', 'Which long-running animated sitcom, created by Matt Groening, is the longest-running American scripted primetime television series?', 'Family Guy', 'South Park', 'The Simpsons', 'American Dad!', 'C', 'The Simpsons, created by Matt Groening, holds the record as the longest-running scripted primetime television series in American history.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'Which long-running animated sitcom, created by Matt Groening, is the longest-running American scripted primetime television series?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'hard', 'What is the name of the fictional prison at the center of the Netflix series ''Orange Is the New Black''?', 'Fox River State Penitentiary', 'Oz Correctional Facility', 'Litchfield Penitentiary', 'Shawshank State Prison', 'C', 'Litchfield Penitentiary is the fictional women''s prison setting of the Netflix series ''Orange Is the New Black.'''
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'What is the name of the fictional prison at the center of the Netflix series ''Orange Is the New Black''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'hard', 'Which South Korean survival drama series became a global phenomenon on Netflix in 2021, centered on a deadly competition for cash prizes?', 'Sweet Home', 'Kingdom', 'Squid Game', 'All of Us Are Dead', 'C', 'Squid Game became a massive global phenomenon on Netflix in 2021, depicting a deadly survival competition among financially desperate contestants.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'Which South Korean survival drama series became a global phenomenon on Netflix in 2021, centered on a deadly competition for cash prizes?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'hard', 'What is the name of the fictional town in Indiana where the events of ''Stranger Things'' take place?', 'Derry', 'Hawkins', 'Castle Rock', 'Silent Hill', 'B', 'Hawkins, Indiana, is the fictional small town where the supernatural events of ''Stranger Things'' unfold.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'What is the name of the fictional town in Indiana where the events of ''Stranger Things'' take place?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'movies_tv', 'hard', 'Which acclaimed television series, starring Bryan Cranston, spawned the prequel spin-off "Better Call Saul"?', 'Ozark', 'Breaking Bad', 'The Wire', 'Narcos', 'B', '"Better Call Saul" is a prequel spin-off of "Breaking Bad," focusing on the character Saul Goodman before the events of the original series.'
where not exists (
  select 1 from questions where category = 'movies_tv' and prompt = 'Which acclaimed television series, starring Bryan Cranston, spawned the prequel spin-off "Better Call Saul"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'hard', 'Which genre of traditional Filipino love songs, known for its slow, melancholic melodies, flourished in the early 20th century?', 'Harana', 'Balitaw', 'Kundiman', 'Kutyapi music', 'C', 'Kundiman is a genre of traditional Filipino love songs characterized by slow, romantic, and often melancholic melodies, flourishing in the early 1900s.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'Which genre of traditional Filipino love songs, known for its slow, melancholic melodies, flourished in the early 20th century?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'hard', 'What is the term for the traditional Filipino serenade performed by a suitor beneath a woman''s window, often accompanied by guitar?', 'Kundiman (the song genre itself, distinct from the practice)', 'Harana', 'Balitaw', 'Kumintang', 'B', 'Harana refers to the traditional practice of serenading, where a suitor sings beneath a woman''s window, often accompanied by guitar, to express romantic interest.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'What is the term for the traditional Filipino serenade performed by a suitor beneath a woman''s window, often accompanied by guitar?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'hard', 'Which indigenous Filipino musical instrument is a bamboo tube zither, plucked to produce distinct tones, associated with the Cordillera and Mindanao regions?', 'Kubing (a jaw''s harp)', 'Kudyapi (a two-stringed lute) or Kolitong (a bamboo zither, depending on regional term)', 'Agung (a gong)', 'Kulintang (a set of gongs)', 'A', 'The kubing is a traditional Filipino jaw''s harp made from bamboo or metal, widely used among various indigenous groups across the archipelago.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'Which indigenous Filipino musical instrument is a bamboo tube zither, plucked to produce distinct tones, associated with the Cordillera and Mindanao regions?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'hard', 'What is the name of the traditional ensemble of tuned, horizontally arranged gongs used in Mindanao''s Maguindanao and Maranao musical traditions?', 'Kudyapi', 'Kubing', 'Agung', 'Kulintang', 'D', 'The kulintang is a set of small, horizontally arranged gongs central to the musical traditions of Mindanao''s Maguindanao, Maranao, and other groups.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'What is the name of the traditional ensemble of tuned, horizontally arranged gongs used in Mindanao''s Maguindanao and Maranao musical traditions?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'hard', 'Which OPM (Original Pilipino Music) genre blends folk and pop influences, closely associated with artists like Freddie Aguilar in the 1970s?', 'Folk-pop OPM (Manila Sound era, broadly)', 'Pinoy rock exclusively', 'Kundiman revival exclusively', 'Novelty pop exclusively', 'A', 'Freddie Aguilar and contemporaries helped popularize a folk-influenced strand of OPM in the 1970s, exemplified by songs like ''Anak.'''
where not exists (
  select 1 from questions where category = 'music' and prompt = 'Which OPM (Original Pilipino Music) genre blends folk and pop influences, closely associated with artists like Freddie Aguilar in the 1970s?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'hard', 'What is the term for the two-stringed, boat-lute instrument traditionally played by the Maguindanao and T''boli peoples of Mindanao?', 'Kulintang', 'Kudyapi', 'Kubing', 'Agung', 'B', 'The kudyapi is a two-stringed boat lute traditionally used by several Mindanao ethnic groups, including the Maguindanao and T''boli.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'What is the term for the two-stringed, boat-lute instrument traditionally played by the Maguindanao and T''boli peoples of Mindanao?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'hard', 'Which musical term describes traditional Visayan folk songs often performed as a musical exchange or courtship dialogue between a man and woman?', 'Kundiman', 'Harana', 'Balitaw', 'Kumintang', 'C', 'Balitaw is a traditional Visayan folk song form, often performed as an improvised musical dialogue or courtship exchange between two singers.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'Which musical term describes traditional Visayan folk songs often performed as a musical exchange or courtship dialogue between a man and woman?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'hard', 'What is the name of the large, single-headed drum used in various indigenous Mindanao musical ensembles, often accompanying the kulintang?', 'Gandingan', 'Dabakan', 'Babendil', 'Agung', 'B', 'The dabakan is a goblet-shaped drum commonly used alongside the kulintang ensemble in traditional Maguindanao and Maranao music.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'What is the name of the large, single-headed drum used in various indigenous Mindanao musical ensembles, often accompanying the kulintang?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'hard', 'Which Western classical music period, spanning roughly 1600-1750, is associated with composers like Bach and Handel and features elaborate ornamentation?', 'The Classical period', 'The Romantic period', 'The Baroque period', 'The Renaissance period', 'C', 'The Baroque period, roughly 1600-1750, is characterized by elaborate ornamentation and complex counterpoint, exemplified by composers like Bach and Handel.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'Which Western classical music period, spanning roughly 1600-1750, is associated with composers like Bach and Handel and features elaborate ornamentation?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'hard', 'What is the term for a musical scale consisting of only five notes, common in many traditional and folk music traditions worldwide?', 'Pentatonic scale', 'Diatonic scale', 'Chromatic scale', 'Whole tone scale', 'A', 'The pentatonic scale, consisting of five notes per octave, appears widely across folk music traditions globally, including many Asian musical systems.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'What is the term for a musical scale consisting of only five notes, common in many traditional and folk music traditions worldwide?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'hard', 'Which musical term describes a piece of music performed without accompaniment, typically referring to vocal music sung without instruments?', 'A cappella', 'Legato', 'Staccato', 'Rubato', 'A', 'A cappella refers to vocal music performed without any instrumental accompaniment.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'Which musical term describes a piece of music performed without accompaniment, typically referring to vocal music sung without instruments?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'hard', 'What is the name for a musical composition structured in three main sections, where the third section repeats or resembles the first (ABA form)?', 'Binary form', 'Rondo form', 'Sonata form', 'Ternary form', 'D', 'Ternary form (ABA) structures a piece into three sections, with the third typically repeating or closely resembling the first section''s musical material.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'What is the name for a musical composition structured in three main sections, where the third section repeats or resembles the first (ABA form)?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'hard', 'Which term describes the simultaneous combination of different, often independently moving, melodic lines in a musical composition?', 'Counterpoint (polyphony)', 'Homophony', 'Monophony', 'Heterophony', 'A', 'Counterpoint refers to the technique of combining multiple independent melodic lines that interact harmonically, central to polyphonic music.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'Which term describes the simultaneous combination of different, often independently moving, melodic lines in a musical composition?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'hard', 'What is the term for the gradual increase in loudness within a musical passage, indicated in notation by a specific symbol?', 'Diminuendo', 'Fortissimo', 'Sforzando', 'Crescendo', 'D', 'A crescendo indicates a gradual increase in volume or intensity within a musical passage.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'What is the term for the gradual increase in loudness within a musical passage, indicated in notation by a specific symbol?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'hard', 'Which musical instrument family does the violin belong to, characterized by producing sound through a bow drawn across strings?', 'Woodwind family', 'Brass family', 'String family (bowed strings)', 'Percussion family', 'C', 'The violin belongs to the string family of instruments, producing sound primarily through a bow drawn across its strings.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'Which musical instrument family does the violin belong to, characterized by producing sound through a bow drawn across strings?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'hard', 'What is the term for a musical work composed for a solo instrument accompanied by an orchestra, often showcasing the soloist''s virtuosity?', 'Symphony', 'Concerto', 'Sonata', 'Suite', 'B', 'A concerto is a musical composition typically featuring a solo instrument accompanied by an orchestra, highlighting the soloist''s technical skill.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'What is the term for a musical work composed for a solo instrument accompanied by an orchestra, often showcasing the soloist''s virtuosity?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'hard', 'Which term describes a musical performance direction indicating a gradual decrease in tempo, commonly seen at the end of a piece?', 'Accelerando', 'Ritardando', 'Vivace', 'Staccato', 'B', 'Ritardando indicates a gradual slowing of tempo, often used to bring a musical phrase or piece to a graceful close.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'Which term describes a musical performance direction indicating a gradual decrease in tempo, commonly seen at the end of a piece?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'music', 'hard', 'What is the term for a Western musical scale consisting of all twelve pitches within an octave, each a half step apart?', 'Diatonic scale', 'Pentatonic scale', 'Whole tone scale', 'Chromatic scale', 'D', 'The chromatic scale includes all twelve pitches within an octave, each separated by a half step, encompassing every note in Western tuning.'
where not exists (
  select 1 from questions where category = 'music' and prompt = 'What is the term for a Western musical scale consisting of all twelve pitches within an octave, each a half step apart?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'hard', 'Which Filipino mythological creature is a vampire-like being said to be able to detach its upper torso and fly at night in search of victims?', 'Aswang (general term, but distinct in specific form)', 'Tikbalang', 'Manananggal', 'Kapre', 'C', 'The manananggal is a specific type of aswang known for its ability to separate its upper torso from its lower body and fly at night.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'Which Filipino mythological creature is a vampire-like being said to be able to detach its upper torso and fly at night in search of victims?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'hard', 'What is the name of the Filipino mythological creature depicted as a tall, dark, tree-dwelling being who smokes a large tobacco pipe?', 'Tikbalang', 'Duwende', 'Kapre', 'Nuno sa Punso', 'C', 'The kapre is a tall, dark-skinned, tree-dwelling creature in Filipino folklore, often depicted smoking an oversized tobacco pipe or cigar.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'What is the name of the Filipino mythological creature depicted as a tall, dark, tree-dwelling being who smokes a large tobacco pipe?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'hard', 'Which Filipino mythological creature has the head and legs of a horse combined with a humanoid body, said to lead travelers astray?', 'Tikbalang', 'Kapre', 'Sigbin', 'Amomongo', 'A', 'The tikbalang is a half-horse, half-human creature said to disorient and mislead travelers, especially those wandering forests at night.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'Which Filipino mythological creature has the head and legs of a horse combined with a humanoid body, said to lead travelers astray?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'hard', 'What is the term for the small, dwarf-like nature spirits in Filipino folklore believed to inhabit anthills or termite mounds?', 'Duwende', 'Diwata', 'Nuno sa punso', 'Engkanto', 'C', '''Nuno sa punso,'' literally ''old man of the mound,'' refers to a dwarf-like spirit believed to inhabit anthills, whom Filipinos traditionally show respect to avoid misfortune.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'What is the term for the small, dwarf-like nature spirits in Filipino folklore believed to inhabit anthills or termite mounds?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'hard', 'Which Filipino mythological figure is regarded as a fairy or nature spirit, often depicted as a beautiful guardian of forests, rivers, or mountains?', 'Diwata', 'Manananggal', 'Aswang', 'Kapre', 'A', 'Diwata are nature spirits or deities in Filipino mythology, often depicted as beautiful guardians of natural elements like forests, rivers, and mountains.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'Which Filipino mythological figure is regarded as a fairy or nature spirit, often depicted as a beautiful guardian of forests, rivers, or mountains?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'hard', 'What is the name of the supreme deity in the pre-colonial Tagalog pantheon, believed to reside in the sky and oversee creation?', 'Bulan', 'Amanikable', 'Bathala', 'Idiyanale', 'C', 'Bathala was the supreme deity in pre-colonial Tagalog mythology, believed to have created the world and to reside in the sky.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'What is the name of the supreme deity in the pre-colonial Tagalog pantheon, believed to reside in the sky and oversee creation?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'hard', 'Which Visayan mythological figure is a powerful goddess associated with death and the underworld, often depicted as a moon deity?', 'Sidapa (a related death deity, though gender varies by source) or more specifically the goddess Meybuyan, who guards the underworld', 'Amanikable', 'Idiyanale', 'Bathala', 'D', 'Meybuyan is a Visayan goddess associated with the underworld, often depicted as caring for the souls of deceased children in mythological accounts.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'Which Visayan mythological figure is a powerful goddess associated with death and the underworld, often depicted as a moon deity?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'hard', 'What is the term for the Filipino belief in mysterious, often mischievous nature spirits believed to inhabit specific places like large trees or rock formations?', 'Diwata (a related but distinct category)', 'Duwende', 'Multo', 'Engkanto', 'D', 'Engkanto refers to a category of nature spirits in Filipino folklore, often depicted as beautiful, otherworldly beings inhabiting specific natural landmarks.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'What is the term for the Filipino belief in mysterious, often mischievous nature spirits believed to inhabit specific places like large trees or rock formations?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'hard', 'Which Filipino mythological creature, said to be a small dog-like being with a long tail, is believed to be capable of transforming into other animals?', 'Sigbin', 'Tikbalang', 'Amomongo', 'Wakwak', 'A', 'The sigbin is a mythical creature from Visayan folklore described as a dog-like being that can shape-shift and is often associated with sorcery.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'Which Filipino mythological creature, said to be a small dog-like being with a long tail, is believed to be capable of transforming into other animals?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'hard', 'What is the name of the malevolent bird-like creature in Filipino folklore, said to announce its presence through a distinctive cry before attacking victims?', 'Manananggal', 'Wakwak', 'Tiyanak', 'Sigbin', 'B', 'The wakwak is a bird-like creature in Filipino folklore whose distinctive cry is said to grow fainter the closer it approaches its victim, a reversal meant to deceive.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'What is the name of the malevolent bird-like creature in Filipino folklore, said to announce its presence through a distinctive cry before attacking victims?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'hard', 'Which Filipino mythological being takes the form of a crying baby to lure unsuspecting victims, especially in forests or isolated areas?', 'Duwende', 'Tiyanak', 'Nuno sa Punso', 'Engkanto', 'B', 'The tiyanak disguises itself as an abandoned crying infant to lure victims close before revealing its true monstrous form and attacking.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'Which Filipino mythological being takes the form of a crying baby to lure unsuspecting victims, especially in forests or isolated areas?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'hard', 'What is the name of the pre-colonial Tagalog god of the sea, often depicted as a fierce and easily angered deity?', 'Bathala', 'Idiyanale', 'Lakapati', 'Amanikable', 'D', 'Amanikable was the pre-colonial Tagalog god of the sea, said to be quick to anger, particularly toward hunters and fishermen.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'What is the name of the pre-colonial Tagalog god of the sea, often depicted as a fierce and easily angered deity?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'hard', 'Which Filipino deity, associated with agriculture and fertility, was traditionally depicted as an intersex or gender-transcending figure?', 'Idiyanale', 'Mayari', 'Dumakulem', 'Lakapati', 'D', 'Lakapati, the pre-colonial Tagalog deity of agriculture and fertility, was traditionally depicted as intersex, embodying both male and female aspects.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'Which Filipino deity, associated with agriculture and fertility, was traditionally depicted as an intersex or gender-transcending figure?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'hard', 'What is the term for the practice of showing respect or seeking permission from unseen nature spirits before actions like cutting trees or urinating outdoors?', 'Performing pagtatawas', 'Saying ''tabi-tabi po''', 'Conducting an atang ritual', 'Reciting an oración', 'B', 'Saying ''tabi-tabi po'' (''excuse me, please'') is a traditional practice of politely acknowledging and requesting permission from unseen nature spirits.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'What is the term for the practice of showing respect or seeking permission from unseen nature spirits before actions like cutting trees or urinating outdoors?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'hard', 'Which Filipino mythological figure is a one-eyed, gigantic ogre-like creature said to guard hidden treasures in mountains?', 'Tikbalang', 'Bungisngis (known for its loud laughter) is one such giant figure, though several regional giant figures exist in Filipino mythology', 'Kapre', 'Sigbin', 'B', 'The Bungisngis is a giant, one-eyed creature in Filipino folklore known for its constant, booming laughter, among several regional giant figures in Philippine mythology.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'Which Filipino mythological figure is a one-eyed, gigantic ogre-like creature said to guard hidden treasures in mountains?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'hard', 'What is the name of the Visayan mythological serpent or dragon-like creature believed to cause eclipses by attempting to swallow the sun or moon?', 'Bakunawa', 'Sawa', 'Naga', 'Bakonawa''s counterpart, Minokawa (a bird version from Mindanao)', 'A', 'Bakunawa is a serpent or dragon-like creature in Visayan mythology said to cause eclipses by attempting to swallow the sun or moon.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'What is the name of the Visayan mythological serpent or dragon-like creature believed to cause eclipses by attempting to swallow the sun or moon?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'hard', 'Which Filipino mythological figure is the goddess of the moon in pre-colonial Tagalog mythology, said to have lost an eye in a fight with her brother?', 'Mayari', 'Bathala', 'Amanikable', 'Idiyanale', 'A', 'Mayari, the Tagalog moon goddess, is said in some myths to have lost an eye during a struggle with her brother, explaining the moon''s phases.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'Which Filipino mythological figure is the goddess of the moon in pre-colonial Tagalog mythology, said to have lost an eye in a fight with her brother?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'mythology_folklore', 'hard', 'What is the term for the pre-colonial Filipino ritual specialist or shaman, often a woman, believed to communicate with spirits and perform healing?', 'Datu', 'Babaylan', 'Timawa', 'Panday', 'B', 'The babaylan was a pre-colonial ritual specialist, healer, and spiritual leader, a role predominantly, though not exclusively, held by women.'
where not exists (
  select 1 from questions where category = 'mythology_folklore' and prompt = 'What is the term for the pre-colonial Filipino ritual specialist or shaman, often a woman, believed to communicate with spirits and perform healing?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'hard', 'Which Philippine bird species, the second-largest eagle in the world by length, is critically endangered and found primarily on Mindanao?', 'Philippine Eagle', 'Philippine Eagle-Owl', 'Rufous Hornbill', 'Palawan Peacock-Pheasant', 'A', 'The Philippine Eagle, one of the largest and most powerful eagles in the world, is critically endangered and found mainly in Mindanao''s forests.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'Which Philippine bird species, the second-largest eagle in the world by length, is critically endangered and found primarily on Mindanao?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'hard', 'What is the term for the unique ecosystem type found in the Tubbataha Reefs, recognized as one of the most biodiverse marine areas on Earth?', 'Mangrove ecosystem', 'Coral reef ecosystem', 'Seagrass ecosystem', 'Kelp forest ecosystem', 'B', 'Tubbataha Reefs Natural Park is a pristine coral reef ecosystem recognized internationally for its exceptional marine biodiversity.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'What is the term for the unique ecosystem type found in the Tubbataha Reefs, recognized as one of the most biodiverse marine areas on Earth?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'hard', 'Which small, nocturnal primate native to the Philippines is known for its enormous eyes relative to its body size?', 'Philippine flying lemur (colugo)', 'Philippine tarsier', 'Palawan bearcat (binturong)', 'Philippine slow loris (not native to the Philippines)', 'B', 'The Philippine tarsier, found primarily in Bohol and nearby islands, is known for its disproportionately large eyes adapted for nocturnal vision.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'Which small, nocturnal primate native to the Philippines is known for its enormous eyes relative to its body size?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'hard', 'What is the term for the Philippine flying lemur, a gliding mammal that is not a true lemur despite its common name?', 'Sugar glider', 'Flying fox', 'Flying squirrel', 'Colugo (Philippine flying lemur)', 'D', 'The colugo, or Philippine flying lemur, is a gliding mammal unrelated to true lemurs, capable of gliding long distances between trees using a membrane.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'What is the term for the Philippine flying lemur, a gliding mammal that is not a true lemur despite its common name?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'hard', 'Which critically endangered freshwater crocodile species is endemic to the Philippines, found in areas like Mindanao and Luzon?', 'Saltwater crocodile', 'Philippine crocodile', 'Siamese crocodile', 'American crocodile', 'B', 'The Philippine crocodile is a critically endangered species endemic to the country, distinct from the larger saltwater crocodile also found in Philippine waters.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'Which critically endangered freshwater crocodile species is endemic to the Philippines, found in areas like Mindanao and Luzon?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'hard', 'What is the name of the Philippines'' national marine turtle protection area, home to nesting grounds for endangered sea turtles?', 'Tubbataha Reefs Natural Park (primarily coral reef focused)', 'Turtle Islands Heritage Protected Area (in the Sulu Sea)', 'Apo Reef Natural Park', 'El Nido Marine Reserve', 'B', 'The Turtle Islands Heritage Protected Area, shared with Malaysia, is a critical nesting ground for endangered green and hawksbill sea turtles.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'What is the name of the Philippines'' national marine turtle protection area, home to nesting grounds for endangered sea turtles?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'hard', 'Which large fruit bat species, native to the Philippines, is among the largest bats in the world by wingspan?', 'Philippine tube-nosed bat', 'Philippine pygmy fruit bat', 'Giant golden-crowned flying fox', 'Common fruit bat', 'C', 'The giant golden-crowned flying fox, native to the Philippines, is among the largest bat species in the world, with a wingspan that can exceed 1.5 meters.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'Which large fruit bat species, native to the Philippines, is among the largest bats in the world by wingspan?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'hard', 'What is the term for the unique limestone karst forest ecosystem found extensively in Palawan, home to many endemic species?', 'Mangrove forest ecosystem', 'Lowland dipterocarp forest (a related but distinct type)', 'Montane forest ecosystem', 'Karst forest ecosystem', 'D', 'Palawan''s karst forest ecosystems, formed on limestone bedrock, support a remarkable diversity of endemic plant and animal species.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'What is the term for the unique limestone karst forest ecosystem found extensively in Palawan, home to many endemic species?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'hard', 'Which endemic Philippine bird, notable for its striking multicolored plumage, is found only on the island of Palawan?', 'Philippine Eagle', 'Rufous Hornbill', 'Palawan Peacock-Pheasant', 'Mindanao Bleeding-heart', 'C', 'The Palawan Peacock-Pheasant is a strikingly colored bird endemic to Palawan, known for the male''s iridescent, eye-spotted plumage.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'Which endemic Philippine bird, notable for its striking multicolored plumage, is found only on the island of Palawan?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'hard', 'What is the term for the Philippine mouse-deer, one of the smallest hoofed mammals in the world, found on Balabac Island?', 'Philippine mouse-deer (balabac chevrotain)', 'Philippine deer', 'Visayan spotted deer', 'Philippine warty pig', 'A', 'The Philippine mouse-deer, or balabac chevrotain, is among the smallest hoofed mammals in the world, endemic to Balabac Island and nearby areas.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'What is the term for the Philippine mouse-deer, one of the smallest hoofed mammals in the world, found on Balabac Island?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'hard', 'Which critically endangered Philippine mammal, sometimes called the ''Visayan warty pig,'' is threatened primarily by habitat loss and hunting?', 'Philippine deer', 'Philippine mouse-deer', 'Palawan bearcat', 'Visayan warty pig', 'D', 'The Visayan warty pig is a critically endangered wild pig species native to the Visayan islands, threatened by deforestation and hunting.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'Which critically endangered Philippine mammal, sometimes called the ''Visayan warty pig,'' is threatened primarily by habitat loss and hunting?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'hard', 'What is the name of the extensive mangrove and wetland ecosystem in Palawan recognized for supporting numerous migratory bird species?', 'Tubbataha Reefs', 'Puerto Princesa Subterranean River watershed and surrounding wetlands', 'Apo Reef', 'Coron Bay', 'B', 'The watershed surrounding the Puerto Princesa Subterranean River encompasses significant wetland and mangrove habitat supporting diverse bird populations.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'What is the name of the extensive mangrove and wetland ecosystem in Palawan recognized for supporting numerous migratory bird species?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'hard', 'Which large monitor lizard species, found in the Philippines, is among the largest lizards in the world after the Komodo dragon?', 'Water monitor lizard', 'Northern Sierra Madre forest monitor (or the more widespread water monitor)', 'Philippine sailfin lizard', 'Bornean earless monitor', 'A', 'The water monitor lizard, found across the Philippines and Southeast Asia, is one of the largest lizard species in the world, second only to the Komodo dragon in some measures.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'Which large monitor lizard species, found in the Philippines, is among the largest lizards in the world after the Komodo dragon?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'hard', 'What is the term for the unique underground river ecosystem found within Puerto Princesa Subterranean River National Park?', 'Subterranean lake ecosystem', 'Aquifer ecosystem', 'Sinkhole ecosystem', 'Karst cave river ecosystem', 'D', 'The Puerto Princesa Subterranean River flows through an extensive karst cave system, forming a unique underground river ecosystem.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'What is the term for the unique underground river ecosystem found within Puerto Princesa Subterranean River National Park?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'hard', 'Which Philippine endemic bird species is known for its striking blue and red plumage and is found in Mindanao''s lowland forests, currently endangered?', 'Palawan Peacock-Pheasant', 'Rufous Hornbill', 'Mindanao Bleeding-heart (a pigeon species with a distinctive red breast marking)', 'Philippine Eagle-Owl', 'C', 'The Mindanao Bleeding-heart is a critically endangered pigeon species named for the distinctive blood-red patch on its otherwise green-and-blue plumage.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'Which Philippine endemic bird species is known for its striking blue and red plumage and is found in Mindanao''s lowland forests, currently endangered?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'hard', 'What is the primary threat facing the Philippine tarsier''s population, leading to its classification as a near-threatened species?', 'Habitat loss due to deforestation and agricultural expansion', 'Overhunting for the exotic pet trade', 'Introduced predator species exclusively', 'Climate-driven sea level rise', 'A', 'The Philippine tarsier''s population is primarily threatened by habitat loss from deforestation and expanding agricultural land use.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'What is the primary threat facing the Philippine tarsier''s population, leading to its classification as a near-threatened species?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'hard', 'Which Philippine endemic hornbill species, found in Luzon, is known for its large, colorful casque atop its bill?', 'Rufous Hornbill', 'Palawan Hornbill', 'Mindanao Hornbill', 'Visayan Hornbill', 'A', 'The Rufous Hornbill, found across Luzon and other islands, is notable for its large size and prominent casque atop its bill.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'Which Philippine endemic hornbill species, found in Luzon, is known for its large, colorful casque atop its bill?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'nature_wildlife', 'hard', 'What is the term for the Philippine deer species found in the Visayan islands, distinguished by white spots on its coat and critically endangered status?', 'Philippine sambar deer', 'Calamian deer', 'Visayan spotted deer', 'Philippine mouse-deer', 'C', 'The Visayan spotted deer is a critically endangered species native to the Visayan islands, distinguished by the white spots covering its coat.'
where not exists (
  select 1 from questions where category = 'nature_wildlife' and prompt = 'What is the term for the Philippine deer species found in the Visayan islands, distinguished by white spots on its coat and critically endangered status?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'hard', 'Which branch of the Philippine government is headed by the Chief Justice of the Supreme Court?', 'The Executive branch', 'The Legislative branch', 'The Judicial branch', 'The Constitutional Commissions (a separate category)', 'C', 'The Judicial branch of the Philippine government is headed by the Chief Justice, who leads the Supreme Court, the highest court in the country.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'Which branch of the Philippine government is headed by the Chief Justice of the Supreme Court?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'hard', 'What is the term of office for a Philippine president under the 1987 Constitution, and can they be reelected?', 'Four years, with one reelection allowed', 'Six years, with one reelection allowed', 'Five years, with no reelection allowed', 'Six years, with no reelection allowed', 'D', 'Under the 1987 Constitution, the Philippine president serves a single six-year term and is constitutionally barred from reelection.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'What is the term of office for a Philippine president under the 1987 Constitution, and can they be reelected?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'hard', 'Which Philippine constitutional body is responsible for overseeing the conduct of national and local elections?', 'Commission on Audit (COA)', 'Civil Service Commission (CSC)', 'Commission on Elections (COMELEC)', 'Office of the Ombudsman', 'C', 'The Commission on Elections (COMELEC) is the constitutional body tasked with enforcing and administering laws related to Philippine elections.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'Which Philippine constitutional body is responsible for overseeing the conduct of national and local elections?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'hard', 'What is the minimum age requirement for a person to run for President of the Philippines, as specified in the 1987 Constitution?', '35 years old', '30 years old', '40 years old', '45 years old', 'C', 'The 1987 Philippine Constitution requires a presidential candidate to be at least 40 years old on the day of the election.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'What is the minimum age requirement for a person to run for President of the Philippines, as specified in the 1987 Constitution?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'hard', 'Which house of the Philippine Congress is composed of senators elected at large, representing the entire country rather than specific districts?', 'The House of Representatives', 'The Senate', 'The Sangguniang Panlalawigan', 'The Sangguniang Bayan', 'B', 'The Senate is composed of senators elected at large nationwide, unlike House members who represent specific legislative districts.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'Which house of the Philippine Congress is composed of senators elected at large, representing the entire country rather than specific districts?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'hard', 'What is the term for the independent constitutional body tasked with investigating and prosecuting government officials for corruption in the Philippines?', 'Commission on Audit', 'Sandiganbayan (the special anti-graft court, distinct from the investigative body)', 'Department of Justice', 'Office of the Ombudsman', 'D', 'The Office of the Ombudsman investigates and prosecutes public officials accused of illegal, unjust, or corrupt acts, functioning independently of other government branches.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'What is the term for the independent constitutional body tasked with investigating and prosecuting government officials for corruption in the Philippines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'hard', 'Which special court in the Philippines has jurisdiction over graft and corruption cases involving public officials?', 'Sandiganbayan', 'Supreme Court', 'Court of Appeals', 'Regional Trial Court', 'A', 'The Sandiganbayan is a special anti-graft court with jurisdiction specifically over corruption and related offenses committed by public officials.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'Which special court in the Philippines has jurisdiction over graft and corruption cases involving public officials?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'hard', 'What is the term for the basic political and administrative unit in the Philippines, smaller than a municipality or city?', 'Barangay', 'Province', 'Municipality', 'Region', 'A', 'The barangay is the smallest local government unit in the Philippines, serving as the basic political and administrative division.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'What is the term for the basic political and administrative unit in the Philippines, smaller than a municipality or city?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'hard', 'Which 1987 constitutional provision restricts the president from serving more than a single term, a direct response to the martial law era?', 'The single six-year term limit for the presidency', 'The bicameral Congress structure', 'The creation of the Ombudsman', 'The party-list system', 'A', 'The single, non-renewable six-year presidential term was instituted in the 1987 Constitution partly as a direct response to the prolonged Marcos martial law era.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'Which 1987 constitutional provision restricts the president from serving more than a single term, a direct response to the martial law era?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'hard', 'What is the term for the Philippine electoral system that reserves a portion of House of Representatives seats for marginalized and underrepresented sectors?', 'The party-list system', 'The block-voting system', 'The at-large representation system', 'The proportional allocation system (a general term, not the specific Philippine mechanism)', 'A', 'The party-list system allocates a portion of House seats to marginalized and underrepresented sectors, elected through a separate party-list ballot.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'What is the term for the Philippine electoral system that reserves a portion of House of Representatives seats for marginalized and underrepresented sectors?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'hard', 'Which Philippine government agency is primarily responsible for auditing the accounts and expenditures of all government branches and agencies?', 'Commission on Elections (COMELEC)', 'Commission on Audit (COA)', 'Civil Service Commission (CSC)', 'Bureau of Internal Revenue (BIR)', 'B', 'The Commission on Audit (COA) is the constitutional body responsible for examining and auditing the accounts of all Philippine government agencies.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'Which Philippine government agency is primarily responsible for auditing the accounts and expenditures of all government branches and agencies?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'hard', 'What is the term for the process by which the Philippine Congress can remove a sitting president or other high official from office for serious offenses?', 'Recall', 'Referendum', 'Plebiscite', 'Impeachment', 'D', 'Impeachment is the constitutional process by which the House of Representatives may formally charge, and the Senate may try, high officials including the president.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'What is the term for the process by which the Philippine Congress can remove a sitting president or other high official from office for serious offenses?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'hard', 'Which body of the Philippine government approves treaties negotiated by the president before they take legal effect?', 'The House of Representatives', 'The Senate (through a two-thirds concurrence vote)', 'The Supreme Court', 'The Cabinet', 'B', 'Under the Philippine Constitution, treaties require concurrence of at least two-thirds of the Senate to become valid and effective.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'Which body of the Philippine government approves treaties negotiated by the president before they take legal effect?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'hard', 'What is the collective term for the heads of the executive departments who advise the Philippine president and implement executive policy?', 'The Sanggunian', 'The Council of State (a broader, separate advisory body)', 'The Bureau', 'The Cabinet', 'D', 'The Cabinet consists of the heads of executive departments, appointed by and serving at the pleasure of the president, to help implement government policy.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'What is the collective term for the heads of the executive departments who advise the Philippine president and implement executive policy?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'hard', 'Which Philippine constitutional commission is responsible for the appointment, promotion, and administration of the civil service workforce?', 'Commission on Audit (COA)', 'Civil Service Commission (CSC)', 'Commission on Elections (COMELEC)', 'Department of Budget and Management', 'B', 'The Civil Service Commission oversees the administration of the country''s civil service system, including appointments, promotions, and personnel policy.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'Which Philippine constitutional commission is responsible for the appointment, promotion, and administration of the civil service workforce?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'hard', 'What is the term for a nationwide vote on a proposed law or constitutional amendment submitted directly to Filipino voters for approval?', 'A recall election', 'A plebiscite (or referendum, depending on the specific mechanism)', 'A snap election', 'A special election', 'B', 'A plebiscite in the Philippines refers to a direct popular vote on a proposed law or constitutional change submitted for ratification by the electorate.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'What is the term for a nationwide vote on a proposed law or constitutional amendment submitted directly to Filipino voters for approval?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'hard', 'Which Philippine law, enacted in 1991, devolved significant powers and responsibilities from the national government to local government units?', 'Local Government Code of 1991', 'Administrative Code of 1987', 'Magna Carta of Public Officials', 'Local Autonomy Act of 1959', 'A', 'The Local Government Code of 1991 significantly devolved governmental powers, functions, and resources from the national government to provinces, cities, municipalities, and barangays.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'Which Philippine law, enacted in 1991, devolved significant powers and responsibilities from the national government to local government units?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'politics_government', 'hard', 'What is the term for the Philippine legal doctrine allowing the president to declare martial law under specific constitutional conditions?', 'Executive privilege', 'Calling-out power (a related but distinct, lesser power)', 'Martial law powers under Article VII of the 1987 Constitution', 'Emergency powers delegation', 'C', 'The 1987 Constitution grants the president authority to declare martial law under strict conditions, subject to congressional review and Supreme Court scrutiny, a direct response to abuses during the Marcos era.'
where not exists (
  select 1 from questions where category = 'politics_government' and prompt = 'What is the term for the Philippine legal doctrine allowing the president to declare martial law under specific constitutional conditions?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'hard', 'Which province is home to the Hundred Islands National Park?', 'Zambales', 'La Union', 'Bataan', 'Pangasinan', 'D', 'The Hundred Islands National Park, comprising over a hundred small islands, is located in Alaminos, Pangasinan.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'Which province is home to the Hundred Islands National Park?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'hard', 'What is the capital city of Cebu province, one of the oldest cities in the Philippines?', 'Mandaue City', 'Cebu City', 'Lapu-Lapu City', 'Talisay City', 'B', 'Cebu City serves as the capital of Cebu province and is recognized as the oldest city in the Philippines, founded in 1565.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'What is the capital city of Cebu province, one of the oldest cities in the Philippines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'hard', 'Which province is known as the ''Cutflower Capital of the Philippines'' due to its flower industry in Trinidad Valley?', 'Ifugao', 'Benguet', 'Mountain Province', 'Kalinga', 'B', 'Benguet, particularly the town of La Trinidad, is renowned for its flower and vegetable production, earning it the title ''Cutflower Capital.'''
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'Which province is known as the ''Cutflower Capital of the Philippines'' due to its flower industry in Trinidad Valley?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'hard', 'What is the newest region of the Philippines, created in 2019 through a plebiscite replacing the ARMM?', 'Negros Island Region', 'Caraga', 'MIMAROPA', 'Bangsamoro Autonomous Region in Muslim Mindanao (BARMM)', 'D', 'The Bangsamoro Autonomous Region in Muslim Mindanao (BARMM) was established in 2019, replacing the earlier ARMM.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'What is the newest region of the Philippines, created in 2019 through a plebiscite replacing the ARMM?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'hard', 'Which city is the capital of Davao del Sur and the largest city in the Philippines by land area?', 'Davao City', 'General Santos City', 'Digos City', 'Tagum City', 'A', 'Davao City is the largest city in the Philippines by land area and serves as a highly urbanized center in Mindanao.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'Which city is the capital of Davao del Sur and the largest city in the Philippines by land area?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'hard', 'Which province is often called the ''Land of the Perpetual Fiesta,'' home to the Ati-Atihan Festival?', 'Aklan', 'Bohol', 'Cebu', 'Samar', 'A', 'Aklan, home to the famed Ati-Atihan Festival, is often associated with the phrase ''Land of the Perpetual Fiesta.'''
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'Which province is often called the ''Land of the Perpetual Fiesta,'' home to the Ati-Atihan Festival?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'hard', 'Which landlocked province in the Cordillera region is known for the Banaue Rice Terraces?', 'Ifugao', 'Benguet', 'Kalinga', 'Apayao', 'A', 'Ifugao province is home to the famous Banaue Rice Terraces, a UNESCO World Heritage Site carved into the mountains.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'Which landlocked province in the Cordillera region is known for the Banaue Rice Terraces?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'hard', 'What is the capital of Batangas province, an important port city?', 'Lipa City', 'Tanauan City', 'Santo Tomas', 'Batangas City', 'D', 'Batangas City serves as the capital of Batangas province and is a major port for trade and shipping.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'What is the capital of Batangas province, an important port city?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'hard', 'Which island province is the smallest in the Philippines both in land area and population?', 'Camiguin', 'Siquijor', 'Batanes', 'Guimaras', 'C', 'Batanes is the smallest province in the Philippines in both land area and population, located at the northernmost tip of the archipelago.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'Which island province is the smallest in the Philippines both in land area and population?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'hard', 'What is the capital city of Iloilo province, known for its heritage architecture and La Paz Batchoy?', 'Passi City', 'Iloilo City', 'Oton', 'Jaro', 'B', 'Iloilo City is the capital of Iloilo province, well known for its Spanish-era architecture and culinary heritage.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'What is the capital city of Iloilo province, known for its heritage architecture and La Paz Batchoy?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'hard', 'Which Mindanao province is known as the ''Fruit Basket of the Philippines'' due to its abundant fruit production?', 'Bukidnon', 'Cotabato', 'Davao del Norte (or Davao region broadly, especially for durian)', 'Zamboanga del Sur', 'C', 'The Davao region, particularly Davao del Norte, is often referred to as a major fruit-producing area, especially known for durian.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'Which Mindanao province is known as the ''Fruit Basket of the Philippines'' due to its abundant fruit production?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'hard', 'What is the capital of Negros Occidental, known as the ''Sugarbowl of the Philippines''?', 'Silay City', 'Talisay City', 'Bago City', 'Bacolod City', 'D', 'Bacolod City is the capital of Negros Occidental, a province historically dominant in sugarcane production.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'What is the capital of Negros Occidental, known as the ''Sugarbowl of the Philippines''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'hard', 'Which province in the Bicol Region is home to Mount Mayon, famous for its perfect cone shape?', 'Camarines Sur', 'Sorsogon', 'Albay', 'Catanduanes', 'C', 'Mount Mayon, renowned for its symmetrical cone, is located in Albay province.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'Which province in the Bicol Region is home to Mount Mayon, famous for its perfect cone shape?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'hard', 'What is the capital city of Pampanga, often called the ''Culinary Capital of the Philippines''?', 'San Fernando', 'Angeles City', 'Mabalacat', 'Guagua', 'A', 'San Fernando serves as the capital of Pampanga, a province widely regarded as the culinary capital of the Philippines.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'What is the capital city of Pampanga, often called the ''Culinary Capital of the Philippines''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'hard', 'Which province is home to the Puerto Princesa Subterranean River National Park?', 'Occidental Mindoro', 'Romblon', 'Palawan', 'Antique', 'C', 'The Puerto Princesa Subterranean River National Park is located in Palawan province, on the island''s western coast.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'Which province is home to the Puerto Princesa Subterranean River National Park?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'hard', 'What is the smallest region in the Philippines by land area, composed mainly of Metro Manila?', 'CALABARZON', 'National Capital Region (NCR)', 'Central Luzon', 'MIMAROPA', 'B', 'The National Capital Region (NCR), comprising Metro Manila''s cities, is the smallest region in the Philippines by land area.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'What is the smallest region in the Philippines by land area, composed mainly of Metro Manila?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'hard', 'Which province is known for producing the sweetest mangoes in the Philippines and hosts the annual Mango Festival?', 'Zambales', 'Pangasinan', 'Guimaras', 'Cebu', 'C', 'Guimaras is renowned for producing some of the sweetest mangoes in the world and hosts an annual Mango Festival.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'Which province is known for producing the sweetest mangoes in the Philippines and hosts the annual Mango Festival?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'hard', 'What is the capital city of Zamboanga del Sur, known as ''Asia''s Latin City''?', 'Pagadian City', 'Zamboanga City (a highly urbanized city, historically the capital seat area)', 'Dipolog City', 'Ipil', 'A', 'Pagadian City is the capital of Zamboanga del Sur province, while Zamboanga City itself is a separate highly urbanized city known as ''Asia''s Latin City.'''
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'What is the capital city of Zamboanga del Sur, known as ''Asia''s Latin City''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'provinces_cities', 'hard', 'Which Visayan province is composed entirely of islands and is known as the ''Island of Fire'' due to its volcano?', 'Siquijor', 'Camiguin', 'Biliran', 'Guimaras', 'B', 'Camiguin, though technically part of Mindanao''s administrative region, is a small island province dubbed the ''Island of Fire'' for its volcanoes.'
where not exists (
  select 1 from questions where category = 'provinces_cities' and prompt = 'Which Visayan province is composed entirely of islands and is known as the ''Island of Fire'' due to its volcano?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'hard', 'Which Philippine religious tradition, celebrated annually in January, honors the image of the Santo Niño de Cebu?', 'The Sinulog Festival tradition', 'Simbang Gabi', 'Flores de Mayo', 'Visita Iglesia', 'A', 'The Sinulog Festival, held every January in Cebu, is a major religious tradition honoring the Santo Niño, a revered image of the Christ Child.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'Which Philippine religious tradition, celebrated annually in January, honors the image of the Santo Niño de Cebu?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'hard', 'What is the name of the nine-day series of dawn masses observed in the Philippines leading up to Christmas Day?', 'Flores de Mayo', 'Panunuluyan', 'Simbang Gabi', 'Salubong', 'C', 'Simbang Gabi is a beloved Filipino Catholic tradition of attending nine consecutive dawn masses in the days leading up to Christmas.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'What is the name of the nine-day series of dawn masses observed in the Philippines leading up to Christmas Day?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'hard', 'Which Filipino Holy Week tradition involves a theatrical or sung chanting of the Passion of Christ, often performed continuously for hours?', 'Pabasa (Pasyon chanting)', 'Senakulo (the theatrical passion play, a related but distinct tradition)', 'Salubong', 'Visita Iglesia', 'A', 'The Pabasa is the traditional chanting or singing of the Pasyon, an epic poem recounting the life, passion, and death of Jesus Christ.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'Which Filipino Holy Week tradition involves a theatrical or sung chanting of the Passion of Christ, often performed continuously for hours?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'hard', 'What is the term for the Filipino Holy Week tradition of visiting seven churches, typically performed on Maundy Thursday?', 'Pabasa', 'Senakulo', 'Panata', 'Visita Iglesia', 'D', 'Visita Iglesia is the practice of visiting seven churches, usually on Maundy Thursday, to pray and reflect during Holy Week.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'What is the term for the Filipino Holy Week tradition of visiting seven churches, typically performed on Maundy Thursday?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'hard', 'Which Filipino Catholic tradition involves offering flowers to the Virgin Mary throughout the month of May, often accompanied by children''s processions?', 'Simbang Gabi', 'Santacruzan (a related closing procession)', 'Flores de Mayo', 'Salubong', 'C', 'Flores de Mayo is a month-long Marian devotion held in May, involving daily flower offerings, often culminating in the Santacruzan procession.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'Which Filipino Catholic tradition involves offering flowers to the Virgin Mary throughout the month of May, often accompanied by children''s processions?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'hard', 'What is the name of the elaborate procession that concludes the Flores de Mayo celebrations, featuring young women representing biblical and historical figures?', 'Santacruzan', 'Panunuluyan', 'Salubong', 'Visita Iglesia', 'A', 'The Santacruzan is a grand procession concluding Flores de Mayo, featuring participants representing biblical figures alongside a reenactment of the finding of the True Cross.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'What is the name of the elaborate procession that concludes the Flores de Mayo celebrations, featuring young women representing biblical and historical figures?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'hard', 'Which Filipino Christmas Eve tradition involves the dramatic reenactment of Mary and Joseph''s search for lodging, often performed before Simbang Gabi?', 'Salubong', 'Panunuluyan', 'Pastores', 'Belen tradition', 'B', 'The Panunuluyan is a traditional reenactment of Mary and Joseph''s search for shelter before Jesus''s birth, often performed on Christmas Eve.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'Which Filipino Christmas Eve tradition involves the dramatic reenactment of Mary and Joseph''s search for lodging, often performed before Simbang Gabi?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'hard', 'What is the term for the joyous Easter Sunday reenactment depicting the meeting between the Risen Christ and the Virgin Mary in Filipino Catholic tradition?', 'Panunuluyan', 'Pabasa', 'Salubong', 'Senakulo', 'C', 'The Salubong is an Easter Sunday ritual reenacting the joyful meeting of the Risen Christ and his mother Mary, often held before dawn.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'What is the term for the joyous Easter Sunday reenactment depicting the meeting between the Risen Christ and the Virgin Mary in Filipino Catholic tradition?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'hard', 'Which major world religion, brought to the southern Philippines centuries before Spanish colonization, remains the dominant faith in parts of Mindanao?', 'Buddhism', 'Islam', 'Hinduism', 'Sikhism', 'B', 'Islam was established in parts of Mindanao and the Sulu Archipelago centuries before Spanish colonization and remains the dominant faith in much of the region.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'Which major world religion, brought to the southern Philippines centuries before Spanish colonization, remains the dominant faith in parts of Mindanao?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'hard', 'What is the term for the Filipino folk Catholic practice of penitents undergoing self-flagellation or even crucifixion reenactments during Holy Week, notably in Pampanga?', 'Penitensya (flagellant and crucifixion rituals)', 'Pabasa', 'Senakulo', 'Visita Iglesia', 'A', 'Penitensya refers to acts of penance during Holy Week, including self-flagellation and, in some towns like San Fernando, Pampanga, actual crucifixion reenactments.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'What is the term for the Filipino folk Catholic practice of penitents undergoing self-flagellation or even crucifixion reenactments during Holy Week, notably in Pampanga?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'hard', 'Which indigenous Philippine religious tradition, distinct from Christianity and Islam, continues to be practiced by various highland and tribal groups?', 'Theravada Buddhism', 'Sikhism', 'Zoroastrianism', 'Indigenous animist traditions (broadly, including specific practices like Anitism)', 'D', 'Various indigenous Philippine groups continue to practice traditional animist belief systems, honoring ancestral and nature spirits distinct from major world religions.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'Which indigenous Philippine religious tradition, distinct from Christianity and Islam, continues to be practiced by various highland and tribal groups?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'hard', 'What is the term for the traditional Filipino Christmas lantern, star-shaped and often illuminated, symbolizing the Star of Bethlehem?', 'Parol', 'Belen', 'Lucero', 'Farol (a related term used in some regions)', 'A', 'The parol is a traditional star-shaped Filipino Christmas lantern symbolizing the Star of Bethlehem that guided the Magi to Jesus''s birthplace.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'What is the term for the traditional Filipino Christmas lantern, star-shaped and often illuminated, symbolizing the Star of Bethlehem?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'hard', 'Which annual Catholic devotion in Quiapo, Manila, draws massive crowds who attempt to touch a centuries-old image of Jesus Christ carrying the cross?', 'The Feast of the Santo Niño', 'The Feast of Our Lady of Peñafrancia', 'The Feast of Our Lady of Manaoag', 'The Feast of the Black Nazarene (Traslacion)', 'D', 'The annual Traslacion procession of the Black Nazarene in Quiapo draws millions of devotees seeking to touch the venerated image for blessings.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'Which annual Catholic devotion in Quiapo, Manila, draws massive crowds who attempt to touch a centuries-old image of Jesus Christ carrying the cross?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'hard', 'What is the term for the traditional Filipino Nativity scene display, typically set up in homes and churches during Christmas?', 'Parol', 'Belen', 'Pesebre (used interchangeably in some Spanish-influenced contexts)', 'Cuna', 'B', 'The ''Belen,'' named after Bethlehem, is the traditional Filipino Nativity scene depicting the birth of Jesus, commonly displayed during Christmas.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'What is the term for the traditional Filipino Nativity scene display, typically set up in homes and churches during Christmas?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'hard', 'Which religious tradition practiced by a significant population in the Philippines was established through centuries of trade contact with China before Spanish colonization?', 'Folk religious practices blending with Chinese-Filipino traditions (e.g., ancestor veneration, though not a single named religion)', 'Traditional Chinese Buddhism and Taoism among Chinese-Filipino communities', 'Confucianism as a dominant state religion', 'Shintoism', 'B', 'Chinese-Filipino communities historically maintained religious practices including Buddhism and Taoism, brought through centuries of trade contact predating Spanish colonization.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'Which religious tradition practiced by a significant population in the Philippines was established through centuries of trade contact with China before Spanish colonization?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'hard', 'What is the name of the grand annual Marian procession honoring Our Lady of Peñafrancia in Naga City, involving a fluvial parade on the Bicol River?', 'The Salubong Procession', 'The Peñafrancia Fluvial Procession', 'The Santacruzan Procession', 'The Traslacion', 'B', 'The Peñafrancia Fluvial Procession is one of the largest Marian devotions in the Philippines, featuring a dramatic river procession along the Bicol River.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'What is the name of the grand annual Marian procession honoring Our Lady of Peñafrancia in Naga City, involving a fluvial parade on the Bicol River?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'hard', 'Which Filipino Catholic tradition involves families displaying an image or icon believed to bring blessings, often carried in home-to-home processions during fiestas?', 'Simbang Gabi', 'Flores de Mayo', 'Fluvial or street processions honoring patron saints (Ala-ala/Patron Saint processions)', 'Pabasa', 'C', 'Many Filipino town fiestas feature processions carrying the image of a patron saint through streets or waterways, believed to bring blessings to the community.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'Which Filipino Catholic tradition involves families displaying an image or icon believed to bring blessings, often carried in home-to-home processions during fiestas?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'religion_traditions', 'hard', 'What is the term for the Filipino Catholic devotional practice of making a vow or promise to a saint in exchange for a favor or blessing?', 'Pabasa', 'Novena (a related but distinct practice of nine days of prayer)', 'Bendisyon', 'Panata', 'D', 'A panata is a personal vow or devotional promise made to a saint, often fulfilled through acts like pilgrimage, penance, or lifelong devotion, in exchange for a granted favor.'
where not exists (
  select 1 from questions where category = 'religion_traditions' and prompt = 'What is the term for the Filipino Catholic devotional practice of making a vow or promise to a saint in exchange for a favor or blessing?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'hard', 'Which subatomic particle was confirmed by CERN''s Large Hadron Collider in 2012, completing the Standard Model?', 'The tau neutrino', 'The top quark', 'The graviton', 'The Higgs boson', 'D', 'The Higgs boson, responsible for giving particles mass via the Higgs field, was confirmed at CERN in 2012.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Which subatomic particle was confirmed by CERN''s Large Hadron Collider in 2012, completing the Standard Model?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'hard', 'What is the name of the process by which stars fuse hydrogen into helium in their cores?', 'Nuclear fusion', 'Nuclear fission', 'Radioactive decay', 'Electrolysis', 'A', 'Stars generate energy through nuclear fusion, combining hydrogen nuclei into helium under immense heat and pressure.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'What is the name of the process by which stars fuse hydrogen into helium in their cores?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'hard', 'Which enzyme unwinds the DNA double helix during replication?', 'Helicase', 'Ligase', 'Polymerase', 'Primase', 'A', 'Helicase breaks the hydrogen bonds between base pairs, unwinding the double helix so replication can proceed.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Which enzyme unwinds the DNA double helix during replication?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'hard', 'What is the term for the phenomenon where light bends as it passes from one medium to another?', 'Diffraction', 'Refraction', 'Reflection', 'Dispersion', 'B', 'Refraction is the bending of light as it changes speed passing between media of different densities.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'What is the term for the phenomenon where light bends as it passes from one medium to another?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'hard', 'Which quantum mechanical principle states that certain pairs of properties, like position and momentum, cannot both be precisely known?', 'Pauli Exclusion Principle', 'Schrodinger''s Equation', 'Heisenberg''s Uncertainty Principle', 'Bohr''s Correspondence Principle', 'C', 'Heisenberg''s Uncertainty Principle establishes a fundamental limit to the precision of simultaneously measuring position and momentum.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Which quantum mechanical principle states that certain pairs of properties, like position and momentum, cannot both be precisely known?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'slang', 'hard', 'In Filipino gay lingo (swardspeak), what does the term ''jowa'' commonly refer to?', 'A romantic partner or significant other', 'A close female friend', 'An enemy or rival', 'A workplace colleague', 'A', '''Jowa'' is a colloquial Filipino term for one''s boyfriend or girlfriend, widely used across informal speech, not exclusively swardspeak.'
where not exists (
  select 1 from questions where category = 'slang' and prompt = 'In Filipino gay lingo (swardspeak), what does the term ''jowa'' commonly refer to?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'slang', 'hard', 'What does the slang term ''chibog'' mean in casual Filipino conversation?', 'Money', 'Food or to eat', 'A vehicle', 'A house party', 'B', '''Chibog'' is Filipino slang for food, often used casually to mean ''let''s eat'' or referring to a meal.'
where not exists (
  select 1 from questions where category = 'slang' and prompt = 'What does the slang term ''chibog'' mean in casual Filipino conversation?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'slang', 'hard', 'In Filipino internet slang, what does ''petmalu'' mean, a term that gained popularity through ''jejemon'' culture?', 'Terrible or bad', 'Confusing', 'Expensive', 'Cool or awesome (a syllable-reversed form of ''malupit'')', 'D', '''Petmalu'' is a reversed, playful form of ''malupit'' (meaning cool or amazing), popularized during the jejemon internet slang trend.'
where not exists (
  select 1 from questions where category = 'slang' and prompt = 'In Filipino internet slang, what does ''petmalu'' mean, a term that gained popularity through ''jejemon'' culture?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'slang', 'hard', 'What does the swardspeak term ''werpa'' mean, popularized in LGBTQ+ Filipino online culture?', 'Weakness', 'Money', 'Power or strength, used as an expression of encouragement', 'Beauty', 'C', '''Werpa,'' derived from ''power'' with syllables swapped, is used as an expression of support or encouragement, similar to saying ''you''ve got this.'''
where not exists (
  select 1 from questions where category = 'slang' and prompt = 'What does the swardspeak term ''werpa'' mean, popularized in LGBTQ+ Filipino online culture?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'slang', 'hard', 'In Filipino slang, what does ''landi'' typically describe?', 'Anger or irritation', 'Laziness', 'Flirtatious or coquettish behavior', 'Generosity', 'C', '''Landi'' refers to flirtatious, coquettish, or overly playful romantic behavior.'
where not exists (
  select 1 from questions where category = 'slang' and prompt = 'In Filipino slang, what does ''landi'' typically describe?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'slang', 'hard', 'What does the term ''chika'' mean in everyday Filipino slang?', 'A type of street food', 'A dance move', 'A traffic jam', 'Gossip or casual chit-chat/news', 'D', '''Chika'' refers to gossip, casual updates, or chit-chat shared among friends.'
where not exists (
  select 1 from questions where category = 'slang' and prompt = 'What does the term ''chika'' mean in everyday Filipino slang?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'slang', 'hard', 'In Filipino slang, what does ''gigil'' describe, a term without a direct English equivalent?', 'Extreme hunger', 'An overwhelming urge to squeeze or pinch something because it''s cute or exciting', 'Deep sadness', 'Boredom', 'B', '''Gigil'' describes the intense, almost uncontrollable urge to squeeze, pinch, or clench something out of overwhelming emotion, often cuteness.'
where not exists (
  select 1 from questions where category = 'slang' and prompt = 'In Filipino slang, what does ''gigil'' describe, a term without a direct English equivalent?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'slang', 'hard', 'What does the Filipino slang term ''sayang'' express?', 'A sense of waste, regret, or missed opportunity', 'Extreme happiness', 'Confusion', 'Excitement about food', 'A', '''Sayang'' expresses regret over something wasted, lost, or a missed opportunity.'
where not exists (
  select 1 from questions where category = 'slang' and prompt = 'What does the Filipino slang term ''sayang'' express?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'slang', 'hard', 'In Taglish youth slang, what does ''char'' or ''charot'' added at the end of a sentence typically signal?', 'That the preceding statement was a joke or not meant seriously', 'Strong agreement', 'A formal request', 'A warning of danger', 'A', '''Char'' or ''charot'' is appended to a statement to indicate it was a joke, sarcasm, or not meant to be taken seriously.'
where not exists (
  select 1 from questions where category = 'slang' and prompt = 'In Taglish youth slang, what does ''char'' or ''charot'' added at the end of a sentence typically signal?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'slang', 'hard', 'What does the term ''bes'' or ''besh'' mean in casual Filipino slang, derived from an English word?', 'Boss or employer', 'Best friend, used as a casual term of address', 'A type of insult', 'A stranger', 'B', '''Bes'' or ''besh'' is a shortened, casual form of ''best friend,'' commonly used to address close friends.'
where not exists (
  select 1 from questions where category = 'slang' and prompt = 'What does the term ''bes'' or ''besh'' mean in casual Filipino slang, derived from an English word?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'slang', 'hard', 'In Filipino slang, what does ''awra'' (from ''aura'') mean when used to describe someone''s presence?', 'Bad luck', 'Physical exhaustion', 'Charisma, confidence, or striking presence', 'Financial trouble', 'C', '''Awra,'' derived from ''aura,'' is used to describe someone''s striking presence, confidence, or charismatic energy, especially in pop culture contexts.'
where not exists (
  select 1 from questions where category = 'slang' and prompt = 'In Filipino slang, what does ''awra'' (from ''aura'') mean when used to describe someone''s presence?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'hard', 'Which planet in the solar system has the most extensive and visible ring system, easily seen even with small telescopes?', 'Jupiter', 'Uranus', 'Neptune', 'Saturn', 'D', 'Saturn''s ring system is by far the most extensive and visually striking in the solar system, composed primarily of ice particles and rocky debris.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'Which planet in the solar system has the most extensive and visible ring system, easily seen even with small telescopes?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'hard', 'What is the term for the boundary around a black hole beyond which nothing, not even light, can escape its gravitational pull?', 'Singularity', 'Accretion disk', 'Event horizon', 'Photon sphere', 'C', 'The event horizon marks the boundary around a black hole beyond which the escape velocity exceeds the speed of light, making escape impossible.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'What is the term for the boundary around a black hole beyond which nothing, not even light, can escape its gravitational pull?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'hard', 'Which spacecraft became the first human-made object to leave the solar system and enter interstellar space, launched in 1977?', 'Voyager 2', 'Pioneer 10', 'Voyager 1', 'New Horizons', 'C', 'Voyager 1, launched in 1977, became the first human-made object to cross into interstellar space, doing so in 2012.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'Which spacecraft became the first human-made object to leave the solar system and enter interstellar space, launched in 1977?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'hard', 'What is the term for the theoretical point of infinite density and zero volume believed to exist at the center of a black hole?', 'Singularity', 'Event horizon', 'Photon sphere', 'Ergosphere', 'A', 'A singularity is the theoretical point at a black hole''s center where density becomes infinite and the known laws of physics break down.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'What is the term for the theoretical point of infinite density and zero volume believed to exist at the center of a black hole?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'hard', 'Which galaxy is the closest large spiral galaxy to the Milky Way and is on a predicted collision course with it in billions of years?', 'Andromeda Galaxy', 'Triangulum Galaxy', 'Whirlpool Galaxy', 'Sombrero Galaxy', 'A', 'The Andromeda Galaxy is the nearest large spiral galaxy to the Milky Way and is predicted to collide with it in roughly 4 to 5 billion years.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'Which galaxy is the closest large spiral galaxy to the Milky Way and is on a predicted collision course with it in billions of years?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'hard', 'What is the term for a star that has exhausted its nuclear fuel and collapsed into an extremely dense remnant, roughly the size of Earth?', 'Neutron star', 'White dwarf', 'Red giant', 'Black hole', 'B', 'A white dwarf is the collapsed core remnant of a low-to-medium mass star after it has exhausted its nuclear fuel, roughly Earth-sized but extremely dense.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'What is the term for a star that has exhausted its nuclear fuel and collapsed into an extremely dense remnant, roughly the size of Earth?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'hard', 'Which NASA space telescope, launched in 2021, is designed to observe the universe primarily in infrared wavelengths, succeeding Hubble?', 'Spitzer Space Telescope', 'Kepler Space Telescope', 'Chandra X-ray Observatory', 'James Webb Space Telescope', 'D', 'The James Webb Space Telescope, launched in December 2021, observes the universe primarily in infrared light, complementing and extending Hubble''s observations.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'Which NASA space telescope, launched in 2021, is designed to observe the universe primarily in infrared wavelengths, succeeding Hubble?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'hard', 'What is the term for the theoretical boundary within the Milky Way galaxy where conditions might be suitable for life to exist on planets?', 'The Galactic Habitable Zone', 'The Circumstellar Habitable Zone (a related but distinct, smaller-scale concept)', 'The Goldilocks Zone (also related, but star-specific)', 'The Kuiper Belt', 'A', 'The Galactic Habitable Zone refers to the theoretical region of a galaxy where conditions, including radiation levels and chemical composition, might best support the emergence of life.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'What is the term for the theoretical boundary within the Milky Way galaxy where conditions might be suitable for life to exist on planets?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'hard', 'Which dwarf planet, located in the Kuiper Belt, was reclassified from full planet status by the International Astronomical Union in 2006?', 'Eris', 'Ceres', 'Makemake', 'Pluto', 'D', 'Pluto was reclassified as a dwarf planet in 2006 after the International Astronomical Union established a formal definition that excluded it from full planet status.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'Which dwarf planet, located in the Kuiper Belt, was reclassified from full planet status by the International Astronomical Union in 2006?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'hard', 'What is the term for the phenomenon in which light from a distant object is stretched to longer wavelengths as the universe expands?', 'Blueshift', 'Redshift', 'Doppler shift (a related but broader term)', 'Gravitational lensing', 'B', 'Redshift refers to the stretching of light to longer, redder wavelengths as distant objects move away due to the expansion of the universe.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'What is the term for the phenomenon in which light from a distant object is stretched to longer wavelengths as the universe expands?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'hard', 'Which type of star explosion, one of the most energetic events in the universe, can briefly outshine an entire galaxy?', 'Supernova', 'Nova', 'Solar flare', 'Gamma-ray burst (a related but distinct phenomenon)', 'A', 'A supernova is a powerful stellar explosion marking the death of a massive star, briefly capable of outshining an entire galaxy.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'Which type of star explosion, one of the most energetic events in the universe, can briefly outshine an entire galaxy?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'hard', 'What is the term for the region of a star''s orbit around it where liquid water could theoretically exist on a planet''s surface?', 'The Roche limit', 'The habitable zone (Goldilocks zone)', 'The Lagrange point', 'The Oort cloud', 'B', 'The habitable zone, or Goldilocks zone, is the orbital region around a star where temperatures could allow liquid water to exist on a planet''s surface.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'What is the term for the region of a star''s orbit around it where liquid water could theoretically exist on a planet''s surface?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'hard', 'Which spacecraft mission, launched by NASA in 2015, provided the first close-up images of Pluto and its moons?', 'New Horizons', 'Voyager 2', 'Cassini', 'Juno', 'A', 'The New Horizons spacecraft provided humanity''s first close-up images of Pluto and its largest moon, Charon, during its 2015 flyby.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'Which spacecraft mission, launched by NASA in 2015, provided the first close-up images of Pluto and its moons?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'hard', 'What is the term for the cloud of icy bodies believed to surround the outer edge of the solar system, source of many long-period comets?', 'The Kuiper Belt', 'The Asteroid Belt', 'The Oort Cloud', 'The Heliosphere', 'C', 'The Oort Cloud is a theoretical spherical shell of icy bodies far beyond Pluto''s orbit, believed to be the source of many long-period comets.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'What is the term for the cloud of icy bodies believed to surround the outer edge of the solar system, source of many long-period comets?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'hard', 'Which term describes the apparent bending of light around a massive object, a phenomenon predicted by Einstein''s theory of general relativity?', 'Redshift', 'Gravitational lensing', 'Refraction', 'Diffraction', 'B', 'Gravitational lensing occurs when light from a distant object bends around a massive foreground object, a direct consequence of general relativity.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'Which term describes the apparent bending of light around a massive object, a phenomenon predicted by Einstein''s theory of general relativity?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'hard', 'What is the name of NASA''s ongoing program aiming to return humans to the Moon, with the eventual goal of establishing a sustainable lunar presence?', 'Apollo program (the historical predecessor)', 'Constellation program (an earlier, cancelled program)', 'Orion program (the spacecraft, not the overall program name)', 'Artemis program', 'D', 'The Artemis program is NASA''s current initiative to return astronauts to the Moon and establish a sustainable long-term human presence there.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'What is the name of NASA''s ongoing program aiming to return humans to the Moon, with the eventual goal of establishing a sustainable lunar presence?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'hard', 'Which term describes the point in a planet''s orbit where it is closest to the Sun?', 'Aphelion', 'Perigee', 'Perihelion', 'Apogee', 'C', 'Perihelion refers to the point in a planet''s elliptical orbit where it comes closest to the Sun, the opposite of aphelion.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'Which term describes the point in a planet''s orbit where it is closest to the Sun?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'space_astronomy', 'hard', 'Which term describes the point in a planet''s orbit where it is farthest from the Sun, the opposite of perihelion?', 'Perihelion', 'Aphelion', 'Apogee', 'Perigee', 'B', 'Aphelion refers to the point in a planet''s elliptical orbit where it is farthest from the Sun.'
where not exists (
  select 1 from questions where category = 'space_astronomy' and prompt = 'Which term describes the point in a planet''s orbit where it is farthest from the Sun, the opposite of perihelion?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'sports', 'hard', 'Which Filipino boxer became the first to win world titles in eight different weight divisions?', 'Nonito Donaire', 'Manny Pacquiao', 'Gerry Peñalosa', 'Flash Elorde', 'B', 'Manny Pacquiao made history as the first boxer to win world titles across eight different weight divisions.'
where not exists (
  select 1 from questions where category = 'sports' and prompt = 'Which Filipino boxer became the first to win world titles in eight different weight divisions?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'sports', 'hard', 'What is the traditional Filipino martial art that uses sticks, blades, and empty-hand techniques, recognized as the national sport alongside sipa?', 'Arnis (Eskrima/Kali)', 'Sipa', 'Sikaran', 'Yawyan', 'A', 'Arnis, also known as Eskrima or Kali, was declared the national martial art and sport of the Philippines by law in 2009.'
where not exists (
  select 1 from questions where category = 'sports' and prompt = 'What is the traditional Filipino martial art that uses sticks, blades, and empty-hand techniques, recognized as the national sport alongside sipa?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'sports', 'hard', 'Which Filipino chess grandmaster became the first Southeast Asian to earn the Grandmaster title?', 'Wesley So', 'Eugenio Torre', 'Rogelio Antonio Jr.', 'Mark Paragua', 'B', 'Eugenio Torre became Asia''s first Grandmaster outside the Soviet sphere and the first Southeast Asian Grandmaster in 1974.'
where not exists (
  select 1 from questions where category = 'sports' and prompt = 'Which Filipino chess grandmaster became the first Southeast Asian to earn the Grandmaster title?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'sports', 'hard', 'What sport does the Philippine Azkals national team compete in internationally?', 'Rugby', 'Field hockey', 'Handball', 'Football (soccer)', 'D', 'The Azkals is the nickname of the Philippine men''s national football team.'
where not exists (
  select 1 from questions where category = 'sports' and prompt = 'What sport does the Philippine Azkals national team compete in internationally?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'sports', 'hard', 'Which Filipina weightlifter won the country''s first-ever Olympic gold medal, at the Tokyo 2020 Games?', 'Margielyn Didal', 'Carlos Yulo', 'Kiyomi Watanabe', 'Hidilyn Diaz', 'D', 'Hidilyn Diaz won gold in women''s weightlifting at the Tokyo 2020 Olympics, the Philippines'' first-ever Olympic gold medal.'
where not exists (
  select 1 from questions where category = 'sports' and prompt = 'Which Filipina weightlifter won the country''s first-ever Olympic gold medal, at the Tokyo 2020 Games?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'sports', 'hard', 'What is the traditional Filipino kicking game played with a woven rattan ball, closely related to sepak takraw?', 'Patintero', 'Tumbang Preso', 'Sipa', 'Luksong Baka', 'C', 'Sipa is a traditional Filipino game involving kicking a small ball, often made of woven rattan, and is considered a precursor to modern sepak takraw.'
where not exists (
  select 1 from questions where category = 'sports' and prompt = 'What is the traditional Filipino kicking game played with a woven rattan ball, closely related to sepak takraw?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'sports', 'hard', 'Which basketball league is considered the oldest professional basketball league in Asia, founded in 1975 in the Philippines?', 'Philippine Basketball Association (PBA)', 'UAAP', 'NCAA Philippines', 'MPBL', 'A', 'The PBA, founded in 1975, is recognized as the first and oldest professional basketball league in Asia.'
where not exists (
  select 1 from questions where category = 'sports' and prompt = 'Which basketball league is considered the oldest professional basketball league in Asia, founded in 1975 in the Philippines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'sports', 'hard', 'Who was the Filipino boxer nicknamed ''The Flash,'' considered one of the greatest Filipino boxers of the pre-Pacquiao era?', 'Pancho Villa', 'Gabriel ''Flash'' Elorde', 'Ceferino Garcia', 'Luisito Espinosa', 'B', 'Gabriel ''Flash'' Elorde was a legendary Filipino boxer who held the world junior lightweight title for over seven years.'
where not exists (
  select 1 from questions where category = 'sports' and prompt = 'Who was the Filipino boxer nicknamed ''The Flash,'' considered one of the greatest Filipino boxers of the pre-Pacquiao era?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'sports', 'hard', 'Which Filipino gymnast won two gold medals at the Tokyo 2020 Olympics, becoming the country''s second gold medalist that Games?', 'EJ Obiena', 'Hidilyn Diaz', 'Carlos Yulo', 'Nesthy Petecio', 'C', 'Carlos Yulo won gold medals in floor exercise and vault at the Tokyo 2020 Olympics.'
where not exists (
  select 1 from questions where category = 'sports' and prompt = 'Which Filipino gymnast won two gold medals at the Tokyo 2020 Olympics, becoming the country''s second gold medalist that Games?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'sports', 'hard', 'What is the name of the annual collegiate athletic competition among Manila''s major universities, one of the oldest in Asia?', 'University Athletic Association of the Philippines (UAAP)', 'National Collegiate Athletic Association (NCAA)', 'Palarong Pambansa', 'Batang Pinoy', 'A', 'The UAAP, established in 1938, is one of the oldest collegiate athletic associations in Asia, featuring major universities like Ateneo, La Salle, and UP.'
where not exists (
  select 1 from questions where category = 'sports' and prompt = 'What is the name of the annual collegiate athletic competition among Manila''s major universities, one of the oldest in Asia?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'hard', 'Which technology company, founded in 1998, began as a search engine and later became one of the world''s most valuable companies?', 'Yahoo', 'Microsoft', 'Google', 'Amazon', 'C', 'Google was founded in 1998 by Larry Page and Sergey Brin, originally as a search engine, later expanding into one of the world''s largest technology companies.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'Which technology company, founded in 1998, began as a search engine and later became one of the world''s most valuable companies?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'hard', 'What is the term for a type of malicious software that encrypts a victim''s files, demanding payment for their release?', 'Spyware', 'Ransomware', 'Adware', 'Trojan horse', 'B', 'Ransomware is malicious software that encrypts a victim''s data, with attackers demanding payment, often in cryptocurrency, to restore access.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'What is the term for a type of malicious software that encrypts a victim''s files, demanding payment for their release?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'hard', 'Which wireless communication technology, standard since the early 2000s, enables short-range data exchange between devices like headphones and phones?', 'Wi-Fi', 'Bluetooth', 'NFC (a related but distinct short-range technology)', 'Infrared', 'B', 'Bluetooth is a wireless technology standard for exchanging data over short distances, widely used for connecting devices like headphones and speakers.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'Which wireless communication technology, standard since the early 2000s, enables short-range data exchange between devices like headphones and phones?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'hard', 'What is the term for a computing model where data storage and processing occur on remote servers accessed via the internet, rather than locally?', 'Edge computing', 'Cloud computing', 'Grid computing', 'Distributed computing (a broader, related term)', 'B', 'Cloud computing allows data storage and processing to occur on remote servers accessed over the internet, rather than on local hardware.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'What is the term for a computing model where data storage and processing occur on remote servers accessed via the internet, rather than locally?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'hard', 'Which technology, first popularized by Bitcoin, uses a decentralized, distributed ledger to record transactions across many computers?', 'Cloud database', 'Peer-to-peer network (a related but broader concept)', 'Blockchain', 'Distributed cache', 'C', 'Blockchain technology, underpinning Bitcoin, uses a decentralized and distributed ledger to securely and transparently record transactions across a network of computers.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'Which technology, first popularized by Bitcoin, uses a decentralized, distributed ledger to record transactions across many computers?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'hard', 'What is the term for a network security system that monitors and controls incoming and outgoing network traffic based on predetermined security rules?', 'Firewall', 'Antivirus software', 'VPN (a related but distinct technology)', 'Intrusion detection system (a related, but not identical, technology)', 'A', 'A firewall is a network security device or software that monitors and filters incoming and outgoing traffic according to established security rules.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'What is the term for a network security system that monitors and controls incoming and outgoing network traffic based on predetermined security rules?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'hard', 'Which programming language, created by Guido van Rossum and first released in 1991, is widely used in data science and web development for its readable syntax?', 'Java', 'Python', 'JavaScript', 'C++', 'B', 'Python, created by Guido van Rossum and first released in 1991, is renowned for its readable syntax, widely adopted in data science, web development, and automation.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'Which programming language, created by Guido van Rossum and first released in 1991, is widely used in data science and web development for its readable syntax?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'hard', 'What is the term for technology that simulates human intelligence processes, such as learning and problem-solving, in machines?', 'Artificial intelligence (AI)', 'Machine learning (a subfield of AI)', 'Deep learning (a subfield of machine learning)', 'Robotic process automation (a related but distinct technology)', 'A', 'Artificial intelligence broadly refers to technology enabling machines to simulate human cognitive processes, including learning, reasoning, and problem-solving.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'What is the term for technology that simulates human intelligence processes, such as learning and problem-solving, in machines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'hard', 'Which technology standard, developed to allow devices to connect wirelessly to the internet, operates using radio waves within local networks?', 'Wi-Fi', 'Bluetooth', 'Cellular data (a distinct, wider-range technology)', 'Ethernet (a wired, not wireless, technology)', 'A', 'Wi-Fi is a wireless networking technology that allows devices to connect to the internet or communicate with each other using radio waves within a local area.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'Which technology standard, developed to allow devices to connect wirelessly to the internet, operates using radio waves within local networks?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'hard', 'What is the term for the practice of testing software for vulnerabilities by simulating cyberattacks, typically performed by authorized security professionals?', 'Malware analysis', 'Vulnerability scanning (a related but narrower technique)', 'Social engineering (an attack method, not a testing practice)', 'Penetration testing', 'D', 'Penetration testing involves authorized professionals simulating cyberattacks against systems to identify and address security vulnerabilities before malicious actors can exploit them.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'What is the term for the practice of testing software for vulnerabilities by simulating cyberattacks, typically performed by authorized security professionals?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'hard', 'Which type of computer memory is volatile, losing its stored data when power is removed, commonly used for a computer''s active working memory?', 'ROM (Read-Only Memory)', 'SSD storage (non-volatile)', 'HDD storage (non-volatile)', 'RAM (Random Access Memory)', 'D', 'RAM (Random Access Memory) is volatile memory, meaning it loses all stored data once power is removed, unlike non-volatile storage like SSDs and HDDs.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'Which type of computer memory is volatile, losing its stored data when power is removed, commonly used for a computer''s active working memory?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'hard', 'What is the term for a technique in which computer systems learn and improve from experience without being explicitly programmed for every scenario?', 'Rule-based programming', 'Procedural programming', 'Machine learning', 'Static analysis', 'C', 'Machine learning enables computer systems to learn patterns and improve performance from data and experience, rather than relying solely on explicit programming.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'What is the term for a technique in which computer systems learn and improve from experience without being explicitly programmed for every scenario?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'hard', 'Which technology allows a single physical server to run multiple independent operating systems simultaneously, each in its own isolated environment?', 'Virtualization', 'Containerization (a related but distinct, lighter-weight technology)', 'Load balancing', 'Clustering', 'A', 'Virtualization allows a single physical machine to host multiple independent virtual machines, each running its own operating system in an isolated environment.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'Which technology allows a single physical server to run multiple independent operating systems simultaneously, each in its own isolated environment?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'hard', 'What is the term for the lightweight, portable software packaging technology popularized by Docker, bundling an application with its dependencies?', 'Containerization', 'Virtualization (a related but heavier-weight technology)', 'Orchestration (the management of multiple containers, not the packaging itself)', 'Microservices (an architectural pattern, not the packaging technology itself)', 'A', 'Containerization, popularized by tools like Docker, packages an application along with its dependencies into a lightweight, portable unit that runs consistently across environments.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'What is the term for the lightweight, portable software packaging technology popularized by Docker, bundling an application with its dependencies?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'hard', 'Which internet protocol suite forms the foundational communication standard for how data is transmitted across the internet?', 'HTTP/HTTPS (application-layer protocols, not the foundational suite)', 'TCP/IP', 'FTP', 'SMTP', 'B', 'TCP/IP (Transmission Control Protocol/Internet Protocol) forms the foundational suite of communication protocols underlying data transmission across the internet.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'Which internet protocol suite forms the foundational communication standard for how data is transmitted across the internet?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'hard', 'What is the term for a cyberattack technique in which an attacker intercepts communication between two parties without their knowledge?', 'Phishing attack', 'Denial-of-service attack', 'Man-in-the-middle attack', 'SQL injection', 'C', 'A man-in-the-middle attack occurs when an attacker secretly intercepts and potentially alters communication between two parties who believe they are communicating directly.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'What is the term for a cyberattack technique in which an attacker intercepts communication between two parties without their knowledge?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'hard', 'Which emerging computing paradigm uses quantum-mechanical phenomena like superposition and entanglement to perform certain calculations exponentially faster than classical computers?', 'Neuromorphic computing', 'Edge computing', 'Optical computing', 'Quantum computing', 'D', 'Quantum computing leverages quantum-mechanical phenomena such as superposition and entanglement to potentially solve certain complex problems far faster than classical computers.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'Which emerging computing paradigm uses quantum-mechanical phenomena like superposition and entanglement to perform certain calculations exponentially faster than classical computers?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'technology', 'hard', 'What is the term for the practice of designing software systems as a collection of small, independently deployable services rather than a single monolithic application?', 'Monolithic architecture', 'Serverless architecture (a related but distinct deployment model)', 'Event-driven architecture (a related but distinct pattern)', 'Microservices architecture', 'D', 'Microservices architecture structures an application as a collection of small, independently deployable services, each responsible for a specific business function.'
where not exists (
  select 1 from questions where category = 'technology' and prompt = 'What is the term for the practice of designing software systems as a collection of small, independently deployable services rather than a single monolithic application?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'trivia', 'hard', 'Which Philippine island group is home to the world''s smallest primate, the Philippine tarsier?', 'Luzon', 'Visayas (Bohol and nearby islands)', 'Mindanao', 'Palawan', 'B', 'The Philippine tarsier is primarily found in Bohol and other Visayan islands, though it''s not the world''s smallest primate—it''s among the smallest.'
where not exists (
  select 1 from questions where category = 'trivia' and prompt = 'Which Philippine island group is home to the world''s smallest primate, the Philippine tarsier?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'trivia', 'hard', 'What is the term for the Philippines'' unique postal address system quirk where many towns share identical names across provinces?', 'Homonymic Municipal Code', 'There is no formal term; it''s addressed via province and ZIP code', 'Dual-Barangay Registry', 'Provincial Duplicate Index', 'B', 'The Philippines has many towns with identical or near-identical names across different provinces, distinguished mainly by province name and ZIP code.'
where not exists (
  select 1 from questions where category = 'trivia' and prompt = 'What is the term for the Philippines'' unique postal address system quirk where many towns share identical names across provinces?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'trivia', 'hard', 'Which Philippine landmark is recognized by UNESCO as one of the New7Wonders of Nature, alongside the Puerto Princesa Underground River?', 'Puerto Princesa Subterranean River is the sole Philippine entrant among the New7Wonders of Nature', 'The Chocolate Hills', 'Mount Mayon', 'The Banaue Rice Terraces', 'A', 'Puerto Princesa Subterranean River National Park was named one of the New7Wonders of Nature in 2012, the only Philippine site on that list.'
where not exists (
  select 1 from questions where category = 'trivia' and prompt = 'Which Philippine landmark is recognized by UNESCO as one of the New7Wonders of Nature, alongside the Puerto Princesa Underground River?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'trivia', 'hard', 'What is the significance of the number of stars on the Philippine flag''s sun, and what do the flag''s three stars represent?', 'The three stars represent Manila, Cebu, and Davao', 'The eight rays represent the eight major ethnic tribes', 'The three stars represent Luzon, Visayas, and Mindanao, while the sun''s eight rays represent the first eight provinces to revolt against Spain', 'The three stars represent past, present, and future', 'C', 'The Philippine flag''s three stars stand for Luzon, Visayas, and Mindanao, while the sun''s eight rays symbolize the first eight provinces placed under martial law during the 1896 revolt.'
where not exists (
  select 1 from questions where category = 'trivia' and prompt = 'What is the significance of the number of stars on the Philippine flag''s sun, and what do the flag''s three stars represent?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'trivia', 'hard', 'Which Filipino inventor developed "banana ketchup" during World War II due to a tomato shortage?', 'Fe del Mundo', 'Eduardo San Juan', 'Agapito Flores', 'Maria Orosa', 'D', 'Maria Orosa, a Filipino food technologist, invented banana ketchup during World War II as a substitute for tomato-based ketchup amid shortages.'
where not exists (
  select 1 from questions where category = 'trivia' and prompt = 'Which Filipino inventor developed "banana ketchup" during World War II due to a tomato shortage?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'trivia', 'hard', 'What is the traditional Filipino unit of land area historically used before the metric system''s full adoption?', 'Hectarea and the older ''balita''', 'Acre', 'Chain', 'Rod', 'A', 'Older Filipino land measurement used units like the ''balita'' alongside the hectare, prior to full standardization under the metric system.'
where not exists (
  select 1 from questions where category = 'trivia' and prompt = 'What is the traditional Filipino unit of land area historically used before the metric system''s full adoption?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'trivia', 'hard', 'Which Philippine bird species, the national bird, is also one of the largest and most powerful eagles in the world?', 'The Palawan Hornbill', 'The Philippine Eagle-Owl', 'The Rufous Hornbill', 'The Philippine Eagle', 'D', 'The Philippine Eagle, the national bird, is among the largest and most powerful eagles in the world by wingspan and size.'
where not exists (
  select 1 from questions where category = 'trivia' and prompt = 'Which Philippine bird species, the national bird, is also one of the largest and most powerful eagles in the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'trivia', 'hard', 'What is the name of the Philippines'' longest bridge, connecting Cebu and Cordova, completed in 2021?', 'San Juanico Bridge', 'Cebu-Cordova Link Expressway (CCLEX)', 'Marcelo Fernan Bridge', 'Mactan-Mandaue Bridge', 'B', 'The Cebu-Cordova Link Expressway (CCLEX), opened in 2022, is recognized as the longest bridge in the Philippines.'
where not exists (
  select 1 from questions where category = 'trivia' and prompt = 'What is the name of the Philippines'' longest bridge, connecting Cebu and Cordova, completed in 2021?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'trivia', 'hard', 'Which Philippine province is the source of the country''s finest pineapples and is also known for its ''pinya'' fabric?', 'Aklan (piña textile) — though pineapples themselves are widely grown, piña cloth traces to Aklan', 'Batangas', 'Davao', 'Bukidnon', 'A', 'Aklan province is historically renowned for piña cloth, a fine fabric woven from pineapple leaf fibers.'
where not exists (
  select 1 from questions where category = 'trivia' and prompt = 'Which Philippine province is the source of the country''s finest pineapples and is also known for its ''pinya'' fabric?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'trivia', 'hard', 'What natural phenomenon is the Hinatuan Enchanted River in Surigao del Sur famous for?', 'Its boiling hot springs', 'Its bioluminescent algae', 'Its strikingly deep blue, clear water fed by an unmapped underground source', 'Its tidal bore waves', 'C', 'The Hinatuan Enchanted River is known for its vivid blue, remarkably clear water whose underground source has never been fully mapped.'
where not exists (
  select 1 from questions where category = 'trivia' and prompt = 'What natural phenomenon is the Hinatuan Enchanted River in Surigao del Sur famous for?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'hard', 'Which fermented soybean paste is a staple ingredient in traditional Japanese and Korean cuisine, used in soups and marinades?', 'Miso (Japan) / Doenjang (Korea)', 'Tempeh', 'Natto', 'Gochujang', 'A', 'Miso in Japan and doenjang in Korea are both fermented soybean pastes central to those cuisines'' soups, marinades, and seasonings.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'Which fermented soybean paste is a staple ingredient in traditional Japanese and Korean cuisine, used in soups and marinades?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'hard', 'What is the name of the traditional Spanish rice dish, often containing saffron, seafood, or meat, cooked in a wide shallow pan?', 'Paella', 'Risotto', 'Jambalaya', 'Pilaf', 'A', 'Paella is a traditional Spanish rice dish, originally from Valencia, cooked in a wide shallow pan with ingredients like saffron, seafood, or meat.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'What is the name of the traditional Spanish rice dish, often containing saffron, seafood, or meat, cooked in a wide shallow pan?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'hard', 'Which French cooking technique involves slowly cooking food in its own fat at a low temperature, traditionally used for duck or goose?', 'Sous vide', 'Confit', 'Braising', 'Poaching', 'B', 'Confit is a traditional French technique of slow-cooking meat, typically duck or goose, submerged in its own rendered fat at low temperature.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'Which French cooking technique involves slowly cooking food in its own fat at a low temperature, traditionally used for duck or goose?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'hard', 'What is the name of the fermented cabbage dish that is a staple of Korean cuisine, typically seasoned with chili pepper and garlic?', 'Sauerkraut', 'Tsukemono', 'Achara', 'Kimchi', 'D', 'Kimchi is a traditional Korean fermented vegetable dish, most commonly made with napa cabbage, seasoned with chili pepper, garlic, and other spices.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'What is the name of the fermented cabbage dish that is a staple of Korean cuisine, typically seasoned with chili pepper and garlic?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'hard', 'Which Italian dish consists of a thin layer of raw meat or fish, typically served as an appetizer, named after a Renaissance painter?', 'Carpaccio', 'Tartare', 'Crudo', 'Ceviche', 'A', 'Carpaccio, thinly sliced raw meat or fish, was named by its creator after the Renaissance painter Vittore Carpaccio, known for his use of red hues.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'Which Italian dish consists of a thin layer of raw meat or fish, typically served as an appetizer, named after a Renaissance painter?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'hard', 'What is the term for the traditional Ethiopian flatbread, made from teff flour, used as both a plate and utensil for meals?', 'Naan', 'Roti', 'Chapati', 'Injera', 'D', 'Injera is a spongy, slightly sour flatbread made from teff flour, central to Ethiopian and Eritrean cuisine, serving as both plate and utensil.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'What is the term for the traditional Ethiopian flatbread, made from teff flour, used as both a plate and utensil for meals?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'hard', 'Which Mexican dish consists of a rich, complex sauce typically made with chili peppers and often chocolate, served over meat?', 'Salsa verde', 'Mole', 'Adobo (Mexican-style, distinct from Filipino adobo)', 'Pico de gallo', 'B', 'Mole is a complex Mexican sauce, often featuring chili peppers and sometimes chocolate, with numerous regional variations across Mexico.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'Which Mexican dish consists of a rich, complex sauce typically made with chili peppers and often chocolate, served over meat?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'hard', 'What is the name of the traditional Indian cooking method using a cylindrical clay oven, producing distinctively charred, smoky flavors?', 'Dum cooking', 'Balti cooking', 'Tandoor cooking', 'Karahi cooking', 'C', 'Tandoor cooking uses a cylindrical clay oven that reaches very high temperatures, producing the distinctive char and smoky flavor of dishes like tandoori chicken and naan.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'What is the name of the traditional Indian cooking method using a cylindrical clay oven, producing distinctively charred, smoky flavors?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'hard', 'Which fermented fish sauce is a fundamental seasoning in Vietnamese and Thai cuisines, providing a salty, umami flavor?', 'Soy sauce', 'Fish sauce (nuoc mam / nam pla)', 'Oyster sauce', 'Hoisin sauce', 'B', 'Fish sauce, called nuoc mam in Vietnam and nam pla in Thailand, is a fundamental fermented condiment providing salty, umami depth to Southeast Asian cuisine.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'Which fermented fish sauce is a fundamental seasoning in Vietnamese and Thai cuisines, providing a salty, umami flavor?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'hard', 'What is the term for the French culinary technique of finely dicing vegetables into a uniform small cube shape, often used for mirepoix?', 'Brunoise', 'Julienne', 'Chiffonade', 'Macedoine', 'A', 'Brunoise refers to a precise French knife cut producing very small, uniform cubes, often used for aromatics in a mirepoix base.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'What is the term for the French culinary technique of finely dicing vegetables into a uniform small cube shape, often used for mirepoix?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'hard', 'Which traditional Middle Eastern dish consists of ground chickpeas, formed into balls or patties, and deep-fried?', 'Hummus', 'Tabbouleh', 'Falafel', 'Shawarma', 'C', 'Falafel is a popular Middle Eastern dish made from ground chickpeas or fava beans, shaped and deep-fried, often served in pita bread.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'Which traditional Middle Eastern dish consists of ground chickpeas, formed into balls or patties, and deep-fried?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'hard', 'What is the name of the traditional Chinese cooking technique involving very high heat and constant, rapid tossing of ingredients in a wok?', 'Steaming', 'Braising', 'Deep-frying', 'Stir-frying', 'D', 'Stir-frying is a fundamental Chinese cooking technique using intense heat and quick tossing motions, typically performed in a wok, to cook ingredients rapidly.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'What is the name of the traditional Chinese cooking technique involving very high heat and constant, rapid tossing of ingredients in a wok?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'hard', 'Which Peruvian dish involves marinating raw fish in citrus juice, often served with onions, chili, and cilantro?', 'Tiradito (a related but distinct Peruvian dish)', 'Ceviche', 'Carpaccio', 'Aguachile (a related Mexican dish)', 'B', 'Ceviche is a signature Peruvian dish in which raw fish is ''cooked'' through the acidity of citrus juice, typically served with onion, chili, and cilantro.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'Which Peruvian dish involves marinating raw fish in citrus juice, often served with onions, chili, and cilantro?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'hard', 'What is the term for the traditional Japanese art of vinegared rice combined with various ingredients, often including raw fish?', 'Sushi', 'Sashimi (raw fish alone, without rice)', 'Tempura (a fried dish, unrelated)', 'Onigiri (a related but distinct rice ball dish)', 'A', 'Sushi refers to dishes featuring vinegared rice combined with a variety of ingredients, commonly including raw or cooked seafood.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'What is the term for the traditional Japanese art of vinegared rice combined with various ingredients, often including raw fish?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'hard', 'Which French pastry technique involves folding butter into dough multiple times to create many thin, flaky layers, used for croissants?', 'Blind baking', 'Tempering', 'Laminating (lamination)', 'Proofing', 'C', 'Lamination is the technique of repeatedly folding butter into dough to create the many thin layers characteristic of croissants and puff pastry.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'Which French pastry technique involves folding butter into dough multiple times to create many thin, flaky layers, used for croissants?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'hard', 'What is the term for the traditional Georgian (country) cheese-filled bread boat, often topped with a raw egg before serving?', 'Lavash', 'Khachapuri', 'Adjarian bread (an alternate regional name for the same dish)', 'Shoti', 'B', 'Khachapuri is a traditional Georgian dish of cheese-filled bread, with the Adjarian variety famously shaped like a boat and topped with a raw egg.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'What is the term for the traditional Georgian (country) cheese-filled bread boat, often topped with a raw egg before serving?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'hard', 'Which Moroccan cooking vessel, a conical clay pot, gives its name to the slow-cooked stew traditionally prepared within it?', 'Couscoussier', 'Bastilla dish (a pastry, not a cooking vessel)', 'Harira pot (not a standard named vessel)', 'Tagine', 'D', 'The tagine is both a conical clay cooking vessel and the name of the slow-cooked Moroccan stew traditionally prepared within it.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'Which Moroccan cooking vessel, a conical clay pot, gives its name to the slow-cooked stew traditionally prepared within it?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_food', 'hard', 'Which German dish consists of fermented cabbage, commonly served alongside sausages, and is also popular in various European cuisines?', 'Kimchi', 'Spaetzle', 'Sauerkraut', 'Rotkohl', 'C', 'Sauerkraut, made from finely cut fermented cabbage, is a staple German dish commonly paired with sausages and other hearty fare.'
where not exists (
  select 1 from questions where category = 'world_food' and prompt = 'Which German dish consists of fermented cabbage, commonly served alongside sausages, and is also popular in various European cuisines?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'hard', 'Which is the longest river in the world by most measurements, flowing through northeastern Africa?', 'The Amazon', 'The Nile', 'The Yangtze', 'The Mississippi', 'B', 'The Nile River, flowing through northeastern Africa, is traditionally considered the longest river in the world, though some studies argue the Amazon is longer.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'Which is the longest river in the world by most measurements, flowing through northeastern Africa?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'hard', 'What is the name of the largest desert in the world by area, encompassing the entire continent it covers?', 'The Sahara Desert', 'The Arabian Desert', 'The Gobi Desert', 'Antarctica (a cold desert, technically the largest by area)', 'D', 'Antarctica is technically the largest desert in the world by area, receiving very little precipitation despite being covered in ice.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'What is the name of the largest desert in the world by area, encompassing the entire continent it covers?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'hard', 'Which mountain range, stretching through South America, is the longest continental mountain range in the world?', 'The Rockies', 'The Himalayas', 'The Andes', 'The Alps', 'C', 'The Andes mountain range stretches roughly 7,000 kilometers along South America''s western edge, making it the longest continental range in the world.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'Which mountain range, stretching through South America, is the longest continental mountain range in the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'hard', 'What is the name of the deepest point in the world''s oceans, located in the Mariana Trench in the Pacific Ocean?', 'Challenger Deep', 'Puerto Rico Trench', 'Java Trench', 'Tonga Trench', 'A', 'Challenger Deep, located in the Mariana Trench, is the deepest known point in the world''s oceans, reaching nearly 11,000 meters.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'What is the name of the deepest point in the world''s oceans, located in the Mariana Trench in the Pacific Ocean?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'hard', 'Which African lake is the largest lake by surface area on the continent and the second-largest freshwater lake in the world?', 'Lake Tanganyika', 'Lake Victoria', 'Lake Malawi', 'Lake Chad', 'B', 'Lake Victoria, bordered by Uganda, Kenya, and Tanzania, is Africa''s largest lake by surface area and the world''s second-largest freshwater lake.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'Which African lake is the largest lake by surface area on the continent and the second-largest freshwater lake in the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'hard', 'What is the name of the strait separating Europe and Asia, connecting the Black Sea to the Sea of Marmara?', 'The Strait of Gibraltar', 'The Dardanelles (a separate but related strait)', 'The Bosphorus Strait', 'The Strait of Hormuz', 'C', 'The Bosphorus Strait, running through Istanbul, separates the European and Asian sides of Turkey, connecting the Black Sea to the Sea of Marmara.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'What is the name of the strait separating Europe and Asia, connecting the Black Sea to the Sea of Marmara?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'hard', 'Which country contains the largest portion of the Amazon Rainforest, the world''s largest tropical rainforest?', 'Peru', 'Colombia', 'Brazil', 'Bolivia', 'C', 'Brazil contains the largest share of the Amazon Rainforest, though significant portions also extend into Peru, Colombia, and other South American countries.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'Which country contains the largest portion of the Amazon Rainforest, the world''s largest tropical rainforest?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'hard', 'What is the name of the highest waterfall in the world by uninterrupted drop, located in Venezuela?', 'Victoria Falls', 'Angel Falls', 'Niagara Falls', 'Iguazu Falls', 'B', 'Angel Falls in Venezuela is the world''s highest uninterrupted waterfall, with a total drop of 979 meters.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'What is the name of the highest waterfall in the world by uninterrupted drop, located in Venezuela?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'hard', 'Which landlocked country in Central Asia is the world''s largest country without direct access to an ocean?', 'Mongolia', 'Uzbekistan', 'Afghanistan', 'Kazakhstan', 'D', 'Kazakhstan is the largest landlocked country in the world by area, situated in Central Asia without direct access to an ocean.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'Which landlocked country in Central Asia is the world''s largest country without direct access to an ocean?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'hard', 'What is the name of the mountain range that forms a natural border between Europe and Asia, running through Russia?', 'The Ural Mountains', 'The Caucasus Mountains', 'The Carpathian Mountains', 'The Altai Mountains', 'A', 'The Ural Mountains, running north to south through Russia, are traditionally considered the geographic boundary between Europe and Asia.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'What is the name of the mountain range that forms a natural border between Europe and Asia, running through Russia?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'hard', 'Which sea, bordered by multiple countries, is the saltiest large body of water in the world, allowing swimmers to float easily?', 'The Red Sea', 'The Dead Sea', 'The Caspian Sea', 'The Aral Sea', 'B', 'The Dead Sea, bordered by Israel, Jordan, and the West Bank, is one of the saltiest bodies of water on Earth, allowing for exceptional buoyancy.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'Which sea, bordered by multiple countries, is the saltiest large body of water in the world, allowing swimmers to float easily?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'hard', 'What is the name of the largest island in the world by area, located off the northeastern coast of North America?', 'Greenland', 'New Guinea', 'Borneo', 'Madagascar', 'A', 'Greenland, an autonomous territory of Denmark, is the largest island in the world by area, though Australia is larger but classified as a continent.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'What is the name of the largest island in the world by area, located off the northeastern coast of North America?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'hard', 'Which mountain, located in Tanzania, is the highest peak in Africa and the tallest free-standing mountain in the world?', 'Mount Kenya', 'Mount Meru', 'Mount Kilimanjaro', 'Ras Dashen', 'C', 'Mount Kilimanjaro in Tanzania is Africa''s highest peak and is often cited as the world''s tallest free-standing mountain, not part of a larger range.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'Which mountain, located in Tanzania, is the highest peak in Africa and the tallest free-standing mountain in the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'hard', 'What is the name of the archipelago nation composed of over 17,000 islands, the largest island country in the world?', 'Indonesia', 'Philippines', 'Japan', 'Papua New Guinea', 'A', 'Indonesia, composed of over 17,000 islands, is the largest archipelago and island country in the world by both landmass and island count.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'What is the name of the archipelago nation composed of over 17,000 islands, the largest island country in the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'hard', 'Which body of water, technically a sea but often mistakenly called a lake, is the largest inland body of water in the world?', 'The Aral Sea', 'Lake Superior', 'The Dead Sea', 'The Caspian Sea', 'D', 'The Caspian Sea, bordered by five countries, is the largest inland body of water in the world, classified variably as either the largest lake or a full sea.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'Which body of water, technically a sea but often mistakenly called a lake, is the largest inland body of water in the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'hard', 'What is the name of the vast, cold desert plateau located mostly in China and Mongolia, known for extreme temperature swings?', 'The Gobi Desert', 'The Taklamakan Desert', 'The Thar Desert', 'The Karakum Desert', 'A', 'The Gobi Desert, spanning parts of China and Mongolia, is known for its extreme seasonal and daily temperature fluctuations.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'What is the name of the vast, cold desert plateau located mostly in China and Mongolia, known for extreme temperature swings?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'hard', 'Which South American country is home to the Atacama Desert, considered the driest non-polar desert in the world?', 'Peru', 'Bolivia', 'Argentina', 'Chile', 'D', 'The Atacama Desert, located primarily in Chile, is widely regarded as the driest non-polar desert on Earth, with some areas rarely receiving any rainfall.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'Which South American country is home to the Atacama Desert, considered the driest non-polar desert in the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_geography', 'hard', 'Which South American country is home to Lake Titicaca, the highest navigable lake in the world, shared with Bolivia?', 'Ecuador', 'Peru', 'Chile', 'Colombia', 'B', 'Lake Titicaca, the highest navigable lake in the world, straddles the border between Peru and Bolivia in the Andes Mountains.'
where not exists (
  select 1 from questions where category = 'world_geography' and prompt = 'Which South American country is home to Lake Titicaca, the highest navigable lake in the world, shared with Bolivia?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'hard', 'Which ancient civilization built the pyramids of Giza and developed one of the earliest writing systems, hieroglyphics?', 'Ancient Mesopotamia', 'Ancient Egypt', 'Ancient Greece', 'The Indus Valley Civilization', 'B', 'Ancient Egypt is renowned for constructing the pyramids of Giza and developing hieroglyphics, one of the world''s earliest writing systems.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'Which ancient civilization built the pyramids of Giza and developed one of the earliest writing systems, hieroglyphics?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'hard', 'What was the name of the 14th-century pandemic that killed an estimated one-third of Europe''s population?', 'The Spanish Flu', 'The Antonine Plague', 'The Plague of Justinian', 'The Black Death (Bubonic Plague)', 'D', 'The Black Death, a bubonic plague pandemic in the 14th century, killed an estimated one-third of Europe''s population within a few years.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'What was the name of the 14th-century pandemic that killed an estimated one-third of Europe''s population?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'hard', 'Which empire, ruled by Genghis Khan and his successors, became the largest contiguous land empire in world history?', 'The Roman Empire', 'The Ottoman Empire', 'The Mongol Empire', 'The British Empire', 'C', 'The Mongol Empire, founded by Genghis Khan in the 13th century, grew to become the largest contiguous land empire ever to exist.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'Which empire, ruled by Genghis Khan and his successors, became the largest contiguous land empire in world history?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'hard', 'What was the name of the 1789 revolution that overthrew the French monarchy and led to major political and social change?', 'The French Revolution', 'The Glorious Revolution', 'The Russian Revolution', 'The Industrial Revolution', 'A', 'The French Revolution, beginning in 1789, overthrew the French monarchy and profoundly reshaped political and social structures in France and beyond.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'What was the name of the 1789 revolution that overthrew the French monarchy and led to major political and social change?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'hard', 'Which ancient wonder of the world, a massive lighthouse, guided ships into the harbor of the ancient Egyptian city of Alexandria?', 'The Lighthouse of Alexandria', 'The Colossus of Rhodes', 'The Great Pyramid of Giza', 'The Hanging Gardens of Babylon', 'A', 'The Lighthouse of Alexandria, one of the Seven Wonders of the Ancient World, guided ships safely into Alexandria''s harbor for centuries.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'Which ancient wonder of the world, a massive lighthouse, guided ships into the harbor of the ancient Egyptian city of Alexandria?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'hard', 'What is the name of the treaty that formally ended World War I, signed in 1919 and imposing harsh terms on Germany?', 'The Treaty of Paris', 'The Treaty of Vienna', 'The Treaty of Westphalia', 'The Treaty of Versailles', 'D', 'The Treaty of Versailles, signed in 1919, formally ended World War I and imposed significant territorial and financial penalties on Germany.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'What is the name of the treaty that formally ended World War I, signed in 1919 and imposing harsh terms on Germany?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'hard', 'Which ancient Greek city-state is credited with developing one of the earliest forms of democracy in the 5th century BCE?', 'Athens', 'Sparta', 'Corinth', 'Thebes', 'A', 'Athens is credited with developing one of history''s earliest forms of democracy, allowing citizen participation in political decision-making in the 5th century BCE.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'Which ancient Greek city-state is credited with developing one of the earliest forms of democracy in the 5th century BCE?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'hard', 'What was the name of the massive wall built by the Roman Empire in Britain to defend against attacks from the north?', 'The Antonine Wall', 'The Limes Germanicus (a related but different frontier system)', 'Hadrian''s Wall', 'The Great Wall of Britain (not a historical name)', 'C', 'Hadrian''s Wall, built under Emperor Hadrian, stretched across northern Britain to defend Roman territory from tribes to the north.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'What was the name of the massive wall built by the Roman Empire in Britain to defend against attacks from the north?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'hard', 'Which 15th-century event marked the fall of the Byzantine Empire, as Ottoman forces captured its capital city?', 'The Fall of Rome (476)', 'The Sack of Baghdad (1258)', 'The Fall of Constantinople (1453)', 'The Fall of Jerusalem (1187)', 'C', 'The Fall of Constantinople in 1453 marked the end of the Byzantine Empire, as Ottoman forces under Sultan Mehmed II captured the city.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'Which 15th-century event marked the fall of the Byzantine Empire, as Ottoman forces captured its capital city?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'hard', 'What was the name of the extensive network of trade routes connecting China with the Mediterranean world, facilitating cultural exchange?', 'The Amber Road', 'The Incense Route', 'The Spice Route', 'The Silk Road', 'D', 'The Silk Road was a vast network of trade routes connecting China to the Mediterranean, facilitating exchange of goods, ideas, and culture for centuries.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'What was the name of the extensive network of trade routes connecting China with the Mediterranean world, facilitating cultural exchange?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'hard', 'Which 1917 event led to the overthrow of the Russian monarchy and eventually established a communist government under the Bolsheviks?', 'The Russian Revolution', 'The Prague Spring', 'The October Manifesto (an earlier, separate event)', 'The Decembrist Revolt (an earlier, separate event)', 'A', 'The Russian Revolution of 1917 overthrew the Tsarist monarchy and, following a subsequent civil war, established a Bolshevik-led communist government.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'Which 1917 event led to the overthrow of the Russian monarchy and eventually established a communist government under the Bolsheviks?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'hard', 'What was the name of the ancient Mesopotamian code, one of the earliest known written legal codes, established by a Babylonian king?', 'The Code of Justinian', 'The Code of Hammurabi', 'The Twelve Tables', 'The Code of Ur-Nammu (an earlier but less complete code)', 'B', 'The Code of Hammurabi, established by the Babylonian king Hammurabi around 1754 BCE, is among the earliest and most complete written legal codes known.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'What was the name of the ancient Mesopotamian code, one of the earliest known written legal codes, established by a Babylonian king?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'hard', 'Which war, fought between Athens and Sparta in ancient Greece, ultimately weakened both city-states and reshaped Greek politics?', 'The Persian Wars', 'The Peloponnesian War', 'The Trojan War (a mythological conflict, not historical in the same sense)', 'The Corinthian War', 'B', 'The Peloponnesian War, fought between Athens and Sparta from 431 to 404 BCE, significantly weakened both powers and reshaped the political landscape of ancient Greece.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'Which war, fought between Athens and Sparta in ancient Greece, ultimately weakened both city-states and reshaped Greek politics?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'hard', 'What was the name of the 1804 revolution that established Haiti as the first independent nation founded by formerly enslaved people?', 'The Cuban War of Independence', 'The Latin American Wars of Independence (a broader, later movement)', 'The Santo Domingo Uprising', 'The Haitian Revolution', 'D', 'The Haitian Revolution, culminating in 1804, established Haiti as the first nation founded through a successful slave revolt, achieving independence from France.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'What was the name of the 1804 revolution that established Haiti as the first independent nation founded by formerly enslaved people?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'hard', 'Which ancient empire, centered in present-day Peru, built an extensive road network across the Andes without the use of the wheel?', 'The Aztec Empire', 'The Inca Empire', 'The Maya civilization', 'The Olmec civilization', 'B', 'The Inca Empire constructed an extensive road network across the rugged Andes Mountains, remarkable for being built and maintained without wheeled vehicles.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'Which ancient empire, centered in present-day Peru, built an extensive road network across the Andes without the use of the wheel?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'hard', 'What was the name of the period of cultural, artistic, and intellectual revival in Europe following the Middle Ages, beginning in Italy?', 'The Enlightenment', 'The Reformation', 'The Renaissance', 'The Baroque period', 'C', 'The Renaissance, beginning in Italy around the 14th century, marked a period of renewed interest in classical learning, art, and scientific inquiry.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'What was the name of the period of cultural, artistic, and intellectual revival in Europe following the Middle Ages, beginning in Italy?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'hard', 'Which 1789 document, adopted during the French Revolution, established fundamental rights and principles of liberty and equality?', 'The Declaration of the Rights of Man and of the Citizen', 'The Magna Carta', 'The Bill of Rights', 'The Declaration of Independence', 'A', 'The Declaration of the Rights of Man and of the Citizen, adopted in 1789, articulated fundamental principles of liberty, equality, and citizenship during the French Revolution.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'Which 1789 document, adopted during the French Revolution, established fundamental rights and principles of liberty and equality?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_history', 'hard', 'Which ancient Chinese dynasty is credited with beginning construction of an early version of the Great Wall of China and unifying the country''s writing system?', 'The Han Dynasty', 'The Qin Dynasty', 'The Tang Dynasty', 'The Ming Dynasty', 'B', 'The Qin Dynasty, under Emperor Qin Shi Huang, unified China and began constructing early sections of what would become the Great Wall.'
where not exists (
  select 1 from questions where category = 'world_history' and prompt = 'Which ancient Chinese dynasty is credited with beginning construction of an early version of the Great Wall of China and unifying the country''s writing system?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'hard', 'Which Russian novelist wrote the epic novel ''War and Peace,'' exploring Russian society during the Napoleonic Wars?', 'Leo Tolstoy', 'Fyodor Dostoevsky', 'Anton Chekhov', 'Ivan Turgenev', 'A', 'Leo Tolstoy wrote ''War and Peace,'' a sweeping epic novel examining Russian society and the impact of the Napoleonic Wars.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'Which Russian novelist wrote the epic novel ''War and Peace,'' exploring Russian society during the Napoleonic Wars?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'hard', 'What is the title of Gabriel Garcia Marquez''s landmark novel, considered a foundational work of magical realism, chronicling the Buendia family?', 'One Hundred Years of Solitude', 'Love in the Time of Cholera', 'Chronicle of a Death Foretold', 'The Autumn of the Patriarch', 'A', '''One Hundred Years of Solitude,'' by Gabriel Garcia Marquez, is a foundational work of magical realism chronicling generations of the Buendia family.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'What is the title of Gabriel Garcia Marquez''s landmark novel, considered a foundational work of magical realism, chronicling the Buendia family?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'hard', 'Which British author wrote the dystopian novel ''1984,'' depicting a totalitarian society under constant surveillance?', 'Aldous Huxley', 'Ray Bradbury', 'H.G. Wells', 'George Orwell', 'D', 'George Orwell wrote ''1984,'' a dystopian novel depicting a totalitarian regime that maintains control through pervasive surveillance and propaganda.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'Which British author wrote the dystopian novel ''1984,'' depicting a totalitarian society under constant surveillance?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'hard', 'What is the title of Franz Kafka''s novella depicting a man who wakes up transformed into a giant insect?', 'The Trial', 'The Metamorphosis', 'The Castle', 'In the Penal Colony', 'B', '''The Metamorphosis,'' by Franz Kafka, tells the surreal story of Gregor Samsa, who wakes to find himself transformed into a giant insect.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'What is the title of Franz Kafka''s novella depicting a man who wakes up transformed into a giant insect?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'hard', 'Which Japanese author wrote ''Norwegian Wood'' and ''Kafka on the Shore,'' known for blending surrealism with everyday life?', 'Yukio Mishima', 'Kenzaburo Oe', 'Haruki Murakami', 'Kobo Abe', 'C', 'Haruki Murakami is renowned for novels like ''Norwegian Wood'' and ''Kafka on the Shore,'' blending surrealist elements with intimate portrayals of everyday life.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'Which Japanese author wrote ''Norwegian Wood'' and ''Kafka on the Shore,'' known for blending surrealism with everyday life?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'hard', 'What is the title of Fyodor Dostoevsky''s novel exploring themes of guilt, redemption, and morality through a young man who commits murder?', 'The Brothers Karamazov', 'Notes from Underground', 'The Idiot', 'Crime and Punishment', 'D', '''Crime and Punishment'' follows Raskolnikov, a young man tormented by guilt after committing murder, exploring deep questions of morality and redemption.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'What is the title of Fyodor Dostoevsky''s novel exploring themes of guilt, redemption, and morality through a young man who commits murder?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'hard', 'Which epic poem, attributed to the ancient Greek poet Homer, recounts the journey of Odysseus returning home after the Trojan War?', 'The Iliad', 'The Odyssey', 'The Aeneid', 'Metamorphoses', 'B', 'The Odyssey, attributed to Homer, recounts the long and perilous journey of Odysseus as he attempts to return home after the Trojan War.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'Which epic poem, attributed to the ancient Greek poet Homer, recounts the journey of Odysseus returning home after the Trojan War?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'hard', 'What is the title of Jane Austen''s novel following Elizabeth Bennet''s evolving relationship with the proud Mr. Darcy?', 'Sense and Sensibility', 'Emma', 'Pride and Prejudice', 'Persuasion', 'C', '''Pride and Prejudice,'' by Jane Austen, centers on Elizabeth Bennet and her complex, evolving relationship with the initially proud Mr. Darcy.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'What is the title of Jane Austen''s novel following Elizabeth Bennet''s evolving relationship with the proud Mr. Darcy?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'hard', 'Which German author wrote ''Faust,'' a tragic play in which a scholar makes a deal with the devil in exchange for knowledge?', 'Friedrich Schiller', 'Johann Wolfgang von Goethe', 'Thomas Mann', 'Heinrich Heine', 'B', '''Faust,'' by Johann Wolfgang von Goethe, tells the story of a scholar who trades his soul to the devil, Mephistopheles, in exchange for unlimited knowledge and worldly pleasure.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'Which German author wrote ''Faust,'' a tragic play in which a scholar makes a deal with the devil in exchange for knowledge?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'hard', 'What is the title of Leo Tolstoy''s novel exploring themes of adultery and Russian aristocratic society, centered on its titular heroine?', 'Anna Karenina', 'War and Peace', 'Resurrection', 'The Death of Ivan Ilyich', 'A', '''Anna Karenina'' follows its titular heroine''s tragic affair and its consequences within the strict social confines of Russian aristocratic society.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'What is the title of Leo Tolstoy''s novel exploring themes of adultery and Russian aristocratic society, centered on its titular heroine?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'hard', 'Which Colombian author''s works, alongside Gabriel Garcia Marquez, helped define the Latin American literary movement known as the ''Boom''?', 'Multiple authors across Latin America contributed to the ''Boom,'' including Mario Vargas Llosa (Peru) and Julio Cortazar (Argentina)', 'Mario Vargas Llosa', 'Julio Cortazar', 'Carlos Fuentes', 'B', 'Mario Vargas Llosa, a Peruvian author, was among the key figures of the Latin American literary ''Boom,'' alongside Garcia Marquez and others.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'Which Colombian author''s works, alongside Gabriel Garcia Marquez, helped define the Latin American literary movement known as the ''Boom''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'hard', 'What is the title of Victor Hugo''s sprawling novel depicting the lives of ex-convict Jean Valjean and various characters amid social upheaval in France?', 'The Hunchback of Notre-Dame', 'Toilers of the Sea', 'Ninety-Three', 'Les Miserables', 'D', '''Les Miserables,'' by Victor Hugo, follows Jean Valjean''s redemption journey against the backdrop of social injustice and upheaval in 19th-century France.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'What is the title of Victor Hugo''s sprawling novel depicting the lives of ex-convict Jean Valjean and various characters amid social upheaval in France?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'hard', 'Which Irish author wrote ''Ulysses,'' a modernist novel that reimagines Homer''s Odyssey across a single day in Dublin?', 'Samuel Beckett', 'Oscar Wilde', 'W.B. Yeats', 'James Joyce', 'D', 'James Joyce''s ''Ulysses'' is a landmark modernist novel that parallels Homer''s Odyssey, unfolding over a single day in Dublin, Ireland.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'Which Irish author wrote ''Ulysses,'' a modernist novel that reimagines Homer''s Odyssey across a single day in Dublin?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'hard', 'What is the title of Miguel de Cervantes'' novel, often cited as one of the first modern novels, following a delusional knight-errant?', 'Don Quixote', 'La Galatea', 'The Exemplary Novels', 'Persiles and Sigismunda', 'A', '''Don Quixote,'' by Miguel de Cervantes, follows the adventures of a delusional knight-errant and is widely regarded as one of the first modern novels.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'What is the title of Miguel de Cervantes'' novel, often cited as one of the first modern novels, following a delusional knight-errant?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'hard', 'Which Chinese classical novel, one of the ''Four Great Classical Novels,'' follows a monk''s pilgrimage to India accompanied by supernatural companions?', 'Dream of the Red Chamber', 'Water Margin', 'Journey to the West', 'Romance of the Three Kingdoms', 'C', '''Journey to the West'' recounts a monk''s pilgrimage to India, accompanied by supernatural companions including the Monkey King, and is among China''s Four Great Classical Novels.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'Which Chinese classical novel, one of the ''Four Great Classical Novels,'' follows a monk''s pilgrimage to India accompanied by supernatural companions?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'hard', 'What is the title of Mary Shelley''s novel, often cited as an early work of science fiction, about a scientist who creates a living creature?', 'The Last Man', 'Valperga', 'Frankenstein', 'Mathilda', 'C', '''Frankenstein,'' by Mary Shelley, tells the story of a scientist whose creation of a living creature leads to tragic and far-reaching consequences, and is considered an early landmark of science fiction.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'What is the title of Mary Shelley''s novel, often cited as an early work of science fiction, about a scientist who creates a living creature?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'hard', 'Which Italian poet''s ''Divine Comedy'' recounts an allegorical journey through Hell, Purgatory, and Paradise?', 'Dante Alighieri', 'Petrarch', 'Boccaccio', 'Ludovico Ariosto', 'A', 'Dante Alighieri''s ''Divine Comedy'' is an epic poem recounting an allegorical journey through Hell, Purgatory, and Paradise, guided first by the poet Virgil.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'Which Italian poet''s ''Divine Comedy'' recounts an allegorical journey through Hell, Purgatory, and Paradise?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_literature', 'hard', 'Which American author wrote "The Great Gatsby," a novel exploring wealth, ambition, and disillusionment in the Jazz Age?', 'Ernest Hemingway', 'F. Scott Fitzgerald', 'William Faulkner', 'John Steinbeck', 'B', '"The Great Gatsby," written by F. Scott Fitzgerald, explores themes of wealth, ambition, and disillusionment set against the backdrop of the Jazz Age.'
where not exists (
  select 1 from questions where category = 'world_literature' and prompt = 'Which American author wrote "The Great Gatsby," a novel exploring wealth, ambition, and disillusionment in the Jazz Age?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'hard', 'Which Japanese director, known for films like ''Seven Samurai'' and ''Rashomon,'' is considered one of the most influential filmmakers in cinema history?', 'Yasujiro Ozu', 'Akira Kurosawa', 'Hayao Miyazaki', 'Hirokazu Kore-eda', 'B', 'Akira Kurosawa, director of ''Seven Samurai'' and ''Rashomon,'' is widely regarded as one of the most influential filmmakers in the history of cinema.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Which Japanese director, known for films like ''Seven Samurai'' and ''Rashomon,'' is considered one of the most influential filmmakers in cinema history?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'hard', 'Which 1927 German film, directed by Fritz Lang, is considered a landmark of science fiction cinema and expressionist filmmaking?', 'Nosferatu', 'The Cabinet of Dr. Caligari', 'Metropolis', 'M', 'C', '''Metropolis,'' directed by Fritz Lang in 1927, is regarded as a landmark of both science fiction cinema and German Expressionist filmmaking.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Which 1927 German film, directed by Fritz Lang, is considered a landmark of science fiction cinema and expressionist filmmaking?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'hard', 'What is the name of the Italian film movement, emerging after World War II, characterized by stories of ordinary people and real locations?', 'Italian Neorealism', 'Giallo', 'Commedia all''italiana', 'Spaghetti Western (a related but distinct genre)', 'A', 'Italian Neorealism emerged after World War II, emphasizing stories of ordinary people, real locations, and often non-professional actors.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'What is the name of the Italian film movement, emerging after World War II, characterized by stories of ordinary people and real locations?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'hard', 'Which Swedish director, known for films like ''The Seventh Seal'' and ''Wild Strawberries,'' is celebrated for exploring existential themes?', 'Lars von Trier (Danish, not Swedish)', 'Roy Andersson', 'Ingmar Bergman', 'Ruben Ostlund', 'C', 'Ingmar Bergman, a Swedish director, is celebrated for his profound exploration of existential and philosophical themes in films like ''The Seventh Seal.'''
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Which Swedish director, known for films like ''The Seventh Seal'' and ''Wild Strawberries,'' is celebrated for exploring existential themes?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'hard', 'What is the name of the acclaimed South Korean film that won the Palme d''Or at Cannes and later the Academy Award for Best Picture in 2020?', 'Oldboy', 'The Handmaiden', 'Burning', 'Parasite', 'D', '''Parasite,'' directed by Bong Joon-ho, won both the Palme d''Or at Cannes and the Academy Award for Best Picture, a historic first for a non-English film.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'What is the name of the acclaimed South Korean film that won the Palme d''Or at Cannes and later the Academy Award for Best Picture in 2020?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'hard', 'Which French New Wave director is known for pioneering jump cuts and unconventional narrative techniques in films like ''Breathless''?', 'Francois Truffaut', 'Jean-Luc Godard', 'Eric Rohmer', 'Claude Chabrol', 'B', 'Jean-Luc Godard, a key figure of the French New Wave, pioneered innovative techniques like jump cuts, notably in his 1960 film ''Breathless.'''
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Which French New Wave director is known for pioneering jump cuts and unconventional narrative techniques in films like ''Breathless''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'hard', 'What is the name of the acclaimed Iranian director known for films like ''A Separation'' and ''The Salesman,'' both Academy Award winners?', 'Abbas Kiarostami', 'Jafar Panahi', 'Majid Majidi', 'Asghar Farhadi', 'D', 'Asghar Farhadi, an acclaimed Iranian director, won two Academy Awards for Best Foreign Language Film with ''A Separation'' and ''The Salesman.'''
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'What is the name of the acclaimed Iranian director known for films like ''A Separation'' and ''The Salesman,'' both Academy Award winners?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'hard', 'Which Indian film industry, based in Mumbai, is the largest producer of films by volume in the world?', 'Bollywood', 'Tollywood (Telugu cinema, a separate industry)', 'Kollywood (Tamil cinema, a separate industry)', 'Lollywood (Pakistani cinema)', 'A', 'Bollywood, based in Mumbai, is the largest film industry in the world by volume of films produced annually.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Which Indian film industry, based in Mumbai, is the largest producer of films by volume in the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'hard', 'What is the name of the acclaimed Mexican director known for films like ''Roma'' and ''Children of Men,'' who won multiple Academy Awards for directing?', 'Guillermo del Toro', 'Alfonso Cuaron', 'Alejandro Gonzalez Inarritu', 'Carlos Reygadas', 'B', 'Alfonso Cuaron, a Mexican director, won Academy Awards for directing both ''Gravity'' and ''Roma,'' among other acclaimed works.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'What is the name of the acclaimed Mexican director known for films like ''Roma'' and ''Children of Men,'' who won multiple Academy Awards for directing?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'hard', 'Which Hong Kong director is renowned for a distinctive visual and romantic style in films like ''In the Mood for Love'' and ''Chungking Express''?', 'John Woo', 'Ang Lee', 'Wong Kar-wai', 'Tsui Hark', 'C', 'Wong Kar-wai is celebrated for his distinctive, atmospheric visual style, evident in acclaimed films like ''In the Mood for Love'' and ''Chungking Express.'''
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Which Hong Kong director is renowned for a distinctive visual and romantic style in films like ''In the Mood for Love'' and ''Chungking Express''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'hard', 'What is the name of the British television series following the adventures of a time-traveling alien known as ''The Doctor,'' running since 1963?', 'Doctor Who', 'Sherlock', 'Black Mirror', 'Torchwood', 'A', '''Doctor Who,'' first airing in 1963, follows the adventures of a time-traveling alien called the Doctor, and remains one of the longest-running sci-fi series in television history.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'What is the name of the British television series following the adventures of a time-traveling alien known as ''The Doctor,'' running since 1963?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'hard', 'Which Danish television series, remade in the U.S. as ''The Killing,'' is known for its atmospheric, slow-burn crime drama style associated with ''Nordic noir''?', 'Bron/Broen (The Bridge)', 'Forbrydelsen', 'Borgen', 'The Killing (the original refers to Forbrydelsen)', 'B', '''Forbrydelsen'' (The Killing), a Danish crime drama, helped popularize the atmospheric ''Nordic noir'' genre internationally and was later remade for American television.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Which Danish television series, remade in the U.S. as ''The Killing,'' is known for its atmospheric, slow-burn crime drama style associated with ''Nordic noir''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'hard', 'What is the name of the acclaimed Taiwanese director known for films like ''Crouching Tiger, Hidden Dragon'' and ''Brokeback Mountain''?', 'Hou Hsiao-hsien', 'Edward Yang', 'Tsai Ming-liang', 'Ang Lee', 'D', 'Ang Lee, a Taiwanese director, achieved international acclaim with diverse films including ''Crouching Tiger, Hidden Dragon'' and ''Brokeback Mountain,'' winning multiple Academy Awards.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'What is the name of the acclaimed Taiwanese director known for films like ''Crouching Tiger, Hidden Dragon'' and ''Brokeback Mountain''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'hard', 'Which German television series, blending time travel and mystery, gained significant international acclaim on Netflix starting in 2017?', 'Dark', 'Babylon Berlin', 'Deutschland 83', 'How to Sell Drugs Online (Fast)', 'A', '''Dark,'' a German science fiction series blending intricate time travel narratives with mystery, garnered significant international critical acclaim after its 2017 Netflix debut.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Which German television series, blending time travel and mystery, gained significant international acclaim on Netflix starting in 2017?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'hard', 'What is the name of the acclaimed Polish director known for the ''Three Colors'' trilogy, exploring themes of liberty, equality, and fraternity?', 'Roman Polanski', 'Krzysztof Kieslowski', 'Andrzej Wajda', 'Agnieszka Holland', 'B', 'Krzysztof Kieslowski''s acclaimed ''Three Colors'' trilogy (Blue, White, Red) explores the French revolutionary ideals of liberty, equality, and fraternity through interconnected stories.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'What is the name of the acclaimed Polish director known for the ''Three Colors'' trilogy, exploring themes of liberty, equality, and fraternity?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'hard', 'Which Spanish director, known for surreal and provocative films, collaborated with Salvador Dali on the short film ''Un Chien Andalou''?', 'Pedro Almodovar', 'Carlos Saura', 'Victor Erice', 'Luis Bunuel', 'D', 'Luis Bunuel collaborated with artist Salvador Dali on ''Un Chien Andalou'' (1929), a surrealist short film that remains highly influential in avant-garde cinema.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Which Spanish director, known for surreal and provocative films, collaborated with Salvador Dali on the short film ''Un Chien Andalou''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'hard', 'Which Italian director, known for films like "8 1/2" and "La Dolce Vita," is celebrated for his distinctive blend of fantasy and reality?', 'Michelangelo Antonioni', 'Vittorio De Sica', 'Federico Fellini', 'Pier Paolo Pasolini', 'C', 'Federico Fellini, celebrated for films like "8 1/2" and "La Dolce Vita," developed a distinctive cinematic style blending fantastical imagery with realistic settings.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Which Italian director, known for films like "8 1/2" and "La Dolce Vita," is celebrated for his distinctive blend of fantasy and reality?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_movies_tv', 'hard', 'Which acclaimed British television series, created by and starring Phoebe Waller-Bridge, follows a sharp-witted, morally complex protagonist speaking directly to the camera?', 'Fleabag', 'Killing Eve', 'Broadchurch', 'Peaky Blinders', 'A', '"Fleabag," created by and starring Phoebe Waller-Bridge, became critically acclaimed for its sharp writing and distinctive fourth-wall-breaking narrative style.'
where not exists (
  select 1 from questions where category = 'world_movies_tv' and prompt = 'Which acclaimed British television series, created by and starring Phoebe Waller-Bridge, follows a sharp-witted, morally complex protagonist speaking directly to the camera?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'hard', 'Which German composer, deaf by the end of his life, composed the Ninth Symphony featuring the famous ''Ode to Joy'' choral finale?', 'Johann Sebastian Bach', 'Ludwig van Beethoven', 'Wolfgang Amadeus Mozart', 'Johannes Brahms', 'B', 'Ludwig van Beethoven, despite becoming completely deaf, composed his Ninth Symphony, whose final movement features the renowned ''Ode to Joy'' chorus.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'Which German composer, deaf by the end of his life, composed the Ninth Symphony featuring the famous ''Ode to Joy'' choral finale?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'hard', 'What is the name of the Argentine musical genre and dance style, characterized by passionate, close embraces, that originated in Buenos Aires?', 'Salsa', 'Bachata', 'Merengue', 'Tango', 'D', 'Tango, both a music genre and dance style, originated in the working-class neighborhoods of Buenos Aires, Argentina, in the late 19th century.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'What is the name of the Argentine musical genre and dance style, characterized by passionate, close embraces, that originated in Buenos Aires?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'hard', 'Which Jamaican music genre, pioneered by artists like Bob Marley, blends elements of ska and rocksteady with socially conscious lyrics?', 'Dancehall', 'Reggae', 'Ska (a direct precursor, but distinct genre)', 'Dub (a production style derived from reggae)', 'B', 'Reggae, pioneered and popularized globally by artists like Bob Marley, blends ska and rocksteady influences with often socially and politically conscious lyrics.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'Which Jamaican music genre, pioneered by artists like Bob Marley, blends elements of ska and rocksteady with socially conscious lyrics?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'hard', 'What is the name of the traditional Spanish musical and dance art form associated with the Andalusian region, known for its passionate, expressive style?', 'Flamenco', 'Fandango (a related but distinct dance form)', 'Sevillana (a specific flamenco-related dance)', 'Bulería (a specific flamenco rhythm style)', 'A', 'Flamenco, originating in Andalusia, Spain, combines singing, guitar playing, and dance in a passionate and highly expressive traditional art form.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'What is the name of the traditional Spanish musical and dance art form associated with the Andalusian region, known for its passionate, expressive style?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'hard', 'Which Brazilian musical genre, characterized by its syncopated rhythms, became closely associated with the country''s annual Carnival celebrations?', 'Bossa Nova', 'Samba', 'Forro', 'MPB (Musica Popular Brasileira)', 'B', 'Samba, with its distinctive syncopated rhythms, is deeply associated with Brazil''s Carnival celebrations and is considered a national symbol of Brazilian music.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'Which Brazilian musical genre, characterized by its syncopated rhythms, became closely associated with the country''s annual Carnival celebrations?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'hard', 'What is the term for the traditional Indian classical music system, distinct from Carnatic music, primarily practiced in northern India?', 'Carnatic music (the southern Indian tradition)', 'Qawwali (a devotional music genre, not the classical system itself)', 'Hindustani classical music', 'Bhajan (a devotional song form, not the classical system)', 'C', 'Hindustani classical music is the primary classical music tradition of northern India, distinct from Carnatic music practiced in South India.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'What is the term for the traditional Indian classical music system, distinct from Carnatic music, primarily practiced in northern India?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'hard', 'Which African musical style, originating in Congo, is characterized by intricate guitar work and became influential across the continent?', 'Highlife', 'Afrobeat', 'Mbaqanga', 'Soukous', 'D', 'Soukous, originating in the Democratic Republic of Congo, is known for its intricate, fast-paced guitar work and has significantly influenced music across Africa.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'Which African musical style, originating in Congo, is characterized by intricate guitar work and became influential across the continent?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'hard', 'What is the name of the Nigerian musical genre, pioneered by Fela Kuti, that blends jazz, funk, and traditional Yoruba music with political themes?', 'Highlife', 'Juju music', 'Fuji music', 'Afrobeat', 'D', 'Afrobeat, pioneered by Fela Kuti, blends jazz, funk, and traditional Yoruba musical elements, often carrying strong political and social commentary.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'What is the name of the Nigerian musical genre, pioneered by Fela Kuti, that blends jazz, funk, and traditional Yoruba music with political themes?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'hard', 'Which Cuban musical genre, blending Spanish and African influences, became the foundation for salsa music developed later in New York?', 'Rumba (a related but distinct genre)', 'Mambo (a related but distinct genre)', 'Cha-cha-cha (a related but distinct genre)', 'Son cubano', 'D', 'Son cubano, blending Spanish guitar traditions with African rhythmic elements, is considered foundational to the later development of salsa music in New York.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'Which Cuban musical genre, blending Spanish and African influences, became the foundation for salsa music developed later in New York?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'hard', 'What is the term for traditional Australian Aboriginal wind instrument, made from a hollowed eucalyptus branch, producing a distinctive drone sound?', 'Didgeridoo', 'Bullroarer', 'Clapsticks', 'Gumleaf', 'A', 'The didgeridoo, a traditional wind instrument of Aboriginal Australians, produces a distinctive continuous drone sound and is among the world''s oldest musical instruments.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'What is the term for traditional Australian Aboriginal wind instrument, made from a hollowed eucalyptus branch, producing a distinctive drone sound?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'hard', 'Which Korean musical genre, blending pop, hip-hop, and electronic music, achieved massive global popularity in the 2010s and 2020s?', 'K-pop', 'Trot (an older Korean genre)', 'J-pop (a Japanese genre, not Korean)', 'C-pop (a Chinese genre, not Korean)', 'A', 'K-pop, a genre blending pop, hip-hop, and electronic influences, achieved unprecedented global popularity, propelled by groups like BTS and BLACKPINK.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'Which Korean musical genre, blending pop, hip-hop, and electronic music, achieved massive global popularity in the 2010s and 2020s?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'hard', 'What is the term for the traditional Scottish and Irish musical instrument consisting of a bag, chanter, and drones, played by blowing air through a mouthpiece?', 'Fiddle', 'Bodhran (a drum, not a wind instrument)', 'Bagpipes', 'Tin whistle', 'C', 'Bagpipes, featuring a bag, chanter, and drone pipes, are iconic traditional instruments closely associated with Scottish and Irish musical traditions.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'What is the term for the traditional Scottish and Irish musical instrument consisting of a bag, chanter, and drones, played by blowing air through a mouthpiece?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'hard', 'Which West African musical instrument, a hand drum played with bare hands, is central to the traditional music of countries like Guinea and Mali?', 'Kora', 'Djembe', 'Balafon', 'Talking drum', 'B', 'The djembe, a goblet-shaped hand drum, is a central instrument in traditional West African music, particularly in countries like Guinea and Mali.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'Which West African musical instrument, a hand drum played with bare hands, is central to the traditional music of countries like Guinea and Mali?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'hard', 'What is the name of the West African stringed instrument, resembling a harp-lute, traditionally played by Mande griots to accompany storytelling?', 'Djembe', 'Balafon', 'Kora', 'Ngoni', 'C', 'The kora, a harp-lute with numerous strings, is traditionally played by Mande griots (oral historians and musicians) to accompany storytelling and praise singing.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'What is the name of the West African stringed instrument, resembling a harp-lute, traditionally played by Mande griots to accompany storytelling?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'hard', 'Which Portuguese musical genre, characterized by melancholic melodies and themes of longing, is often associated with the concept of ''saudade''?', 'Morna (a related Cape Verdean genre)', 'Flamenco (a Spanish, not Portuguese, genre)', 'Fado', 'Rebetiko (a Greek, not Portuguese, genre)', 'C', 'Fado, a traditional Portuguese musical genre, is characterized by its melancholic tone and themes of longing, deeply connected to the untranslatable concept of ''saudade.'''
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'Which Portuguese musical genre, characterized by melancholic melodies and themes of longing, is often associated with the concept of ''saudade''?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'hard', 'What is the term for the traditional Japanese theatrical art form combining highly stylized music, dance, and drama, developed in the Edo period?', 'Noh (an older, more austere theatrical form)', 'Kabuki', 'Bunraku (puppet theater, a related but distinct art form)', 'Rakugo (a form of comedic storytelling, not theater)', 'B', 'Kabuki is a traditional Japanese theatrical art form combining stylized music, dance, and elaborate drama, which flourished during the Edo period.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'What is the term for the traditional Japanese theatrical art form combining highly stylized music, dance, and drama, developed in the Edo period?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'hard', 'Which traditional Chinese stringed instrument, plucked and having a pear-shaped body, is one of the most recognizable instruments in Chinese classical music?', 'Pipa', 'Guzheng', 'Erhu (a bowed, not plucked, instrument)', 'Yangqin (a hammered dulcimer, not plucked by fingers in the traditional sense)', 'A', 'The pipa, a plucked, pear-shaped lute, is one of the most recognizable and historically significant instruments in traditional Chinese music.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'Which traditional Chinese stringed instrument, plucked and having a pear-shaped body, is one of the most recognizable instruments in Chinese classical music?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_music', 'hard', 'Which Greek musical genre, associated with urban subcultures and often compared to blues for its themes of hardship, emerged in the early 20th century?', 'Rebetiko', 'Laiko (a later, related genre)', 'Nisiotika (island folk music, a distinct genre)', 'Dimotiko (rural folk music, a distinct genre)', 'A', 'Rebetiko emerged in early 20th-century Greece among urban subcultures, often compared to blues music for its themes of hardship, love, and social marginalization.'
where not exists (
  select 1 from questions where category = 'world_music' and prompt = 'Which Greek musical genre, associated with urban subcultures and often compared to blues for its themes of hardship, emerged in the early 20th century?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'hard', 'Which country has won the most FIFA World Cup titles in men''s football, with five championships as of 2022?', 'Germany', 'Italy', 'Argentina', 'Brazil', 'D', 'Brazil has won the FIFA World Cup a record five times: in 1958, 1962, 1970, 1994, and 2002.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'Which country has won the most FIFA World Cup titles in men''s football, with five championships as of 2022?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'hard', 'What is the term for a perfect score in ten-pin bowling, achieved by rolling twelve consecutive strikes in a single game?', 'A perfect game (300)', 'A turkey (three consecutive strikes)', 'A double (two consecutive strikes)', 'A spare game', 'A', 'A perfect game in ten-pin bowling requires twelve consecutive strikes, resulting in the maximum possible score of 300.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'What is the term for a perfect score in ten-pin bowling, achieved by rolling twelve consecutive strikes in a single game?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'hard', 'Which tennis Grand Slam tournament is played on clay courts and is held annually in Paris, France?', 'Wimbledon', 'The French Open (Roland Garros)', 'The US Open', 'The Australian Open', 'B', 'The French Open, held at Roland Garros in Paris, is the only Grand Slam tennis tournament played on clay courts.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'Which tennis Grand Slam tournament is played on clay courts and is held annually in Paris, France?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'hard', 'What is the maximum number of clubs a golfer is permitted to carry in their bag during a round, according to the Rules of Golf?', '12', '14', '16', '10', 'B', 'The Rules of Golf permit a maximum of 14 clubs to be carried by a player during a round of competitive play.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'What is the maximum number of clubs a golfer is permitted to carry in their bag during a round, according to the Rules of Golf?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'hard', 'Which country has won the most Olympic gold medals in the sport of table tennis since its introduction as an Olympic event in 1988?', 'South Korea', 'Japan', 'Sweden', 'China', 'D', 'China has dominated Olympic table tennis since its introduction in 1988, winning the overwhelming majority of available gold medals.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'Which country has won the most Olympic gold medals in the sport of table tennis since its introduction as an Olympic event in 1988?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'hard', 'What is the term for a score of one under par on a single hole in golf?', 'An eagle', 'A bogey', 'A birdie', 'An albatross', 'C', 'A birdie refers to completing a golf hole in one stroke less than par.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'What is the term for a score of one under par on a single hole in golf?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'hard', 'Which country''s national rugby team is known by the nickname ''the All Blacks,'' famous for performing the haka before matches?', 'Australia', 'South Africa', 'Wales', 'New Zealand', 'D', 'New Zealand''s national rugby union team, the All Blacks, is renowned worldwide, including for performing the traditional Maori haka before matches.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'Which country''s national rugby team is known by the nickname ''the All Blacks,'' famous for performing the haka before matches?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'hard', 'What is the term for the specific swimming stroke characterized by simultaneous arm movements and a whip-like kick, generally the slowest competitive stroke?', 'Breaststroke', 'Butterfly', 'Freestyle (front crawl)', 'Backstroke', 'A', 'Breaststroke, featuring simultaneous frog-like arm and leg movements, is generally the slowest of the four competitive swimming strokes.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'What is the term for the specific swimming stroke characterized by simultaneous arm movements and a whip-like kick, generally the slowest competitive stroke?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'hard', 'Which cycling race, first held in 1903, is considered the most prestigious and one of the most physically demanding annual sporting events in the world?', 'The Giro d''Italia', 'The Vuelta a España', 'The Tour de France', 'Paris-Roubaix', 'C', 'The Tour de France, first held in 1903, is widely regarded as cycling''s most prestigious and grueling annual multi-stage race.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'Which cycling race, first held in 1903, is considered the most prestigious and one of the most physically demanding annual sporting events in the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'hard', 'What is the term for the position in American football responsible for throwing passes and leading the offense?', 'Running back', 'Quarterback', 'Wide receiver', 'Tight end', 'B', 'The quarterback is the offensive player primarily responsible for throwing passes and directing the team''s offensive strategy in American football.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'What is the term for the position in American football responsible for throwing passes and leading the offense?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'hard', 'Which martial art, originating in Brazil and blending Japanese Jiu-Jitsu with local influences, emphasizes ground fighting and submission holds?', 'Capoeira (a distinct Afro-Brazilian art blending dance and combat)', 'Muay Thai (originating in Thailand, not Brazil)', 'Brazilian Jiu-Jitsu', 'Judo (originating in Japan, not Brazil)', 'C', 'Brazilian Jiu-Jitsu developed from Japanese Jiu-Jitsu and Judo, emphasizing ground fighting techniques and submission holds, and became especially influential in mixed martial arts.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'Which martial art, originating in Brazil and blending Japanese Jiu-Jitsu with local influences, emphasizes ground fighting and submission holds?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'hard', 'What is the term for cricket''s rarest and most difficult bowling feat, taking three wickets with three consecutive deliveries?', 'A maiden over', 'A hat-trick', 'A googly (a type of delivery, not an achievement)', 'A yorker (a type of delivery, not an achievement)', 'B', 'A hat-trick in cricket occurs when a bowler dismisses three batsmen with three consecutive deliveries, a rare and celebrated achievement.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'What is the term for cricket''s rarest and most difficult bowling feat, taking three wickets with three consecutive deliveries?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'hard', 'Which country has historically dominated Olympic gymnastics, particularly during the Soviet era and continuing in the post-Soviet period?', 'Russia (and formerly the Soviet Union)', 'China', 'Romania', 'United States', 'A', 'The Soviet Union, and later Russia, has historically dominated Olympic gymnastics, amassing more medals in the sport than any other nation.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'Which country has historically dominated Olympic gymnastics, particularly during the Soviet era and continuing in the post-Soviet period?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'hard', 'What is the term for the specific position in association football responsible primarily for preventing goals by using their hands within the penalty area?', 'Defender', 'Goalkeeper', 'Sweeper (a specific defensive role, not synonymous)', 'Libero (a specific defensive role, similar to sweeper)', 'B', 'The goalkeeper is the only player on a football team permitted to use their hands within the penalty area, tasked primarily with preventing goals.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'What is the term for the specific position in association football responsible primarily for preventing goals by using their hands within the penalty area?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'hard', 'Which Grand Slam tennis tournament, held in England, is the oldest tennis tournament in the world and is played on grass courts?', 'Wimbledon', 'The French Open', 'The US Open', 'The Australian Open', 'A', 'Wimbledon, first held in 1877, is the oldest tennis tournament in the world and remains the only Grand Slam played on grass courts.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'Which Grand Slam tennis tournament, held in England, is the oldest tennis tournament in the world and is played on grass courts?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'hard', 'What is the term for a boxing match ending when a fighter is deemed unable to continue safely, decided by the referee rather than a scorecard?', 'A knockout (KO)', 'A disqualification', 'A no contest', 'A technical knockout (TKO)', 'D', 'A technical knockout occurs when the referee stops a match because a fighter cannot safely continue, distinct from a full knockout where a fighter is rendered unconscious.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'What is the term for a boxing match ending when a fighter is deemed unable to continue safely, decided by the referee rather than a scorecard?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'hard', 'Which country won the inaugural Cricket World Cup in 1975, and has since become one of the sport''s most dominant nations?', 'The West Indies', 'England', 'Australia', 'India', 'A', 'The West Indies won the inaugural Cricket World Cup in 1975, going on to establish themselves as a dominant force in international cricket during that era.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'Which country won the inaugural Cricket World Cup in 1975, and has since become one of the sport''s most dominant nations?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_sports', 'hard', 'Which country has won the most Olympic gold medals in badminton, dominating the sport for much of its Olympic history?', 'Indonesia', 'South Korea', 'China', 'Denmark', 'C', 'China has won more Olympic badminton gold medals than any other nation since the sport''s introduction to the Games in 1992.'
where not exists (
  select 1 from questions where category = 'world_sports' and prompt = 'Which country has won the most Olympic gold medals in badminton, dominating the sport for much of its Olympic history?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'hard', 'Which South Korean technology company is the world''s largest manufacturer of memory chips and smartphones by market share?', 'LG Electronics', 'SK Hynix', 'Samsung Electronics', 'Hyundai', 'C', 'Samsung Electronics is the world''s largest manufacturer of memory chips and, for much of the past decade, has also led global smartphone shipments.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'Which South Korean technology company is the world''s largest manufacturer of memory chips and smartphones by market share?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'hard', 'What is the name of the Taiwanese company that is the world''s largest dedicated semiconductor foundry, manufacturing chips for companies like Apple and Nvidia?', 'TSMC (Taiwan Semiconductor Manufacturing Company)', 'UMC (United Microelectronics Corporation)', 'MediaTek', 'Foxconn', 'A', 'TSMC is the world''s largest dedicated semiconductor foundry, manufacturing chips designed by companies including Apple, Nvidia, and AMD.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'What is the name of the Taiwanese company that is the world''s largest dedicated semiconductor foundry, manufacturing chips for companies like Apple and Nvidia?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'hard', 'Which Finnish company dominated the global mobile phone market in the late 1990s and early 2000s before losing significant market share to smartphone rivals?', 'Ericsson', 'Motorola (American, not Finnish)', 'Nokia', 'Siemens (German, not Finnish)', 'C', 'Nokia dominated global mobile phone sales in the late 1990s and early 2000s, later losing substantial market share as smartphones from Apple and Android manufacturers gained popularity.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'Which Finnish company dominated the global mobile phone market in the late 1990s and early 2000s before losing significant market share to smartphone rivals?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'hard', 'What is the name of the Chinese technology company that became the world''s largest telecommunications equipment manufacturer, facing scrutiny over security concerns in various countries?', 'ZTE', 'Xiaomi', 'Lenovo', 'Huawei', 'D', 'Huawei grew into the world''s largest telecommunications equipment manufacturer, while also facing significant security-related scrutiny and restrictions in several countries.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'What is the name of the Chinese technology company that became the world''s largest telecommunications equipment manufacturer, facing scrutiny over security concerns in various countries?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'hard', 'Which Japanese company, originally a manufacturer of automatic looms, later became a major player in gaming consoles and video game development?', 'Sony', 'Nintendo', 'Sega', 'Bandai Namco', 'B', 'Nintendo began as a manufacturer of automatic looms and playing cards before evolving into one of the world''s leading video game companies.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'Which Japanese company, originally a manufacturer of automatic looms, later became a major player in gaming consoles and video game development?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'hard', 'What is the name of the Estonian-founded peer-to-peer communication service, later acquired by Microsoft, that pioneered widespread video calling?', 'Skype', 'Zoom (founded later, American)', 'WhatsApp (founded later, American, text/voice focused)', 'Viber (Israeli-founded)', 'A', 'Skype, founded by Estonian developers, pioneered widespread accessible video calling before being acquired by Microsoft in 2011.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'What is the name of the Estonian-founded peer-to-peer communication service, later acquired by Microsoft, that pioneered widespread video calling?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'hard', 'Which Chinese e-commerce company, founded by Jack Ma, became one of the largest online marketplaces in the world?', 'JD.com', 'Pinduoduo', 'Tencent (primarily social/gaming, not e-commerce focused originally)', 'Alibaba', 'D', 'Alibaba, founded by Jack Ma in 1999, grew into one of the world''s largest e-commerce and technology conglomerates.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'Which Chinese e-commerce company, founded by Jack Ma, became one of the largest online marketplaces in the world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'hard', 'What is the term for the Indian technology hub, often called the ''Silicon Valley of India,'' known for its concentration of tech companies and startups?', 'Bangalore (Bengaluru)', 'Mumbai', 'Hyderabad (a significant but secondary tech hub)', 'Delhi', 'A', 'Bangalore, officially Bengaluru, is widely known as the ''Silicon Valley of India'' due to its dense concentration of technology companies and startups.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'What is the term for the Indian technology hub, often called the ''Silicon Valley of India,'' known for its concentration of tech companies and startups?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'hard', 'Which Swedish company, founded in 2006, became one of the world''s leading music streaming services?', 'Deezer (French, not Swedish)', 'Spotify', 'SoundCloud (German, not Swedish)', 'Tidal (Norwegian, not Swedish)', 'B', 'Spotify, founded in Sweden in 2006, grew to become one of the world''s leading music streaming platforms.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'Which Swedish company, founded in 2006, became one of the world''s leading music streaming services?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'hard', 'What is the name of the Chinese short-video social media app, developed by ByteDance, that became a global cultural phenomenon in the late 2010s and 2020s?', 'Kuaishou (a related Chinese app, primarily domestic)', 'WeChat (a different type of app, primarily messaging)', 'Weibo (a different type of app, primarily microblogging)', 'TikTok', 'D', 'TikTok, developed by the Chinese company ByteDance, became a massive global phenomenon, particularly popular among younger users worldwide.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'What is the name of the Chinese short-video social media app, developed by ByteDance, that became a global cultural phenomenon in the late 2010s and 2020s?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'hard', 'Which German automotive company has become a significant investor and developer in autonomous driving and electric vehicle technology?', 'Volkswagen Group', 'BMW', 'Mercedes-Benz (Daimler)', 'Porsche', 'A', 'Volkswagen Group has made substantial investments in electric vehicle and autonomous driving technology as part of its broader strategic transformation.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'Which German automotive company has become a significant investor and developer in autonomous driving and electric vehicle technology?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'hard', 'What is the name of the Canadian e-commerce platform company that enables businesses to build and manage online stores?', 'Squarespace (American, not Canadian)', 'BigCommerce (American, not Canadian)', 'Shopify', 'WooCommerce (American, not Canadian)', 'C', 'Shopify, founded in Canada, provides an e-commerce platform allowing businesses of various sizes to build and manage their own online stores.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'What is the name of the Canadian e-commerce platform company that enables businesses to build and manage online stores?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'hard', 'Which Dutch company is one of the world''s leading manufacturers of photolithography systems essential for producing advanced semiconductor chips?', 'NXP Semiconductors (a different type of Dutch semiconductor company)', 'Philips (a broader electronics company, not chip-lithography focused)', 'Besi', 'ASML', 'D', 'ASML, based in the Netherlands, is the world''s leading manufacturer of extreme ultraviolet lithography machines essential for producing the most advanced semiconductor chips.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'Which Dutch company is one of the world''s leading manufacturers of photolithography systems essential for producing advanced semiconductor chips?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'hard', 'What is the name of the Israeli cybersecurity company known for developing enterprise firewall and network security technology, founded in 1993?', 'CyberArk', 'Wix (an unrelated website-building company)', 'Check Point Software Technologies', 'NSO Group (a controversial spyware company, different focus)', 'C', 'Check Point Software Technologies, founded in Israel in 1993, is a major cybersecurity company known for pioneering enterprise firewall technology.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'What is the name of the Israeli cybersecurity company known for developing enterprise firewall and network security technology, founded in 1993?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'hard', 'Which Chinese company, founded by Pony Ma, operates the massive WeChat ''super app'' combining messaging, payments, and social media?', 'Alibaba', 'Tencent', 'Baidu (primarily search-focused, not messaging)', 'ByteDance', 'B', 'Tencent, founded by Pony Ma, operates WeChat, a ''super app'' combining messaging, mobile payments, social media, and numerous other services widely used across China.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'Which Chinese company, founded by Pony Ma, operates the massive WeChat ''super app'' combining messaging, payments, and social media?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'hard', 'What is the name of the South Korean conglomerate, alongside Samsung, that produces a significant share of the world''s memory chips and consumer electronics?', 'SK Hynix', 'LG Electronics', 'Hyundai', 'Kakao (primarily a services company, not a major chip manufacturer)', 'A', 'SK Hynix, alongside Samsung, is one of the two dominant South Korean manufacturers of memory chips used globally in electronics and computing devices.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'What is the name of the South Korean conglomerate, alongside Samsung, that produces a significant share of the world''s memory chips and consumer electronics?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'hard', 'Which Japanese technology and entertainment company owns major franchises including PlayStation, and has diversified across electronics, gaming, and media?', 'Nintendo', 'Sony', 'Panasonic', 'Toshiba', 'B', 'Sony, a major Japanese conglomerate, owns the PlayStation gaming brand alongside extensive holdings across consumer electronics, film, and music.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'Which Japanese technology and entertainment company owns major franchises including PlayStation, and has diversified across electronics, gaming, and media?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'world_technology', 'hard', 'Which Indian conglomerate, led by Mukesh Ambani, operates Jio, one of the largest telecommunications and digital services providers in India?', 'Tata Group', 'Reliance Industries', 'Infosys', 'Wipro', 'B', 'Reliance Industries, led by Mukesh Ambani, operates Jio, which rapidly became one of India''s largest telecommunications and digital services providers after its 2016 launch.'
where not exists (
  select 1 from questions where category = 'world_technology' and prompt = 'Which Indian conglomerate, led by Mukesh Ambani, operates Jio, one of the largest telecommunications and digital services providers in India?'
);
