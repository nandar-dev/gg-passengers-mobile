import 'package:json_annotation/json_annotation.dart';

part 'otp_verify_response_model.g.dart';

@JsonSerializable()
class OtpVerifyResponseModel {
  final bool success;
  final int code;
  final String message;
  final dynamic data;
  final dynamic errors;

  const OtpVerifyResponseModel({
    required this.success,
    required this.code,
    required this.message,
    this.data,
    this.errors,
  });

  factory OtpVerifyResponseModel.fromJson(Map<String, dynamic> json) =>
      _$OtpVerifyResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$OtpVerifyResponseModelToJson(this);
}
