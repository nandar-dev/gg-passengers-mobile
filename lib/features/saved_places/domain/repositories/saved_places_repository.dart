import '../entities/saved_place.dart';

abstract class SavedPlacesRepository {
  Future<List<SavedPlace>> getSavedPlaces({bool forceRefresh = false});

  Future<SavedPlace> getSavedPlace(String id);

  Future<SavedPlace> createSavedPlace({
    required String label,
    required String addressName,
    required double latitude,
    required double longitude,
    required bool isDefault,
  });

  Future<SavedPlace> updateSavedPlace({
    required String id,
    required String label,
    required String addressName,
    required double latitude,
    required double longitude,
    required bool isDefault,
  });

  Future<void> deleteSavedPlace(String id);

  Future<void> setDefaultPlace(String id);
}
