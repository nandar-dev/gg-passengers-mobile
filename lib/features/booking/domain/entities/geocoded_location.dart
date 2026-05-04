import 'package:equatable/equatable.dart';

class GeocodedLocation extends Equatable {
  final double lat;
  final double lng;
  final String displayName;

  const GeocodedLocation({
    required this.lat,
    required this.lng,
    required this.displayName,
  });

  @override
  List<Object?> get props => [lat, lng, displayName];
}
