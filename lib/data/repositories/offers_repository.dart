import '../../domain/entities/offer.dart';
import '../../domain/entities/price_comparison.dart';
import '../sources/marktguru_remote_source.dart';

abstract class OffersRepository {
  Future<List<Offer>> searchOffers({
    required String query,
    required String zipCode,
    List<String> retailers,
  });

  Future<List<Offer>> getWeeklyDeals({
    required String zipCode,
    String? category,
  });

  Future<PriceComparison> comparePrice({
    required String productName,
    required String zipCode,
  });
}

class OffersRepositoryImpl implements OffersRepository {
  final MarktguruRemoteSource _remoteSource;

  OffersRepositoryImpl(this._remoteSource);

  @override
  Future<List<Offer>> searchOffers({
    required String query,
    required String zipCode,
    List<String> retailers = const [],
  }) async {
    final models = await _remoteSource.searchOffers(
      query: query,
      zipCode: zipCode,
    );
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<List<Offer>> getWeeklyDeals({
    required String zipCode,
    String? category,
  }) async {
    final models = await _remoteSource.getWeeklyDeals(
      zipCode: zipCode,
      category: category,
    );
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<PriceComparison> comparePrice({
    required String productName,
    required String zipCode,
  }) async {
    final offers = await searchOffers(
      query: productName,
      zipCode: zipCode,
    );
    return PriceComparison.fromOffers(offers);
  }
}
