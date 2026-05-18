import '../../domain/entities/nearby_driver.dart';

class NearbyDriverModel {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String vehicleNumber;
  final double? distanceKm;
  final int? etaMinutes;

  const NearbyDriverModel({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.vehicleNumber,
    this.distanceKm,
    this.etaMinutes,
  });

  factory NearbyDriverModel.fromJson(Map<String, dynamic> json) {
    final position = json['position'];
    final lat = _toDouble(json['lat']) ?? _toDouble(json['latitude']) ??
        (position is Map<String, dynamic> ? _toDouble(position['lat']) ?? _toDouble(position['latitude']) : null) ??
        0;
    final lng = _toDouble(json['lng']) ?? _toDouble(json['longitude']) ??
        (position is Map<String, dynamic> ? _toDouble(position['lng']) ?? _toDouble(position['longitude']) : null) ??
        0;

    return NearbyDriverModel(
      id: (json['id'] ?? json['driver_id'] ?? '').toString(),
      name: (json['name'] ?? json['driver_name'] ?? 'Driver').toString(),
      lat: lat,
      lng: lng,
      vehicleNumber: (json['vehicle_number'] ?? json['vehicleNumber'] ?? '').toString(),
      distanceKm: _toDouble(json['distance_km'] ?? json['distance']),
      etaMinutes: _toInt(json['eta_minutes'] ?? json['eta']),
    );
  }

  NearbyDriver toDomain() {
    return NearbyDriver(
      id: id,
      name: name,
      lat: lat,
      lng: lng,
      vehicleNumber: vehicleNumber,
      distanceKm: distanceKm,
      etaMinutes: etaMinutes,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
