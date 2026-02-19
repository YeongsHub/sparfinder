import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/offer.dart';
import '../../../core/providers/app_providers.dart';

// 선택된 카테고리 필터
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// 홈 화면 주간 세일 데이터
final weeklyDealsProvider = FutureProvider.autoDispose<List<Offer>>((ref) async {
  final zipCode = ref.watch(zipCodeProvider);
  final category = ref.watch(selectedCategoryProvider);
  final useCase = ref.watch(getWeeklyDealsUseCaseProvider);
  return useCase(zipCode: zipCode, category: category);
});

// 카테고리 목록 (주간 딜에서 추출)
final categoriesProvider = Provider.autoDispose<List<String>>((ref) {
  final asyncDeals = ref.watch(weeklyDealsProvider);
  return asyncDeals.whenData((deals) {
    final cats = deals
        .map((o) => o.category ?? 'Sonstiges')
        .toSet()
        .toList()
      ..sort();
    return cats;
  }).valueOrNull ?? [];
});
