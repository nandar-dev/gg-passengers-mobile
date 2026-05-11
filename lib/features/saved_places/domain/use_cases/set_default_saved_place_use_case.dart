import 'package:injectable/injectable.dart';

import '../repositories/saved_places_repository.dart';

@lazySingleton
class SetDefaultSavedPlaceUseCase {
  final SavedPlacesRepository _repository;

  const SetDefaultSavedPlaceUseCase(this._repository);

  Future<void> call(String id) {
    return _repository.setDefaultPlace(id);
  }
}
