// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reset_password_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResetPasswordRequestModel _$ResetPasswordRequestModelFromJson(
  Map<String, dynamic> json,
) => ResetPasswordRequestModel(
  login: json['login'] as String,
  resetToken: json['reset_token'] as String,
  newPassword: json['new_password'] as String,
  newPasswordConfirmation: json['new_password_confirmation'] as String,
);

Map<String, dynamic> _$ResetPasswordRequestModelToJson(
  ResetPasswordRequestModel instance,
) => <String, dynamic>{
  'login': instance.login,
  'reset_token': instance.resetToken,
  'new_password': instance.newPassword,
  'new_password_confirmation': instance.newPasswordConfirmation,
};
