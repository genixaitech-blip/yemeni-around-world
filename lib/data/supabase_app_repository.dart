import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_repository.dart';
import 'models.dart';

class SupabaseAppRepository implements AppRepository {
  SupabaseAppRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Category>> getCategories() async {
    final rows = await _client
        .from('categories')
        .select('slug,name_ar,name_en,icon_key')
        .eq('is_active', true)
        .order('sort_order');
    return rows.map<Category>((row) => Category(
      id: row['slug'] as String,
      nameAr: row['name_ar'] as String,
      nameEn: row['name_en'] as String,
      icon: _categoryIcon(row['icon_key'] as String?),
    )).toList();
  }

  @override
  Future<List<Listing>> search({
    String query = '',
    String? country,
    String? city,
    String? categoryId,
    bool nearby = false,
  }) async {
    final rows = await _client.rpc('search_directory', params: {
      'search_query': _normalizeQuery(query),
      'country_name': _nullIfEmpty(country),
      'city_name': _nullIfEmpty(city),
      'category_slug': _nullIfEmpty(categoryId),
      'only_with_location': nearby,
    });
    return (rows as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(_listingFromRow)
        .toList(growable: false);
  }

  @override
  Future<Listing?> getListing(String id) async {
    final rows = await _client.rpc('search_directory', params: {
      'listing_id': id,
    });
    final list = rows as List<dynamic>;
    if (list.isEmpty) return null;
    return _listingFromRow(list.first as Map<String, dynamic>);
  }

  @override
  Future<List<ServiceRequest>> getRequests() async {
    final rows = await _client
        .from('service_requests')
        .select('id,title,description,budget_max,created_at,country:countries(name_ar),city:cities(name_ar),category:categories(slug),request_offers(count)')
        .eq('status', 'open')
        .order('created_at', ascending: false);
    return rows.map<ServiceRequest>((row) {
      final createdAt = DateTime.parse(row['created_at'] as String).toLocal();
      final offerCounts = row['request_offers'] as List<dynamic>? ?? const [];
      final offerCount = offerCounts.isEmpty ? 0 : _asInt((offerCounts.first as Map<String, dynamic>)['count']);
      return ServiceRequest(
        id: row['id'] as String,
        title: row['title'] as String,
        description: row['description'] as String,
        place: PlaceRef(
          country: ((row['country'] as Map<String, dynamic>?)?['name_ar'] as String?) ?? '',
          city: ((row['city'] as Map<String, dynamic>?)?['name_ar'] as String?) ?? '',
        ),
        categoryId: ((row['category'] as Map<String, dynamic>?)?['slug'] as String?) ?? '',
        createdAgo: _createdAgo(createdAt),
        offerCount: offerCount,
        budget: _asNullableInt(row['budget_max']),
      );
    }).toList();
  }

  @override
  Future<List<DealOffer>> getOffers() async {
    final rows = await _client
        .from('offers')
        .select('id,title,old_price,new_price,ends_at,business:businesses(name),profile:profiles(display_name),branch:business_branches(city:cities(name_ar))')
        .eq('publication', 'published')
        .lte('starts_at', DateTime.now().toUtc().toIso8601String())
        .gt('ends_at', DateTime.now().toUtc().toIso8601String())
        .order('ends_at');
    return rows.map<DealOffer>((row) {
      final business = row['business'] as Map<String, dynamic>?;
      final profile = row['profile'] as Map<String, dynamic>?;
      final branch = row['branch'] as Map<String, dynamic>?;
      final city = branch?['city'] as Map<String, dynamic>?;
      final end = DateTime.parse(row['ends_at'] as String).toLocal();
      final days = end.difference(DateTime.now()).inDays;
      return DealOffer(
        id: row['id'] as String,
        title: row['title'] as String,
        businessName: (business?['name'] ?? profile?['display_name'] ?? '') as String,
        city: (city?['name_ar'] as String?) ?? '',
        oldPrice: _asInt(row['old_price']),
        newPrice: _asInt(row['new_price']),
        endsIn: days <= 0 ? 'ينتهي اليوم' : 'متبقي $days أيام',
      );
    }).toList();
  }

  @override
  Future<void> createRequest({
    required String title,
    required String description,
    required String country,
    required String city,
    required String category,
    int? budget,
    DateTime? startsAt,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('Authentication is required');

    final countryRow = await _client.from('countries').select('id').eq('name_ar', country).single();
    final cityRow = await _client
        .from('cities')
        .select('id')
        .eq('country_id', countryRow['id'])
        .eq('name_ar', city)
        .single();
    final categoryRow = await _client.from('categories').select('id').eq('name_ar', category).single();

    await _client.from('service_requests').insert({
      'requester_id': user.id,
      'country_id': countryRow['id'],
      'city_id': cityRow['id'],
      'category_id': categoryRow['id'],
      'title': title.trim(),
      'description': description.trim(),
      'starts_at': startsAt?.toUtc().toIso8601String(),
      'budget_max': budget,
      'currency': budget == null ? null : 'USD',
      'expires_at': DateTime.now().toUtc().add(const Duration(days: 30)).toIso8601String(),
    });
  }

  Listing _listingFromRow(Map<String, dynamic> row) => Listing(
    id: row['id'] as String,
    type: row['entity_type'] == 'business' ? ListingType.business : ListingType.person,
    name: row['name'] as String,
    subtitle: (row['subtitle'] as String?) ?? '',
    categoryId: (row['category_slug'] as String?) ?? '',
    place: PlaceRef(
      country: (row['country_name'] as String?) ?? '',
      city: (row['city_name'] as String?) ?? '',
    ),
    rating: _asDouble(row['rating']),
    reviewCount: _asInt(row['review_count']),
    verified: row['verified'] == true,
    imageUrl: (row['image_url'] as String?) ?? '',
    about: (row['about'] as String?) ?? '',
    languages: (row['languages'] as List<dynamic>? ?? const []).cast<String>(),
    distanceKm: _asNullableDouble(row['distance_km']),
    priceFrom: _asNullableInt(row['price_from']),
    latitude: _asNullableDouble(row['latitude']),
    longitude: _asNullableDouble(row['longitude']),
    availableNow: row['available_now'] == true,
  );

  String? _nullIfEmpty(String? value) => value == null || value.trim().isEmpty ? null : value.trim();
  static String _normalizeQuery(String input) {
    const ignored = {'في', 'من', 'الى', 'إلى', 'يمني', 'يمنية'};
    return input
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 1 && !ignored.contains(word))
        .join(' ');
  }

  static String _categoryIcon(String? key) => switch (key) {
    'translate' => '文',
    'restaurant' => '☕',
    'directions_car' => '↗',
    'local_shipping' => '▣',
    'home' => '⌂',
    'photo_camera' => '●',
    'storefront' => '◆',
    'code' => '</>',
    _ => '•',
  };

  static double _asDouble(dynamic value) => value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
  static double? _asNullableDouble(dynamic value) => value == null ? null : _asDouble(value);
  static int _asInt(dynamic value) => value is num ? value.round() : int.tryParse('$value') ?? 0;
  static int? _asNullableInt(dynamic value) => value == null ? null : _asInt(value);

  static String _createdAgo(DateTime value) {
    final difference = DateTime.now().difference(value);
    if (difference.inMinutes < 60) return 'منذ ${difference.inMinutes.clamp(1, 59)} دقيقة';
    if (difference.inHours < 24) return 'منذ ${difference.inHours} ساعة';
    return 'منذ ${difference.inDays} يوم';
  }
}
