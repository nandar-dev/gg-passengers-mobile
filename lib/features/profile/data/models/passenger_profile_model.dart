import '../../domain/entities/passenger_profile.dart';

class PassengerProfileModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final bool isVerified;
  final String? createdAt;

  const PassengerProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.isVerified,
    required this.createdAt,
  });

  factory PassengerProfileModel.fromJson(Map<String, dynamic> json) {
    return PassengerProfileModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
      isVerified: json['is_verified'] == true,
      createdAt: json['created_at']?.toString(),
    );
  }

  PassengerProfile toDomain() {
    return PassengerProfile(
      id: id,
      name: name,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl,
      isVerified: isVerified,
      createdAt: createdAt,
    );
  }
}
