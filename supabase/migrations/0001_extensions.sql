-- Pinoy Quiz — 0001: extensions
-- gen_random_uuid() is built into Postgres core (13+), which Supabase runs,
-- but pgcrypto is enabled too since Supabase projects ship with it by default
-- and some environments still expect it explicitly.
create extension if not exists pgcrypto;
