\set ON_ERROR_STOP on
set search_path = hindsight_spike, public;

truncate score_ledger, resolution_ledger, audit_event, forecast, prediction_event, group_membership, group_space, app_user restart identity;
insert into app_user (user_id) values ('u_owner'), ('u_member'), ('u_outsider');
insert into group_space (group_id) values ('g_synthetic');
insert into group_membership (group_id, user_id, role) values
  ('g_synthetic', 'u_owner', 'owner'), ('g_synthetic', 'u_member', 'member');
insert into prediction_event (event_id, group_id, deadline_at_utc) values
  ('e_future', 'g_synthetic', clock_timestamp() + interval '1 hour'),
  ('e_late', 'g_synthetic', clock_timestamp() - interval '1 second'),
  ('e_removed', 'g_synthetic', clock_timestamp() + interval '1 hour');

do $$
declare
  v_id bigint;
  v_replay boolean;
  v_locked timestamptz;
  v_rejected boolean;
  v_before timestamptz := clock_timestamp();
begin
  select forecast_id, locked_at_utc, replay into v_id, v_locked, v_replay
  from lock_forecast('u_owner', 'e_future', 75, 'key_same', '2000-01-01 00:00:00+00');
  if v_replay or v_locked < v_before then raise exception 'assertion failed'; end if;
  select forecast_id, replay into strict v_id, v_replay
  from lock_forecast('u_owner', 'e_future', 75, 'key_same', '2099-01-01 00:00:00+00');
  if not v_replay then raise exception 'assertion failed'; end if;

  begin perform lock_forecast('u_owner', 'e_future', 76, 'key_same', clock_timestamp()); exception when sqlstate 'P0001' then v_rejected := true; end;
  if not coalesce(v_rejected, false) then raise exception 'assertion failed'; end if;
  v_rejected := false;
  begin perform lock_forecast('u_owner', 'e_future', 75, 'key_other', clock_timestamp()); exception when sqlstate 'P0001' then v_rejected := true; end;
  if not v_rejected then raise exception 'assertion failed'; end if;
  v_rejected := false;
  begin perform lock_forecast('u_outsider', 'e_removed', 75, 'outsider', clock_timestamp()); exception when sqlstate 'P0001' then v_rejected := true; end;
  if not v_rejected then raise exception 'assertion failed'; end if;
  update group_membership set active = false where group_id = 'g_synthetic' and user_id = 'u_member';
  v_rejected := false;
  begin perform lock_forecast('u_member', 'e_removed', 75, 'removed', clock_timestamp()); exception when sqlstate 'P0001' then v_rejected := true; end;
  if not v_rejected then raise exception 'assertion failed'; end if;
  v_rejected := false;
  begin perform lock_forecast('u_owner', 'e_late', 75, 'late', '2099-01-01 00:00:00+00'); exception when sqlstate 'P0001' then v_rejected := true; end;
  if not v_rejected then raise exception 'assertion failed'; end if;
  v_rejected := false;
  begin update forecast set confidence = 1 where forecast_id = v_id; exception when sqlstate 'P0001' then v_rejected := true; end;
  if not v_rejected then raise exception 'assertion failed'; end if;
  v_rejected := false;
  begin delete from forecast where forecast_id = v_id; exception when sqlstate 'P0001' then v_rejected := true; end;
  if not v_rejected then raise exception 'assertion failed'; end if;
  v_rejected := false;
  begin update audit_event set event_type = 'forecast_locked' where forecast_id = v_id; exception when sqlstate 'P0001' then v_rejected := true; end;
  if not v_rejected then raise exception 'assertion failed'; end if;
  v_rejected := false;
  begin delete from audit_event where forecast_id = v_id; exception when sqlstate 'P0001' then v_rejected := true; end;
  if not v_rejected then raise exception 'assertion failed'; end if;
end;
$$;

insert into resolution_ledger (event_id, resolution_version, evidence_reference) values ('e_future', 1, 'synthetic-ref');
insert into score_ledger (event_id, user_id, resolution_id, formula_version, score_delta)
select 'e_future', 'u_owner', resolution_id, null, null from resolution_ledger where event_id = 'e_future';
do $$
declare v_rejected boolean := false;
begin
  begin update resolution_ledger set evidence_reference = 'changed'; exception when sqlstate 'P0001' then v_rejected := true; end;
  if not v_rejected then raise exception 'assertion failed'; end if;
  v_rejected := false;
  begin delete from score_ledger; exception when sqlstate 'P0001' then v_rejected := true; end;
  if not v_rejected then raise exception 'assertion failed'; end if;
end;
$$;

select 'SPIKE_TEST_RESULT=PASS';
select 'FORECAST_COUNT=' || count(*) from forecast;
select 'AUDIT_COUNT=' || count(*) from audit_event;
select 'RESOLUTION_COUNT=' || count(*) from resolution_ledger;
select 'SCORE_PLACEHOLDER_COUNT=' || count(*) from score_ledger;
