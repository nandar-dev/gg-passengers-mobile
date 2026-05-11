class PassengerProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final bool isVerified;
  final String? createdAt;

  const PassengerProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.isVerified,
    required this.createdAt,
  });
}
