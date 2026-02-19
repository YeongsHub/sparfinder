class Offer {
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
  final String? unit; // "1 kg", "500 ml" 등
  final String? description;

  const Offer({
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

  double get discountPercent {
    if (originalPrice == null || originalPrice! <= 0) return 0;
    return (originalPrice! - price) / originalPrice! * 100;
  }

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  String get displayName {
    if (brand != null && brand!.isNotEmpty) {
      return '$brand $productName';
    }
    return productName;
  }

  bool get isValid {
    final now = DateTime.now();
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validUntil != null && now.isAfter(validUntil!)) return false;
    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Offer &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
