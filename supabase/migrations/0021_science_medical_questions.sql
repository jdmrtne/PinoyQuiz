-- Pinoy Quiz — 0021: Science + Medical categories, 100 new questions
--
-- Adds 100 new, English-language, general-knowledge questions across the
-- 2 new categories added in 0020_science_medical_categories.sql:
--   science  -- 50 questions: 10 each of Biology, Chemistry, Physics,
--               Earth Science, and Astronomy
--   medical  -- 50 questions: 10 each of Anatomy, Physiology,
--               Microbiology, Pathology, and Pharmacology
-- Difficulty split (both categories combined): 30 easy / 44 medium / 26 hard,
-- approximating the requested 30/45/25 target.
--
-- Unlike 0019's Philippines-focused expansion, these questions are
-- deliberately general (globally-established science/medical knowledge, not
-- Philippines-scoped) since no existing category fit. Every question was
-- checked against the full existing question bank (seed + 0019) for topic
-- and prompt overlap before being written — none was found, since the
-- existing 280 questions are all Philippines-specific (culture, geography,
-- history, Filipino scientists/inventors, etc.), not general science/medical
-- fact recall. All 100 prompts below are also unique against each other.
--
-- Medical questions are deliberately non-diagnostic and non-clinical:
-- objective anatomy/physiology/microbiology/pathology/pharmacology facts
-- only, no patient scenarios, personalized advice, or contested claims.
-- Every question has exactly one objectively correct, well-established
-- answer and four same-domain (non-absurd) distractors.
--
-- Must run after 0020_science_medical_categories.sql has committed (same
-- enum-then-insert ordering constraint 0018/0019 documented).
--
-- Idempotency: matches 0019's approach — a NOT EXISTS guard per row on
-- (category, prompt), since `questions` has no natural unique key on
-- content. Safe to run more than once without inserting duplicates.

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'easy', 'Which organelle is known as the "powerhouse of the cell" because it generates most of the cell''s usable energy (ATP)?', 'Mitochondrion', 'Nucleus', 'Ribosome', 'Golgi apparatus', 'A', 'Mitochondria convert nutrients into ATP through cellular respiration, earning them the nickname "powerhouse of the cell."'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Which organelle is known as the "powerhouse of the cell" because it generates most of the cell''s usable energy (ATP)?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'easy', 'How many chromosomes are present in a normal human somatic (body) cell?', '23', '44', '46', '48', 'C', 'A typical human somatic cell contains 46 chromosomes, arranged in 23 pairs.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'How many chromosomes are present in a normal human somatic (body) cell?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'easy', 'Which blood cells are primarily responsible for carrying oxygen throughout the body?', 'Red blood cells', 'White blood cells', 'Platelets', 'Plasma cells', 'A', 'Red blood cells contain hemoglobin, a protein that binds oxygen and transports it from the lungs to body tissues.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Which blood cells are primarily responsible for carrying oxygen throughout the body?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'medium', 'Charles Darwin proposed that species change over generations mainly through which process?', 'Natural selection', 'Genetic engineering', 'Spontaneous generation', 'Use and disuse of organs', 'A', 'Darwin''s theory holds that individuals with traits better suited to their environment are more likely to survive and reproduce, passing those traits on.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Charles Darwin proposed that species change over generations mainly through which process?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'medium', 'In an ecosystem, organisms that produce their own food using sunlight are classified as what?', 'Producers', 'Primary consumers', 'Decomposers', 'Secondary consumers', 'A', 'Producers, such as green plants and algae, use photosynthesis to convert sunlight into chemical energy, forming the base of most food chains.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'In an ecosystem, organisms that produce their own food using sunlight are classified as what?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'medium', 'Why are viruses generally not classified as independently living organisms?', 'They cannot reproduce on their own and need a host cell''s machinery to replicate', 'They are too small to be seen with any microscope', 'They do not contain any genetic material', 'They can only exist inside plant cells', 'A', 'Viruses lack the cellular machinery to reproduce independently, so they must hijack a host cell''s systems to make copies of themselves.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Why are viruses generally not classified as independently living organisms?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'medium', 'Which animal group is characterized by an aquatic, gill-breathing larval stage that typically metamorphoses into a lung-breathing, land-capable adult?', 'Amphibians', 'Reptiles', 'Birds', 'Mammals', 'A', 'Amphibians such as frogs typically hatch as aquatic larvae (like tadpoles) and undergo metamorphosis into air-breathing adults.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Which animal group is characterized by an aquatic, gill-breathing larval stage that typically metamorphoses into a lung-breathing, land-capable adult?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'medium', 'What is the primary function of stomata found on plant leaves?', 'Regulating gas exchange and water loss', 'Storing genetic material', 'Producing chlorophyll', 'Transporting sugars exclusively', 'A', 'Stomata are tiny pores that open and close to control the intake of carbon dioxide, release of oxygen, and loss of water vapor.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'What is the primary function of stomata found on plant leaves?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'hard', 'In a genetic cross between two heterozygous parents for a single gene with complete dominance (Aa x Aa), what phenotype ratio is expected in the offspring?', '3 dominant : 1 recessive', '1 dominant : 1 recessive', '9:3:3:1', '1 dominant : 2 heterozygous : 1 recessive', 'A', 'A monohybrid Aa x Aa cross produces a 1:2:1 genotype ratio (AA:Aa:aa), which yields a 3:1 phenotype ratio when the A allele is completely dominant.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'In a genetic cross between two heterozygous parents for a single gene with complete dominance (Aa x Aa), what phenotype ratio is expected in the offspring?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'hard', 'In human cell division for growth and repair, which process produces two genetically identical daughter cells with the same chromosome number as the parent cell?', 'Mitosis', 'Meiosis', 'Binary fission', 'Fertilization', 'A', 'Mitosis divides one cell into two daughter cells that are genetically identical to the parent and each other, maintaining the chromosome number.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'In human cell division for growth and repair, which process produces two genetically identical daughter cells with the same chromosome number as the parent cell?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'easy', 'What is the chemical symbol for gold?', 'Au', 'Ag', 'Gd', 'Go', 'A', 'Gold''s chemical symbol, Au, comes from its Latin name "aurum."'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'What is the chemical symbol for gold?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'easy', 'Which subatomic particle carries a negative electric charge?', 'Proton', 'Neutron', 'Electron', 'Positron', 'C', 'Electrons orbit the nucleus and carry a negative charge, balancing the positive charge of protons in a neutral atom.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Which subatomic particle carries a negative electric charge?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'easy', 'On the pH scale, a solution with a pH of 7 is considered to be what?', 'Neutral', 'Strongly acidic', 'Strongly basic', 'Radioactive', 'A', 'A pH of 7, like pure water, is neither acidic nor basic and is defined as neutral on the 0–14 pH scale.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'On the pH scale, a solution with a pH of 7 is considered to be what?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'medium', 'What type of chemical bond forms when two atoms share a pair of electrons?', 'Covalent bond', 'Ionic bond', 'Metallic bond', 'Hydrogen bond', 'A', 'In a covalent bond, atoms share electrons to achieve a more stable electron configuration, as seen in molecules like water and methane.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'What type of chemical bond forms when two atoms share a pair of electrons?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'medium', 'Which of the following substances is classified as a base rather than an acid?', 'Sodium hydroxide (NaOH)', 'Hydrochloric acid (HCl)', 'Acetic acid', 'Sulfuric acid', 'A', 'Sodium hydroxide releases hydroxide ions (OH-) in water and has a pH above 7, making it a base, unlike the other three listed acids.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Which of the following substances is classified as a base rather than an acid?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'medium', 'Elements in the same vertical column (group) of the periodic table generally share what property?', 'A similar number of valence electrons and similar chemical behavior', 'Identical atomic mass', 'Identical number of neutrons', 'Identical melting points', 'A', 'Elements in the same group have the same number of valence electrons, which gives them similar chemical reactivity and properties.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Elements in the same vertical column (group) of the periodic table generally share what property?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'medium', 'What is produced when an acid reacts with a base in a neutralization reaction?', 'A salt and water', 'Only a gas', 'Only a pure metal', 'A new, stronger acid', 'A', 'In a neutralization reaction, the hydrogen ions from the acid combine with the hydroxide ions from the base to form water, while the remaining ions form a salt.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'What is produced when an acid reacts with a base in a neutralization reaction?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'hard', 'A neutral atom of carbon-12 has 6 protons. How many neutrons does it contain?', '6', '12', '8', '18', 'A', 'The mass number (12) equals the number of protons plus neutrons. Subtracting the 6 protons leaves 6 neutrons.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'A neutral atom of carbon-12 has 6 protons. How many neutrons does it contain?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'hard', 'What term describes atoms of the same element that have the same number of protons but different numbers of neutrons?', 'Isotopes', 'Isomers', 'Ions', 'Allotropes', 'A', 'Isotopes share the same atomic number (proton count) but differ in mass number due to a different number of neutrons, such as carbon-12 and carbon-14.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'What term describes atoms of the same element that have the same number of protons but different numbers of neutrons?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'hard', 'In organic chemistry, what is the general term for a hydrocarbon that contains at least one carbon-carbon double bond?', 'Alkene', 'Alkane', 'Alkyne', 'Alcohol', 'A', 'Alkenes are hydrocarbons defined by having one or more carbon-carbon double bonds, distinguishing them from alkanes, which have only single bonds.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'In organic chemistry, what is the general term for a hydrocarbon that contains at least one carbon-carbon double bond?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'easy', 'What is the SI (International System) unit of force?', 'Newton', 'Joule', 'Watt', 'Pascal', 'A', 'The newton, named after Isaac Newton, is the SI unit of force, defined as the force needed to accelerate one kilogram at one meter per second squared.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'What is the SI (International System) unit of force?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'easy', 'Which of the following best describes an object''s velocity?', 'Its speed in a specific direction', 'Its mass multiplied by acceleration only', 'The rate of change of its acceleration', 'The total distance traveled regardless of direction', 'A', 'Velocity is a vector quantity describing both how fast an object is moving and the direction of that motion, unlike speed, which is direction-independent.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Which of the following best describes an object''s velocity?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'easy', 'Which form of energy is stored in an object due to its position, such as a ball held above the ground?', 'Gravitational potential energy', 'Kinetic energy', 'Thermal energy', 'Electrical energy', 'A', 'Gravitational potential energy depends on an object''s height and mass; it is converted into kinetic energy as the object falls.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Which form of energy is stored in an object due to its position, such as a ball held above the ground?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'medium', 'According to Newton''s Third Law of Motion, when one object exerts a force on a second object, what happens?', 'The second object exerts an equal and opposite force back on the first', 'The second object always accelerates faster than the first', 'No reaction force occurs unless the objects are the same size', 'The first object loses all of its momentum instantly', 'A', 'Newton''s Third Law states that for every action force, there is an equal and opposite reaction force acting on the other object.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'According to Newton''s Third Law of Motion, when one object exerts a force on a second object, what happens?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'medium', 'Sound waves are an example of which type of wave, in which particles oscillate in the same direction the wave travels?', 'Longitudinal wave', 'Transverse wave', 'Electromagnetic wave', 'Standing wave only', 'A', 'In a longitudinal wave like sound, particles of the medium vibrate back and forth parallel to the direction the wave is traveling.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Sound waves are an example of which type of wave, in which particles oscillate in the same direction the wave travels?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'medium', 'What generally happens to the electrical resistance of a typical metallic conductor as its temperature increases?', 'Resistance generally increases', 'Resistance generally drops to zero', 'Resistance is completely unaffected by temperature', 'Current increases without limit', 'A', 'As a metal heats up, increased atomic vibration disrupts electron flow more, which generally raises the conductor''s electrical resistance.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'What generally happens to the electrical resistance of a typical metallic conductor as its temperature increases?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'medium', 'Which law states that the total energy of an isolated system remains constant, even as it changes from one form to another?', 'The law of conservation of energy', 'Newton''s First Law', 'Ohm''s Law', 'The law of universal gravitation', 'A', 'The law of conservation of energy states energy cannot be created or destroyed, only transformed, such as potential energy converting to kinetic energy.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Which law states that the total energy of an isolated system remains constant, even as it changes from one form to another?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'hard', 'If a 2 kg object accelerates at 3 m/s^2, what net force (in newtons) is acting on it, using Newton''s Second Law (F = m x a)?', '6 N', '1.5 N', '5 N', '9 N', 'A', 'Newton''s Second Law states force equals mass times acceleration: F = 2 kg x 3 m/s^2 = 6 newtons.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'If a 2 kg object accelerates at 3 m/s^2, what net force (in newtons) is acting on it, using Newton''s Second Law (F = m x a)?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'hard', 'What phenomenon explains why a magnetic field forms around a wire that is carrying an electric current?', 'Electromagnetism, the relationship between electric current and magnetic fields', 'Static friction between charges', 'Radioactive decay of the wire''s atoms', 'Nuclear fusion occurring within the wire', 'A', 'Electromagnetism describes how moving electric charges (current) generate a magnetic field, a principle used in electromagnets and motors.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'What phenomenon explains why a magnetic field forms around a wire that is carrying an electric current?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'hard', 'In thermodynamics, what does the Second Law state about the total entropy of an isolated system over time?', 'It tends to increase or, at best, stay the same, but never decrease', 'It always decreases over time', 'It stays exactly constant in every real-world process', 'It always becomes negative', 'A', 'The Second Law of Thermodynamics states that the total entropy (disorder) of an isolated system never decreases over time in natural processes.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'In thermodynamics, what does the Second Law state about the total entropy of an isolated system over time?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'easy', 'What is the name of Earth''s outermost solid layer, on which continents and ocean basins sit?', 'Crust', 'Mantle', 'Outer core', 'Inner core', 'A', 'The crust is Earth''s thin, rigid outermost layer, forming both the continents and the ocean floor.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'What is the name of Earth''s outermost solid layer, on which continents and ocean basins sit?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'easy', 'Which type of rock forms from the cooling and solidification of molten magma or lava?', 'Igneous rock', 'Sedimentary rock', 'Metamorphic rock', 'Organic rock', 'A', 'Igneous rocks, such as granite and basalt, crystallize directly from cooling molten rock material.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Which type of rock forms from the cooling and solidification of molten magma or lava?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'easy', 'Which kind of scale, such as the Richter scale, is used to measure the magnitude of an earthquake?', 'A magnitude scale', 'The Beaufort scale', 'The Fujita scale', 'The pH scale', 'A', 'Earthquake magnitude scales, historically including the Richter scale, quantify the energy released at an earthquake''s source.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Which kind of scale, such as the Richter scale, is used to measure the magnitude of an earthquake?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'medium', 'What is the primary driving force behind the slow movement of Earth''s tectonic plates over geological time?', 'Convection currents in the mantle', 'Ocean tides', 'Earth''s rotation alone', 'The moon''s gravitational pull on rock layers', 'A', 'Heat from Earth''s interior drives convection currents in the mantle, which slowly move the rigid tectonic plates riding above it.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'What is the primary driving force behind the slow movement of Earth''s tectonic plates over geological time?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'medium', 'Which type of tectonic plate boundary is most associated with the formation of new oceanic crust as plates move apart?', 'Divergent boundary', 'Convergent boundary', 'Transform boundary', 'Passive boundary', 'A', 'At divergent boundaries, plates move apart and magma rises to fill the gap, creating new oceanic crust, as seen at mid-ocean ridges.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Which type of tectonic plate boundary is most associated with the formation of new oceanic crust as plates move apart?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'medium', 'Volcanoes most commonly form in which of the following tectonic settings?', 'Along convergent plate boundaries and over hotspots', 'Only in the exact center of continents, far from any plate boundary', 'Only along transform boundaries', 'Only in locations with no connection to plate tectonics', 'A', 'Most volcanoes occur at convergent boundaries, where one plate is forced beneath another, or over hotspots of rising magma such as Hawaii.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Volcanoes most commonly form in which of the following tectonic settings?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'medium', 'Which layer of the atmosphere, closest to Earth''s surface, is where most weather phenomena occur?', 'Troposphere', 'Stratosphere', 'Mesosphere', 'Thermosphere', 'A', 'The troposphere is the lowest atmospheric layer, containing most of the atmosphere''s water vapor and where clouds, storms, and weather form.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Which layer of the atmosphere, closest to Earth''s surface, is where most weather phenomena occur?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'hard', 'What is the key distinction between climate and weather?', 'Climate describes long-term average atmospheric patterns, while weather describes short-term atmospheric conditions', 'Climate refers only to daily temperature readings', 'Weather refers only to precipitation trends measured over decades', 'There is no meaningful scientific distinction between the two', 'A', 'Weather describes atmospheric conditions over hours or days, while climate refers to long-term average patterns in a region over decades.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'What is the key distinction between climate and weather?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'hard', 'Metamorphic rocks form primarily through which process?', 'Existing rock is transformed by heat and pressure without fully melting', 'Cooling of molten lava at Earth''s surface', 'Compaction and cementation of loose sediment alone', 'Rapid crystallization directly from evaporating seawater', 'A', 'Metamorphic rocks form when existing rock is subjected to intense heat and pressure underground, altering its structure without complete melting.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Metamorphic rocks form primarily through which process?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'hard', 'Which of Earth''s interior layers is believed to generate Earth''s magnetic field, through the movement of molten iron and nickel?', 'Outer core', 'Inner core', 'Mantle', 'Crust', 'A', 'Convective movement of liquid iron and nickel in the outer core is thought to generate Earth''s magnetic field through a process called the geodynamo.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Which of Earth''s interior layers is believed to generate Earth''s magnetic field, through the movement of molten iron and nickel?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'easy', 'Which planet in our solar system is popularly known as the "Red Planet"?', 'Mars', 'Venus', 'Jupiter', 'Mercury', 'A', 'Mars appears reddish due to iron oxide (rust) covering much of its surface, earning it the nickname "Red Planet."'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Which planet in our solar system is popularly known as the "Red Planet"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'easy', 'What is the name of the natural satellite that orbits Earth?', 'The Moon', 'Titan', 'Europa', 'Phobos', 'A', 'The Moon is Earth''s only natural satellite, while Titan, Europa, and Phobos orbit other planets.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'What is the name of the natural satellite that orbits Earth?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'easy', 'Which celestial object sits at the center of our solar system, providing light and heat to the planets?', 'The Sun', 'The Moon', 'Jupiter', 'Polaris', 'A', 'The Sun is the star at the center of our solar system, and its gravity keeps the planets, including Earth, in orbit around it.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Which celestial object sits at the center of our solar system, providing light and heat to the planets?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'medium', 'Which planet in our solar system is the largest by both mass and diameter?', 'Jupiter', 'Saturn', 'Neptune', 'Earth', 'A', 'Jupiter is the largest planet in the solar system, with a mass more than twice that of all other planets combined.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Which planet in our solar system is the largest by both mass and diameter?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'medium', 'What primarily causes the changing phases of the Moon as seen from Earth?', 'The changing relative positions of the Sun, Earth, and Moon', 'The Moon spinning rapidly on its own axis', 'Earth''s shadow permanently covering part of the Moon', 'Clouds forming on the Moon''s surface', 'A', 'As the Moon orbits Earth, the portion of its sunlit side visible from Earth changes, producing the cycle of phases.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'What primarily causes the changing phases of the Moon as seen from Earth?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'medium', 'Which force is primarily responsible for keeping planets in orbit around the Sun?', 'Gravity', 'Magnetism', 'Nuclear force', 'Friction', 'A', 'The Sun''s gravitational pull continuously acts on the planets, curving their paths into stable orbits rather than allowing them to fly off in a straight line.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Which force is primarily responsible for keeping planets in orbit around the Sun?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'medium', 'What is a galaxy, in astronomical terms?', 'A massive, gravitationally bound system of stars, gas, dust, and dark matter', 'A single, extremely large star', 'A cluster of asteroids orbiting within one solar system', 'A type of nebula found only within our own solar system', 'A', 'Galaxies are enormous collections of stars, gas, dust, and other matter held together by gravity, with our own galaxy being the Milky Way.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'What is a galaxy, in astronomical terms?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'medium', 'Which of the following best describes a light-year?', 'A unit of distance equal to how far light travels in one year', 'A unit of time equal to one Earth year', 'A measurement of how bright a star appears', 'A unit used only to measure the length of a planet''s orbit', 'A', 'Despite its name, a light-year is a unit of distance: the distance light travels through a vacuum in one year, used to measure vast astronomical distances.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Which of the following best describes a light-year?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'hard', 'Why do astronauts aboard the International Space Station experience apparent weightlessness while orbiting Earth?', 'They and the station are in continuous free fall around Earth, so it feels weightless even though gravity still acts on them', 'There is no gravity at the station''s altitude', 'The station''s engines actively cancel out gravity', 'They are far enough from Earth that gravity no longer has any effect', 'A', 'The ISS and everything inside it are constantly falling toward Earth under gravity while also moving forward fast enough to continually "miss" the planet, producing a sensation of weightlessness called microgravity.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'Why do astronauts aboard the International Space Station experience apparent weightlessness while orbiting Earth?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'science', 'hard', 'What is the currently most widely accepted scientific model describing the origin and expansion of the universe?', 'The Big Bang theory', 'The Steady State theory', 'The geocentric model', 'The static universe theory', 'A', 'The Big Bang theory, supported by evidence such as cosmic microwave background radiation and the observed expansion of the universe, is the leading scientific model for the universe''s origin.'
where not exists (
  select 1 from questions where category = 'science' and prompt = 'What is the currently most widely accepted scientific model describing the origin and expansion of the universe?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'easy', 'Which organ is primarily responsible for pumping blood throughout the human body?', 'Heart', 'Liver', 'Kidney', 'Pancreas', 'A', 'The heart is a muscular organ that contracts rhythmically to pump blood through the circulatory system, delivering oxygen and nutrients to tissues.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which organ is primarily responsible for pumping blood throughout the human body?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'easy', 'Which body system includes the bones and joints, providing structural support and protection for internal organs?', 'Skeletal system', 'Muscular system', 'Nervous system', 'Endocrine system', 'A', 'The skeletal system is made up of bones and joints that support the body, protect organs, and serve as attachment points for muscles.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which body system includes the bones and joints, providing structural support and protection for internal organs?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'easy', 'Which pair of organs is the primary site of gas exchange between the air and the bloodstream?', 'Lungs', 'Heart', 'Liver', 'Stomach', 'A', 'The lungs contain millions of tiny air sacs called alveoli, where oxygen enters the blood and carbon dioxide is released to be exhaled.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which pair of organs is the primary site of gas exchange between the air and the bloodstream?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'medium', 'Which chamber of the heart pumps oxygen-rich blood out to the rest of the body through the aorta?', 'Left ventricle', 'Right atrium', 'Right ventricle', 'Left atrium', 'A', 'The left ventricle has the thickest, most muscular wall of the heart''s four chambers because it must generate enough pressure to pump oxygenated blood through the aorta to the entire body.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which chamber of the heart pumps oxygen-rich blood out to the rest of the body through the aorta?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'medium', 'Which bone is widely recognized as the longest bone in the human body?', 'Femur', 'Humerus', 'Tibia', 'Fibula', 'A', 'The femur, or thigh bone, is the longest and strongest bone in the human skeleton.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which bone is widely recognized as the longest bone in the human body?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'medium', 'Which part of the brain is primarily responsible for coordinating balance and fine-tuning voluntary muscle movements?', 'Cerebellum', 'Cerebrum', 'Medulla oblongata', 'Hypothalamus', 'A', 'The cerebellum, located at the back of the brain, coordinates muscle movement, posture, and balance.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which part of the brain is primarily responsible for coordinating balance and fine-tuning voluntary muscle movements?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'medium', 'Which organ system includes the esophagus, stomach, and intestines, and is primarily responsible for breaking down food?', 'Digestive system', 'Respiratory system', 'Urinary system', 'Endocrine system', 'A', 'The digestive system processes food mechanically and chemically as it passes through the esophagus, stomach, and intestines, absorbing nutrients along the way.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which organ system includes the esophagus, stomach, and intestines, and is primarily responsible for breaking down food?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'medium', 'Which endocrine gland, located in the neck, produces hormones that help regulate the body''s metabolic rate?', 'Thyroid gland', 'Adrenal gland', 'Pituitary gland', 'Pancreas', 'A', 'The thyroid gland, located in the front of the neck, produces hormones such as thyroxine that regulate how the body uses energy.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which endocrine gland, located in the neck, produces hormones that help regulate the body''s metabolic rate?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'hard', 'Which structure connects muscle to bone, transmitting the force needed for movement?', 'Tendon', 'Ligament', 'Cartilage', 'Synovial membrane', 'A', 'Tendons are tough, fibrous connective tissue that attach muscles to bones; ligaments, by contrast, connect bone to bone.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which structure connects muscle to bone, transmitting the force needed for movement?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'hard', 'Which cranial nerve is primarily responsible for controlling most of the muscles used for facial expression?', 'Facial nerve (cranial nerve VII)', 'Trigeminal nerve (cranial nerve V)', 'Vagus nerve (cranial nerve X)', 'Optic nerve (cranial nerve II)', 'A', 'The facial nerve (cranial nerve VII) innervates the muscles responsible for facial expressions, such as smiling and closing the eyes.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which cranial nerve is primarily responsible for controlling most of the muscles used for facial expression?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'easy', 'What is the approximate normal resting heart rate range for a healthy adult, in beats per minute?', 'About 60 to 100 bpm', 'About 150 to 200 bpm', 'About 20 to 40 bpm', 'About 250 to 300 bpm', 'A', 'A healthy adult''s resting heart rate typically falls between 60 and 100 beats per minute, though it varies with fitness level and other factors.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'What is the approximate normal resting heart rate range for a healthy adult, in beats per minute?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'easy', 'Which process describes the exchange of oxygen and carbon dioxide between the lungs and the bloodstream?', 'Respiration (gas exchange)', 'Digestion', 'Filtration', 'Peristalsis', 'A', 'During respiration, oxygen diffuses from the air in the lungs into the blood, while carbon dioxide diffuses from the blood into the lungs to be exhaled.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which process describes the exchange of oxygen and carbon dioxide between the lungs and the bloodstream?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'easy', 'What is the primary function of the kidneys in the human body?', 'Filtering waste products and excess substances from the blood to form urine', 'Pumping blood throughout the body', 'Producing digestive enzymes exclusively', 'Storing oxygen for later use', 'A', 'The kidneys filter blood continuously, removing metabolic waste and excess water and electrolytes, which are excreted as urine.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'What is the primary function of the kidneys in the human body?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'medium', 'What term describes the body''s ability to maintain a stable, balanced internal environment despite changes in the outside world?', 'Homeostasis', 'Metabolism', 'Osmosis', 'Adaptation', 'A', 'Homeostasis refers to the body''s regulatory processes, such as controlling temperature and blood glucose, that keep internal conditions stable.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'What term describes the body''s ability to maintain a stable, balanced internal environment despite changes in the outside world?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'medium', 'Insulin, a hormone produced by the pancreas, primarily functions to do what?', 'Lower blood glucose levels by promoting its uptake into cells', 'Raise blood glucose levels exclusively', 'Directly regulate heart rate', 'Control the sleep-wake cycle', 'A', 'Insulin allows cells to take up glucose from the bloodstream for energy or storage, which lowers blood glucose levels after eating.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Insulin, a hormone produced by the pancreas, primarily functions to do what?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'medium', 'During digestion, where does most nutrient absorption into the bloodstream primarily occur?', 'Small intestine', 'Stomach', 'Large intestine', 'Esophagus', 'A', 'The small intestine''s highly folded, villus-lined walls provide a large surface area where most digested nutrients are absorbed into the blood.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'During digestion, where does most nutrient absorption into the bloodstream primarily occur?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'medium', 'Which type of blood vessel typically carries blood away from the heart to the rest of the body?', 'Arteries', 'Veins', 'Capillaries', 'Lymph vessels', 'A', 'Arteries carry blood away from the heart, generally under higher pressure, while veins return blood back toward the heart.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which type of blood vessel typically carries blood away from the heart to the rest of the body?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'medium', 'What is the primary role of hemoglobin found within red blood cells?', 'Binding to and transporting oxygen throughout the body', 'Fighting off infections', 'Clotting blood at a wound site', 'Producing antibodies', 'A', 'Hemoglobin is an iron-containing protein in red blood cells that binds oxygen in the lungs and releases it to tissues throughout the body.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'What is the primary role of hemoglobin found within red blood cells?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'hard', 'Rising carbon dioxide levels (and falling pH) in the blood primarily trigger increased breathing rate through which mechanism?', 'Chemoreceptors detecting the change and stimulating the brain''s respiratory centers', 'Receptors that detect a drop in body temperature', 'Stretching of the stomach lining after a meal', 'A drop in blood pressure alone', 'A', 'Chemoreceptors sensitive to blood carbon dioxide and pH levels signal the brainstem''s respiratory centers to increase the rate and depth of breathing.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Rising carbon dioxide levels (and falling pH) in the blood primarily trigger increased breathing rate through which mechanism?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'hard', 'Which division of the nervous system primarily controls involuntary functions such as heart rate, digestion, and breathing rate, largely outside conscious control?', 'The autonomic nervous system', 'The somatic nervous system', 'The central nervous system exclusively', 'Peripheral sensory nerves only', 'A', 'The autonomic nervous system regulates involuntary bodily functions like heart rate and digestion, operating largely without conscious control, unlike the somatic nervous system, which governs voluntary movement.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which division of the nervous system primarily controls involuntary functions such as heart rate, digestion, and breathing rate, largely outside conscious control?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'easy', 'Which of the following is a single-celled microorganism that can be either helpful, such as in digestion, or harmful, such as causing infections?', 'Bacteria', 'Antibodies', 'Hormones', 'Neurons', 'A', 'Bacteria are single-celled microorganisms; some species aid digestion or produce useful substances, while others cause infections.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which of the following is a single-celled microorganism that can be either helpful, such as in digestion, or harmful, such as causing infections?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'easy', 'Antibiotics are specifically designed to treat infections caused by which type of pathogen?', 'Bacteria', 'Viruses', 'Prions', 'All pathogen types equally', 'A', 'Antibiotics target structures and processes specific to bacterial cells, such as cell walls, and are not effective against viruses.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Antibiotics are specifically designed to treat infections caused by which type of pathogen?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'easy', 'Which term describes an organism that lives on or inside a host and benefits at the host''s expense?', 'Parasite', 'Producer', 'Decomposer', 'Predator', 'A', 'A parasite obtains nutrients or other resources from a host organism, often causing the host harm in the process.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which term describes an organism that lives on or inside a host and benefits at the host''s expense?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'medium', 'Why are antibiotics generally ineffective against viral infections such as the common cold?', 'Viruses lack the cellular structures, like cell walls, that antibiotics are designed to target', 'Viruses are physically too large for antibiotics to reach', 'Antibiotics only function when taken with food', 'Viruses are unaffected by any form of medication whatsoever', 'A', 'Antibiotics work by disrupting bacterial structures or processes, such as cell wall synthesis, which viruses do not have, making antibiotics ineffective against them.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Why are antibiotics generally ineffective against viral infections such as the common cold?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'medium', 'Which of the following best describes how most vaccines work to protect against disease?', 'They stimulate the immune system to recognize and remember a pathogen without causing the full disease', 'They directly kill bacteria already present in the bloodstream', 'They replace organs damaged by a prior infection', 'They permanently alter a person''s DNA to block all future infections', 'A', 'Vaccines expose the immune system to a harmless form or piece of a pathogen, training it to respond quickly if it encounters the real pathogen later.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which of the following best describes how most vaccines work to protect against disease?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'medium', 'Fungal infections, such as athlete''s foot, are caused by which type of organism?', 'Fungi', 'Bacteria', 'Viruses', 'Protozoa', 'A', 'Athlete''s foot is a common skin infection caused by fungi that thrive in warm, moist environments.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Fungal infections, such as athlete''s foot, are caused by which type of organism?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'medium', 'Which basic shape classification describes bacteria that are spherical in shape?', 'Cocci', 'Bacilli', 'Spirilla', 'Vibrio', 'A', 'Bacteria are often classified by shape: cocci are spherical, bacilli are rod-shaped, and spirilla are spiral-shaped.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which basic shape classification describes bacteria that are spherical in shape?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'hard', 'Which of the following best explains why overusing antibiotics can lead to antibiotic-resistant bacteria?', 'Bacteria that happen to survive due to resistance traits reproduce, passing that resistance on to future generations', 'Antibiotics deliberately mutate bacteria to make them stronger', 'Antibiotic resistance can only ever develop in viruses, not bacteria', 'Antibiotic resistance cannot occur through any natural process', 'A', 'When antibiotics kill susceptible bacteria but some resistant bacteria survive, those survivors reproduce, gradually increasing the proportion of resistant bacteria in the population.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which of the following best explains why overusing antibiotics can lead to antibiotic-resistant bacteria?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'hard', 'Malaria, a serious infectious disease transmitted through mosquito bites, is primarily caused by which type of pathogen?', 'A parasitic protozoan (Plasmodium)', 'A bacterium', 'A virus', 'A fungus', 'A', 'Malaria is caused by Plasmodium parasites, single-celled protozoa transmitted to humans through the bites of infected Anopheles mosquitoes.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Malaria, a serious infectious disease transmitted through mosquito bites, is primarily caused by which type of pathogen?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'hard', 'What is a fundamental biological difference between a virus and a bacterium?', 'A virus cannot reproduce on its own and needs a host cell''s machinery, while bacteria are living cells that can reproduce independently', 'A virus is always physically larger than a bacterium', 'Bacteria require a host cell to reproduce, while viruses do not', 'There is no meaningful biological difference between them', 'A', 'Bacteria are independent, self-replicating living cells, while viruses are much simpler particles that must hijack a host cell''s machinery in order to reproduce.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'What is a fundamental biological difference between a virus and a bacterium?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'easy', 'Which of the following is a classic sign of acute inflammation in body tissue?', 'Redness, heat, swelling, and pain', 'Permanent tissue death only', 'Complete loss of sensation', 'Increased bone density', 'A', 'Acute inflammation is classically characterized by redness, heat, swelling, and pain as the body responds to injury or infection.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which of the following is a classic sign of acute inflammation in body tissue?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'easy', 'A disease that can be passed from one person to another is generally classified as what type of disease?', 'An infectious (communicable) disease', 'A genetic disease exclusively', 'A degenerative disease exclusively', 'An autoimmune disease exclusively', 'A', 'Infectious, or communicable, diseases are caused by pathogens such as bacteria or viruses and can spread between people.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'A disease that can be passed from one person to another is generally classified as what type of disease?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'easy', 'Which term describes an abnormal growth of tissue that can be either benign or malignant?', 'Tumor (neoplasm)', 'Ligament', 'Antibody', 'Hormone', 'A', 'A tumor, or neoplasm, is an abnormal mass of tissue that forms when cells divide more than they should; it may be benign (non-cancerous) or malignant (cancerous).'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which term describes an abnormal growth of tissue that can be either benign or malignant?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'medium', 'What is the fundamental difference between a benign tumor and a malignant tumor?', 'Malignant tumors can invade nearby tissue and spread to other parts of the body, while benign tumors generally do not', 'Benign tumors always grow faster than malignant tumors', 'Malignant tumors never require any medical treatment', 'Benign tumors always spread to other organs', 'A', 'Malignant tumors are cancerous and can invade surrounding tissue and metastasize to distant sites, whereas benign tumors typically stay localized and do not spread.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'What is the fundamental difference between a benign tumor and a malignant tumor?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'medium', 'In an autoimmune disease, what fundamentally goes wrong in the body?', 'The immune system mistakenly attacks the body''s own healthy cells and tissues', 'The immune system stops functioning entirely', 'Bacteria multiply uncontrollably throughout the bloodstream', 'Blood cell production stops entirely', 'A', 'Autoimmune diseases occur when the immune system fails to distinguish the body''s own tissues from foreign invaders and attacks healthy cells as a result.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'In an autoimmune disease, what fundamentally goes wrong in the body?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'medium', 'Which of the following best describes atherosclerosis?', 'The buildup of fatty plaques within artery walls, gradually narrowing them', 'A sudden bacterial infection of the heart valves', 'The complete blockage of a vein by a blood clot', 'A hereditary disorder that affects only the liver', 'A', 'Atherosclerosis is the gradual accumulation of fatty deposits, or plaques, along artery walls, which can narrow arteries and restrict blood flow over time.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which of the following best describes atherosclerosis?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'medium', 'What is the general term for tissue death caused by an inadequate blood supply?', 'Necrosis', 'Hypertrophy', 'Regeneration', 'Mitosis', 'A', 'Necrosis refers to the death of cells or tissue, often resulting from insufficient blood supply (ischemia) depriving the tissue of oxygen and nutrients.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'What is the general term for tissue death caused by an inadequate blood supply?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'hard', 'Chronic, low-grade inflammation sustained over long periods has been associated with an increased risk of which group of conditions?', 'Conditions such as cardiovascular disease and type 2 diabetes', 'Only the common cold', 'No known long-term health conditions', 'Exclusively bone fractures', 'A', 'Long-term, low-grade inflammation is linked to a higher risk of chronic conditions including cardiovascular disease, type 2 diabetes, and certain other illnesses.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Chronic, low-grade inflammation sustained over long periods has been associated with an increased risk of which group of conditions?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'hard', 'Which best describes the general concept of a disease''s "pathophysiology"?', 'The functional and physical changes that occur in the body as a result of a disease process', 'The historical timeline of when a disease was first discovered', 'The financial cost of treating a disease', 'The legal classification of a disease', 'A', 'Pathophysiology refers to the disordered physiological processes and functional changes associated with a disease or injury.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which best describes the general concept of a disease''s "pathophysiology"?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'hard', 'Type 2 diabetes is primarily characterized by what underlying physiological problem?', 'The body''s cells becoming resistant to insulin, impairing normal blood glucose regulation', 'A complete absence of the pancreas', 'An excess of red blood cells in circulation', 'A bacterial infection of the pancreas', 'A', 'In type 2 diabetes, cells become less responsive to insulin (insulin resistance), which impairs the body''s ability to regulate blood glucose effectively.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Type 2 diabetes is primarily characterized by what underlying physiological problem?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'easy', 'Which route of drug administration involves taking medication by mouth?', 'Oral', 'Intravenous', 'Intramuscular', 'Topical', 'A', 'Oral administration means a medication is swallowed and absorbed through the digestive system, as with most pills and tablets.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which route of drug administration involves taking medication by mouth?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'easy', 'Medications that reduce pain are generally classified under which broad category?', 'Analgesics', 'Antibiotics', 'Antihistamines', 'Diuretics', 'A', 'Analgesics are the broad class of medications specifically used to relieve pain.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Medications that reduce pain are generally classified under which broad category?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'easy', 'Which class of medication is specifically used to treat infections caused by bacteria?', 'Antibiotics', 'Antivirals', 'Antihistamines', 'Antipyretics', 'A', 'Antibiotics are designed to kill or inhibit the growth of bacteria, making them the standard treatment for bacterial infections.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which class of medication is specifically used to treat infections caused by bacteria?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'medium', 'Which route of drug administration delivers medication directly into a vein, typically producing the fastest onset of effect?', 'Intravenous (IV)', 'Oral', 'Topical', 'Subcutaneous', 'A', 'Intravenous administration delivers medication straight into the bloodstream through a vein, allowing it to take effect more quickly than most other routes.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Which route of drug administration delivers medication directly into a vein, typically producing the fastest onset of effect?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'medium', 'What is the general purpose of a diuretic medication?', 'To increase urine production, helping the body eliminate excess fluid and salt', 'To reduce blood clotting exclusively', 'To increase blood glucose levels', 'To numb pain at an injection site', 'A', 'Diuretics act on the kidneys to increase urine output, helping remove excess fluid and sodium from the body, often used to manage high blood pressure.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'What is the general purpose of a diuretic medication?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'medium', 'Antihistamines are commonly used to relieve symptoms associated with which condition?', 'Allergic reactions', 'Bacterial infections exclusively', 'High blood pressure exclusively', 'Bone fractures', 'A', 'Antihistamines block the effects of histamine, a chemical released during allergic reactions, helping relieve symptoms such as sneezing and itching.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Antihistamines are commonly used to relieve symptoms associated with which condition?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'medium', 'What does the term "dosage" refer to in pharmacology?', 'The amount and frequency of a medication given to achieve a therapeutic effect', 'The chemical formula of a drug', 'The manufacturer that produces a drug', 'The expiration date printed on a medication', 'A', 'Dosage refers to the specific amount of a medication, and how often it is taken, needed to produce the desired therapeutic effect.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'What does the term "dosage" refer to in pharmacology?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'hard', 'What does a drug''s "half-life" refer to in pharmacology?', 'The time required for the concentration of a drug in the body to reduce by half', 'The total time a drug remains effective before it expires on the shelf', 'Half of the maximum recommended dosage', 'The time it takes to manufacture a batch of the drug', 'A', 'A drug''s half-life is the time it takes for its concentration in the bloodstream to decrease by fifty percent, which helps determine dosing frequency.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'What does a drug''s "half-life" refer to in pharmacology?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'hard', 'Why might a medication be given by injection (a parenteral route) rather than by mouth in certain situations?', 'To bypass digestive breakdown and achieve faster or more reliable absorption into the bloodstream', 'Because injections are always cheaper to produce than pills', 'Because oral medications never enter the bloodstream', 'Because injected drugs never cause any side effects', 'A', 'Injecting a drug bypasses the digestive system, avoiding breakdown by stomach acid or the liver, which can allow for faster, more predictable absorption.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'Why might a medication be given by injection (a parenteral route) rather than by mouth in certain situations?'
);

insert into questions (category, difficulty, prompt, option_a, option_b, option_c, option_d, correct_option, explanation)
select 'medical', 'hard', 'What general purpose do anticoagulant medications, such as warfarin, serve?', 'Reducing the blood''s ability to clot, lowering the risk of harmful blood clots forming', 'Increasing red blood cell production', 'Directly killing bacteria in the bloodstream', 'Raising blood pressure to improve circulation', 'A', 'Anticoagulants interfere with the blood clotting process, reducing the risk of dangerous clots in conditions such as atrial fibrillation or after certain surgeries.'
where not exists (
  select 1 from questions where category = 'medical' and prompt = 'What general purpose do anticoagulant medications, such as warfarin, serve?'
);
