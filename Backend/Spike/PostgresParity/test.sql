\set ON_ERROR_STOP on
set search_path=parity,public;
do $$ declare rejected boolean; oid bigint; begin
 set local role api_actor; set local app.actor='dev:u_outsider';
 begin perform * from lock_forecast('dev:e_future',1,'outsider','2000-01-01Z'); exception when sqlstate 'P0001' then rejected := sqlerrm='MEMBERSHIP_INACTIVE'; end; if not rejected then raise exception 'outsider'; end if;
 reset role; update membership set active=false where user_id='dev:u_member' and group_id='dev:g_alpha'; set local role api_actor; set local app.actor='dev:u_member'; rejected:=false; begin perform * from lock_forecast('dev:e_future',1,'removed','2000-01-01Z'); exception when sqlstate 'P0001' then rejected := sqlerrm='MEMBERSHIP_INACTIVE'; end; if not rejected then raise exception 'removed'; end if;
 reset role; update membership set active=true where user_id='dev:u_member' and group_id='dev:g_alpha'; set local role api_actor; set local app.actor='dev:u_member'; rejected:=false; begin perform * from lock_forecast('qa:e_future',1,'cross','2000-01-01Z'); exception when sqlstate 'P0001' then rejected := sqlerrm='NOT_FOUND'; end; if not rejected then raise exception 'cross'; end if;
 rejected:=false; begin perform * from lock_forecast('dev:e_late',1,'late','2099-01-01Z'); exception when sqlstate 'P0001' then rejected := sqlerrm='FORECAST_DEADLINE_PASSED'; end; if not rejected then raise exception 'late'; end if;
 select forecast_id into oid from lock_forecast('dev:e_future',20,'same','2000-01-01Z'); perform * from lock_forecast('dev:e_future',20,'same','2099-01-01Z'); rejected:=false; begin perform * from lock_forecast('dev:e_future',21,'same','2099-01-01Z'); exception when sqlstate 'P0001' then rejected := sqlerrm='IDEMPOTENCY_KEY_REUSED'; end; if not rejected then raise exception 'idempotency'; end if;
 reset role; rejected:=false; begin update forecast set confidence=1 where forecast_id=oid; exception when sqlstate 'P0001' then rejected:=true; end; if not rejected then raise exception 'forecast mutable'; end if;
 rejected:=false; begin delete from audit_ledger where forecast_id=oid; exception when sqlstate 'P0001' then rejected:=true; end; if not rejected then raise exception 'audit mutable'; end if;
 insert into resolution_ledger(event_id,version,evidence_ref) values('dev:e_future',1,'synthetic-reference'); rejected:=false; begin delete from resolution_ledger; exception when sqlstate 'P0001' then rejected:=true; end; if not rejected then raise exception 'resolution mutable'; end if;
end $$;
set role api_actor;
set app.actor='dev:u_outsider';
select 1 / case when count(*)=0 then 1 else 0 end as rls_outsider_cannot_read_alpha from group_space where group_id='dev:g_alpha';
set app.actor='dev:u_member';
select 1 / case when count(*)=1 then 1 else 0 end as rls_member_can_read_alpha from group_space where group_id='dev:g_alpha';
reset role;
select 'BASE_TEST=PASS';
