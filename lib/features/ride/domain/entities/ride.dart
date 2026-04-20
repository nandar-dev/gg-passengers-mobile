import 'package:equatable/equatable.dart';

enum RideStatus { pending, accepted, arrivedPickup, started, completed, cancelled }

class Ride extends Equatable {
  final String id;
  final String userId;
  final String? driverId;
  final String categoryId;
  final double pickupLatitude;
  final double pickupLongitude;
  final String pickupAddress;
  final double dropoffLatitude;
  final double dropoffLongitude;
  final String dropoffAddress;
  final RideStatus status;
  final double estimatedFare;
  final double? actualFare;
  final DateTime requestedAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final int? driverRating;
  final String? driverReview;

  const Ride({
    required this.id,
    required this.userId,
    this.driverId,
    required this.categoryId,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.pickupAddress,
    required this.dropoffLatitude,
    required this.dropoffLongitude,
    required this.dropoffAddress,
    required this.status,
    required this.estimatedFare,
    this.actualFare,
    required this.requestedAt,
    this.acceptedAt,
    this.completedAt,
    this.driverRating,
    this.driverReview,
  });

  Ride copyWith({
    String? id,
    String? userId,
    String? driverId,
    String? categoryId,
    double? pickupLatitude,
    double? pickupLongitude,
    String? pickupAddress,
    double? dropoffLatitude,
    double? dropoffLongitude,
    String? dropoffAddress,
    RideStatus? status,
    double? estimatedFare,
    double? actualFare,
    DateTime? requestedAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
    int? driverRating,
    String? driverReview,
  }) {
    return Ride(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      driverId: driverId ?? this.driverId,
      categoryId: categoryId ?? this.categoryId,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffLatitude: dropoffLatitude ?? this.dropoffLatitude,
      dropoffLongitude: dropoffLongitude ?? this.dropoffLongitude,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      status: status ?? this.status,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      actualFare: actualFare ?? this.actualFare,
      requestedAt: requestedAt ?? this.requestedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      driverRating: driverRating ?? this.driverRating,
      driverReview: driverReview ?? this.driverReview,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    driverId,
    categoryId,
    pickupLatitude,
    pickupLongitude,
    pickupAddress,
    dropoffLatitude,
    dropoffLongitude,
    dropoffAddress,
    status,
    estimatedFare,
    actualFare,
    requestedAt,
    acceptedAt,
    completedAt,
    driverRating,
    driverReview,
  ];
}

class Driver extends Equatable {
  final String id;
  final String name;
  final String phoneNumber;
  final String? profileImageUrl;
  final double rating;
  final int completedRides;
  final String carModel;
  final String carPlate;
  final double currentLatitude;
  final double currentLongitude;

  const Driver({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.profileImageUrl,
    required this.rating,
    required this.completedRides,
    required this.carModel,
    required this.carPlate,
    required this.currentLatitude,
    required this.currentLongitude,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    phoneNumber,
    profileImageUrl,
    rating,
    completedRides,
    carModel,
    carPlate,
    currentLatitude,
    currentLongitude,
  ];
}
