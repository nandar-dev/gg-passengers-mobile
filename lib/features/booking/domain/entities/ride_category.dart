import 'package:equatable/equatable.dart';

enum RideCategoryType { economy, comfort, xl }

class RideCategory extends Equatable {
  final String id;
  final RideCategoryType type;
  final String name;
  final String description;
  final int maxPassengers;
  final double baseFare;
  final double perKmRate;
  final double perMinRate;
  final String imageUrl;

  const RideCategory({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.maxPassengers,
    required this.baseFare,
    required this.perKmRate,
    required this.perMinRate,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [
    id,
    type,
    name,
    description,
    maxPassengers,
    baseFare,
    perKmRate,
    perMinRate,
    imageUrl,
  ];
}

class RideFareEstimate extends Equatable {
  final double estimatedFare;
  final double baseFare;
  final double distanceFare;
  final double timeFare;
  final double surgeMultiplier;
  final int estimatedDurationMinutes;
  final double estimatedDistanceKm;

  const RideFareEstimate({
    required this.estimatedFare,
    required this.baseFare,
    required this.distanceFare,
    required this.timeFare,
    required this.surgeMultiplier,
    required this.estimatedDurationMinutes,
    required this.estimatedDistanceKm,
  });

  @override
  List<Object?> get props => [
    estimatedFare,
    baseFare,
    distanceFare,
    timeFare,
    surgeMultiplier,
    estimatedDurationMinutes,
    estimatedDistanceKm,
  ];
}
