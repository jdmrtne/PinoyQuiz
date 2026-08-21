import { defineConfig } from "vitest/config";

// Phase 11: this project's game logic is server-side (Postgres functions —
// see supabase/tests/run_scenarios.sql for that half of testing). What's
// unit-tested here is the client's pure, framework-agnostic logic only
// (src/game-engine/, gameApi's error-message mapping, data-table
// integrity) — no component rendering, so no jsdom environment is needed.
export default defineConfig({
  test: {
    environment: "node",
    include: ["src/**/*.test.ts"],
  },
});
