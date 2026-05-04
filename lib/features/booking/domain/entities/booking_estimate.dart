import 'package:equatable/equatable.dart';

class BookingEstimate extends Equatable {
  final int distanceMeters;
  final int durationSeconds;
  final List<VehicleEstimate> vehicles;

  const BookingEstimate({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.vehicles,
  });

  @override
  List<Object?> get props => [distanceMeters, durationSeconds, vehicles];
}

class VehicleEstimate extends Equatable {
  final String vehicleTypeId;
  final String nameEn;
  final String nameMm;
  final int capacity;
  final bool isEv;
  final double estimatedFare;

  const VehicleEstimate({
    required this.vehicleTypeId,
    required this.nameEn,
    required this.nameMm,
    required this.capacity,
    required this.isEv,
    required this.estimatedFare,
  });

  @override
  List<Object?> get props => [
    vehicleTypeId,
    nameEn,
    nameMm,
    capacity,
    isEv,
    estimatedFare,
  ];
}
