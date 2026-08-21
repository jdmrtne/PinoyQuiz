import { createClient } from "@supabase/supabase-js";
import type { Database } from "../types/database.types";

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  // Fail loudly in dev rather than silently making requests to `undefined`.
  throw new Error(
    "Missing VITE_SUPABASE_URL or VITE_SUPABASE_ANON_KEY. Copy .env.example to .env.local and fill in your Supabase project values."
  );
}

export const supabase = createClient<Database>(supabaseUrl, supabaseAnonKey, {
  auth: {
    // Every player — host included — gets an anonymous Supabase Auth
    // session so RLS policies always have an auth.uid() to check against.
    // See docs/ARCHITECTURE.md "Security model" and
    // supabase/migrations/0005_rls.sql.
    persistSession: true,
    autoRefreshToken: true,
  },
});

/**
 * Ensures the current browser has an anonymous Supabase Auth session,
 * creating one if needed. Call this once on app load, before any game
 * create/join flow (wired up in Phase 3).
 */
export async function ensureAnonymousSession() {
  const { data } = await supabase.auth.getSession();
  if (data.session) return data.session;

  const { data: signInData, error } = await supabase.auth.signInAnonymously();
  if (error) throw error;
  return signInData.session;
}
