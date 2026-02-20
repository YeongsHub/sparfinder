import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/offer.dart';
import '../../../core/providers/app_providers.dart';

/// 홈 화면에서 사용하는 중복 제거된 딜 — 같은 제품 중 최저가만 표시
class HomeOffer {
  final Offer cheapest;        // 표시할 최저가 offer
  final int storeCount;        // 이 제품을 세일하는 총 마켓 수
  final List<Offer> allOffers; // 가격비교 화면 전달용 전체 목록

  const HomeOffer({
    required this.cheapest,
    required this.storeCount,
    required this.allOffers,
  });
}

// 선택된 카테고리 필터
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// 선택된 슈퍼마켓 필터
final selectedSupermarketProvider = StateProvider<String?>((ref) => null);

// 홈 화면 주간 세일 데이터 (중복 제거 후 최저가만)
final weeklyDealsProvider =
    FutureProvider.autoDispose<List<HomeOffer>>((ref) async {
  final zipCode = ref.watch(zipCodeProvider);
  final category = ref.watch(selectedCategoryProvider);
  final supermarket = ref.watch(selectedSupermarketProvider);
  final useCase = ref.watch(getWeeklyDealsUseCaseProvider);

  final allOffers = await useCase(zipCode: zipCode, category: category);

  // 슈퍼마켓 필터 적용
  final filtered = supermarket != null
      ? allOffers
          .where((o) => o.supermarketName
              .toLowerCase()
              .contains(supermarket.toLowerCase()))
          .toList()
      : allOffers;

  return _deduplicateCheapest(filtered);
});

/// 같은 제품명 그룹화 → 최저가 하나만 남기고 storeCount 기록
List<HomeOffer> _deduplicateCheapest(List<Offer> offers) {
  String normalize(String name) => name.toLowerCase().trim();

  final Map<String, List<Offer>> groups = {};
  for (final offer in offers) {
    final key = normalize(offer.productName);
    groups.putIfAbsent(key, () => []).add(offer);
  }

  final result = <HomeOffer>[];
  for (final group in groups.values) {
    group.sort((a, b) => a.price.compareTo(b.price));
    result.add(HomeOffer(
      cheapest: group.first,
      storeCount: group.length,
      allOffers: group,
    ));
  }

  // 할인율 높은 순으로 최종 정렬
  result.sort((a, b) =>
      b.cheapest.discountPercent.compareTo(a.cheapest.discountPercent));

  return result;
}
