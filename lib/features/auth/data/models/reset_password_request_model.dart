import 'package:json_annotation/json_annotation.dart';

part 'reset_password_request_model.g.dart';

@JsonSerializable()
class ResetPasswordRequestModel {
  final String login;
  @JsonKey(name: 'reset_token')
  final String resetToken;
  @JsonKey(name: 'new_password')
  final String newPassword;
  @JsonKey(name: 'new_password_confirmation')
  final String newPasswordConfirmation;

  const ResetPasswordRequestModel({
    required this.login,
    required this.resetToken,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  factory ResetPasswordRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResetPasswordRequestModelToJson(this);
}
