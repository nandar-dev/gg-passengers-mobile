import 'package:dio/dio.dart';

import 'api_exception.dart';

class DioErrorMapper {
  const DioErrorMapper._();

  static ApiException map(Object error) {
    if (error is! DioException) {
      return ApiException(message: 'Unexpected error occurred. Please try again.');
    }

    final response = error.response;
    final int? statusCode = response?.statusCode;
    final dynamic data = response?.data;

    if (data is Map<String, dynamic>) {
      final String? serverMessage = data['message'] as String?;
      if (serverMessage != null && serverMessage.trim().isNotEmpty) {
        return ApiException(
          message: serverMessage,
          statusCode: statusCode,
          details: data,
        );
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Request timed out. Please check your internet and try again.',
          statusCode: statusCode,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'No internet connection. Please check your network.',
          statusCode: statusCode,
        );
      case DioExceptionType.badResponse:
        return ApiException(
          message: 'Request failed with status code ${statusCode ?? '-'}',
          statusCode: statusCode,
          details: data is Map<String, dynamic> ? data : null,
        );
      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled.',
          statusCode: statusCode,
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return ApiException(
          message: 'Unable to connect right now. Please try again later.',
          statusCode: statusCode,
        );
    }
  }
}
