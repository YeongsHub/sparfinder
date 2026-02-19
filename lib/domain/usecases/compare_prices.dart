import '../entities/price_comparison.dart';
import '../../data/repositories/offers_repository.dart';

class ComparePricesUseCase {
  final OffersRepository _repository;

  ComparePricesUseCase(this._repository);

  Future<PriceComparison> call({
    required String productName,
    required String zipCode,
  }) {
    return _repository.comparePrice(
      productName: productName,
      zipCode: zipCode,
    );
  }
}
