import 'package:equatable/equatable.dart';

class NearbyDriver extends Equatable {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String vehicleNumber;
  final double? distanceKm;
  final int? etaMinutes;

  const NearbyDriver({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.vehicleNumber,
    this.distanceKm,
    this.etaMinutes,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        lat,
        lng,
        vehicleNumber,
        distanceKm,
        etaMinutes,
      ];
}
