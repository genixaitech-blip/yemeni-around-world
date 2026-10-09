import 'models.dart';

abstract interface class AppRepository {
  Future<List<Category>> getCategories();
  Future<List<Listing>> search(
      {String query = '',
      String? country,
      String? city,
      String? categoryId,
      bool nearby = false,
      double? originLat,
      double? originLng});
  Future<Listing?> getListing(String id);
  Future<List<ServiceRequest>> getRequests();
  Future<ServiceRequest?> getRequest(String id);
  Future<List<RequestProposal>> getProposals(String requestId);
  Future<void> submitProposal(
      {required String requestId,
      required double price,
      required String description,
      required String deliveryTime});
  Future<String> openListingConversation(Listing listing);
  Future<String> openProposalConversation(String proposalId);
  Future<List<ConversationSummary>> getConversations();
  Stream<List<ChatMessage>> watchMessages(String conversationId);
  Future<void> sendMessage(String conversationId, String text);
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
