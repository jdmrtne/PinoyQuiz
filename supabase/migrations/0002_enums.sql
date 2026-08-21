-- Pinoy Quiz — 0002: enum types

-- Game state machine (see docs/ARCHITECTURE.md).
-- Clients render off this value; only server-side functions ever write it.
create type game_status as enum (
  'WAITING',
  'COUNTDOWN',
  'QUESTION',
  'REVEAL',
  'LEADERBOARD',
  'FINISHED'
);

-- 'random' is a valid *game setting* (meaning "any category"), but is never
-- stored on an individual question row — enforced by two separate types.
create type game_category_setting as enum (
  'history',
  'geography',
  'culture',
  'food',
  'entertainment',
  'sports',
  'trivia',
  'slang',
  'random'
);

create type question_category as enum (
  'history',
  'geography',
  'culture',
  'food',
  'entertainment',
  'sports',
  'trivia',
  'slang'
);

create type question_difficulty as enum ('easy', 'medium', 'hard');

-- A game setting can additionally accept "mixed" difficulty (any of the three).
create type game_difficulty_setting as enum ('easy', 'medium', 'hard', 'mixed');

create type answer_option as enum ('A', 'B', 'C', 'D');
