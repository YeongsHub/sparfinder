import 'package:dio/dio.dart';
import '../models/offer_model.dart';
import '../../core/constants/api_constants.dart';

class MarktguruRemoteSource {
  final Dio _dio;

  MarktguruRemoteSource(this._dio);

  /// 상품 검색 — 실제 marktguru API
  /// GET /api/v1/offers/search?as=web&q=butter&zipCode=10115&limit=50&offset=0
  Future<List<OfferModel>> searchOffers({
    required String query,
    required String zipCode,
    int limit = ApiConstants.defaultLimit,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.marktguruBaseUrl}${ApiConstants.marktguruSearchPath}',
        queryParameters: {
          'as': 'web',
          'q': query,
          'zipCode': zipCode,
          'limit': limit,
          'offset': offset,
        },
        options: Options(headers: ApiConstants.marktguruHeaders),
      );

      final data = response.data as Map<String, dynamic>?;
      final results = data?['results'] as List<dynamic>? ?? [];
      return results
          .map((e) => OfferModel.fromMarktguru(e as Map<String, dynamic>))
          .where((o) => o.price > 0)
          .toList();
    } on DioException catch (e) {
      // API 실패 시 Mock 폴백
      if (_isFallbackError(e)) return OfferModel.generateMockData(query);
      rethrow;
    }
  }

  /// 주간 세일 전체 — 여러 키워드로 검색해 합산
  /// (marktguru는 list 엔드포인트가 없어서 키워드 검색으로 대체)
  Future<List<OfferModel>> getWeeklyDeals({
    required String zipCode,
    String? category,
  }) async {
    // 주요 카테고리 키워드로 병렬 검색
    final keywords = category != null
        ? [category]
        : ['Milch', 'Butter', 'Fleisch', 'Obst', 'Gemüse', 'Brot',
           'Käse', 'Eier', 'Getränke', 'Fisch'];

    try {
      final futures = keywords.map((kw) => searchOffers(
            query: kw,
            zipCode: zipCode,
            limit: 20,
          ));
      final results = await Future.wait(futures);

      // 중복 ID 제거 후 합산
      final seen = <String>{};
      final all = <OfferModel>[];
      for (final list in results) {
        for (final offer in list) {
          if (seen.add(offer.id)) {
            all.add(offer);
          }
        }
      }
      return all;
    } on DioException catch (e) {
      if (_isFallbackError(e)) return OfferModel.generateWeeklyMockDeals();
      rethrow;
    }
  }

  bool _isFallbackError(DioException e) =>
      e.response?.statusCode == 403 ||
      e.response?.statusCode == 401 ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.connectionError;
}
