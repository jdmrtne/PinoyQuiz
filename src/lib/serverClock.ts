/**
 * Client/server clock-offset calibration.
 *
 * Host pause/resume (0037_host_pause_resume.sql) freezes the on-screen
 * countdown using ONLY server-generated timestamps (games.question_started_at
 * and games.paused_at, both set by Postgres `now()`) — see useServerTimer.ts.
 * That math never touches the device's own clock while paused, so it's
 * exact regardless of the device.
 *
 * The moment a game resumes, though, the running countdown goes back to
 * comparing the device's own `Date.now()` against that same server
 * timestamp — same as it does for any non-paused question. If the
 * device's system clock is off from the server's (unsynced clocks, VMs,
 * emulators, a phone with the wrong time zone/time set — all common),
 * that drift is a small *constant* offset baked into every tick of a
 * normal countdown, easy to not notice. But right after a pause, it shows
 * up as a sudden, visible jump: the frozen number was exact, and resuming
 * reintroduces the device's skewed clock for the first time. A device
 * clock that's a few seconds fast, for instance, makes the resumed timer
 * appear to have "lost" those same few seconds the instant you resume.
 *
 * This module estimates that offset once per session — from the `Date`
 * response header every Supabase REST request already returns, no extra
 * RPC/migration needed — and callers use `getServerNow()` in place of
 * `Date.now()` so the timer's device-clock comparison is corrected back
 * to the server's clock, removing the jump.
 */

let offsetMs = 0;
let calibratePromise: Promise<void> | null = null;

async function calibrateOnce(): Promise<void> {
  const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
  if (!supabaseUrl) return;

  try {
    const before = Date.now();
    const res = await fetch(`${supabaseUrl}/rest/v1/`, { method: "HEAD" });
    const after = Date.now();
    const dateHeader = res.headers.get("date");
    if (!dateHeader) return;

    const serverNowMs = new Date(dateHeader).getTime();
    if (Number.isNaN(serverNowMs)) return;

    // The `Date` header reflects the server's clock at some point during
    // the round trip; the request's midpoint is the best single estimate
    // of "client time that corresponded to that server time" without
    // needing a dedicated timestamp-echoing endpoint.
    const roundTripMidpoint = before + (after - before) / 2;
    offsetMs = serverNowMs - roundTripMidpoint;
  } catch {
    // Offline/CORS/etc — leave offsetMs at 0 (today's uncorrected
    // behavior) rather than throwing; a later call can retry.
  }
}

/**
 * Kicks off calibration if it hasn't run yet this session. Safe to call
 * from multiple places (e.g. app start and GameRoom mount) — subsequent
 * calls reuse the same in-flight/completed calibration.
 */
export function calibrateServerClock(): Promise<void> {
  if (!calibratePromise) {
    calibratePromise = calibrateOnce();
  }
  return calibratePromise;
}

/** Best current estimate of the server's wall-clock time, in ms. Falls
 *  back to the device's own clock (offset 0) until calibration finishes,
 *  which matches today's behavior in the meantime. */
export function getServerNow(): number {
  return Date.now() + offsetMs;
}
