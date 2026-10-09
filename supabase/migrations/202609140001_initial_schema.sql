begin;

create extension if not exists pgcrypto;
create extension if not exists postgis;

create type public.publication_status as enum ('draft', 'pending', 'published', 'rejected', 'archived');
create type public.verification_status as enum ('unverified', 'pending', 'verified', 'rejected');
create type public.member_role as enum ('owner', 'manager', 'editor');
create type public.request_status as enum ('open', 'awarded', 'completed', 'cancelled', 'expired');
create type public.proposal_status as enum ('submitted', 'accepted', 'rejected', 'withdrawn');
create type public.entity_kind as enum ('profile', 'business');

create table public.accounts (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  avatar_url text,
  preferred_locale text not null default 'ar' check (preferred_locale in ('ar', 'en')),
  status text not null default 'active' check (status in ('active', 'suspended', 'deleted')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.account_roles (
  account_id uuid not null references public.accounts(id) on delete cascade,
  role text not null check (role in ('user', 'moderator', 'country_manager', 'super_admin')),
  country_id uuid,
  created_at timestamptz not null default now(),
  primary key (account_id, role)
);

create table public.countries (
  id uuid primary key default gen_random_uuid(),
  iso2 char(2) not null unique,
  name_ar text not null,
  name_en text not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.account_roles add constraint account_roles_country_fk foreign key (country_id) references public.countries(id);

create table public.regions (
  id uuid primary key default gen_random_uuid(),
  country_id uuid not null references public.countries(id) on delete cascade,
  name_ar text not null,
  name_en text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.cities (
  id uuid primary key default gen_random_uuid(),
  country_id uuid not null references public.countries(id) on delete cascade,
  region_id uuid references public.regions(id) on delete set null,
  name_ar text not null,
  name_en text not null,
  center geography(point, 4326),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (country_id, name_en)
);

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  parent_id uuid references public.categories(id) on delete restrict,
  slug text not null unique,
  name_ar text not null,
  name_en text not null,
  icon_key text,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.services (
  id uuid primary key default gen_random_uuid(),
  category_id uuid not null references public.categories(id) on delete restrict,
  slug text not null unique,
  name_ar text not null,
  name_en text not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.profiles (
  id uuid primary key default gen_random_uuid(),
  account_id uuid unique references public.accounts(id) on delete set null,
  display_name text not null,
  headline text,
  bio text,
  avatar_url text,
  cover_url text,
  city_id uuid references public.cities(id) on delete set null,
  service_area_text text,
  approximate_location geography(point, 4326),
  expose_exact_location boolean not null default false,
  languages text[] not null default '{}',
  years_experience smallint check (years_experience between 0 and 80),
  whatsapp text,
  phone text,
  rating numeric(2,1) not null default 0 check (rating between 0 and 5),
  review_count integer not null default 0 check (review_count >= 0),
  verification verification_status not null default 'unverified',
  publication publication_status not null default 'draft',
  search_document tsvector generated always as (to_tsvector('simple', coalesce(display_name, '') || ' ' || coalesce(headline, '') || ' ' || coalesce(bio, ''))) stored,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table public.businesses (
  id uuid primary key default gen_random_uuid(),
  created_by uuid references public.accounts(id) on delete set null default auth.uid(),
  name text not null,
  slug text not null unique,
  description text,
  logo_url text,
  cover_url text,
  website_url text,
  whatsapp text,
  phone text,
  social_links jsonb not null default '{}',
  rating numeric(2,1) not null default 0 check (rating between 0 and 5),
  review_count integer not null default 0 check (review_count >= 0),
  verification verification_status not null default 'unverified',
  publication publication_status not null default 'draft',
  search_document tsvector generated always as (to_tsvector('simple', coalesce(name, '') || ' ' || coalesce(description, ''))) stored,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table public.business_members (
  business_id uuid not null references public.businesses(id) on delete cascade,
  account_id uuid not null references public.accounts(id) on delete cascade,
  role member_role not null,
  permissions jsonb not null default '{}',
  invited_by uuid references public.accounts(id) on delete set null,
  accepted_at timestamptz,
  created_at timestamptz not null default now(),
  primary key (business_id, account_id)
);

create table public.business_branches (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  city_id uuid not null references public.cities(id) on delete restrict,
  name text not null,
  address text,
  public_location geography(point, 4326),
  opening_hours jsonb not null default '{}',
  phone text,
  publication publication_status not null default 'draft',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table public.profile_services (
  profile_id uuid not null references public.profiles(id) on delete cascade,
  service_id uuid not null references public.services(id) on delete restrict,
  price_from numeric(12,2),
  currency char(3),
  is_available boolean not null default true,
  created_at timestamptz not null default now(),
  primary key (profile_id, service_id)
);

create table public.business_services (
  business_id uuid not null references public.businesses(id) on delete cascade,
  service_id uuid not null references public.services(id) on delete restrict,
  price_from numeric(12,2),
  currency char(3),
  created_at timestamptz not null default now(),
  primary key (business_id, service_id)
);

create table public.media (
  id uuid primary key default gen_random_uuid(),
  owner_account_id uuid references public.accounts(id) on delete set null,
  entity_kind entity_kind not null,
  entity_id uuid not null,
  storage_key text not null,
  original_url text not null,
  medium_url text,
  thumbnail_url text,
  mime_type text not null,
  byte_size bigint not null check (byte_size > 0),
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table public.service_requests (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references public.accounts(id) on delete cascade,
  country_id uuid not null references public.countries(id) on delete restrict,
  city_id uuid not null references public.cities(id) on delete restrict,
  category_id uuid not null references public.categories(id) on delete restrict,
  service_id uuid references public.services(id) on delete restrict,
  title text not null check (char_length(title) between 5 and 140),
  description text not null check (char_length(description) between 10 and 4000),
  starts_at timestamptz,
  ends_at timestamptz,
  budget_min numeric(12,2),
  budget_max numeric(12,2),
  currency char(3),
  expires_at timestamptz not null,
  status request_status not null default 'open',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  check (budget_min is null or budget_max is null or budget_min <= budget_max)
);

create table public.request_offers (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references public.service_requests(id) on delete cascade,
  provider_account_id uuid not null references public.accounts(id) on delete cascade,
  profile_id uuid references public.profiles(id) on delete restrict,
  business_id uuid references public.businesses(id) on delete restrict,
  price numeric(12,2) not null check (price >= 0),
  currency char(3) not null,
  description text not null check (char_length(description) between 5 and 2000),
  delivery_time text,
  available_at timestamptz,
  status proposal_status not null default 'submitted',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (request_id, provider_account_id),
  check ((profile_id is not null)::int + (business_id is not null)::int = 1)
);

create table public.conversations (
  id uuid primary key default gen_random_uuid(),
  request_id uuid references public.service_requests(id) on delete set null,
  offer_id uuid references public.request_offers(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.conversation_members (
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  account_id uuid not null references public.accounts(id) on delete cascade,
  last_read_at timestamptz,
  is_muted boolean not null default false,
  created_at timestamptz not null default now(),
  primary key (conversation_id, account_id)
);

create table public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  sender_id uuid not null references public.accounts(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 4000),
  attachment jsonb,
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table public.offers (
  id uuid primary key default gen_random_uuid(),
  business_id uuid references public.businesses(id) on delete cascade,
  profile_id uuid references public.profiles(id) on delete cascade,
  branch_id uuid references public.business_branches(id) on delete set null,
  category_id uuid references public.categories(id) on delete restrict,
  title text not null,
  description text,
  image_url text,
  old_price numeric(12,2),
  new_price numeric(12,2),
  currency char(3),
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  terms text,
  publication publication_status not null default 'draft',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check ((profile_id is not null)::int + (business_id is not null)::int = 1),
  check (ends_at > starts_at)
);

create table public.reviews (
  id uuid primary key default gen_random_uuid(),
  reviewer_id uuid not null references public.accounts(id) on delete cascade,
  profile_id uuid references public.profiles(id) on delete cascade,
  business_id uuid references public.businesses(id) on delete cascade,
  rating smallint not null check (rating between 1 and 5),
  comment text check (char_length(comment) <= 2000),
  status publication_status not null default 'published',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check ((profile_id is not null)::int + (business_id is not null)::int = 1),
  unique nulls not distinct (reviewer_id, profile_id, business_id)
);

create table public.favorites (
  account_id uuid not null references public.accounts(id) on delete cascade,
  entity_kind entity_kind not null,
  entity_id uuid not null,
  created_at timestamptz not null default now(),
  primary key (account_id, entity_kind, entity_id)
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  account_id uuid not null references public.accounts(id) on delete cascade,
  kind text not null,
  title text not null,
  body text,
  data jsonb not null default '{}',
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.notification_preferences (
  account_id uuid primary key references public.accounts(id) on delete cascade,
  matching_requests boolean not null default true,
  messages boolean not null default true,
  offer_updates boolean not null default true,
  nearby_promotions boolean not null default false,
  marketing boolean not null default false,
  updated_at timestamptz not null default now()
);

create table public.verification_requests (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references public.accounts(id) on delete cascade,
  entity_kind entity_kind not null,
  entity_id uuid not null,
  document_keys text[] not null default '{}',
  status verification_status not null default 'pending',
  reviewer_id uuid references public.accounts(id) on delete set null,
  reviewer_note text,
  created_at timestamptz not null default now(),
  reviewed_at timestamptz
);

create table public.claim_requests (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references public.accounts(id) on delete cascade,
  entity_kind entity_kind not null,
  entity_id uuid not null,
  evidence_keys text[] not null default '{}',
  status verification_status not null default 'pending',
  reviewer_id uuid references public.accounts(id) on delete set null,
  created_at timestamptz not null default now(),
  reviewed_at timestamptz
);

create table public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.accounts(id) on delete cascade,
  target_type text not null,
  target_id uuid not null,
  reason text not null,
  details text,
  status text not null default 'open' check (status in ('open', 'reviewing', 'resolved', 'dismissed')),
  created_at timestamptz not null default now(),
  resolved_at timestamptz
);

create table public.blocks (
  blocker_id uuid not null references public.accounts(id) on delete cascade,
  blocked_id uuid not null references public.accounts(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);

create table public.device_tokens (
  id uuid primary key default gen_random_uuid(),
  account_id uuid not null references public.accounts(id) on delete cascade,
  token_hash text not null unique,
  platform text not null check (platform in ('ios', 'android', 'web')),
  last_seen_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table public.admin_actions (
  id bigint generated always as identity primary key,
  actor_id uuid not null references public.accounts(id) on delete restrict,
  action text not null,
  target_type text not null,
  target_id uuid,
  metadata jsonb not null default '{}',
  created_at timestamptz not null default now()
);

create index cities_center_gix on public.cities using gist(center);
create index profiles_location_gix on public.profiles using gist(approximate_location) where deleted_at is null;
create index branches_location_gix on public.business_branches using gist(public_location) where deleted_at is null;
create index profiles_search_gin on public.profiles using gin(search_document);
create index businesses_search_gin on public.businesses using gin(search_document);
create index profiles_city_published_idx on public.profiles(city_id, rating desc) where publication = 'published' and deleted_at is null;
create index branches_city_published_idx on public.business_branches(city_id, business_id) where publication = 'published' and deleted_at is null;
create index requests_discovery_idx on public.service_requests(city_id, category_id, created_at desc) where status = 'open' and deleted_at is null;
create index request_offers_request_idx on public.request_offers(request_id, status, created_at desc);
create index messages_conversation_idx on public.messages(conversation_id, created_at desc) where deleted_at is null;
create index notifications_account_idx on public.notifications(account_id, created_at desc);
create index offers_active_idx on public.offers(ends_at, starts_at) where publication = 'published';

create or replace function public.touch_updated_at() returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end;
$$;

create or replace function public.handle_new_auth_user() returns trigger security definer set search_path = public language plpgsql as $$
begin
  insert into public.accounts(id, display_name) values (new.id, coalesce(new.raw_user_meta_data->>'name', ''));
  insert into public.account_roles(account_id, role) values (new.id, 'user');
  insert into public.notification_preferences(account_id) values (new.id);
  return new;
end;
$$;

create or replace function public.add_business_creator_as_owner() returns trigger security definer set search_path = public language plpgsql as $$
begin
  if new.created_by is not null then
    insert into public.business_members(business_id, account_id, role, accepted_at)
    values (new.id, new.created_by, 'owner', now()) on conflict do nothing;
  end if;
  return new;
end;
$$;

create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_auth_user();
create trigger on_business_created after insert on public.businesses for each row execute procedure public.add_business_creator_as_owner();

create or replace function public.is_staff() returns boolean language sql stable security definer set search_path = public as $$
  select exists(select 1 from public.account_roles where account_id = auth.uid() and role in ('moderator', 'country_manager', 'super_admin'));
$$;

create or replace function public.can_manage_business(target_business_id uuid) returns boolean language sql stable security definer set search_path = public as $$
  select public.is_staff() or exists(select 1 from public.business_members where business_id = target_business_id and account_id = auth.uid() and accepted_at is not null);
$$;

create or replace function public.is_conversation_member(target_conversation_id uuid) returns boolean language sql stable security definer set search_path = public as $$
  select exists(select 1 from public.conversation_members where conversation_id = target_conversation_id and account_id = auth.uid());
$$;

create or replace function public.nearby_profiles(origin_lat double precision, origin_lng double precision, radius_m integer default 25000, result_limit integer default 20)
returns table(profile_id uuid, distance_m double precision) language sql stable as $$
  select p.id, st_distance(p.approximate_location, st_setsrid(st_makepoint(origin_lng, origin_lat), 4326)::geography) as distance_m
  from public.profiles p
  where p.publication = 'published' and p.deleted_at is null and p.approximate_location is not null
    and st_dwithin(p.approximate_location, st_setsrid(st_makepoint(origin_lng, origin_lat), 4326)::geography, least(radius_m, 100000))
  order by distance_m limit least(result_limit, 100);
$$;

do $$ declare table_name text; begin
  foreach table_name in array array['accounts','countries','regions','cities','categories','services','profiles','businesses','business_branches','service_requests','request_offers','conversations','offers','reviews']
  loop execute format('create trigger touch_%1$s before update on public.%1$s for each row execute procedure public.touch_updated_at()', table_name); end loop;
end $$;

alter table public.accounts enable row level security;
alter table public.account_roles enable row level security;
alter table public.countries enable row level security;
alter table public.regions enable row level security;
alter table public.cities enable row level security;
alter table public.categories enable row level security;
alter table public.services enable row level security;
alter table public.profiles enable row level security;
alter table public.businesses enable row level security;
alter table public.business_members enable row level security;
alter table public.business_branches enable row level security;
alter table public.profile_services enable row level security;
alter table public.business_services enable row level security;
alter table public.media enable row level security;
alter table public.service_requests enable row level security;
alter table public.request_offers enable row level security;
alter table public.conversations enable row level security;
alter table public.conversation_members enable row level security;
alter table public.messages enable row level security;
alter table public.offers enable row level security;
alter table public.reviews enable row level security;
alter table public.favorites enable row level security;
alter table public.notifications enable row level security;
alter table public.notification_preferences enable row level security;
alter table public.verification_requests enable row level security;
alter table public.claim_requests enable row level security;
alter table public.reports enable row level security;
alter table public.blocks enable row level security;
alter table public.device_tokens enable row level security;
alter table public.admin_actions enable row level security;

create policy "public reference data" on public.countries for select using (is_active);
create policy "public regions" on public.regions for select using (true);
create policy "public cities" on public.cities for select using (is_active);
create policy "public categories" on public.categories for select using (is_active);
create policy "public services" on public.services for select using (is_active);
create policy "public published profiles" on public.profiles for select using (publication = 'published' and deleted_at is null or account_id = auth.uid() or public.is_staff());
create policy "profile owner insert" on public.profiles for insert with check (account_id = auth.uid());
create policy "profile owner update" on public.profiles for update using (account_id = auth.uid() or public.is_staff()) with check (account_id = auth.uid() or public.is_staff());
create policy "public published businesses" on public.businesses for select using (publication = 'published' and deleted_at is null or public.can_manage_business(id));
create policy "authenticated create business" on public.businesses for insert to authenticated with check (created_by = auth.uid());
create policy "business managers update" on public.businesses for update using (public.can_manage_business(id)) with check (public.can_manage_business(id));
create policy "members see own business team" on public.business_members for select using (account_id = auth.uid() or public.can_manage_business(business_id));
create policy "owners manage members" on public.business_members for all using (public.can_manage_business(business_id)) with check (public.can_manage_business(business_id));
create policy "public branches" on public.business_branches for select using (publication = 'published' and deleted_at is null or public.can_manage_business(business_id));
create policy "business managers manage branches" on public.business_branches for all using (public.can_manage_business(business_id)) with check (public.can_manage_business(business_id));
create policy "public profile services" on public.profile_services for select using (exists(select 1 from public.profiles p where p.id = profile_id and p.publication = 'published'));
create policy "profile owners manage services" on public.profile_services for all using (exists(select 1 from public.profiles p where p.id = profile_id and p.account_id = auth.uid()) or public.is_staff()) with check (exists(select 1 from public.profiles p where p.id = profile_id and p.account_id = auth.uid()) or public.is_staff());
create policy "public business services" on public.business_services for select using (exists(select 1 from public.businesses b where b.id = business_id and b.publication = 'published'));
create policy "business managers manage services" on public.business_services for all using (public.can_manage_business(business_id)) with check (public.can_manage_business(business_id));
create policy "account reads self" on public.accounts for select using (id = auth.uid() or public.is_staff());
create policy "account updates self" on public.accounts for update using (id = auth.uid()) with check (id = auth.uid());
create policy "roles read self" on public.account_roles for select using (account_id = auth.uid() or public.is_staff());
create policy "staff manage reference countries" on public.countries for all using (public.is_staff()) with check (public.is_staff());
create policy "staff manage reference regions" on public.regions for all using (public.is_staff()) with check (public.is_staff());
create policy "staff manage reference cities" on public.cities for all using (public.is_staff()) with check (public.is_staff());
create policy "staff manage reference categories" on public.categories for all using (public.is_staff()) with check (public.is_staff());
create policy "staff manage reference services" on public.services for all using (public.is_staff()) with check (public.is_staff());
create policy "public open requests" on public.service_requests for select using (status = 'open' and deleted_at is null or requester_id = auth.uid() or public.is_staff());
create policy "requester creates request" on public.service_requests for insert to authenticated with check (requester_id = auth.uid());
create policy "requester manages request" on public.service_requests for update using (requester_id = auth.uid() or public.is_staff()) with check (requester_id = auth.uid() or public.is_staff());
create policy "offer parties read" on public.request_offers for select using (provider_account_id = auth.uid() or exists(select 1 from public.service_requests r where r.id = request_id and r.requester_id = auth.uid()) or public.is_staff());
create policy "provider submits offer" on public.request_offers for insert to authenticated with check (provider_account_id = auth.uid());
create policy "offer parties update" on public.request_offers for update using (provider_account_id = auth.uid() or exists(select 1 from public.service_requests r where r.id = request_id and r.requester_id = auth.uid())) with check (provider_account_id = auth.uid() or exists(select 1 from public.service_requests r where r.id = request_id and r.requester_id = auth.uid()));
create policy "conversation members read" on public.conversations for select using (public.is_conversation_member(id));
create policy "authenticated creates conversation" on public.conversations for insert to authenticated with check (true);
create policy "members read membership" on public.conversation_members for select using (public.is_conversation_member(conversation_id));
create policy "members add membership" on public.conversation_members for insert to authenticated with check (account_id = auth.uid() or public.is_conversation_member(conversation_id));
create policy "members read messages" on public.messages for select using (public.is_conversation_member(conversation_id));
create policy "members send messages" on public.messages for insert with check (sender_id = auth.uid() and public.is_conversation_member(conversation_id));
create policy "public active offers" on public.offers for select using (publication = 'published' and starts_at <= now() and ends_at > now());
create policy "offer owner manages" on public.offers for all using ((profile_id is not null and exists(select 1 from public.profiles p where p.id = profile_id and p.account_id = auth.uid())) or (business_id is not null and public.can_manage_business(business_id)) or public.is_staff()) with check ((profile_id is not null and exists(select 1 from public.profiles p where p.id = profile_id and p.account_id = auth.uid())) or (business_id is not null and public.can_manage_business(business_id)) or public.is_staff());
create policy "public reviews" on public.reviews for select using (status = 'published');
create policy "reviewer creates" on public.reviews for insert with check (reviewer_id = auth.uid() and not exists(select 1 from public.profiles p where p.id = profile_id and p.account_id = auth.uid()) and not exists(select 1 from public.business_members bm where bm.business_id = reviews.business_id and bm.account_id = auth.uid()));
create policy "reviewer updates own" on public.reviews for update using (reviewer_id = auth.uid() or public.is_staff()) with check (reviewer_id = auth.uid() or public.is_staff());
create policy "favorites own" on public.favorites for all using (account_id = auth.uid()) with check (account_id = auth.uid());
create policy "notifications own" on public.notifications for select using (account_id = auth.uid());
create policy "notifications mark own" on public.notifications for update using (account_id = auth.uid()) with check (account_id = auth.uid());
create policy "preferences own" on public.notification_preferences for all using (account_id = auth.uid()) with check (account_id = auth.uid());
create policy "verification requester read" on public.verification_requests for select using (requester_id = auth.uid() or public.is_staff());
create policy "verification requester create" on public.verification_requests for insert with check (requester_id = auth.uid());
create policy "claims requester read" on public.claim_requests for select using (requester_id = auth.uid() or public.is_staff());
create policy "claims requester create" on public.claim_requests for insert with check (requester_id = auth.uid());
create policy "reports requester create" on public.reports for insert with check (reporter_id = auth.uid());
create policy "reports requester or staff read" on public.reports for select using (reporter_id = auth.uid() or public.is_staff());
create policy "blocks own" on public.blocks for all using (blocker_id = auth.uid()) with check (blocker_id = auth.uid());
create policy "tokens own" on public.device_tokens for all using (account_id = auth.uid()) with check (account_id = auth.uid());
create policy "media public read" on public.media for select using (true);
create policy "media owner manage" on public.media for all using (owner_account_id = auth.uid() or public.is_staff()) with check (owner_account_id = auth.uid() or public.is_staff());
create policy "staff verification manage" on public.verification_requests for update using (public.is_staff()) with check (public.is_staff());
create policy "staff claims manage" on public.claim_requests for update using (public.is_staff()) with check (public.is_staff());
create policy "staff reports manage" on public.reports for update using (public.is_staff()) with check (public.is_staff());
create policy "staff audit read" on public.admin_actions for select using (public.is_staff());
create policy "staff audit write" on public.admin_actions for insert with check (public.is_staff() and actor_id = auth.uid());

commit;
