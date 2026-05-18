import '../../domain/entities/active_booking.dart';
import '../../domain/entities/active_booking_stop.dart';
import '../../domain/entities/booking_stop.dart';

class ActiveBookingStopModel {
  final String id;
  final String address;
  final BookingStopType stopType;
  final String status;
  final double? lat;
  final double? lng;

  const ActiveBookingStopModel({
    required this.id,
    required this.address,
    required this.stopType,
    required this.status,
    this.lat,
    this.lng,
  });

  factory ActiveBookingStopModel.fromJson(Map<String, dynamic> json) {
    return ActiveBookingStopModel(
      id: json['id']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      stopType: _parseStopType(json['stop_type']?.toString()),
      status: json['status']?.toString() ?? 'pending',
      lat: _toDouble(json['lat'] ?? json['latitude']),
      lng: _toDouble(json['lng'] ?? json['longitude']),
    );
  }

  ActiveBookingStop toDomain() {
    return ActiveBookingStop(
      id: id,
      address: address,
      stopType: stopType,
      status: status,
      lat: lat,
      lng: lng,
    );
  }

  static BookingStopType _parseStopType(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'pickup':
        return BookingStopType.pickup;
      case 'waypoint':
        return BookingStopType.waypoint;
      case 'dropoff':
        return BookingStopType.dropoff;
      default:
        return BookingStopType.dropoff;
    }
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class ActiveBookingModel {
  final String id;
  final String bookingId;
  final String serviceId;
  final String status;
  final double estimatedFare;
  final String pickupAddress;
  final String dropoffAddress;
  final List<ActiveBookingStopModel> stops;

  const ActiveBookingModel({
    required this.id,
    required this.bookingId,
    required this.serviceId,
    required this.status,
    required this.estimatedFare,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.stops,
  });

  factory ActiveBookingModel.fromJson(Map<String, dynamic> json) {
    return ActiveBookingModel(
      id: json['id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      serviceId: json['service_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      estimatedFare: _toDouble(json['estimated_fare']) ?? 0,
      pickupAddress: json['pickup_address']?.toString() ?? '',
      dropoffAddress: json['dropoff_address']?.toString() ?? '',
      stops: (json['stops'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ActiveBookingStopModel.fromJson)
          .toList(growable: false),
    );
  }

  ActiveBooking toDomain() {
    return ActiveBooking(
      id: id,
      bookingId: bookingId,
      serviceId: serviceId,
      status: status,
      estimatedFare: estimatedFare,
      pickupAddress: pickupAddress,
      dropoffAddress: dropoffAddress,
      stops: stops.map((stop) => stop.toDomain()).toList(growable: false),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
