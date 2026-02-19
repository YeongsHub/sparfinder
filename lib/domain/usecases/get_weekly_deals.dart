import '../entities/offer.dart';
import '../../data/repositories/offers_repository.dart';

class GetWeeklyDealsUseCase {
  final OffersRepository _repository;

  GetWeeklyDealsUseCase(this._repository);

  Future<List<Offer>> call({
    required String zipCode,
    String? category,
  }) {
    return _repository.getWeeklyDeals(
      zipCode: zipCode,
      category: category,
    );
  }
}
