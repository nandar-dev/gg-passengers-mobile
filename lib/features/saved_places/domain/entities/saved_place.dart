class SavedPlace {
  final String id;
  final String label;
  final String addressName;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final String? createdAt;

  const SavedPlace({
    required this.id,
    required this.label,
    required this.addressName,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
    required this.createdAt,
  });
}
