import '../entities/geocoded_location.dart';

abstract class GeocodingRepository {
  Future<GeocodedLocation> geocode(String query);
  Future<GeocodedLocation> reverseGeocode({
    required double lat,
    required double lng,
  });
  Future<List<GeocodedLocation>> search({
    required String query,
    double? lat,
    double? lng,
  });
}
