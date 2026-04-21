// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_reset_otp_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyResetOtpResponseModel _$VerifyResetOtpResponseModelFromJson(
  Map<String, dynamic> json,
) => VerifyResetOtpResponseModel(
  success: json['success'] as bool,
  code: (json['code'] as num).toInt(),
  message: json['message'] as String,
  data: json['data'] == null
      ? null
      : VerifyResetOtpDataModel.fromJson(json['data'] as Map<String, dynamic>),
  errors: json['errors'],
);

Map<String, dynamic> _$VerifyResetOtpResponseModelToJson(
  VerifyResetOtpResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
  'errors': instance.errors,
};

VerifyResetOtpDataModel _$VerifyResetOtpDataModelFromJson(
  Map<String, dynamic> json,
) => VerifyResetOtpDataModel(resetToken: json['reset_token'] as String);

Map<String, dynamic> _$VerifyResetOtpDataModelToJson(
  VerifyResetOtpDataModel instance,
) => <String, dynamic>{'reset_token': instance.resetToken};
