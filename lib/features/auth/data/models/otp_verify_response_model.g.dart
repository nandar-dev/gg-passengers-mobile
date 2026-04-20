// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_verify_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtpVerifyResponseModel _$OtpVerifyResponseModelFromJson(
  Map<String, dynamic> json,
) => OtpVerifyResponseModel(
  success: json['success'] as bool,
  code: (json['code'] as num).toInt(),
  message: json['message'] as String,
  data: json['data'],
  errors: json['errors'],
);

Map<String, dynamic> _$OtpVerifyResponseModelToJson(
  OtpVerifyResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
  'errors': instance.errors,
};
