-- Pinoy Quiz — 0013: disconnect/reconnect handling (Phase 8)
--
-- Closes the gap called out at the end of Phase 7: every state-machine
-- transition so far (start_game, begin_first_question, end_question,
-- advance_to_leaderboard, advance_question) is host-only and
-- client-triggered, with no server-side fallback if the host's tab closes
-- mid-game. This migration adds three SECURITY DEFINER functions:
--
--   heartbeat(game_id)          — any participant, called periodically by
--                                  their own client to prove they're still
--                                  around.
--   mark_stale_players(game_id) — any participant, called periodically by
--                                  *any* client (not just the host's) to
--                                  flip connected=false for anyone who's
--                                  stopped heartbeating.
--   claim_host(game_id)         — any *other* participant, to take over as
--                                  host once the current host is stale.
--
-- Mechanism choice — heartbeat/staleness over Realtime Presence:
-- docs/ARCHITECTURE.md flags both as options ("Presence... is the natural
-- fit... The `connected` DB column... could instead become 'haven't ack'd
-- in N seconds' via a heartbeat"). Presence would give faster, more
-- immediate "who's got a live socket right now" signal, but — like the
-- rest of Supabase Realtime (see Phase 4's CHANGELOG entry and
-- useGameRealtime.ts's doc comment) — it's a hosted service this sandbox
-- cannot exercise at all, live-wire behavior included. A heartbeat is a
-- plain SECURITY DEFINER function + a plain UPDATE, so it's fully
-- reproducible against the disposable local Postgres this project has used
-- to validate every phase so far, and it reuses the *already-tested*
-- postgres_changes subscription on `players` (Phase 4) to broadcast the
-- resulting `connected` flip to every client — no new Realtime feature
-- needed. Trade-off: staleness detection lags by up to STALE_SECONDS
-- (below) rather than being instant. Documented rather than silently
-- swapped in without discussion — revisit if that lag proves too slow in
-- practice against a live project.
--
-- Staleness threshold: 20 seconds. The client calls heartbeat() and
-- mark_stale_players() together on the same interval — see
-- src/hooks/useHeartbeat.ts — every 8 seconds, so 20s is a little over two
-- missed heartbeats before someone is considered gone: enough slack for a
-- backgrounded mobile tab's throttled timers or a brief network hiccup,
-- short enough that a real drop is caught well within one question's
-- typical time limit (5-120s per games_time_limit_range).

create or replace function heartbeat(p_game_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'You must be signed in.' using errcode = '28000';
  end if;

  update players
    set connected = true, last_seen_at = now()
    where game_id = p_game_id and user_id = v_uid;

  if not found then
    raise exception 'You are not part of this game.' using errcode = '42501';
  end if;
end;
$$;


-- mark_stale_players: deliberately callable by *any* participant, not just
-- the host — the whole point of Phase 8 is that the host might be the one
-- who's gone, so this can't require the host to be the one to notice.
-- Purely a maintenance sweep: flips connected=false for anyone in this
-- game who's missed enough heartbeats. Idempotent (only touches rows that
-- are currently connected=true and actually stale) so calling it
-- redundantly from every client's timer, at slightly different times, is
-- harmless — last writer just re-sets the same value.
create or replace function mark_stale_players(p_game_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_stale_after constant interval := interval '20 seconds';
begin
  if v_uid is null then
    raise exception 'You must be signed in.' using errcode = '28000';
  end if;

  if not exists (select 1 from players where game_id = p_game_id and user_id = v_uid) then
    raise exception 'You are not part of this game.' using errcode = '42501';
  end if;

  update players
    set connected = false
    where game_id = p_game_id
      and connected = true
      and last_seen_at < now() - v_stale_after;
end;
$$;


-- claim_host: lets a remaining connected player take over as host once the
-- current host has gone stale (same 20s threshold as mark_stale_players,
-- checked independently here server-side rather than trusting the
-- caller's possibly-out-of-date view of `players.connected` — a client
-- could otherwise race a call in right as the real host reconnects).
-- New host is *not* whoever happened to click first among several who
-- might try — it's deterministically the earliest-joined currently
-- connected player (excluding the stale host), same "next-oldest
-- connected player" rule docs/MASTER_HANDOFF.md's Phase 8 section
-- proposed, so simultaneous claim attempts from two different clients
-- converge on the same answer rather than depending on request timing.
-- The caller only needs to be *a* participant (doesn't have to be the one
-- who ends up as the new host) — clicking "Become host" is really just
-- "run the reassignment", and GameRoom.tsx only shows that control to
-- non-host players once they can see (via the already-realtime-synced
-- `connected` flag) that the host looks gone.
create or replace function claim_host(p_game_id uuid)
returns table (
  out_new_host_player_id uuid,
  out_new_host_nickname text
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_game games%rowtype;
  v_host players%rowtype;
  v_candidate players%rowtype;
  v_stale_after constant interval := interval '20 seconds';
begin
  if v_uid is null then
    raise exception 'You must be signed in.' using errcode = '28000';
  end if;

  select * into v_game from games where id = p_game_id;
  if not found then
    raise exception 'Game not found.' using errcode = 'P0002';
  end if;

  if not exists (select 1 from players where game_id = p_game_id and user_id = v_uid) then
    raise exception 'You are not part of this game.' using errcode = '42501';
  end if;

  if v_game.status = 'FINISHED' then
    raise exception 'This game has already finished.' using errcode = 'P0001';
  end if;

  select * into v_host from players where game_id = p_game_id and is_host = true;
  if not found then
    -- Shouldn't happen (every game has exactly one host from create_game
    -- onward), but fail clearly rather than silently picking someone.
    raise exception 'This game has no host on record.' using errcode = 'P0007';
  end if;

  if v_host.user_id = v_uid then
    raise exception 'You are already the host.' using errcode = '22023';
  end if;

  if v_host.connected and v_host.last_seen_at >= now() - v_stale_after then
    raise exception 'The host is still connected.' using errcode = 'P0008';
  end if;

  select * into v_candidate
    from players
    where game_id = p_game_id
      and id <> v_host.id
      and connected = true
    order by joined_at asc
    limit 1;

  if not found then
    raise exception 'No other connected players are available to become host.'
      using errcode = 'P0009';
  end if;

  update players set is_host = false where id = v_host.id;
  update players set is_host = true where id = v_candidate.id;
  update games set host_user_id = v_candidate.user_id where id = p_game_id;

  return query select v_candidate.id, v_candidate.nickname;
end;
$$;


revoke execute on function heartbeat(uuid) from public;
revoke execute on function mark_stale_players(uuid) from public;
revoke execute on function claim_host(uuid) from public;

grant execute on function heartbeat(uuid) to authenticated;
grant execute on function mark_stale_players(uuid) to authenticated;
grant execute on function claim_host(uuid) to authenticated;
