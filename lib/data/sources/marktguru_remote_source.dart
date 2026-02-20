import 'package:dio/dio.dart';
import '../models/offer_model.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/supermarket_constants.dart';

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
          .where((o) => o.price > 0 && SupermarketConstants.isKnownSupermarket(o.supermarketName))
          .toList();
    } on DioException catch (e) {
      // API 실패 시 Mock 폴백
      if (_isFallbackError(e)) return OfferModel.generateMockData(query);
      rethrow;
    }
  }

  /// 주간 세일 전체 — 35개 카테고리 키워드 병렬 검색으로 최대한 많은 제품 수집
  /// (marktguru에 /list 엔드포인트 없음 → 키워드 검색 합산으로 대체)
  Future<List<OfferModel>> getWeeklyDeals({
    required String zipCode,
    String? category,
  }) async {
    // 카테고리 지정 시 해당 키워드만, 없으면 전체 35개 카테고리 키워드
    final keywords = category != null
        ? [category]
        : [
            // 유제품
            'Milch', 'Butter', 'Käse', 'Joghurt', 'Sahne', 'Quark',
            // 육류 & 가공육
            'Fleisch', 'Hähnchen', 'Rind', 'Schwein', 'Wurst', 'Schinken',
            // 수산물
            'Fisch', 'Lachs', 'Thunfisch',
            // 채소 & 과일
            'Gemüse', 'Obst', 'Salat', 'Kartoffel', 'Tomate', 'Paprika',
            // 빵 & 제과
            'Brot', 'Brötchen', 'Kuchen',
            // 음료
            'Getränke', 'Bier', 'Wein', 'Saft', 'Wasser',
            // 냉동식품
            'Tiefkühl',
            // 과자 & 간식
            'Schokolade', 'Chips',
            // 기타 식품
            'Eier', 'Kaffee', 'Nudeln',
          ];

    try {
      final futures = keywords.map((kw) => searchOffers(
            query: kw,
            zipCode: zipCode,
            limit: 50,
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
