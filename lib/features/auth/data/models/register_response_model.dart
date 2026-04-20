import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user.dart';

part 'register_response_model.g.dart';

@JsonSerializable()
class RegisterResponseModel {
  final bool success;
  final int code;
  final String message;
  final RegisterDataModel data;
  final dynamic errors;

  const RegisterResponseModel({
    required this.success,
    required this.code,
    required this.message,
    required this.data,
    this.errors,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterResponseModelToJson(this);
}

@JsonSerializable()
class RegisterDataModel {
  final RegisteredPassengerModel passenger;

  const RegisterDataModel({required this.passenger});

  factory RegisterDataModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterDataModelToJson(this);
}

@JsonSerializable()
class RegisteredPassengerModel {
  final String id;
  final String name;
  final String email;
  final String phone;

  const RegisteredPassengerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory RegisteredPassengerModel.fromJson(Map<String, dynamic> json) =>
      _$RegisteredPassengerModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegisteredPassengerModelToJson(this);

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
      isPhoneVerified: false,
      isProfileSetup: true,
      createdAt: now,
      updatedAt: now,
    );
  }
}
