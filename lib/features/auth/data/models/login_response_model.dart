import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user.dart';

part 'login_response_model.g.dart';

@JsonSerializable()
class LoginResponseModel {
  final bool success;
  final int code;
  final String message;
  final LoginDataModel data;
  final dynamic errors;

  const LoginResponseModel({
    required this.success,
    required this.code,
    required this.message,
    required this.data,
    this.errors,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseModelToJson(this);
}

@JsonSerializable()
class LoginDataModel {
  final LoginPassengerModel passenger;
  final String token;
  @JsonKey(name: 'token_type')
  final String tokenType;

  const LoginDataModel({
    required this.passenger,
    required this.token,
    required this.tokenType,
  });

  factory LoginDataModel.fromJson(Map<String, dynamic> json) =>
      _$LoginDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginDataModelToJson(this);

  AuthSession toDomain() {
    return AuthSession(
      passenger: passenger.toDomain(),
      token: token,
      tokenType: tokenType,
    );
  }
}

@JsonSerializable()
class LoginPassengerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  @JsonKey(name: 'is_verified')
  final bool isVerified;

  const LoginPassengerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.isVerified,
  });

  factory LoginPassengerModel.fromJson(Map<String, dynamic> json) =>
      _$LoginPassengerModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginPassengerModelToJson(this);

  User toDomain() {
    final names = name.trim().split(RegExp(r'\s+')).where((item) => item.isNotEmpty).toList();
    final firstName = names.isNotEmpty ? names.first : null;
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : null;
    final now = DateTime.now();

    return User(
      id: id,
      phoneNumber: phone,
      firstName: firstName,
      lastName: lastName,
      email: email,
      isPhoneVerified: isVerified,
      isProfileSetup: true,
      createdAt: now,
      updatedAt: now,
    );
  }
}
