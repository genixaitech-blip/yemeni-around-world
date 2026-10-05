begin;

-- Editors may edit content; only owners may change the team.
create or replace function public.can_manage_business_team(target_business_id uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select public.is_staff() or exists (
    select 1 from public.business_members where business_id = target_business_id
      and account_id = auth.uid() and role = 'owner' and accepted_at is not null
  );
$$;
revoke all on function public.can_manage_business_team(uuid) from public;
grant execute on function public.can_manage_business_team(uuid) to anon, authenticated;
drop policy "owners manage members" on public.business_members;
create policy "owners manage members" on public.business_members for all
  using (public.can_manage_business_team(business_id))
  with check (public.can_manage_business_team(business_id));

-- Protect server-maintained values on both INSERT and UPDATE.
create function public.guard_directory_trust() returns trigger language plpgsql
set search_path = public as $$
begin
  if current_user in ('postgres', 'service_role', 'supabase_admin') or public.is_staff() then return new; end if;
  if tg_op = 'INSERT' then
    if new.verification <> 'unverified' or new.rating <> 0 or new.review_count <> 0
       or new.publication not in ('draft', 'pending') then
      raise exception 'Directory trust fields are managed by staff' using errcode = '42501';
    end if;
  else
    if new.verification is distinct from old.verification or new.rating is distinct from old.rating
       or new.review_count is distinct from old.review_count
       or (new.publication is distinct from old.publication and new.publication not in ('draft', 'pending')) then
      raise exception 'Directory trust fields are managed by staff' using errcode = '42501';
    end if;
    if tg_table_name = 'profiles' and (to_jsonb(new)->'account_id') is distinct from (to_jsonb(old)->'account_id') then
      raise exception 'Profile ownership is managed by staff' using errcode = '42501';
    elsif tg_table_name = 'businesses' and (to_jsonb(new)->'created_by') is distinct from (to_jsonb(old)->'created_by') then
      raise exception 'Business ownership is managed by staff' using errcode = '42501';
    end if;
  end if;
  return new;
end;
$$;
create trigger protect_profile_trust before insert or update on public.profiles
  for each row execute function public.guard_directory_trust();
create trigger protect_business_trust before insert or update on public.businesses
  for each row execute function public.guard_directory_trust();

-- Direct membership writes cannot establish access. Only the scoped RPC below can.
drop policy "members add membership" on public.conversation_members;
drop policy "authenticated creates conversation" on public.conversations;
revoke insert, update, delete on public.conversation_members from anon, authenticated;
revoke insert, update, delete on public.conversations from anon, authenticated;
alter table public.conversations add column conversation_key text unique;
alter table public.conversations add column title text not null default 'محادثة';

create function public.open_conversation(listing_type text default null,
  listing_id uuid default null, proposal_id uuid default null)
returns uuid language plpgsql security definer set search_path = public as $$
declare
  actor uuid := auth.uid(); peer uuid; label text; request_key uuid; offer_key uuid;
  chat_key text; chat_id uuid;
begin
  if actor is null or not exists(select 1 from public.accounts where id = actor and status = 'active') then
    raise exception 'Sign in is required' using errcode = '42501';
  end if;
  if proposal_id is not null then
    if listing_id is not null or listing_type is not null then raise exception 'Choose one conversation target'; end if;
    select case when r.requester_id = actor then o.provider_account_id else r.requester_id end,
           r.title, r.id, o.id into peer, label, request_key, offer_key
      from public.request_offers o join public.service_requests r on r.id = o.request_id
      where o.id = proposal_id and (o.provider_account_id = actor or r.requester_id = actor)
        and r.deleted_at is null;
    chat_key := 'offer:' || proposal_id;
  elsif listing_type = 'person' then
    select account_id, display_name into peer, label from public.profiles
      where id = listing_id and publication = 'published' and deleted_at is null;
    chat_key := 'person:' || listing_id || ':' || least(actor, peer) || ':' || greatest(actor, peer);
  elsif listing_type = 'business' then
    select bm.account_id, b.name into peer, label from public.businesses b
      join public.business_members bm on bm.business_id = b.id
      where b.id = listing_id and b.publication = 'published' and b.deleted_at is null
        and bm.role = 'owner' and bm.accepted_at is not null
      order by bm.created_at, bm.account_id limit 1;
    chat_key := 'business:' || listing_id || ':' || least(actor, peer) || ':' || greatest(actor, peer);
  else
    raise exception 'Invalid conversation target';
  end if;
  if peer is null or peer = actor then raise exception 'No other participant is available'; end if;
  if not exists(select 1 from public.accounts where id = peer and status = 'active')
     or exists(select 1 from public.blocks where (blocker_id = actor and blocked_id = peer)
       or (blocker_id = peer and blocked_id = actor)) then
    raise exception 'Conversation is unavailable' using errcode = '42501';
  end if;
  insert into public.conversations(conversation_key, title, request_id, offer_id)
    values(chat_key, label, request_key, offer_key)
    on conflict (conversation_key) do update set conversation_key = excluded.conversation_key
    returning id into chat_id;
  insert into public.conversation_members(conversation_id, account_id)
    values(chat_id, actor), (chat_id, peer) on conflict do nothing;
  return chat_id;
end;
$$;
revoke all on function public.open_conversation(text,uuid,uuid) from public;
grant execute on function public.open_conversation(text,uuid,uuid) to authenticated;

-- Build offers with a profile owned by the authenticated provider. The request is
-- locked so an offer cannot race with closing or deleting it.
create function public.submit_request_offer(target_request uuid, offer_price numeric,
  offer_description text, delivery_text text)
returns uuid language plpgsql security definer set search_path = public as $$
declare actor uuid := auth.uid(); target public.service_requests; profile_key uuid; offer_key uuid;
begin
  if actor is null or not exists(select 1 from public.accounts where id = actor and status = 'active') then
    raise exception 'Sign in is required' using errcode = '42501';
  end if;
  if offer_price is null or offer_price < 0 or offer_price > 9999999999.99
    or offer_description is null or char_length(trim(offer_description)) not between 5 and 2000
    or delivery_text is null or char_length(trim(delivery_text)) not between 1 and 200 then
    raise exception 'Invalid offer details';
  end if;
  select * into target from public.service_requests where id = target_request for update;
  if not found or target.status <> 'open' or target.deleted_at is not null or target.expires_at <= now()
     or target.requester_id = actor then raise exception 'This request cannot receive your offer'; end if;
  insert into public.profiles(account_id, display_name)
    select actor, coalesce(nullif(display_name, ''), 'مقدم خدمة') from public.accounts where id = actor
    on conflict (account_id) do nothing;
  select id into profile_key from public.profiles where account_id = actor and deleted_at is null;
  if profile_key is null then raise exception 'Provider profile is unavailable'; end if;
  insert into public.request_offers(request_id, provider_account_id, profile_id, price, currency, description, delivery_time)
    values(target_request, actor, profile_key, offer_price, coalesce(target.currency, 'USD'), trim(offer_description), trim(delivery_text))
    returning id into offer_key;
  return offer_key;
end;
$$;
revoke all on function public.submit_request_offer(uuid,numeric,text,text) from public;
grant execute on function public.submit_request_offer(uuid,numeric,text,text) to authenticated;
-- All provider offer creation goes through the validated transaction.
drop policy "provider submits offer" on public.request_offers;
revoke insert on public.request_offers from anon, authenticated;

-- Do not allow providers to mark their own offer accepted or rewrite its parties.
create function public.guard_offer_update() returns trigger language plpgsql set search_path = public as $$
begin
  if current_user in ('postgres', 'service_role', 'supabase_admin') or public.is_staff() then return new; end if;
  if row(new.request_id, new.provider_account_id, new.profile_id, new.business_id)
     is distinct from row(old.request_id, old.provider_account_id, old.profile_id, old.business_id) then
    raise exception 'Offer parties cannot change' using errcode = '42501';
  end if;
  if auth.uid() = old.provider_account_id then
    if new.status is distinct from old.status and new.status <> 'withdrawn' then
      raise exception 'Only the requester may decide an offer' using errcode = '42501';
    end if;
  elsif row(new.price, new.currency, new.description, new.delivery_time, new.available_at)
     is distinct from row(old.price, old.currency, old.description, old.delivery_time, old.available_at) then
    raise exception 'Only the provider may edit offer details' using errcode = '42501';
  end if;
  return new;
end;
$$;
create trigger protect_offer_update before update on public.request_offers
  for each row execute function public.guard_offer_update();

-- Names are visible only to the requester, the submitting provider or staff.
create function public.get_request_proposals(target_request uuid)
returns table(id uuid, provider_name text, price numeric, currency char(3), description text, delivery_time text)
language sql stable security definer set search_path = public as $$
  select o.id, coalesce(nullif(p.display_name, ''), b.name, 'مقدم خدمة'),
    o.price, o.currency, o.description, coalesce(o.delivery_time, '')
  from public.request_offers o join public.service_requests r on r.id = o.request_id
    left join public.profiles p on p.id = o.profile_id left join public.businesses b on b.id = o.business_id
  where o.request_id = target_request and o.status <> 'withdrawn'
    and (o.provider_account_id = auth.uid() or r.requester_id = auth.uid() or public.is_staff())
  order by o.created_at;
$$;
revoke all on function public.get_request_proposals(uuid) from public;
grant execute on function public.get_request_proposals(uuid) to authenticated;

-- Realtime subscriptions still use the existing membership SELECT policy.
do $$ begin
  if exists(select 1 from pg_publication where pubname = 'supabase_realtime') and not exists(
    select 1 from pg_publication_tables where pubname = 'supabase_realtime'
      and schemaname = 'public' and tablename = 'messages') then
    alter publication supabase_realtime add table public.messages;
  end if;
end $$;
commit;
