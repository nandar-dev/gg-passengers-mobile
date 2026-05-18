import '../../../booking/domain/entities/booking_stop.dart';

class RideTrackingArgs {
  final String bookingId;
  final String bookingCode;
  final String status;
  final String serviceId;
  final BookingStop pickup;
  final BookingStop? waypoint;
  final BookingStop dropoff;

  const RideTrackingArgs({
    required this.bookingId,
    required this.bookingCode,
    required this.status,
    required this.serviceId,
    required this.pickup,
    this.waypoint,
    required this.dropoff,
  });
}
