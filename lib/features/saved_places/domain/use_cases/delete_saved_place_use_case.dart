import 'package:injectable/injectable.dart';

import '../repositories/saved_places_repository.dart';

@lazySingleton
class DeleteSavedPlaceUseCase {
  final SavedPlacesRepository _repository;

  const DeleteSavedPlaceUseCase(this._repository);

  Future<void> call(String id) {
    return _repository.deleteSavedPlace(id);
  }
}
