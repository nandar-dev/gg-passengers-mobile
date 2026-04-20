import 'package:injectable/injectable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/logout_response_model.dart';
import '../models/otp_verify_request_model.dart';
import '../models/otp_verify_response_model.dart';
import '../models/register_request_model.dart';
import '../models/register_response_model.dart';
import 'auth_api_service.dart';

@lazySingleton
class AuthRemoteDataSource {
  final AuthApiService _apiService;

  const AuthRemoteDataSource(this._apiService);

  Future<RegisterResponseModel> registerPassenger({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _apiService.registerPassenger(
        RegisterRequestModel(
          name: name,
          email: email,
          phone: phone,
          password: password,
        ),
      );

      if (!response.success) {
        throw ApiException(
          message: response.message,
          statusCode: response.code,
          details: response.errors is Map<String, dynamic>
              ? response.errors as Map<String, dynamic>
              : null,
        );
      }

      return response;
    } catch (error) {
      if (error is ApiException) rethrow;
      throw DioErrorMapper.map(error);
    }
  }

  Future<LoginResponseModel> loginPassenger({
    required String login,
    required String password,
  }) async {
    try {
      final response = await _apiService.loginPassenger(
        LoginRequestModel(
          login: login,
          password: password,
        ),
      );

      if (!response.success) {
        throw ApiException(
          message: response.message,
          statusCode: response.code,
          details: response.errors is Map<String, dynamic>
              ? <String, dynamic>{'errors': response.errors}
              : null,
        );
      }

      return response;
    } catch (error) {
      if (error is ApiException) rethrow;
      throw DioErrorMapper.map(error);
    }
  }

  Future<OtpVerifyResponseModel> verifyPassengerOtp({
    required String otpCode,
  }) async {
    try {
      final response = await _apiService.verifyPassengerOtp(
        OtpVerifyRequestModel(
          otpCode: otpCode,
        ),
      );

      if (!response.success) {
        throw ApiException(
          message: response.message,
          statusCode: response.code,
          details: response.errors is Map<String, dynamic>
              ? <String, dynamic>{'errors': response.errors}
              : null,
        );
      }

      return response;
    } catch (error) {
      if (error is ApiException) rethrow;
      throw DioErrorMapper.map(error);
    }
  }

  Future<LoginResponseModel> refreshPassengerToken({required String bearerToken}) async {
    try {
      final response = await _apiService.refreshPassengerToken(bearerToken);

      if (!response.success) {
        throw ApiException(
          message: response.message,
          statusCode: response.code,
          details: response.errors is Map<String, dynamic>
              ? <String, dynamic>{'errors': response.errors}
              : null,
        );
      }

      return response;
    } catch (error) {
      if (error is ApiException) rethrow;
      throw DioErrorMapper.map(error);
    }
  }

  Future<LogoutResponseModel> logoutPassenger({required String bearerToken}) async {
    try {
      final response = await _apiService.logoutPassenger(bearerToken);

      if (!response.success) {
        throw ApiException(
          message: response.message,
          statusCode: response.code,
          details: response.errors is Map<String, dynamic>
              ? <String, dynamic>{'errors': response.errors}
              : null,
        );
      }

      return response;
    } catch (error) {
      if (error is ApiException) rethrow;
      throw DioErrorMapper.map(error);
    }
  }
}
