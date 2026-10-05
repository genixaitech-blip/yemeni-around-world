begin;

create or replace function public.nearby_profiles(origin_lat double precision, origin_lng double precision, radius_m integer default 25000, result_limit integer default 20)
returns table(profile_id uuid, distance_m double precision) language sql stable set search_path = public as $$
  select p.id, st_distance(p.approximate_location, st_setsrid(st_makepoint(origin_lng, origin_lat), 4326)::geography) as distance_m
  from public.profiles p
  where p.publication = 'published' and p.deleted_at is null and p.approximate_location is not null
    and st_dwithin(p.approximate_location, st_setsrid(st_makepoint(origin_lng, origin_lat), 4326)::geography, least(greatest(radius_m,1000), 100000))
  order by distance_m limit least(greatest(result_limit,1), 100);
$$;

do $ begin
  if not exists(select 1 from pg_type t join pg_namespace n on n.oid = t.typnamespace
      where t.typname = 'directory_entry' and n.nspname = 'public') then
    create type public.directory_entry as (
      id text, entity_type text, name text, subtitle text, category_slug text,
      country_name text, city_name text, rating double precision, review_count integer,
      verified boolean, image_url text, about text, languages text[], price_from numeric,
      latitude double precision, longitude double precision, distance_km double precision, available_now boolean
    );
  end if;
end $;
drop function if exists public.search_directory(text,text,text,text,boolean,text,double precision,double precision,integer);

create or replace function public.search_directory(
  search_query text default '',
  country_name text default null,
  city_name text default null,
  category_slug text default null,
  only_with_location boolean default false,
  listing_id text default null,
  origin_lat double precision default null,
  origin_lng double precision default null,
  radius_m integer default 100000
)
returns setof public.directory_entry
language sql
stable
set search_path = public
as $$
  with directory as (
    select
      p.id::text as id,
      'person'::text as entity_type,
      p.display_name as name,
      coalesce(p.headline, '') as subtitle,
      selected_service.category_slug,
      country.name_ar as country_name,
      city.name_ar as city_name,
      p.rating::double precision as rating,
      p.review_count,
      p.verification = 'verified' as verified,
      coalesce(p.avatar_url, '') as image_url,
      coalesce(p.bio, '') as about,
      p.languages,
      selected_service.price_from,
      st_y(p.approximate_location::geometry) as latitude,
      st_x(p.approximate_location::geometry) as longitude,
      case
        when search_directory.origin_lat is null or search_directory.origin_lng is null or p.approximate_location is null then null
        else st_distance(
          p.approximate_location,
          st_setsrid(st_makepoint(search_directory.origin_lng, search_directory.origin_lat), 4326)::geography
        ) / 1000.0
      end as distance_km,
      coalesce(selected_service.is_available, false) as available_now
    from public.profiles p
    left join public.cities city on city.id = p.city_id
    left join public.countries country on country.id = city.country_id
    left join lateral (
      select c.slug as category_slug, ps.price_from, ps.is_available
      from public.profile_services ps
      join public.services s on s.id = ps.service_id and s.is_active
      join public.categories c on c.id = s.category_id and c.is_active
      where ps.profile_id = p.id
        and (search_directory.category_slug is null or c.slug = search_directory.category_slug)
      order by ps.is_available desc, ps.price_from nulls last, c.sort_order
      limit 1
    ) selected_service on true
    where p.publication = 'published'
      and p.deleted_at is null
      and (search_directory.listing_id is null or p.id::text = search_directory.listing_id)
      and (search_directory.country_name is null or country.name_ar = search_directory.country_name or country.name_en = search_directory.country_name)
      and (search_directory.city_name is null or city.name_ar = search_directory.city_name or city.name_en = search_directory.city_name)
      and (search_directory.category_slug is null or selected_service.category_slug is not null)
      and (not search_directory.only_with_location or p.approximate_location is not null)
      and (
        coalesce(trim(search_directory.search_query), '') = ''
        or p.search_document @@ websearch_to_tsquery('simple', search_directory.search_query)
        or concat_ws(' ', p.display_name, p.headline, p.bio, city.name_ar, country.name_ar) ilike '%' || trim(search_directory.search_query) || '%'
      )
      and (
        search_directory.origin_lat is null or search_directory.origin_lng is null or p.approximate_location is null
        or st_dwithin(
          p.approximate_location,
          st_setsrid(st_makepoint(search_directory.origin_lng, search_directory.origin_lat), 4326)::geography,
          least(greatest(search_directory.radius_m, 1000), 100000)
        )
      )

    union all

    select
      b.id::text,
      'business'::text,
      b.name,
      coalesce(selected_service.service_name, ''),
      selected_service.category_slug,
      branch.country_name,
      branch.city_name,
      b.rating::double precision,
      b.review_count,
      b.verification = 'verified',
      coalesce(b.logo_url, ''),
      coalesce(b.description, ''),
      '{}'::text[],
      selected_service.price_from,
      branch.latitude,
      branch.longitude,
      case
        when search_directory.origin_lat is null or search_directory.origin_lng is null or branch.public_location is null then null
        else st_distance(
          branch.public_location,
          st_setsrid(st_makepoint(search_directory.origin_lng, search_directory.origin_lat), 4326)::geography
        ) / 1000.0
      end,
      true
    from public.businesses b
    left join lateral (
      select
        bb.public_location,
        st_y(bb.public_location::geometry) as latitude,
        st_x(bb.public_location::geometry) as longitude,
        city.name_ar as city_name,
        country.name_ar as country_name
      from public.business_branches bb
      join public.cities city on city.id = bb.city_id
      join public.countries country on country.id = city.country_id
      where bb.business_id = b.id
        and bb.publication = 'published'
        and bb.deleted_at is null
        and (search_directory.country_name is null or country.name_ar = search_directory.country_name or country.name_en = search_directory.country_name)
        and (search_directory.city_name is null or city.name_ar = search_directory.city_name or city.name_en = search_directory.city_name)
      order by case when search_directory.origin_lat is not null and search_directory.origin_lng is not null
        then st_distance(bb.public_location, st_setsrid(st_makepoint(search_directory.origin_lng, search_directory.origin_lat), 4326)::geography)
        end nulls last, bb.created_at
      limit 1
    ) branch on true
    left join lateral (
      select c.slug as category_slug, s.name_ar as service_name, bs.price_from
      from public.business_services bs
      join public.services s on s.id = bs.service_id and s.is_active
      join public.categories c on c.id = s.category_id and c.is_active
      where bs.business_id = b.id
        and (search_directory.category_slug is null or c.slug = search_directory.category_slug)
      order by bs.price_from nulls last, c.sort_order
      limit 1
    ) selected_service on true
    where b.publication = 'published'
      and b.deleted_at is null
      and (search_directory.listing_id is null or b.id::text = search_directory.listing_id)
      and (search_directory.country_name is null or branch.country_name is not null)
      and (search_directory.city_name is null or branch.city_name is not null)
      and (search_directory.category_slug is null or selected_service.category_slug is not null)
      and (not search_directory.only_with_location or branch.public_location is not null)
      and (
        coalesce(trim(search_directory.search_query), '') = ''
        or b.search_document @@ websearch_to_tsquery('simple', search_directory.search_query)
        or concat_ws(' ', b.name, b.description, branch.city_name, branch.country_name) ilike '%' || trim(search_directory.search_query) || '%'
      )
      and (
        search_directory.origin_lat is null or search_directory.origin_lng is null or branch.public_location is null
        or st_dwithin(
          branch.public_location,
          st_setsrid(st_makepoint(search_directory.origin_lng, search_directory.origin_lat), 4326)::geography,
          least(greatest(search_directory.radius_m, 1000), 100000)
        )
      )
  )
  select * from directory
  order by distance_km nulls last, rating desc, review_count desc
  limit 100;
$$;

revoke all on function public.search_directory(text,text,text,text,boolean,text,double precision,double precision,integer) from public;
grant execute on function public.search_directory(text,text,text,text,boolean,text,double precision,double precision,integer) to anon, authenticated;

commit;
