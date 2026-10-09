-- All fixtures are rolled back. Run on the disposable database after migrations and seed.
begin;
insert into auth.users(id, raw_user_meta_data) values
 ('a0000000-0000-0000-0000-000000000001', '{"name":"Requester"}'),
 ('a0000000-0000-0000-0000-000000000002', '{"name":"Provider"}'),
 ('a0000000-0000-0000-0000-000000000003', '{"name":"Editor"}'),
 ('a0000000-0000-0000-0000-000000000004', '{"name":"Outsider"}');
insert into public.profiles(id, account_id, display_name, publication) values
 ('b0000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000002','Provider','published');
insert into public.businesses(id, created_by, name, slug, publication) values
 ('c0000000-0000-0000-0000-000000000001','a0000000-0000-0000-0000-000000000001','Test business','security-test-business','published');
insert into public.business_members(business_id,account_id,role,accepted_at) values
 ('c0000000-0000-0000-0000-000000000001','a0000000-0000-0000-0000-000000000003','editor',now());
insert into public.business_branches(business_id,city_id,name,public_location,publication,created_at) values
 ('c0000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000006','Far branch',st_point(-74.0060,40.7128)::geography,'published',now()-interval '1 day'),
 ('c0000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','Near branch',st_point(46.6753,24.7136)::geography,'published',now());
insert into public.service_requests(id,requester_id,country_id,city_id,category_id,title,description,expires_at) values
 ('d0000000-0000-0000-0000-000000000001','a0000000-0000-0000-0000-000000000001',
 '10000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001',
 '30000000-0000-0000-0000-000000000006','Test request','Test request details',now()+interval '1 day');

create function pg_temp.assert_true(ok boolean, label text) returns void language plpgsql as $$
begin if ok is distinct from true then raise exception 'FAILED: %', label; end if; end $$;
create function pg_temp.expect_denied(statement text) returns void language plpgsql as $$
declare denied boolean := false;
begin
  begin execute statement; exception when insufficient_privilege then denied := true; end;
  if not denied then raise exception 'Expected permission denial: %', statement; end if;
end $$;
create function pg_temp.expect_failure(statement text) returns void language plpgsql as $$
declare failed boolean := false;
begin
  begin execute statement; exception when others then failed := true; end;
  if not failed then raise exception 'Expected failure: %', statement; end if;
end $$;
grant execute on function pg_temp.assert_true(boolean,text), pg_temp.expect_denied(text), pg_temp.expect_failure(text) to authenticated;

set local role authenticated;
select set_config('request.jwt.claim.sub','a0000000-0000-0000-0000-000000000002',true);
-- A provider may edit ordinary content but cannot forge trust on insert or update.
update public.profiles set headline='Permitted edit' where id='b0000000-0000-0000-0000-000000000002';
select pg_temp.expect_denied($q$update public.profiles set verification='verified' where id='b0000000-0000-0000-0000-000000000002'$q$);
select pg_temp.expect_denied($q$update public.profiles set rating=5,review_count=100 where id='b0000000-0000-0000-0000-000000000002'$q$);
select pg_temp.expect_denied($q$update public.profiles set publication='published',verification='verified' where id='b0000000-0000-0000-0000-000000000002'$q$);
select public.submit_request_offer('d0000000-0000-0000-0000-000000000001',123.45,'Actual persisted offer','Two days');
select pg_temp.assert_true((select count(*)=1 from public.get_request_proposals('d0000000-0000-0000-0000-000000000001')),'provider sees saved offer');
select pg_temp.expect_failure($q$select public.submit_request_offer('d0000000-0000-0000-0000-000000000001',123,'Duplicate offer','Two days')$q$);
select pg_temp.expect_denied($q$update public.request_offers set status='accepted' where request_id='d0000000-0000-0000-0000-000000000001'$q$);
select public.open_conversation(proposal_id => (select id from public.request_offers where request_id='d0000000-0000-0000-0000-000000000001'));
insert into public.messages(conversation_id,sender_id,body)
 select id,auth.uid(),'Private message' from public.conversations;
select pg_temp.assert_true((select count(*)=1 from public.messages),'provider reads persisted message');

-- Editor content writes remain possible; team escalation does not.
select set_config('request.jwt.claim.sub','a0000000-0000-0000-0000-000000000003',true);
update public.businesses set name='Edited business' where id='c0000000-0000-0000-0000-000000000001';
select pg_temp.expect_denied($q$update public.businesses set verification='verified' where id='c0000000-0000-0000-0000-000000000001'$q$);
update public.business_members set role='owner' where account_id=auth.uid();
select pg_temp.assert_true((select role='editor' from public.business_members where account_id=auth.uid()),'editor cannot promote self');
select pg_temp.expect_denied($q$insert into public.business_members(business_id,account_id,role,accepted_at) values('c0000000-0000-0000-0000-000000000001','a0000000-0000-0000-0000-000000000004','owner',now())$q$);

-- Use the known conversation UUID to prove the fix is authorization, not obscurity.
reset role;
create temporary table known_chat as select id from public.conversations;
grant select on known_chat to authenticated;
set local role authenticated;
select set_config('request.jwt.claim.sub','a0000000-0000-0000-0000-000000000004',true);
select pg_temp.expect_denied($q$insert into public.conversation_members(conversation_id,account_id) select id,auth.uid() from known_chat$q$);
select pg_temp.assert_true((select count(*)=0 from public.messages),'outsider cannot read messages');
select pg_temp.expect_denied($q$insert into public.messages(conversation_id,sender_id,body) select id,auth.uid(),'Intrusion' from known_chat$q$);
select pg_temp.assert_true((select count(*)=0 from public.get_request_proposals('d0000000-0000-0000-0000-000000000001')),'outsider cannot read offers');
select pg_temp.expect_denied($q$insert into public.profiles(account_id,display_name,verification) values(auth.uid(),'Forged','verified')$q$);

-- Owner can read the offer and message, and membership RPC is idempotent.
select set_config('request.jwt.claim.sub','a0000000-0000-0000-0000-000000000001',true);
select pg_temp.assert_true((select count(*)=1 from public.get_request_proposals('d0000000-0000-0000-0000-000000000001')),'requester sees offer');
select pg_temp.assert_true((select count(*)=1 from public.messages),'requester reads message');
select pg_temp.assert_true(public.open_conversation(proposal_id => (select id from public.request_offers where request_id='d0000000-0000-0000-0000-000000000001')) = (select id from known_chat),'RPC reuses conversation');
update public.business_members set role='manager' where account_id='a0000000-0000-0000-0000-000000000003';
select pg_temp.assert_true((select role='manager' from public.business_members where account_id='a0000000-0000-0000-0000-000000000003'),'owner can manage team');
select pg_temp.assert_true((select count(*)=1 from public.search_directory(only_with_location=>true,
 listing_id=>'c0000000-0000-0000-0000-000000000001',origin_lat=>24.7136,origin_lng=>46.6753,radius_m=>1000)),'nearby chooses nearest branch rather than oldest');
select pg_temp.assert_true((select distance_km < 0.001 from public.search_directory(only_with_location=>true,
 listing_id=>'c0000000-0000-0000-0000-000000000001',origin_lat=>24.7136,origin_lng=>46.6753,radius_m=>1000)),'nearby computes actual distance');
reset role;
rollback;
