import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/booking_stop.dart';
import '../models/active_booking_model.dart';
import '../models/booking_estimate_model.dart';
import '../models/booking_creation_response_model.dart';
import '../models/nearby_driver_model.dart';

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

  Future<List<ActiveBookingModel>> fetchActiveBookings() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/passenger/bookings',
      );

      final body = response.data;
      if (body == null) {
        throw const ApiException(message: 'Active bookings response is empty.');
      }

      final success = body['success'] == true;
      final code = body['code'] is int
          ? body['code'] as int
          : int.tryParse(body['code']?.toString() ?? '');
      final message = (body['message'] ?? 'Unable to load active bookings').toString();

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
      if (data is! List<dynamic>) {
        return const [];
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(ActiveBookingModel.fromJson)
          .toList(growable: false);
    } catch (error) {
      if (error is ApiException) rethrow;
      throw DioErrorMapper.map(error);
    }
  }

  Future<ActiveBookingModel> fetchActiveBookingById({
    required String bookingId,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/passenger/bookings/$bookingId',
      );

      final body = response.data;
      if (body == null) {
        throw const ApiException(message: 'Booking detail response is empty.');
      }

      final success = body['success'] == true;
      final code = body['code'] is int
          ? body['code'] as int
          : int.tryParse(body['code']?.toString() ?? '');
      final message = (body['message'] ?? 'Unable to load booking detail').toString();

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
        throw const ApiException(message: 'Booking detail data is missing.');
      }

      return ActiveBookingModel.fromJson(data);
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

  Future<void> cancelBooking({
    required String bookingId,
    required String reason,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/passenger/bookings/$bookingId/cancel',
        data: {
          'reason': reason,
        },
      );

      final body = response.data;
      if (body == null) {
        throw const ApiException(message: 'Cancel booking response is empty.');
      }

      final success = body['success'] == true;
      final code = body['code'] is int
          ? body['code'] as int
          : int.tryParse(body['code']?.toString() ?? '');
      final message = (body['message'] ?? 'Unable to cancel booking').toString();

      if (!success || (code != null && code >= 400)) {
        throw ApiException(
          message: message,
          statusCode: code,
          details: body['errors'] is Map<String, dynamic>
              ? body['errors'] as Map<String, dynamic>
              : null,
        );
      }
    } catch (error) {
      if (error is ApiException) rethrow;
      throw DioErrorMapper.map(error);
    }
  }

  Future<void> submitBookingReview({
    required String bookingId,
    required int ratingValue,
    required String comment,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/passenger/bookings/$bookingId/reviews',
        data: {
          'rating_value': ratingValue,
          'comment': comment,
        },
      );

      final body = response.data;
      if (body == null) {
        throw const ApiException(message: 'Review response is empty.');
      }

      final success = body['success'] == true;
      final code = body['code'] is int
          ? body['code'] as int
          : int.tryParse(body['code']?.toString() ?? '');
      final message = (body['message'] ?? 'Unable to submit review').toString();

      if (!success || (code != null && code >= 400)) {
        throw ApiException(
          message: message,
          statusCode: code,
          details: body['errors'] is Map<String, dynamic>
              ? body['errors'] as Map<String, dynamic>
              : null,
        );
      }
    } catch (error) {
      if (error is ApiException) rethrow;
      throw DioErrorMapper.map(error);
    }
  }

  Future<List<NearbyDriverModel>> fetchNearbyDrivers({
    required double lat,
    required double lng,
    required String serviceId,
    double radiusKm = 50,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/passenger/nearby-drivers',
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'service_id': serviceId,
          'radius_km': radiusKm,
        },
      );

      final body = response.data;
      if (body == null) {
        throw const ApiException(message: 'Nearby drivers response is empty.');
      }

      final success = body['success'] == true;
      final code = body['code'] is int
          ? body['code'] as int
          : int.tryParse(body['code']?.toString() ?? '');
      final message = (body['message'] ?? 'Unable to fetch nearby drivers').toString();

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
      List<dynamic> rawList = const [];
      if (data is List<dynamic>) {
        rawList = data;
      } else if (data is Map<String, dynamic>) {
        final drivers = data['drivers'] ?? data['nearby_drivers'] ?? data['items'];
        if (drivers is List<dynamic>) {
          rawList = drivers;
        }
      }

      return rawList
          .whereType<Map<String, dynamic>>()
          .map(NearbyDriverModel.fromJson)
          .toList(growable: false);
    } catch (error) {
      if (error is ApiException) rethrow;
      throw DioErrorMapper.map(error);
    }
  }

  Future<String> fetchBookingStatus({
    required String bookingId,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/passenger/bookings/$bookingId',
      );

      final body = response.data;
      if (body == null) {
        throw const ApiException(message: 'Booking status response is empty.');
      }

      final success = body['success'] == true;
      final code = body['code'] is int
          ? body['code'] as int
          : int.tryParse(body['code']?.toString() ?? '');
      final message = (body['message'] ?? 'Unable to fetch booking status').toString();

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
        throw const ApiException(message: 'Booking status data is missing.');
      }

      final status = data['status']?.toString().trim().toLowerCase() ?? '';
      if (status.isEmpty) {
        throw const ApiException(message: 'Booking status is missing.');
      }

      return status;
    } catch (error) {
      if (error is ApiException) rethrow;
      throw DioErrorMapper.map(error);
    }
  }
}
