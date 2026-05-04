import '../../domain/entities/geocoded_location.dart';

class GeocodingResultModel {
  final double lat;
  final double lng;
  final String displayName;

  const GeocodingResultModel({
    required this.lat,
    required this.lng,
    required this.displayName,
  });

  factory GeocodingResultModel.fromJson(Map<String, dynamic> json) {
    final lat = _toDouble(json['lat']);
    final lng = _toDouble(json['lon']);
    final displayName = json['display_name']?.toString() ?? '';

    return GeocodingResultModel(
      lat: lat,
      lng: lng,
      displayName: displayName,
    );
  }

  GeocodedLocation toDomain() {
    return GeocodedLocation(
      lat: lat,
      lng: lng,
      displayName: displayName,
    );
  }
}

double _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}
