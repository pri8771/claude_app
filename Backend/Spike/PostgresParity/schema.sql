-- Synthetic, disposable F0.3 parity model.  It is not an application migration.
create schema parity;
set search_path = parity, public;
create table app_meta (environment text primary key check (environment in ('dev','qa')));
create table app_user (user_id text primary key check (user_id ~ '^(dev|qa):u_[a-z]+$'));
create table group_space (group_id text primary key check (group_id ~ '^(dev|qa):g_[a-z]+$'));
create table membership (group_id text references group_space, user_id text references app_user, active boolean not null, primary key(group_id,user_id));
create table prediction_event (event_id text primary key check (event_id ~ '^(dev|qa):e_[a-z]+$'), group_id text not null references group_space, deadline_at_utc timestamptz not null, state text not null default 'open');
create table forecast (forecast_id bigint generated always as identity primary key, event_id text not null references prediction_event, user_id text not null references app_user, confidence int not null check(confidence between 0 and 100), idempotency_key text not null check(length(idempotency_key) between 1 and 128), payload_hash text not null, locked_at_utc timestamptz not null default clock_timestamp(), unique(event_id,user_id), unique(event_id,user_id,idempotency_key));
create table audit_ledger (audit_id bigint generated always as identity primary key, forecast_id bigint not null unique references forecast, action text not null check(action='forecast.locked'), occurred_at_utc timestamptz not null default clock_timestamp());
create table resolution_ledger (resolution_id bigint generated always as identity primary key, event_id text not null references prediction_event, version int not null, evidence_ref text not null, recorded_at_utc timestamptz not null default clock_timestamp(), unique(event_id,version));
create table notification_outbox (outbox_id bigint generated always as identity primary key, topic text not null, resource_id text not null, attempts int not null default 0, available_at_utc timestamptz not null default clock_timestamp(), leased_until_utc timestamptz, delivered_at_utc timestamptz, last_error_code text check(last_error_code !~ '[[:space:]]'), check(topic !~ '[[:space:]]')); -- intentionally no content column
create table change_feed (sequence bigint generated always as identity primary key, topic text not null, resource_id text not null, resource_version int not null default 1, occurred_at_utc timestamptz not null default clock_timestamp());

create or replace function immutable() returns trigger language plpgsql as $$ begin raise exception 'IMMUTABLE_RECORD' using errcode='P0001'; end $$;
create trigger forecast_immutable before update or delete on forecast for each row execute function immutable();
create trigger audit_immutable before update or delete on audit_ledger for each row execute function immutable();
create trigger resolution_immutable before update or delete on resolution_ledger for each row execute function immutable();

create or replace function actor() returns text language sql stable as $$ select current_setting('app.actor', true) $$;
create or replace function env() returns text language sql stable as $$ select (select environment from app_meta) $$;
create or replace function is_active(p_group text) returns boolean language sql stable security definer set search_path=parity,public as $$ select exists(select 1 from membership where group_id=p_group and user_id=actor() and active) $$;
create or replace function lock_forecast(p_event text,p_confidence int,p_key text,p_client_timestamp timestamptz)
returns table(forecast_id bigint,replay boolean) language plpgsql security definer set search_path=parity,public as $$
declare e prediction_event%rowtype; f forecast%rowtype; h text := md5('social.v1|' || p_confidence::text);
begin
 if actor() is null or split_part(actor(),':',1) <> env() then raise exception 'UNAUTHENTICATED' using errcode='P0001'; end if;
 select * into e from prediction_event where event_id=p_event for update;
 if not found or split_part(p_event,':',1) <> env() then raise exception 'NOT_FOUND' using errcode='P0001'; end if;
 if not is_active(e.group_id) then raise exception 'MEMBERSHIP_INACTIVE' using errcode='P0001'; end if;
 if e.state <> 'open' then raise exception 'EVENT_NOT_OPEN' using errcode='P0001'; end if;
 if clock_timestamp() >= e.deadline_at_utc then raise exception 'FORECAST_DEADLINE_PASSED' using errcode='P0001'; end if;
 perform pg_sleep(0.20); -- makes the two independent psql sessions overlap deterministically
 select * into f from forecast where event_id=p_event and user_id=actor() and idempotency_key=p_key;
 if found then if f.payload_hash<>h then raise exception 'IDEMPOTENCY_KEY_REUSED' using errcode='P0001'; end if; return query select f.forecast_id,true; return; end if;
 if exists(select 1 from forecast where event_id=p_event and user_id=actor()) then raise exception 'FORECAST_EXISTS' using errcode='P0001'; end if;
 insert into forecast(event_id,user_id,confidence,idempotency_key,payload_hash) values(p_event,actor(),p_confidence,p_key,h) returning forecast.forecast_id into f.forecast_id;
 insert into audit_ledger(forecast_id,action) values(f.forecast_id,'forecast.locked');
 insert into notification_outbox(topic,resource_id) values('forecast.locked',p_event);
 insert into change_feed(topic,resource_id) values('group.changed',p_event);
 return query select f.forecast_id,false;
end $$;
create or replace function claim_outbox() returns table(outbox_id bigint) language sql security definer set search_path=parity,public as $$
 with c as (select o.outbox_id from notification_outbox o where delivered_at_utc is null and available_at_utc<=clock_timestamp() and (leased_until_utc is null or leased_until_utc<clock_timestamp()) order by outbox_id for update skip locked limit 1)
 update notification_outbox o set attempts=attempts+1, leased_until_utc=clock_timestamp()+interval '1 minute' from c where o.outbox_id=c.outbox_id returning o.outbox_id $$;
create or replace function fail_outbox(p_id bigint) returns void language sql security definer set search_path=parity,public as $$ update notification_outbox set leased_until_utc=clock_timestamp()-interval '1 second',available_at_utc=clock_timestamp(),last_error_code='RETRY' where outbox_id=p_id $$;
create or replace function ack_outbox(p_id bigint) returns void language sql security definer set search_path=parity,public as $$ update notification_outbox set delivered_at_utc=clock_timestamp(),leased_until_utc=null where outbox_id=p_id $$;
create or replace function reconcile(p_after bigint) returns table(sequence bigint,resource_id text) language sql security definer set search_path=parity,public as $$ select c.sequence,c.resource_id from change_feed c join prediction_event e on e.event_id=c.resource_id where c.sequence>p_after and is_active(e.group_id) order by c.sequence $$;

revoke all on schema parity from public; revoke all on all tables in schema parity from public;
do $$ begin
  if not exists (select 1 from pg_roles where rolname = 'api_actor') then create role api_actor nologin; end if;
end $$;
grant usage on schema parity to api_actor; grant select on group_space,prediction_event,forecast,change_feed to api_actor;
grant execute on function lock_forecast(text,int,text,timestamptz), reconcile(bigint) to api_actor;
alter table group_space enable row level security; alter table prediction_event enable row level security; alter table forecast enable row level security; alter table change_feed enable row level security;
create policy group_read on group_space for select to api_actor using (is_active(group_id));
create policy event_read on prediction_event for select to api_actor using (is_active(group_id));
create policy forecast_read on forecast for select to api_actor using (user_id=actor());
create policy feed_read on change_feed for select to api_actor using (exists(select 1 from prediction_event e where e.event_id=change_feed.resource_id and is_active(e.group_id)));
