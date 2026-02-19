import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/offers_repository.dart';
import '../../data/sources/marktguru_remote_source.dart';
import '../../domain/usecases/compare_prices.dart';
import '../../domain/usecases/get_weekly_deals.dart';
import '../../domain/usecases/search_offers.dart';
import '../../core/constants/api_constants.dart';

// SharedPreferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize via ProviderScope override');
});

// Dio HTTP client
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));
  return dio;
});

// Data sources
final marktguruRemoteSourceProvider = Provider<MarktguruRemoteSource>((ref) {
  return MarktguruRemoteSource(ref.watch(dioProvider));
});

// Repository
final offersRepositoryProvider = Provider<OffersRepository>((ref) {
  return OffersRepositoryImpl(ref.watch(marktguruRemoteSourceProvider));
});

// UseCases
final searchOffersUseCaseProvider = Provider<SearchOffersUseCase>((ref) {
  return SearchOffersUseCase(ref.watch(offersRepositoryProvider));
});

final getWeeklyDealsUseCaseProvider = Provider<GetWeeklyDealsUseCase>((ref) {
  return GetWeeklyDealsUseCase(ref.watch(offersRepositoryProvider));
});

final comparePricesUseCaseProvider = Provider<ComparePricesUseCase>((ref) {
  return ComparePricesUseCase(ref.watch(offersRepositoryProvider));
});

// 현재 사용자 우편번호 (설정에서 저장)
final zipCodeProvider = StateProvider<String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString('zipCode') ?? ApiConstants.defaultZipCode;
});

// 저장된 상품 목록
final savedOffersProvider =
    StateNotifierProvider<SavedOffersNotifier, List<String>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SavedOffersNotifier(prefs);
});

class SavedOffersNotifier extends StateNotifier<List<String>> {
  final SharedPreferences _prefs;
  static const _key = 'saved_offers';

  SavedOffersNotifier(this._prefs)
      : super(_prefs.getStringList(_key) ?? []);

  void toggle(String offerId) {
    if (state.contains(offerId)) {
      state = state.where((id) => id != offerId).toList();
    } else {
      state = [...state, offerId];
    }
    _prefs.setStringList(_key, state);
  }

  bool isSaved(String offerId) => state.contains(offerId);
}
