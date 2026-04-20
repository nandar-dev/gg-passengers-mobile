// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  phoneNumber: json['phone_number'] as String,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  email: json['email'] as String?,
  profileImageUrl: json['profile_image_url'] as String?,
  isPhoneVerified: json['is_phone_verified'] as bool,
  isProfileSetup: json['is_profile_setup'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'phone_number': instance.phoneNumber,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'email': instance.email,
  'profile_image_url': instance.profileImageUrl,
  'is_phone_verified': instance.isPhoneVerified,
  'is_profile_setup': instance.isProfileSetup,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
