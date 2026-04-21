import 'package:json_annotation/json_annotation.dart';

part 'verify_reset_otp_response_model.g.dart';

@JsonSerializable()
class VerifyResetOtpResponseModel {
  final bool success;
  final int code;
  final String message;
  final VerifyResetOtpDataModel? data;
  final dynamic errors;

  const VerifyResetOtpResponseModel({
    required this.success,
    required this.code,
    required this.message,
    this.data,
    this.errors,
  });

  factory VerifyResetOtpResponseModel.fromJson(Map<String, dynamic> json) =>
      _$VerifyResetOtpResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyResetOtpResponseModelToJson(this);
}

@JsonSerializable()
class VerifyResetOtpDataModel {
  @JsonKey(name: 'reset_token')
  final String resetToken;

  const VerifyResetOtpDataModel({
    required this.resetToken,
  });

  factory VerifyResetOtpDataModel.fromJson(Map<String, dynamic> json) =>
      _$VerifyResetOtpDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyResetOtpDataModelToJson(this);
}
