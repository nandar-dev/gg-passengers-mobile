import 'package:injectable/injectable.dart';

import '../../domain/entities/geocoded_location.dart';
import '../../domain/repositories/geocoding_repository.dart';
import '../data_sources/geocoding_remote_data_source.dart';

@LazySingleton(as: GeocodingRepository)
class GeocodingRepositoryImpl implements GeocodingRepository {
  final GeocodingRemoteDataSource _remoteDataSource;

  GeocodingRepositoryImpl(this._remoteDataSource);

  @override
  Future<GeocodedLocation> geocode(String query) async {
    final model = await _remoteDataSource.geocode(query);
    return model.toDomain();
  }

  @override
  Future<GeocodedLocation> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    final model = await _remoteDataSource.reverseGeocode(lat: lat, lng: lng);
    return model.toDomain();
  }

  @override
  Future<List<GeocodedLocation>> search({
    required String query,
    double? lat,
    double? lng,
  }) async {
    final results = await _remoteDataSource.search(
      query: query,
      lat: lat,
      lng: lng,
    );
    return results.map((item) => item.toDomain()).toList(growable: false);
  }
}
