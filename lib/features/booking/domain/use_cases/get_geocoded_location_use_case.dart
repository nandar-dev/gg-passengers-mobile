import 'package:injectable/injectable.dart';

import '../entities/geocoded_location.dart';
import '../repositories/geocoding_repository.dart';

@lazySingleton
class GetGeocodedLocationUseCase {
  final GeocodingRepository _repository;

  GetGeocodedLocationUseCase(this._repository);

  Future<GeocodedLocation> call(String query) {
    return _repository.geocode(query);
  }

  Future<GeocodedLocation> reverse({
    required double lat,
    required double lng,
  }) {
    return _repository.reverseGeocode(lat: lat, lng: lng);
  }

  Future<List<GeocodedLocation>> search({
    required String query,
    double? lat,
    double? lng,
  }) {
    return _repository.search(query: query, lat: lat, lng: lng);
  }
}
