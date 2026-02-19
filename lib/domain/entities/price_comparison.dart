import 'offer.dart';

class PriceComparison {
  final String productName;
  final List<Offer> offers; // 가격 오름차순 정렬

  const PriceComparison({
    required this.productName,
    required this.offers,
  });

  Offer? get cheapest => offers.isNotEmpty ? offers.first : null;
  Offer? get mostExpensive => offers.isNotEmpty ? offers.last : null;

  double get priceDifference {
    if (cheapest == null || mostExpensive == null) return 0;
    return mostExpensive!.price - cheapest!.price;
  }

  double get savings => priceDifference;

  bool get hasMultipleOffers => offers.length > 1;

  static PriceComparison fromOffers(List<Offer> rawOffers) {
    final sorted = List<Offer>.from(rawOffers)
      ..sort((a, b) => a.price.compareTo(b.price));
    return PriceComparison(
      productName: rawOffers.isNotEmpty ? rawOffers.first.productName : '',
      offers: sorted,
    );
  }
}
