-- Pinoy Quiz — 0008: realtime
-- Supabase provisions a `supabase_realtime` publication in every project;
-- tables must be explicitly added to it before postgres_changes events are
-- broadcast for them. Realtime respects each table's existing RLS policies
-- (0005_rls.sql) automatically — a client only receives change events for
-- rows it's already allowed to SELECT, so no separate "realtime policy" is
-- needed.
--
-- Note: this statement assumes the `supabase_realtime` publication already
-- exists, which it always does on a real Supabase project. It will fail on
-- a vanilla local Postgres unless that publication is created first — see
-- docs/ARCHITECTURE.md "Real-time multiplayer architecture" for how this
-- was validated without a live Realtime service.

alter publication supabase_realtime add table games;
alter publication supabase_realtime add table players;
