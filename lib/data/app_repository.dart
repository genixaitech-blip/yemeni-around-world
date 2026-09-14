import 'models.dart';

abstract interface class AppRepository {
  Future<List<Category>> getCategories();
  Future<List<Listing>> search({String query = '', String? country, String? city, String? categoryId, bool nearby = false});
  Future<Listing?> getListing(String id);
  Future<List<ServiceRequest>> getRequests();
  Future<List<DealOffer>> getOffers();
  Future<void> createRequest({
    required String title,
    required String description,
    required String country,
    required String city,
    required String category,
    int? budget,
    DateTime? startsAt,
  });
}
