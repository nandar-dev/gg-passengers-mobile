import 'package:json_annotation/json_annotation.dart';

part 'forgot_password_request_model.g.dart';

@JsonSerializable()
class ForgotPasswordRequestModel {
  final String login;

  const ForgotPasswordRequestModel({
    required this.login,
  });

  factory ForgotPasswordRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordRequestModelToJson(this);
}
