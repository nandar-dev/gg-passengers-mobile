import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/booking_stop.dart';
import '../models/booking_estimate_model.dart';
import '../models/booking_creation_response_model.dart';

@lazySingleton
class BookingRemoteDataSource {
  final Dio _dio;

  const BookingRemoteDataSource(this._dio);

  Future<BookingEstimateModel> fetchEstimate({
    required String serviceId,
    required List<BookingStop> stops,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/passenger/bookings/estimate',
        data: {
          'service_id': serviceId,
          'locations': stops.map((stop) => stop.toRequestJson()).toList(),
        },
      );

      final body = response.data;
      if (body == null) {
        throw const ApiException(message: 'Estimate response is empty.');
      }

      final success = body['success'] == true;
      final code = body['code'] is int
          ? body['code'] as int
          : int.tryParse(body['code']?.toString() ?? '');
      final message = (body['message'] ?? 'Unable to fetch estimate').toString();

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
        throw const ApiException(message: 'Estimate data is missing.');
      }

      return BookingEstimateModel.fromJson(data);
    } catch (error) {
      if (error is ApiException) rethrow;
      throw DioErrorMapper.map(error);
    }
  }

  Future<BookingCreationResponseModel> createBooking({
    required String serviceId,
    required String vehicleTypeId,
    required List<BookingStop> stops,
    String? paymentMethodId,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/passenger/bookings',
        data: {
          'service_id': serviceId,
          'vehicle_type_id': vehicleTypeId,
          'payment_method_id': paymentMethodId,
          'stops': stops.map((stop) => stop.toRequestJson()).toList(),
        },
      );

      final body = response.data;
      if (body == null) {
        throw const ApiException(message: 'Booking response is empty.');
      }

      final success = body['success'] == true;
      final code = body['code'] is int
          ? body['code'] as int
          : int.tryParse(body['code']?.toString() ?? '');
      final message = (body['message'] ?? 'Unable to create booking').toString();

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
        throw const ApiException(message: 'Booking data is missing.');
      }

      return BookingCreationResponseModel.fromJson(data);
    } catch (error) {
      if (error is ApiException) rethrow;
      throw DioErrorMapper.map(error);
    }
  }
}
