import 'package:equatable/equatable.dart';

enum BookingStopType { pickup, waypoint, dropoff }

extension BookingStopTypeX on BookingStopType {
  String get apiValue {
    switch (this) {
      case BookingStopType.pickup:
        return 'pickup';
      case BookingStopType.waypoint:
        return 'waypoint';
      case BookingStopType.dropoff:
        return 'dropoff';
    }
  }
}

class BookingStop extends Equatable {
  final String address;
  final double lat;
  final double lng;
  final BookingStopType stopType;

  const BookingStop({
    required this.address,
    required this.lat,
    required this.lng,
    required this.stopType,
  });

  Map<String, dynamic> toRequestJson() {
    return {
      'address': address,
      'lat': lat,
      'lng': lng,
      'stop_type': stopType.apiValue,
    };
  }

  @override
  List<Object?> get props => [address, lat, lng, stopType];
}
