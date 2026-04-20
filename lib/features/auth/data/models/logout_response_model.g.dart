// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logout_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogoutResponseModel _$LogoutResponseModelFromJson(Map<String, dynamic> json) =>
    LogoutResponseModel(
      success: json['success'] as bool,
      code: (json['code'] as num).toInt(),
      message: json['message'] as String,
      data: json['data'],
      errors: json['errors'],
    );

Map<String, dynamic> _$LogoutResponseModelToJson(
  LogoutResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
  'errors': instance.errors,
};
