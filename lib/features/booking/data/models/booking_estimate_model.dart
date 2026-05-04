import '../../domain/entities/booking_estimate.dart';

class BookingEstimateModel {
  final int distanceMeters;
  final int durationSeconds;
  final List<VehicleEstimateModel> vehicles;

  const BookingEstimateModel({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.vehicles,
  });

  factory BookingEstimateModel.fromJson(Map<String, dynamic> json) {
    final distance = json['distance_m'];
    final duration = json['duration_s'];
    final vehiclesJson = json['vehicles'];

    final List<VehicleEstimateModel> vehicles = vehiclesJson is List
        ? vehiclesJson
            .whereType<Map<String, dynamic>>()
            .map(VehicleEstimateModel.fromJson)
            .toList(growable: false)
        : const <VehicleEstimateModel>[];

    return BookingEstimateModel(
      distanceMeters: _toInt(distance),
      durationSeconds: _toInt(duration),
      vehicles: vehicles,
    );
  }

  BookingEstimate toDomain() {
    return BookingEstimate(
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
      vehicles: vehicles.map((model) => model.toDomain()).toList(growable: false),
    );
  }
}

class VehicleEstimateModel {
  final String vehicleTypeId;
  final String nameEn;
  final String nameMm;
  final int capacity;
  final bool isEv;
  final double estimatedFare;

  const VehicleEstimateModel({
    required this.vehicleTypeId,
    required this.nameEn,
    required this.nameMm,
    required this.capacity,
    required this.isEv,
    required this.estimatedFare,
  });

  factory VehicleEstimateModel.fromJson(Map<String, dynamic> json) {
    final vehicleTypeId = json['vehicle_type_id']?.toString() ?? '';
    final nameEn = json['name_en']?.toString() ?? '';
    final nameMm = json['name_mm']?.toString() ?? '';
    final capacity = _toInt(json['capacity']);
    final isEvRaw = json['is_ev'];
    final estimatedFare = _toDouble(json['estimated_fare']);

    return VehicleEstimateModel(
      vehicleTypeId: vehicleTypeId,
      nameEn: nameEn,
      nameMm: nameMm,
      capacity: capacity,
      isEv: isEvRaw == 1 || isEvRaw == true,
      estimatedFare: estimatedFare,
    );
  }

  VehicleEstimate toDomain() {
    return VehicleEstimate(
      vehicleTypeId: vehicleTypeId,
      nameEn: nameEn,
      nameMm: nameMm,
      capacity: capacity,
      isEv: isEv,
      estimatedFare: estimatedFare,
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}
