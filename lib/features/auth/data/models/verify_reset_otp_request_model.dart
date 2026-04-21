import 'package:json_annotation/json_annotation.dart';

part 'verify_reset_otp_request_model.g.dart';

@JsonSerializable()
class VerifyResetOtpRequestModel {
  final String login;
  final String otp;

  const VerifyResetOtpRequestModel({
    required this.login,
    required this.otp,
  });

  factory VerifyResetOtpRequestModel.fromJson(Map<String, dynamic> json) =>
      _$VerifyResetOtpRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyResetOtpRequestModelToJson(this);
}
