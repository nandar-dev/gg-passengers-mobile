import 'package:injectable/injectable.dart';

import '../entities/saved_place.dart';
import '../repositories/saved_places_repository.dart';

@lazySingleton
class CreateSavedPlaceUseCase {
  final SavedPlacesRepository _repository;

  const CreateSavedPlaceUseCase(this._repository);

  Future<SavedPlace> call({
    required String label,
    required String addressName,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) {
    return _repository.createSavedPlace(
      label: label,
      addressName: addressName,
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault,
    );
  }
}
