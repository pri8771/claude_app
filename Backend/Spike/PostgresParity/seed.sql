set search_path=parity,public;
insert into app_meta values (:'environment');
insert into app_user values (:'environment'||':u_owner'),(:'environment'||':u_member'),(:'environment'||':u_outsider');
insert into group_space values (:'environment'||':g_alpha'),(:'environment'||':g_other');
insert into membership values (:'environment'||':g_alpha',:'environment'||':u_owner',true),(:'environment'||':g_alpha',:'environment'||':u_member',true),(:'environment'||':g_other',:'environment'||':u_outsider',true);
insert into prediction_event values (:'environment'||':e_future',:'environment'||':g_alpha',clock_timestamp()+interval '1 hour','open'),(:'environment'||':e_late',:'environment'||':g_alpha',clock_timestamp()-interval '1 second','open'),(:'environment'||':e_race',:'environment'||':g_alpha',clock_timestamp()+interval '1 hour','open');
