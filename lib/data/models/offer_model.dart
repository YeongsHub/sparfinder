import '../../domain/entities/offer.dart';

class OfferModel {
  final String id;
  final String productName;
  final String? brand;
  final double price;
  final double? originalPrice;
  final String supermarketName;
  final String? imageUrl;
  final String? category;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final String? unit;
  final String? description;

  const OfferModel({
    required this.id,
    required this.productName,
    this.brand,
    required this.price,
    this.originalPrice,
    required this.supermarketName,
    this.imageUrl,
    this.category,
    this.validFrom,
    this.validUntil,
    this.unit,
    this.description,
  });

  /// marktguru API JSON 응답 파싱
  factory OfferModel.fromMarktguru(Map<String, dynamic> json) {
    // API 응답 구조에 맞게 파싱
    final priceInfo = json['price'] as Map<String, dynamic>?;
    final retailer = json['retailer'] as Map<String, dynamic>?;
    final product = json['product'] as Map<String, dynamic>?;
    final validityData = json['validity'] as Map<String, dynamic>?;

    double price = 0;
    double? originalPrice;

    if (priceInfo != null) {
      price = (priceInfo['value'] as num?)?.toDouble() ?? 0;
      final regularPrice = priceInfo['regularValue'] as num?;
      if (regularPrice != null && regularPrice.toDouble() > price) {
        originalPrice = regularPrice.toDouble();
      }
    }

    // 이미지 URL 추출
    String? imageUrl;
    final images = json['images'] as List<dynamic>?;
    if (images != null && images.isNotEmpty) {
      final firstImage = images.first as Map<String, dynamic>?;
      imageUrl = firstImage?['url'] as String?;
    }

    // 유효기간 파싱
    DateTime? validFrom;
    DateTime? validUntil;
    if (validityData != null) {
      final fromStr = validityData['from'] as String?;
      final toStr = validityData['to'] as String?;
      if (fromStr != null) validFrom = DateTime.tryParse(fromStr);
      if (toStr != null) validUntil = DateTime.tryParse(toStr);
    }

    return OfferModel(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      productName: json['name'] as String? ?? '',
      brand: product?['brand'] as String?,
      price: price,
      originalPrice: originalPrice,
      supermarketName: retailer?['name'] as String? ?? 'Unknown',
      imageUrl: imageUrl,
      category: json['category'] as String?,
      validFrom: validFrom,
      validUntil: validUntil,
      unit: json['quantity'] as String?,
      description: json['description'] as String?,
    );
  }

  Offer toDomain() {
    return Offer(
      id: id,
      productName: productName,
      brand: brand,
      price: price,
      originalPrice: originalPrice,
      supermarketName: supermarketName,
      imageUrl: imageUrl,
      category: category,
      validFrom: validFrom,
      validUntil: validUntil,
      unit: unit,
      description: description,
    );
  }

  /// Mock 데이터 생성 (API 미연결 시 테스트용)
  static List<OfferModel> generateMockData(String query) {
    final now = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));

    return [
      OfferModel(
        id: '1',
        productName: query.isEmpty ? 'Vollmilch 3,5%' : query,
        brand: 'Landfein',
        price: 0.79,
        originalPrice: 1.09,
        supermarketName: 'ALDI Süd',
        imageUrl: null,
        category: 'Milchprodukte',
        validFrom: now,
        validUntil: weekEnd,
        unit: '1 l',
      ),
      OfferModel(
        id: '2',
        productName: query.isEmpty ? 'Vollmilch 3,5%' : query,
        brand: 'REWE Bio',
        price: 0.99,
        originalPrice: 1.29,
        supermarketName: 'REWE',
        imageUrl: null,
        category: 'Milchprodukte',
        validFrom: now,
        validUntil: weekEnd,
        unit: '1 l',
      ),
      OfferModel(
        id: '3',
        productName: query.isEmpty ? 'Vollmilch 3,5%' : query,
        brand: 'Milbona',
        price: 0.89,
        originalPrice: null,
        supermarketName: 'LIDL',
        imageUrl: null,
        category: 'Milchprodukte',
        validFrom: now,
        validUntil: weekEnd,
        unit: '1 l',
      ),
      OfferModel(
        id: '4',
        productName: query.isEmpty ? 'Vollmilch 3,5%' : query,
        brand: 'K-Classic',
        price: 1.05,
        originalPrice: 1.35,
        supermarketName: 'Kaufland',
        imageUrl: null,
        category: 'Milchprodukte',
        validFrom: now,
        validUntil: weekEnd,
        unit: '1 l',
      ),
      OfferModel(
        id: '5',
        productName: query.isEmpty ? 'Vollmilch 3,5%' : query,
        brand: 'Penny',
        price: 0.85,
        originalPrice: 1.15,
        supermarketName: 'Penny',
        imageUrl: null,
        category: 'Milchprodukte',
        validFrom: now,
        validUntil: weekEnd,
        unit: '1 l',
      ),
    ];
  }

  static List<OfferModel> generateWeeklyMockDeals() {
    final now = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));

    return [
      OfferModel(id: 'w1', productName: 'Butter', brand: 'Landfein', price: 1.49, originalPrice: 2.29, supermarketName: 'ALDI Süd', category: 'Milchprodukte', validFrom: now, validUntil: weekEnd, unit: '250 g'),
      OfferModel(id: 'w2', productName: 'Eier Freilandhaltung', brand: null, price: 1.99, originalPrice: 2.79, supermarketName: 'LIDL', category: 'Eier', validFrom: now, validUntil: weekEnd, unit: '10 Stück'),
      OfferModel(id: 'w3', productName: 'Hähnchenbrust', brand: null, price: 3.49, originalPrice: 5.99, supermarketName: 'REWE', category: 'Fleisch', validFrom: now, validUntil: weekEnd, unit: '500 g'),
      OfferModel(id: 'w4', productName: 'Gouda Scheiben', brand: 'Milkana', price: 1.79, originalPrice: 2.49, supermarketName: 'Kaufland', category: 'Käse', validFrom: now, validUntil: weekEnd, unit: '400 g'),
      OfferModel(id: 'w5', productName: 'Bananen', brand: null, price: 1.29, originalPrice: 1.79, supermarketName: 'Penny', category: 'Obst & Gemüse', validFrom: now, validUntil: weekEnd, unit: '1 kg'),
      OfferModel(id: 'w6', productName: 'Toastbrot', brand: 'Lieken Urkorn', price: 0.99, originalPrice: 1.49, supermarketName: 'ALDI Nord', category: 'Brot & Backwaren', validFrom: now, validUntil: weekEnd, unit: '500 g'),
      OfferModel(id: 'w7', productName: 'Cola', brand: 'Coca-Cola', price: 0.79, originalPrice: 1.29, supermarketName: 'LIDL', category: 'Getränke', validFrom: now, validUntil: weekEnd, unit: '1,5 l'),
      OfferModel(id: 'w8', productName: 'Joghurt', brand: 'Activia', price: 2.49, originalPrice: 3.29, supermarketName: 'REWE', category: 'Milchprodukte', validFrom: now, validUntil: weekEnd, unit: '4x125 g'),
      OfferModel(id: 'w9', productName: 'Lachs', brand: null, price: 4.99, originalPrice: 7.99, supermarketName: 'Kaufland', category: 'Fisch', validFrom: now, validUntil: weekEnd, unit: '400 g'),
      OfferModel(id: 'w10', productName: 'Apfel Gala', brand: null, price: 1.49, originalPrice: 1.99, supermarketName: 'Netto', category: 'Obst & Gemüse', validFrom: now, validUntil: weekEnd, unit: '1 kg'),
      OfferModel(id: 'w11', productName: 'Öl Sonnenblumenöl', brand: 'Brat-Fix', price: 1.29, originalPrice: 2.19, supermarketName: 'ALDI Süd', category: 'Öl & Essig', validFrom: now, validUntil: weekEnd, unit: '1 l'),
      OfferModel(id: 'w12', productName: 'Müsli', brand: 'Dr. Oetker', price: 1.99, originalPrice: 2.99, supermarketName: 'REWE', category: 'Frühstück', validFrom: now, validUntil: weekEnd, unit: '500 g'),
    ];
  }
}

// Flutter의 UniqueKey를 사용하기 위한 임시 구현
class UniqueKey {
  @override
  String toString() => DateTime.now().millisecondsSinceEpoch.toString();
}
