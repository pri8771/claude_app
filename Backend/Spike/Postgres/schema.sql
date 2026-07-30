-- Disposable F0.3 integrity spike only. Synthetic fixtures never leave local PostgreSQL.
begin;

create schema if not exists hindsight_spike;
set local search_path = hindsight_spike, public;

create table if not exists spike_marker (
  marker text primary key check (marker = 'hindsight_f03_postgres_integrity_spike'),
  created_at_utc timestamptz not null default clock_timestamp()
);
insert into spike_marker (marker) values ('hindsight_f03_postgres_integrity_spike') on conflict do nothing;

create table if not exists app_user (
  user_id text primary key,
  created_at_utc timestamptz not null default clock_timestamp()
);

create table if not exists group_space (
  group_id text primary key,
  created_at_utc timestamptz not null default clock_timestamp()
);

create table if not exists group_membership (
  group_id text not null references group_space(group_id),
  user_id text not null references app_user(user_id),
  role text not null check (role in ('owner', 'member')),
  active boolean not null default true,
  changed_at_utc timestamptz not null default clock_timestamp(),
  primary key (group_id, user_id)
);

create table if not exists prediction_event (
  event_id text primary key,
  group_id text not null references group_space(group_id),
  deadline_at_utc timestamptz not null,
  state text not null check (state in ('open', 'closed')) default 'open',
  created_at_utc timestamptz not null default clock_timestamp()
);

create table if not exists forecast (
  forecast_id bigint generated always as identity primary key,
  event_id text not null references prediction_event(event_id),
  user_id text not null references app_user(user_id),
  confidence integer not null check (confidence between 0 and 100),
  idempotency_key text not null check (length(idempotency_key) between 1 and 128),
  payload_hash text not null,
  locked_at_utc timestamptz not null default clock_timestamp(),
  unique (event_id, user_id),
  unique (event_id, user_id, idempotency_key)
);

create table if not exists audit_event (
  audit_id bigint generated always as identity primary key,
  forecast_id bigint not null unique references forecast(forecast_id),
  event_type text not null check (event_type = 'forecast_locked'),
  occurred_at_utc timestamptz not null default clock_timestamp()
);

-- These ledgers intentionally carry no scoring formula. A future approved policy owns meaning.
create table if not exists resolution_ledger (
  resolution_id bigint generated always as identity primary key,
  event_id text not null references prediction_event(event_id),
  resolution_version integer not null check (resolution_version > 0),
  evidence_reference text not null,
  recorded_at_utc timestamptz not null default clock_timestamp(),
  unique (event_id, resolution_version)
);

create table if not exists score_ledger (
  score_entry_id bigint generated always as identity primary key,
  event_id text not null references prediction_event(event_id),
  user_id text not null references app_user(user_id),
  resolution_id bigint references resolution_ledger(resolution_id),
  formula_version text,
  score_delta numeric,
  recorded_at_utc timestamptz not null default clock_timestamp(),
  check ((formula_version is null and score_delta is null) or (formula_version is not null and score_delta is not null))
);

create or replace function reject_immutable_write()
returns trigger language plpgsql as $$
begin
  raise exception using errcode = 'P0001', message = 'IMMUTABLE_RECORD';
end;
$$;

drop trigger if exists forecast_immutable on forecast;
create trigger forecast_immutable before update or delete on forecast
for each row execute function reject_immutable_write();
drop trigger if exists audit_immutable on audit_event;
create trigger audit_immutable before update or delete on audit_event
for each row execute function reject_immutable_write();
drop trigger if exists resolution_immutable on resolution_ledger;
create trigger resolution_immutable before update or delete on resolution_ledger
for each row execute function reject_immutable_write();
drop trigger if exists score_immutable on score_ledger;
create trigger score_immutable before update or delete on score_ledger
for each row execute function reject_immutable_write();

create or replace function lock_forecast(
  p_actor_id text,
  p_event_id text,
  p_confidence integer,
  p_idempotency_key text,
  p_client_timestamp timestamptz
)
returns table (forecast_id bigint, locked_at_utc timestamptz, replay boolean)
language plpgsql
security invoker
set search_path = hindsight_spike, public
as $$
declare
  v_group_id text;
  v_deadline timestamptz;
  v_state text;
  v_payload_hash text := md5(format('forecast-v1|%s', p_confidence));
  v_existing forecast%rowtype;
  v_inserted_id bigint;
  v_locked_at timestamptz;
begin
  -- The event row lock serializes deadline and duplicate decisions. p_client_timestamp is ignored.
  select group_id, deadline_at_utc, state into v_group_id, v_deadline, v_state
  from prediction_event where event_id = p_event_id for update;
  if not found or v_state <> 'open' or clock_timestamp() >= v_deadline then
    raise exception using errcode = 'P0001', message = 'FORECAST_REJECTED';
  end if;

  if not exists (
    select 1 from group_membership
    where group_id = v_group_id and user_id = p_actor_id and active
  ) then
    raise exception using errcode = 'P0001', message = 'FORECAST_REJECTED';
  end if;

  select * into v_existing from forecast
  where event_id = p_event_id and user_id = p_actor_id and idempotency_key = p_idempotency_key;
  if found then
    if v_existing.payload_hash <> v_payload_hash then
      raise exception using errcode = 'P0001', message = 'FORECAST_REJECTED';
    end if;
    return query select v_existing.forecast_id, v_existing.locked_at_utc, true;
    return;
  end if;

  if exists (select 1 from forecast where event_id = p_event_id and user_id = p_actor_id) then
    raise exception using errcode = 'P0001', message = 'FORECAST_REJECTED';
  end if;

  insert into forecast (event_id, user_id, confidence, idempotency_key, payload_hash)
  values (p_event_id, p_actor_id, p_confidence, p_idempotency_key, v_payload_hash)
  returning forecast.forecast_id, forecast.locked_at_utc into v_inserted_id, v_locked_at;
  insert into audit_event (forecast_id, event_type) values (v_inserted_id, 'forecast_locked');
  return query select v_inserted_id, v_locked_at, false;
end;
$$;

commit;
