-- Pinoy Quiz — 0003: core tables
-- FKs to auth.users assume Supabase Auth (anonymous sign-in — see
-- docs/ARCHITECTURE.md "Security model"). Every player, including the host,
-- authenticates anonymously via supabase.auth.signInAnonymously() before
-- joining/creating a room, so auth.uid() is always available for RLS.

create table if not exists games (
  id                    uuid primary key default gen_random_uuid(),
  room_code             text not null,
  host_user_id          uuid not null references auth.users(id) on delete cascade,
  status                game_status not null default 'WAITING',

  -- settings, editable by host only while status = 'WAITING'
  category              game_category_setting not null default 'random',
  difficulty            game_difficulty_setting not null default 'mixed',
  question_count        smallint not null default 10,
  time_limit_seconds    smallint not null default 15,

  -- scoring is configurable per game, not hard-coded in application logic
  scoring_config        jsonb not null default jsonb_build_object(
                           'basePoints', 1000,
                           'maxSpeedBonus', 500,
                           'incorrectPoints', 0,
                           'noAnswerPoints', 0
                         ),

  -- live play state — written only by server-side functions (Phase 5/6)
  current_question_index smallint not null default 0,
  current_question_id    uuid, -- FK added after game_questions exists
  question_started_at    timestamptz, -- server-authoritative timer anchor

  created_at            timestamptz not null default now(),
  started_at            timestamptz,
  finished_at           timestamptz,

  constraint games_room_code_format check (room_code ~ '^[A-Z0-9]{6}$'),
  constraint games_question_count_range check (question_count between 1 and 50),
  constraint games_time_limit_range check (time_limit_seconds between 5 and 120),
  constraint games_current_question_index_nonneg check (current_question_index >= 0)
);

-- Room codes must be unique only while "in use" — old finished games could in
-- principle reuse a code, but simplest correct rule for v1 is global
-- uniqueness. Revisit if room codes need to be recycled at scale.
create unique index if not exists games_room_code_key on games (room_code);
create index if not exists games_status_idx on games (status);
create index if not exists games_host_user_id_idx on games (host_user_id);

comment on column games.current_question_id is
  'References game_questions.id (added as FK in 0004) once a question is live. Null in WAITING/COUNTDOWN/FINISHED.';


create table if not exists players (
  id            uuid primary key default gen_random_uuid(),
  game_id       uuid not null references games(id) on delete cascade,
  user_id       uuid not null references auth.users(id) on delete cascade,
  nickname      text not null,
  score         integer not null default 0,
  is_host       boolean not null default false,
  connected     boolean not null default true,
  joined_at     timestamptz not null default now(),
  last_seen_at  timestamptz not null default now(),

  constraint players_nickname_length check (char_length(trim(nickname)) between 1 and 20),
  -- one player identity per (user, game) — re-joining the same room reuses the row
  constraint players_game_user_unique unique (game_id, user_id)
);

-- Case-insensitive unique nickname per room (spec 6.4 "duplicate nickname" error)
create unique index if not exists players_game_nickname_ci_key
  on players (game_id, lower(nickname));
create index if not exists players_game_id_idx on players (game_id);


create table if not exists questions (
  id              uuid primary key default gen_random_uuid(),
  category        question_category not null,
  difficulty      question_difficulty not null,
  prompt          text not null,
  option_a        text not null,
  option_b        text not null,
  option_c        text not null,
  option_d        text not null,
  correct_option  answer_option not null,
  explanation     text,
  created_at      timestamptz not null default now(),

  constraint questions_prompt_not_blank check (char_length(trim(prompt)) > 0)
);

create index if not exists questions_category_difficulty_idx
  on questions (category, difficulty);


create table if not exists game_questions (
  id              uuid primary key default gen_random_uuid(),
  game_id         uuid not null references games(id) on delete cascade,
  question_id     uuid not null references questions(id),
  question_order  smallint not null,

  -- Per-game answer shuffle. Maps *displayed* position (0-3) to the
  -- question's original option index (0=A .. 3=D), e.g. [2,0,3,1] means
  -- displayed slot 0 shows original option C. Computed once when the game
  -- is built (Phase 5) and never exposed to clients as "here's the mapping
  -- and here's which one is right" — only used server-side to check answers
  -- and to render option *text* in shuffled order.
  shuffle_map     smallint[] not null,

  constraint game_questions_order_unique unique (game_id, question_order),
  constraint game_questions_no_dupes unique (game_id, question_id),
  constraint game_questions_shuffle_map_shape check (array_length(shuffle_map, 1) = 4)
);

create index if not exists game_questions_game_id_idx on game_questions (game_id);

alter table games
  add constraint games_current_question_fk
  foreign key (current_question_id) references game_questions(id);


create table if not exists answers (
  id                uuid primary key default gen_random_uuid(),
  game_id           uuid not null references games(id) on delete cascade,
  player_id         uuid not null references players(id) on delete cascade,
  question_id       uuid not null references questions(id),
  selected_option   smallint, -- displayed position 0-3; null = no answer submitted
  is_correct        boolean not null default false,
  response_time_ms  integer,
  points            integer not null default 0,
  created_at        timestamptz not null default now(),

  constraint answers_selected_option_range check (selected_option between 0 and 3),
  -- exactly one submission per player per question — the DB itself enforces
  -- "no double submission", not just application logic
  constraint answers_one_per_player_per_question unique (game_id, player_id, question_id)
);

create index if not exists answers_game_question_idx on answers (game_id, question_id);
create index if not exists answers_player_idx on answers (player_id);
