import 'app_repository.dart';
import 'models.dart';

class MockAppRepository implements AppRepository {
  static const categories = <Category>[
    Category(id: 'translation', nameAr: 'ترجمة', nameEn: 'Translation', icon: '文'),
    Category(id: 'restaurants', nameAr: 'مطاعم', nameEn: 'Restaurants', icon: '☕'),
    Category(id: 'transport', nameAr: 'نقل وسائقون', nameEn: 'Transport', icon: '↗'),
    Category(id: 'shipping', nameAr: 'شحن', nameEn: 'Shipping', icon: '▣'),
    Category(id: 'housing', nameAr: 'سكن', nameEn: 'Housing', icon: '⌂'),
    Category(id: 'photo', nameAr: 'تصوير', nameEn: 'Photography', icon: '●'),
    Category(id: 'honey', nameAr: 'عسل ومتاجر', nameEn: 'Honey & shops', icon: '◆'),
    Category(id: 'tech', nameAr: 'تقنية', nameEn: 'Technology', icon: '</>'),
  ];

  static const listings = <Listing>[
    Listing(id: 'p1', type: ListingType.person, name: 'محمد علي', subtitle: 'مترجم ومرافق أعمال', categoryId: 'translation', place: PlaceRef(country: 'الهند', city: 'نيودلهي'), rating: 4.9, reviewCount: 126, verified: true, imageUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=600', about: 'مترجم عربي وإنجليزي وهندي، أساعد الزوار والطلاب ورجال الأعمال في نيودلهي منذ 8 سنوات.', languages: ['العربية', 'English', 'हिन्दी'], priceFrom: 45, availableNow: true),
    Listing(id: 'b1', type: ListingType.business, name: 'باب اليمن', subtitle: 'مطعم يمني أصيل', categoryId: 'restaurants', place: PlaceRef(country: 'السعودية', city: 'الرياض'), rating: 4.8, reviewCount: 842, verified: true, imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600', about: 'مندي ومظبي وسلتة بنكهات يمنية أصيلة، وجلسات عائلية هادئة.', languages: ['العربية', 'English'], distanceKm: .8, latitude: 24.7136, longitude: 46.6753, availableNow: true),
    Listing(id: 'p2', type: ListingType.person, name: 'سالم القباطي', subtitle: 'سائق واستقبال مطار', categoryId: 'transport', place: PlaceRef(country: 'ماليزيا', city: 'كوالالمبور'), rating: 4.9, reviewCount: 203, verified: true, imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=600', about: 'استقبال من المطار وجولات خاصة للعائلات والطلاب داخل كوالالمبور.', languages: ['العربية', 'English', 'Malay'], priceFrom: 30, distanceKm: 3.2, availableNow: true),
    Listing(id: 'b2', type: ListingType.business, name: 'سكن روافد الطلاب', subtitle: 'سكن طلاب قريب من الجامعة', categoryId: 'housing', place: PlaceRef(country: 'ماليزيا', city: 'كوالالمبور'), rating: 4.7, reviewCount: 91, verified: true, imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=600', about: 'غرف مفروشة وخدمة استقبال ومساعدة للطلاب اليمنيين الجدد.', languages: ['العربية', 'English'], priceFrom: 180),
    Listing(id: 'p3', type: ListingType.person, name: 'أروى الحكيمي', subtitle: 'مصورة فعاليات وفيديو', categoryId: 'photo', place: PlaceRef(country: 'السعودية', city: 'الرياض'), rating: 4.9, reviewCount: 74, verified: true, imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=600', about: 'تغطية فعاليات ومناسبات وإنتاج فيديو قصير باحترافية وخصوصية.', languages: ['العربية', 'English'], priceFrom: 650, distanceKm: 5.1),
    Listing(id: 'b3', type: ListingType.business, name: 'سبأ للشحن الدولي', subtitle: 'شحن طرود وبضائع إلى اليمن', categoryId: 'shipping', place: PlaceRef(country: 'أمريكا', city: 'نيويورك'), rating: 4.6, reviewCount: 318, verified: true, imageUrl: 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=600', about: 'حلول شحن جوي وبحري وتتبع للطرود من الولايات المتحدة إلى اليمن.', languages: ['العربية', 'English']),
    Listing(id: 'b4', type: ListingType.business, name: 'مناحل حضرموت', subtitle: 'عسل سدر يمني موثوق', categoryId: 'honey', place: PlaceRef(country: 'مصر', city: 'القاهرة'), rating: 4.8, reviewCount: 159, verified: false, imageUrl: 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=600', about: 'منتجات عسل يمني مختارة مع توصيل داخل القاهرة والجيزة.', languages: ['العربية'], distanceKm: 2.3),
    Listing(id: 'b5', type: ListingType.business, name: 'جينيس للتقنية', subtitle: 'حلول رقمية وأتمتة', categoryId: 'tech', place: PlaceRef(country: 'مصر', city: 'القاهرة'), rating: 5, reviewCount: 48, verified: true, imageUrl: 'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=600', about: 'بناء تطبيقات ومنصات رقمية للشركات والمؤسسات في المنطقة.', languages: ['العربية', 'English']),
  ];

  static const requests = <ServiceRequest>[
    ServiceRequest(id: 'r1', title: 'أحتاج مصورًا في الرياض', description: 'تغطية فعالية يوم الجمعة من 6 إلى 10 مساءً.', place: PlaceRef(country: 'السعودية', city: 'الرياض'), categoryId: 'photo', createdAgo: 'منذ 18 دقيقة', offerCount: 3, budget: 1200),
    ServiceRequest(id: 'r2', title: 'مترجم في نيودلهي', description: 'مرافق لمدة يومين لمواعيد عمل.', place: PlaceRef(country: 'الهند', city: 'نيودلهي'), categoryId: 'translation', createdAgo: 'منذ ساعة', offerCount: 5, budget: 180),
    ServiceRequest(id: 'r3', title: 'سكن طالب لمدة شهر', description: 'غرفة قريبة من المواصلات ابتداء من أكتوبر.', place: PlaceRef(country: 'ماليزيا', city: 'كوالالمبور'), categoryId: 'housing', createdAgo: 'منذ 3 ساعات', offerCount: 8),
  ];

  static const offers = <DealOffer>[
    DealOffer(id: 'o1', title: 'خصم غداء العائلة', businessName: 'باب اليمن', city: 'الرياض', oldPrice: 180, newPrice: 135, endsIn: 'ينتهي الليلة'),
    DealOffer(id: 'o2', title: 'شهر سكن للطلاب الجدد', businessName: 'سكن روافد الطلاب', city: 'كوالالمبور', oldPrice: 240, newPrice: 190, endsIn: 'متبقي 3 أيام'),
    DealOffer(id: 'o3', title: 'شحن أول طرد', businessName: 'سبأ للشحن الدولي', city: 'نيويورك', oldPrice: 90, newPrice: 65, endsIn: 'متبقي 5 أيام'),
  ];

  @override
  Future<List<Category>> getCategories() async => categories;

  @override
  Future<List<Listing>> search({String query = '', String? country, String? city, String? categoryId, bool nearby = false}) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final needle = _normalize(query);
    final tokens = needle.split(' ').where((token) => token.length > 1 && !const {'في', 'من', 'الى', 'إلى', 'يمني', 'يمنية'}.contains(token));
    final result = listings.where((item) {
      final haystack = _normalize('${item.name} ${item.subtitle} ${item.about} ${item.place.country} ${item.place.city}');
      final textMatches = needle.isEmpty || tokens.every(haystack.contains);
      final countryMatches = country == null || country.isEmpty || item.place.country == country;
      final cityMatches = city == null || city.isEmpty || item.place.city == city;
      final categoryMatches = categoryId == null || categoryId.isEmpty || item.categoryId == categoryId;
      final nearbyMatches = !nearby || item.distanceKm != null;
      return textMatches && countryMatches && cityMatches && categoryMatches && nearbyMatches;
    }).toList();
    if (nearby) result.sort((a, b) => (a.distanceKm ?? 999).compareTo(b.distanceKm ?? 999));
    return result;
  }

  String _normalize(String input) => input
      .toLowerCase()
      .replaceAll(RegExp('[أإآ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAll(RegExp(r'[^\w\u0600-\u06ff]+'), ' ')
      .trim();

  @override
  Future<Listing?> getListing(String id) async {
    for (final item in listings) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<List<ServiceRequest>> getRequests() async => requests;

  @override
  Future<List<DealOffer>> getOffers() async => offers;

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
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
}
