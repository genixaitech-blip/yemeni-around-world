enum ListingType { person, business }

class PlaceRef {
  const PlaceRef({required this.country, required this.city});
  final String country;
  final String city;
}

class Category {
  const Category(
      {required this.id,
      required this.nameAr,
      required this.nameEn,
      required this.icon});
  final String id;
  final String nameAr;
  final String nameEn;
  final String icon;
}

class Listing {
  const Listing({
    required this.id,
    required this.type,
    required this.name,
    required this.subtitle,
    required this.categoryId,
    required this.place,
    required this.rating,
    required this.reviewCount,
    required this.verified,
    required this.imageUrl,
    required this.about,
    required this.languages,
    this.distanceKm,
    this.priceFrom,
    this.latitude,
    this.longitude,
    this.availableNow = false,
  });

  final String id;
  final ListingType type;
  final String name;
  final String subtitle;
  final String categoryId;
  final PlaceRef place;
  final double rating;
  final int reviewCount;
  final bool verified;
  final String imageUrl;
  final String about;
  final List<String> languages;
  final double? distanceKm;
  final int? priceFrom;
  final double? latitude;
  final double? longitude;
  final bool availableNow;
}

class ServiceRequest {
  const ServiceRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.place,
    required this.categoryId,
    required this.createdAgo,
    required this.offerCount,
    this.budget,
    this.startsAt,
    this.requesterId,
    this.currency = 'USD',
  });
  final String id;
  final String title;
  final String description;
  final PlaceRef place;
  final String categoryId;
  final String createdAgo;
  final int offerCount;
  final int? budget;
  final DateTime? startsAt;
  final String? requesterId;
  final String currency;
}

class DealOffer {
  const DealOffer({
    required this.id,
    required this.title,
    required this.businessName,
    required this.city,
    required this.oldPrice,
    required this.newPrice,
    required this.endsIn,
  });
  final String id;
  final String title;
  final String businessName;
  final String city;
  final int oldPrice;
  final int newPrice;
  final String endsIn;
}

class ChatMessage {
  const ChatMessage(
      {required this.text,
      required this.mine,
      required this.time,
      this.id = ''});
  final String id;
  final String text;
  final bool mine;
  final String time;
}

class RequestProposal {
  const RequestProposal(
      {required this.id,
      required this.providerName,
      required this.price,
      required this.description,
      this.currency = 'USD',
      this.deliveryTime = ''});
  final String id;
  final String providerName;
  final double price;
  final String description;
  final String currency;
  final String deliveryTime;
}

class ConversationSummary {
  const ConversationSummary({required this.id, required this.title});
  final String id;
  final String title;
}
