import '../../domain/entities/booking_stop.dart';

class SearchLocationArgs {
  final String serviceId;

  const SearchLocationArgs({required this.serviceId});
}

class RideCategoryArgs {
  final String serviceId;
  final BookingStop pickup;
  final BookingStop? waypoint;
  final BookingStop dropoff;

  const RideCategoryArgs({
    required this.serviceId,
    required this.pickup,
    this.waypoint,
    required this.dropoff,
  });
}
