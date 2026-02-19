import '../entities/offer.dart';
import '../../data/repositories/offers_repository.dart';

class SearchOffersUseCase {
  final OffersRepository _repository;

  SearchOffersUseCase(this._repository);

  Future<List<Offer>> call({
    required String query,
    required String zipCode,
    List<String> retailers = const [],
  }) {
    return _repository.searchOffers(
      query: query,
      zipCode: zipCode,
      retailers: retailers,
    );
  }
}
