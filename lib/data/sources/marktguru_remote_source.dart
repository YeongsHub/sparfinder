import 'package:dio/dio.dart';
import '../models/offer_model.dart';
import '../../core/constants/api_constants.dart';

class MarktguruRemoteSource {
  final Dio _dio;

  MarktguruRemoteSource(this._dio);

  /// 상품 검색: 여러 슈퍼마켓의 현재 세일 정보 반환
  Future<List<OfferModel>> searchOffers({
    required String query,
    required String zipCode,
    int limit = ApiConstants.defaultLimit,
    int offset = 0,
    List<String> retailers = const [],
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.marktguruBaseUrl}${ApiConstants.marktguruSearchPath}',
        queryParameters: {
          'q': query,
          'zipCode': zipCode,
          'limit': limit,
          'offset': offset,
          if (retailers.isNotEmpty) 'retailer': retailers.join(','),
        },
        options: Options(headers: ApiConstants.marktguruHeaders),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final offers = data['offers'] as List<dynamic>? ??
            data['items'] as List<dynamic>? ??
            data['results'] as List<dynamic>? ??
            [];
        return offers
            .map((e) => OfferModel.fromMarktguru(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      // API가 불안정하면 Mock 데이터로 폴백
      if (e.response?.statusCode == 403 ||
          e.response?.statusCode == 401 ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        return OfferModel.generateMockData(query);
      }
      rethrow;
    }
  }

  /// 주간 세일 전체 목록 (우편번호 기반)
  Future<List<OfferModel>> getWeeklyDeals({
    required String zipCode,
    String? category,
    int limit = ApiConstants.defaultLimit,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.marktguruBaseUrl}${ApiConstants.marktguruListPath}',
        queryParameters: {
          'zipCode': zipCode,
          'limit': limit,
          'category': category,
        },
        options: Options(headers: ApiConstants.marktguruHeaders),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final offers = data['offers'] as List<dynamic>? ??
            data['items'] as List<dynamic>? ??
            [];
        return offers
            .map((e) => OfferModel.fromMarktguru(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException {
      // API 실패 시 Mock 데이터 반환
      return OfferModel.generateWeeklyMockDeals();
    }
  }
}
