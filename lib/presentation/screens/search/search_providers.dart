import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/offer.dart';
import '../../../core/providers/app_providers.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider =
    FutureProvider.autoDispose<List<Offer>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final zipCode = ref.watch(zipCodeProvider);

  if (query.trim().isEmpty) return [];

  final useCase = ref.watch(searchOffersUseCaseProvider);
  final results = await useCase(query: query, zipCode: zipCode);

  // 가격 오름차순 정렬
  results.sort((a, b) => a.price.compareTo(b.price));
  return results;
});
