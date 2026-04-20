import 'package:json_annotation/json_annotation.dart';

part 'logout_response_model.g.dart';

@JsonSerializable()
class LogoutResponseModel {
  final bool success;
  final int code;
  final String message;
  final dynamic data;
  final dynamic errors;

  const LogoutResponseModel({
    required this.success,
    required this.code,
    required this.message,
    this.data,
    this.errors,
  });

  factory LogoutResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LogoutResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LogoutResponseModelToJson(this);
}
