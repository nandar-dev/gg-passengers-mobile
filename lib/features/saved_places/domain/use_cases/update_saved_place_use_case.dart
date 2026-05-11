import 'package:injectable/injectable.dart';

import '../entities/saved_place.dart';
import '../repositories/saved_places_repository.dart';

@lazySingleton
class UpdateSavedPlaceUseCase {
  final SavedPlacesRepository _repository;

  const UpdateSavedPlaceUseCase(this._repository);

  Future<SavedPlace> call({
    required String id,
    required String label,
    required String addressName,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) {
    return _repository.updateSavedPlace(
      id: id,
      label: label,
      addressName: addressName,
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault,
    );
  }
}
