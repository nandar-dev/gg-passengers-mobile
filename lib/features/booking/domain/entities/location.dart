import 'package:equatable/equatable.dart';

class Location extends Equatable {
  final double latitude;
  final double longitude;
  final String address;
  final String placeId;

  const Location({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.placeId,
  });

  Location copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? placeId,
  }) {
    return Location(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      placeId: placeId ?? this.placeId,
    );
  }

  @override
  List<Object?> get props => [latitude, longitude, address, placeId];
}

class LocationSuggestion extends Equatable {
  final String mainText;
  final String secondaryText;
  final String placeId;

  const LocationSuggestion({
    required this.mainText,
    required this.secondaryText,
    required this.placeId,
  });

  @override
  List<Object?> get props => [mainText, secondaryText, placeId];
}
