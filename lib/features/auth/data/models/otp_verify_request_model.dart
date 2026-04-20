import 'package:json_annotation/json_annotation.dart';

part 'otp_verify_request_model.g.dart';

@JsonSerializable()
class OtpVerifyRequestModel {
  @JsonKey(name: 'otp_code')
  final String otpCode;

  const OtpVerifyRequestModel({
    required this.otpCode,
  });

  factory OtpVerifyRequestModel.fromJson(Map<String, dynamic> json) =>
      _$OtpVerifyRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$OtpVerifyRequestModelToJson(this);
}
