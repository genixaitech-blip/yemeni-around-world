insert into public.countries(id, iso2, name_ar, name_en) values
('10000000-0000-0000-0000-000000000001', 'SA', 'السعودية', 'Saudi Arabia'),
('10000000-0000-0000-0000-000000000002', 'EG', 'مصر', 'Egypt'),
('10000000-0000-0000-0000-000000000003', 'MY', 'ماليزيا', 'Malaysia'),
('10000000-0000-0000-0000-000000000004', 'IN', 'الهند', 'India'),
('10000000-0000-0000-0000-000000000005', 'US', 'أمريكا', 'United States')
on conflict do nothing;

insert into public.cities(id, country_id, name_ar, name_en, center) values
('20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'الرياض', 'Riyadh', st_point(46.6753, 24.7136)::geography),
('20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', 'جدة', 'Jeddah', st_point(39.1925, 21.4858)::geography),
('20000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000002', 'القاهرة', 'Cairo', st_point(31.2357, 30.0444)::geography),
('20000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000003', 'كوالالمبور', 'Kuala Lumpur', st_point(101.6869, 3.1390)::geography),
('20000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000004', 'نيودلهي', 'New Delhi', st_point(77.2090, 28.6139)::geography),
('20000000-0000-0000-0000-000000000006', '10000000-0000-0000-0000-000000000005', 'نيويورك', 'New York', st_point(-74.0060, 40.7128)::geography)
on conflict do nothing;

insert into public.categories(id, slug, name_ar, name_en, icon_key, sort_order) values
('30000000-0000-0000-0000-000000000001', 'translation', 'ترجمة', 'Translation', 'translate', 1),
('30000000-0000-0000-0000-000000000002', 'restaurants', 'مطاعم', 'Restaurants', 'restaurant', 2),
('30000000-0000-0000-0000-000000000003', 'transport', 'نقل وسائقون', 'Transport', 'directions_car', 3),
('30000000-0000-0000-0000-000000000004', 'shipping', 'شحن', 'Shipping', 'local_shipping', 4),
('30000000-0000-0000-0000-000000000005', 'housing', 'سكن', 'Housing', 'home', 5),
('30000000-0000-0000-0000-000000000006', 'photo', 'تصوير', 'Photography', 'photo_camera', 6),
('30000000-0000-0000-0000-000000000007', 'honey', 'عسل ومتاجر', 'Honey and shops', 'storefront', 7),
('30000000-0000-0000-0000-000000000008', 'tech', 'تقنية', 'Technology', 'code', 8)
on conflict do nothing;

insert into public.services(category_id, slug, name_ar, name_en) values
('30000000-0000-0000-0000-000000000001', 'interpreter', 'مترجم ومرافق', 'Interpreter and companion'),
('30000000-0000-0000-0000-000000000002', 'yemeni-food', 'مطعم يمني', 'Yemeni restaurant'),
('30000000-0000-0000-0000-000000000003', 'airport-pickup', 'استقبال مطار', 'Airport pickup'),
('30000000-0000-0000-0000-000000000004', 'international-shipping', 'شحن دولي', 'International shipping'),
('30000000-0000-0000-0000-000000000005', 'student-housing', 'سكن طلاب', 'Student housing'),
('30000000-0000-0000-0000-000000000006', 'event-photo', 'تصوير فعاليات', 'Event photography'),
('30000000-0000-0000-0000-000000000007', 'yemeni-honey', 'عسل يمني', 'Yemeni honey'),
('30000000-0000-0000-0000-000000000008', 'software-development', 'تطوير برمجيات', 'Software development')
on conflict do nothing;

insert into public.profiles(id, display_name, headline, bio, city_id, service_area_text, approximate_location, languages, years_experience, rating, review_count, verification, publication) values
('40000000-0000-0000-0000-000000000001', 'محمد علي', 'مترجم ومرافق أعمال', 'مترجم عربي وإنجليزي وهندي لمواعيد العمل والسفر.', '20000000-0000-0000-0000-000000000005', 'نيودلهي وضواحيها', st_point(77.21, 28.61)::geography, array['ar','en','hi'], 8, 4.9, 126, 'verified', 'published'),
('40000000-0000-0000-0000-000000000002', 'سالم القباطي', 'سائق واستقبال مطار', 'استقبال مطار وجولات خاصة للعائلات والطلاب.', '20000000-0000-0000-0000-000000000004', 'كوالالمبور', st_point(101.69, 3.14)::geography, array['ar','en','ms'], 6, 4.9, 203, 'verified', 'published'),
('40000000-0000-0000-0000-000000000003', 'أروى الحكيمي', 'مصورة فعاليات وفيديو', 'تغطية احترافية للفعاليات والمناسبات.', '20000000-0000-0000-0000-000000000001', 'الرياض', st_point(46.68, 24.72)::geography, array['ar','en'], 5, 4.9, 74, 'verified', 'published')
on conflict do nothing;

insert into public.businesses(id, name, slug, description, rating, review_count, verification, publication) values
('50000000-0000-0000-0000-000000000001', 'باب اليمن', 'bab-al-yemen-riyadh', 'مطعم يمني أصيل في الرياض.', 4.8, 842, 'verified', 'published'),
('50000000-0000-0000-0000-000000000002', 'سكن روافد الطلاب', 'rawafed-student-housing', 'غرف مفروشة وخدمة استقبال للطلاب.', 4.7, 91, 'verified', 'published'),
('50000000-0000-0000-0000-000000000003', 'سبأ للشحن الدولي', 'saba-shipping-new-york', 'شحن جوي وبحري من أمريكا إلى اليمن.', 4.6, 318, 'verified', 'published'),
('50000000-0000-0000-0000-000000000004', 'مناحل حضرموت', 'hadramout-honey-cairo', 'عسل سدر يمني مع توصيل داخل القاهرة.', 4.8, 159, 'unverified', 'published'),
('50000000-0000-0000-0000-000000000005', 'جينيس للتقنية', 'genix-technology', 'حلول رقمية وأتمتة للشركات.', 5.0, 48, 'verified', 'published')
on conflict do nothing;

insert into public.business_branches(business_id, city_id, name, address, public_location, publication) values
('50000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'فرع الرياض', 'حي الملز، الرياض', st_point(46.68, 24.71)::geography, 'published'),
('50000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000004', 'السكن الرئيسي', 'كوالالمبور', st_point(101.69, 3.14)::geography, 'published'),
('50000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000006', 'مكتب نيويورك', 'New York, NY', st_point(-74.00, 40.71)::geography, 'published'),
('50000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000003', 'فرع القاهرة', 'مدينة نصر، القاهرة', st_point(31.33, 30.06)::geography, 'published'),
('50000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000003', 'مكتب القاهرة', 'القاهرة', st_point(31.24, 30.04)::geography, 'published');

insert into public.profile_services(profile_id, service_id, price_from, currency, is_available)
select assignments.profile_id, services.id, assignments.price_from, 'USD', true
from (values
  ('40000000-0000-0000-0000-000000000001'::uuid, 'interpreter', 45::numeric),
  ('40000000-0000-0000-0000-000000000002'::uuid, 'airport-pickup', 30::numeric),
  ('40000000-0000-0000-0000-000000000003'::uuid, 'event-photo', 650::numeric)
) as assignments(profile_id, service_slug, price_from)
join public.services on services.slug = assignments.service_slug
on conflict do nothing;

insert into public.business_services(business_id, service_id, price_from, currency)
select assignments.business_id, services.id, assignments.price_from, 'USD'
from (values
  ('50000000-0000-0000-0000-000000000001'::uuid, 'yemeni-food', 12::numeric),
  ('50000000-0000-0000-0000-000000000002'::uuid, 'student-housing', 180::numeric),
  ('50000000-0000-0000-0000-000000000003'::uuid, 'international-shipping', 65::numeric),
  ('50000000-0000-0000-0000-000000000004'::uuid, 'yemeni-honey', 40::numeric),
  ('50000000-0000-0000-0000-000000000005'::uuid, 'software-development', 500::numeric)
) as assignments(business_id, service_slug, price_from)
join public.services on services.slug = assignments.service_slug
on conflict do nothing;

insert into public.offers(id, business_id, category_id, title, description, old_price, new_price, currency, starts_at, ends_at, publication)
values
  ('60000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000002', 'خصم غداء العائلة', 'عرض لفترة محدودة على وجبة العائلة.', 180, 135, 'USD', now() - interval '1 day', now() + interval '1 day', 'published'),
  ('60000000-0000-0000-0000-000000000002', '50000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000005', 'شهر سكن للطلاب الجدد', 'سعر خاص لأول شهر للطلاب الجدد.', 240, 190, 'USD', now() - interval '1 day', now() + interval '3 days', 'published'),
  ('60000000-0000-0000-0000-000000000003', '50000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000004', 'شحن أول طرد', 'خصم على أول شحنة دولية.', 90, 65, 'USD', now() - interval '1 day', now() + interval '5 days', 'published')
on conflict (id) do update set
  old_price = excluded.old_price,
  new_price = excluded.new_price,
  starts_at = excluded.starts_at,
  ends_at = excluded.ends_at,
  publication = excluded.publication;
