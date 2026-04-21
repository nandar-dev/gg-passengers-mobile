import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/logout_response_model.dart';
import '../models/forgot_password_request_model.dart';
import '../models/otp_verify_request_model.dart';
import '../models/otp_verify_response_model.dart';
import '../models/reset_password_request_model.dart';
import '../models/register_request_model.dart';
import '../models/register_response_model.dart';
import '../models/verify_reset_otp_request_model.dart';
import '../models/verify_reset_otp_response_model.dart';

part 'auth_api_service.g.dart';

@RestApi()
@lazySingleton
abstract class AuthApiService {
  @factoryMethod
  factory AuthApiService(Dio dio) = _AuthApiService;

  @POST('/v1/auth/passenger/register')
  Future<RegisterResponseModel> registerPassenger(@Body() RegisterRequestModel body);

  @POST('/v1/auth/passenger/login')
  Future<LoginResponseModel> loginPassenger(@Body() LoginRequestModel body);

  @POST('/v1/auth/passenger/otp-verify')
  Future<OtpVerifyResponseModel> verifyPassengerOtp(@Body() OtpVerifyRequestModel body);

  @POST('/v1/auth/passenger/otp-resend')
  Future<OtpVerifyResponseModel> resendPassengerOtp();

  @POST('/v1/auth/passenger/forgot-password')
  Future<OtpVerifyResponseModel> forgotPassengerPassword(
    @Body() ForgotPasswordRequestModel body,
  );

  @POST('/v1/auth/passenger/verify-reset-otp')
  Future<VerifyResetOtpResponseModel> verifyPassengerResetOtp(
    @Body() VerifyResetOtpRequestModel body,
  );

  @POST('/v1/auth/passenger/reset-password')
  Future<OtpVerifyResponseModel> resetPassengerPassword(
    @Body() ResetPasswordRequestModel body,
  );

  @POST('/v1/auth/passenger/refresh')
  Future<LoginResponseModel> refreshPassengerToken(@Header('Token') String token);

  @POST('/v1/auth/passenger/logout')
  Future<LogoutResponseModel> logoutPassenger(@Header('Token') String token);
}
