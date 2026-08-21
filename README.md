# Pinoy Quiz 🇵🇭

A real-time multiplayer quiz game built around Filipino history, geography,
culture, food, entertainment, sports, trivia, and slang — questions are
Philippines-themed but written entirely in English. A host creates a room,
friends join with a code or link, and everyone answers live, Kahoot-style.

> **Status: Phase 9 complete** (security + anti-cheat hardening —
> rate limiting on every mutating function, plus a `claim_host` race
> fix). See [docs/MASTER_HANDOFF.md](docs/MASTER_HANDOFF.md) for
> current state and next steps, and
> [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the full phase plan.

## Tech stack

- **Frontend:** React 19 + TypeScript + Vite + Tailwind CSS v4 + React Router
- **State:** Zustand (installed, not yet wired up — Phase 4)
- **Backend:** Supabase (Postgres + Realtime + Row Level Security) — schema
  and client wiring land in Phase 2/3
- **Deployment target:** Vercel (frontend) + Supabase (backend)

## Project structure

```
src/
  pages/            One component per route (Home built; others are
                     placeholders until their phase)
  components/
    ui/              Shared primitives (Button, Card, ...)
    lobby/           Lobby-specific components (Phase 4)
    host/            Host-only controls (Phase 4/5)
    game/            Question/reveal/leaderboard screens (Phase 5-7)
  game-engine/       Server-authoritative game logic: scoring, question
                     selection, state machine (Phase 5+, framework-agnostic
                     so it can be unit tested without a DB)
  lib/               Supabase client, API helpers (Phase 2+)
  hooks/             Realtime subscription hooks (Phase 4+)
  types/             Shared TypeScript contracts (game.ts implemented now)
  data/              Local fallback/dev data (seed questions live in
                     supabase/seed instead, since they're server-owned)
supabase/
  migrations/        SQL schema migrations (Phase 2)
  seed/              Question seed scripts (Phase 2/14)
docs/
  ARCHITECTURE.md    Full technical architecture + phase roadmap
tests/               Game logic unit tests (Phase 5+)
```

## Installation

```bash
npm install
```

## Environment variables

Copy `.env.example` to `.env.local` and fill in your Supabase project's
public values (never the `service_role` key):

```bash
cp .env.example .env.local
```

| Variable | Description |
|---|---|
| `VITE_SUPABASE_URL` | Your Supabase project URL |
| `VITE_SUPABASE_ANON_KEY` | Public anon key (safe for frontend — RLS does the enforcing) |

## Supabase setup

A project is already linked via `.env.local` (not committed). To set up
the database itself:

1. **Enable Anonymous Sign-ins.** In the Supabase Dashboard, go to
   **Authentication → Sign In / Providers → Anonymous** and turn it on.
   Every player (including the host) authenticates anonymously before
   touching any table — RLS depends on `auth.uid()` always being present.
2. **Run the migrations, in order.** Open **SQL Editor** in the dashboard
   and run each file in `supabase/migrations/` top to bottom:
   `0001_extensions.sql` → `0002_enums.sql` → `0003_tables.sql` →
   `0004_views.sql` → `0005_rls.sql` → `0006_grants.sql` →
   `0007_room_functions.sql` → `0008_realtime.sql` →
   `0009_lobby_functions.sql` → `0010_game_engine.sql` →
   `0011_answer_submission.sql`.
   (If you use the Supabase CLI instead: `supabase link` then
   `supabase db push`.)
3. **Verify RLS is on.** In **Table Editor**, each of `games`, `players`,
   `questions`, `game_questions`, `answers` should show a "RLS enabled"
   badge. If any table shows it as off, re-run `0005_rls.sql`.
4. **Realtime is enabled by migration.** `0008_realtime.sql` adds
   `games`/`players` to the `supabase_realtime` publication — no dashboard
   step needed, it's part of running the migrations above. You can confirm
   it in **Database → Replication**: both tables should be listed under
   the `supabase_realtime` publication.

All six migration files were validated by running them against a local
throwaway Postgres instance (with `auth.users`/`auth.uid()` stubbed to
match Supabase) before being written here, including a full read/write
security test — see `docs/ARCHITECTURE.md` for what was tested and
`CHANGELOG.md` for the bug that testing caught and fixed.

## Running locally

```bash
npm run dev
```

**Verifying changes:** always use `npm run build` (which runs `tsc -b &&
vite build`), not a bare `npx tsc --noEmit` — this project's root
`tsconfig.json` has `"files": []` with only `references`, so an unscoped
`tsc --noEmit` silently checks zero files and reports false success. This
already masked two real type errors once; see `CHANGELOG.md` Phase 3. If
you want a quick check without a full Vite build, use
`npx tsc -b --force`.

## Seeding questions

`supabase/seed/0001_sample_questions.sql` contains 80 verified questions
(10 per category — not yet the full 240 the spec targets; see the file's
header and `docs/ARCHITECTURE.md` for why). Run it in the SQL Editor after
the migrations above, or via `psql`:

```bash
psql "$DATABASE_URL" -f supabase/seed/0001_sample_questions.sql
```

With only ~3-4 questions per category+difficulty combination, starting a
game with a narrow setting (a specific category *and* a specific
difficulty, asking for more questions than exist in that cell) will
correctly fail with a friendly "not enough questions available" error.
For now, prefer **Mixed** difficulty or **Random** category when testing.

## Running tests

Not yet available — lands in Phase 5+ alongside the game engine.

## Production deployment

Not yet documented — lands in Phase 12. Target is Vercel for the frontend
(`npm run build` → `dist/`) with Supabase as the hosted backend.

## Known limitations (through Phase 8)

- Question bank has 80 of the eventual 240 questions — narrow settings
  (specific category + specific difficulty) can hit "not enough
  questions available"; Mixed difficulty or Random category work
  comfortably (see "Seeding questions" above). Tracked separately as
  Phase 14.
- Realtime message delivery (roster sync, status changes, disconnect
  flags) is wired up per Phase 4 but hasn't been confirmed against a
  live Supabase project from this environment — everything downstream of
  it (including all of Phase 8) has only been validated against a local
  Postgres standing in for the database layer, not the live Realtime
  wire. Two real browser tabs against a live project is the needed
  manual check.
- Disconnect detection (Phase 8) has up to ~20 seconds of lag and relies
  on *some* other connected client's own heartbeat timer to notice — if
  every participant disconnects at the same moment, nothing brings the
  game back on its own without a server-side scheduled job, which this
  phase deliberately didn't introduce. See `docs/ARCHITECTURE.md`'s
  Phase 8 section and `supabase/migrations/0013_disconnect_reconnect.sql`
  for the full reasoning.
- A removed player's own screen may not reliably show they were removed
  (Phase 4) — see `docs/ARCHITECTURE.md`.
- No anti-cheat hardening beyond what's already in place (rate limiting
  on state-transition calls, etc.) — Phase 9.
- No mobile-specific polish pass beyond reusing existing responsive
  primitives and design tokens — Phase 10.

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the phase-by-phase plan
and [CHANGELOG.md](CHANGELOG.md) for what's been completed so far.
