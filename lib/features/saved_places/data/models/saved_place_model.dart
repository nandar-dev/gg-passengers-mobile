import '../../domain/entities/saved_place.dart';

class SavedPlaceModel {
  final String id;
  final String label;
  final String addressName;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final String? createdAt;

  const SavedPlaceModel({
    required this.id,
    required this.label,
    required this.addressName,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
    required this.createdAt,
  });

  factory SavedPlaceModel.fromJson(Map<String, dynamic> json) {
    return SavedPlaceModel(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      addressName: json['address_name']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isDefault: json['is_default'] == true,
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toCreatePayload() {
    return {
      'label': label,
      'address_name': addressName,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
    };
  }

  SavedPlace toDomain() {
    return SavedPlace(
      id: id,
      label: label,
      addressName: addressName,
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault,
      createdAt: createdAt,
    );
  }
}
