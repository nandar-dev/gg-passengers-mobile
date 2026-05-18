import 'package:equatable/equatable.dart';

import 'active_booking_stop.dart';

class ActiveBooking extends Equatable {
  final String id;
  final String bookingId;
  final String serviceId;
  final String status;
  final double estimatedFare;
  final String pickupAddress;
  final String dropoffAddress;
  final List<ActiveBookingStop> stops;

  const ActiveBooking({
    required this.id,
    required this.bookingId,
    required this.serviceId,
    required this.status,
    required this.estimatedFare,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.stops,
  });

  @override
  List<Object?> get props => [
        id,
        bookingId,
        serviceId,
        status,
        estimatedFare,
        pickupAddress,
        dropoffAddress,
        stops,
      ];
}
