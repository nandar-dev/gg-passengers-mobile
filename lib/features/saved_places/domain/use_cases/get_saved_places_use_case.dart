import 'package:injectable/injectable.dart';

import '../entities/saved_place.dart';
import '../repositories/saved_places_repository.dart';

@lazySingleton
class GetSavedPlacesUseCase {
  final SavedPlacesRepository _repository;

  const GetSavedPlacesUseCase(this._repository);

  Future<List<SavedPlace>> call({bool forceRefresh = false}) {
    return _repository.getSavedPlaces(forceRefresh: forceRefresh);
  }
}
