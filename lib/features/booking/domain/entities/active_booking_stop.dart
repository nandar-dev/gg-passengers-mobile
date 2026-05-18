import 'package:equatable/equatable.dart';

import 'booking_stop.dart';

class ActiveBookingStop extends Equatable {
  final String id;
  final String address;
  final BookingStopType stopType;
  final String status;
  final double? lat;
  final double? lng;

  const ActiveBookingStop({
    required this.id,
    required this.address,
    required this.stopType,
    required this.status,
    this.lat,
    this.lng,
  });

  @override
  List<Object?> get props => [id, address, stopType, status, lat, lng];
}
