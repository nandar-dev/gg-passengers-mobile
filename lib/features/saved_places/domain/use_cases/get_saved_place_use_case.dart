import 'package:injectable/injectable.dart';

import '../entities/saved_place.dart';
import '../repositories/saved_places_repository.dart';

@lazySingleton
class GetSavedPlaceUseCase {
  final SavedPlacesRepository _repository;

  const GetSavedPlaceUseCase(this._repository);

  Future<SavedPlace> call(String id) {
    return _repository.getSavedPlace(id);
  }
}
