import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_config.dart';
import 'app_repository.dart';
import 'auth_controller.dart';
import 'mock_repository.dart';
import 'models.dart';
import 'supabase_app_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  return AppConfig.hasSupabase ? Supabase.instance.client : null;
});
final appRepositoryProvider = Provider<AppRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? MockAppRepository() : SupabaseAppRepository(client);
});
final categoriesProvider = FutureProvider<List<Category>>((ref) => ref.watch(appRepositoryProvider).getCategories());
final homeListingsProvider = FutureProvider<List<Listing>>((ref) => ref.watch(appRepositoryProvider).search());
final requestsProvider = FutureProvider<List<ServiceRequest>>((ref) => ref.watch(appRepositoryProvider).getRequests());
final dealsProvider = FutureProvider<List<DealOffer>>((ref) => ref.watch(appRepositoryProvider).getOffers());
final favoritesProvider = StateProvider<Set<String>>((ref) => <String>{});
final authControllerProvider = StateNotifierProvider<AppAuthController, bool>((ref) {
  return AppAuthController(ref.watch(supabaseClientProvider));
});
final signedInProvider = Provider<bool>((ref) => ref.watch(authControllerProvider));

class SearchFilters {
  const SearchFilters({this.query = '', this.country, this.city, this.categoryId, this.nearby = false});
  final String query;
  final String? country;
  final String? city;
  final String? categoryId;
  final bool nearby;

  SearchFilters copyWith({String? query, String? country, String? city, String? categoryId, bool? nearby}) => SearchFilters(
    query: query ?? this.query,
    country: country ?? this.country,
    city: city ?? this.city,
    categoryId: categoryId ?? this.categoryId,
    nearby: nearby ?? this.nearby,
  );
}

final searchFiltersProvider = StateProvider<SearchFilters>((ref) => const SearchFilters());
final searchResultsProvider = FutureProvider<List<Listing>>((ref) {
  final filters = ref.watch(searchFiltersProvider);
  return ref.watch(appRepositoryProvider).search(
    query: filters.query,
    country: filters.country,
    city: filters.city,
    categoryId: filters.categoryId,
    nearby: filters.nearby,
  );
});
