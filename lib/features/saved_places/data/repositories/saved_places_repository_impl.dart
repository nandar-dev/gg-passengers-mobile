import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/saved_place.dart';
import '../../domain/repositories/saved_places_repository.dart';
import '../data_sources/saved_places_remote_data_source.dart';
import '../models/saved_place_model.dart';

@LazySingleton(as: SavedPlacesRepository)
class SavedPlacesRepositoryImpl implements SavedPlacesRepository {
  final SavedPlacesRemoteDataSource _remoteDataSource;
  final Uuid _uuid = const Uuid();

  SavedPlacesRepositoryImpl(this._remoteDataSource);

  List<SavedPlace>? _cachedPlaces;

  @override
  Future<List<SavedPlace>> getSavedPlaces({bool forceRefresh = false}) async {
    final hasMemoryCache = _cachedPlaces != null && _cachedPlaces!.isNotEmpty;
    if (!forceRefresh && hasMemoryCache) {
      return _cachedPlaces!;
    }

    try {
      final items = await _remoteDataSource.fetchSavedPlaces();
      final mapped = items.map((model) => model.toDomain()).toList(growable: false);
      _cachedPlaces = mapped;
      return mapped;
    } catch (_) {
      if (hasMemoryCache) {
        return _cachedPlaces!;
      }
      rethrow;
    }
  }

  @override
  Future<SavedPlace> getSavedPlace(String id) async {
    final item = await _remoteDataSource.fetchSavedPlace(id);
    return item.toDomain();
  }

  @override
  Future<SavedPlace> createSavedPlace({
    required String label,
    required String addressName,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) async {
    final model = SavedPlaceModel(
      id: '',
      label: label,
      addressName: addressName,
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault,
      createdAt: null,
    );
    final created = await _remoteDataSource.createSavedPlace(model);
    final saved = _ensureId(created).toDomain();
    _cachedPlaces = _mergeSavedPlace(saved);
    return saved;
  }

  @override
  Future<SavedPlace> updateSavedPlace({
    required String id,
    required String label,
    required String addressName,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) async {
    final model = SavedPlaceModel(
      id: id,
      label: label,
      addressName: addressName,
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault,
      createdAt: null,
    );
    final updated = await _remoteDataSource.updateSavedPlace(id, model);
    final saved = _ensureId(updated).toDomain();
    _cachedPlaces = _mergeSavedPlace(saved);
    return saved;
  }

  @override
  Future<void> deleteSavedPlace(String id) async {
    await _remoteDataSource.deleteSavedPlace(id);
    if (_cachedPlaces == null) return;
    _cachedPlaces = _cachedPlaces!.where((item) => item.id != id).toList(growable: false);
  }

  @override
  Future<void> setDefaultPlace(String id) async {
    await _remoteDataSource.setDefaultPlace(id);
    if (_cachedPlaces == null) return;
    _cachedPlaces = _cachedPlaces!
        .map((item) => SavedPlace(
              id: item.id,
              label: item.label,
              addressName: item.addressName,
              latitude: item.latitude,
              longitude: item.longitude,
              isDefault: item.id == id,
              createdAt: item.createdAt,
            ))
        .toList(growable: false);
  }

  List<SavedPlace> _mergeSavedPlace(SavedPlace saved) {
    final existing = _cachedPlaces ?? const [];
    final updated = [saved, ...existing.where((item) => item.id != saved.id)];
    if (saved.isDefault) {
      return updated
          .map((item) => SavedPlace(
                id: item.id,
                label: item.label,
                addressName: item.addressName,
                latitude: item.latitude,
                longitude: item.longitude,
                isDefault: item.id == saved.id,
                createdAt: item.createdAt,
              ))
          .toList(growable: false);
    }
    return updated;
  }

  SavedPlaceModel _ensureId(SavedPlaceModel model) {
    if (model.id.isNotEmpty) return model;
    return SavedPlaceModel(
      id: _uuid.v4(),
      label: model.label,
      addressName: model.addressName,
      latitude: model.latitude,
      longitude: model.longitude,
      isDefault: model.isDefault,
      createdAt: model.createdAt,
    );
  }
}
