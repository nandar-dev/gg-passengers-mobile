import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/passenger_profile_model.dart';

@lazySingleton
class PassengerProfileRemoteDataSource {
  final Dio _dio;

  const PassengerProfileRemoteDataSource(this._dio);

  Future<PassengerProfileModel> fetchProfile() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/v1/passenger/profile');
      final body = response.data;

      if (body == null) {
        throw const ApiException(message: 'Profile response is empty.');
      }

      final success = body['success'] == true;
      final code = body['code'] is int
          ? body['code'] as int
          : int.tryParse(body['code']?.toString() ?? '');
      final message = (body['message'] ?? 'Unable to fetch profile').toString();

      if (!success || (code != null && code >= 400)) {
        throw ApiException(
          message: message,
          statusCode: code,
          details: body['errors'] is Map<String, dynamic>
              ? body['errors'] as Map<String, dynamic>
              : null,
        );
      }

      final data = body['data'];
      if (data is! Map<String, dynamic>) {
        throw const ApiException(message: 'Profile data is empty.');
      }

      return PassengerProfileModel.fromJson(data);
    } catch (error) {
      if (error is ApiException) rethrow;
      throw DioErrorMapper.map(error);
    }
  }

  Future<PassengerProfileModel> updateProfile({
    required String fullName,
    required String email,
    required String phone,
    String? avatarFilePath,
  }) async {
    try {
      final bool hasAvatar =
          avatarFilePath != null && avatarFilePath.trim().isNotEmpty;

      late final Response<Map<String, dynamic>> response;

      if (hasAvatar) {
        final formData = FormData.fromMap({
          '_method': 'POST',
          'full_name': fullName,
          'email': email,
          'phone': phone,
          'avatar': await MultipartFile.fromFile(avatarFilePath.trim()),
        });

        response = await _dio.post<Map<String, dynamic>>(
          '/v1/passenger/profile',
          data: formData,
        );
      } else {
        // Server only exposes POST; use Laravel _method spoofing for update.
        response = await _dio.post<Map<String, dynamic>>(
          '/v1/passenger/profile',
          data: <String, dynamic>{
            '_method': 'POST',
            'full_name': fullName,
            'email': email,
            'phone': phone,
          },
          options: Options(
            headers: <String, dynamic>{
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );
      }

      final body = response.data;

      if (body == null) {
        throw const ApiException(message: 'Profile response is empty.');
      }

      final success = body['success'] == true;
      final code = body['code'] is int
          ? body['code'] as int
          : int.tryParse(body['code']?.toString() ?? '');
      final message = (body['message'] ?? 'Unable to update profile').toString();

      if (!success || (code != null && code >= 400)) {
        throw ApiException(
          message: message,
          statusCode: code,
          details: body['errors'] is Map<String, dynamic>
              ? body['errors'] as Map<String, dynamic>
              : null,
        );
      }

      final data = body['data'];
      if (data is Map<String, dynamic>) {
        return PassengerProfileModel.fromJson(data);
      }

      return PassengerProfileModel(
        id: '',
        name: fullName,
        email: email,
        phone: phone,
        avatarUrl: null,
        isVerified: true,
        createdAt: null,
      );
    } catch (error) {
      if (error is ApiException) rethrow;
      throw DioErrorMapper.map(error);
    }
  }
}
