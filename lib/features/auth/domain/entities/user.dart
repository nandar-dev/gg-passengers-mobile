import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? profileImageUrl;
  final bool isPhoneVerified;
  final bool isProfileSetup;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.email,
    this.profileImageUrl,
    this.isPhoneVerified = false,
    this.isProfileSetup = false,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  User copyWith({
    String? id,
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? email,
    String? profileImageUrl,
    bool? isPhoneVerified,
    bool? isProfileSetup,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isProfileSetup: isProfileSetup ?? this.isProfileSetup,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    phoneNumber,
    firstName,
    lastName,
    email,
    profileImageUrl,
    isPhoneVerified,
    isProfileSetup,
    createdAt,
    updatedAt,
  ];
}
