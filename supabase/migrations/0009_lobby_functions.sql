-- Pinoy Quiz — 0009: lobby host controls
-- remove_player rounds out the Phase 4 lobby: the host can remove someone
-- before the game starts (spec section 5, "Remove a player"). Like every
-- other write in this app, it's SECURITY DEFINER and RLS-inaccessible any
-- other way.

create or replace function remove_player(p_player_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_target players%rowtype;
  v_game games%rowtype;
begin
  if v_uid is null then
    raise exception 'You must be signed in.' using errcode = '28000';
  end if;

  select * into v_target from players where id = p_player_id;
  if not found then
    raise exception 'That player has already left the room.' using errcode = 'P0002';
  end if;

  select * into v_game from games where id = v_target.game_id;

  if v_game.host_user_id <> v_uid then
    raise exception 'Only the host can remove players.' using errcode = '42501';
  end if;

  if v_target.user_id = v_uid then
    raise exception 'You can''t remove yourself — end the game instead.' using errcode = '22023';
  end if;

  delete from players where id = p_player_id;
end;
$$;

revoke execute on function remove_player(uuid) from public;
grant execute on function remove_player(uuid) to authenticated;
