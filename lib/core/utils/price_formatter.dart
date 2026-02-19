class PriceFormatter {
  /// 독일식 가격 포맷: 1.99 → "€ 1,99"
  static String format(double price) {
    final euros = price.floor();
    final cents = ((price - euros) * 100).round();
    return '€ $euros,${cents.toString().padLeft(2, '0')}';
  }

  /// 할인율 계산: "- 30%"
  static String discountPercent(double original, double sale) {
    if (original <= 0) return '';
    final percent = ((original - sale) / original * 100).round();
    return '- $percent%';
  }

  /// 절약 금액: "Sie sparen € 0,50"
  static String savedAmount(double original, double sale) {
    final saved = original - sale;
    return 'Sie sparen ${format(saved)}';
  }
}
