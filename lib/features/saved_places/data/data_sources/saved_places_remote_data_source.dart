import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/saved_place_model.dart';

@lazySingleton
class SavedPlacesRemoteDataSource {
  final Dio _dio;

  const SavedPlacesRemoteDataSource(this._dio);

  Future<List<SavedPlaceModel>> fetchSavedPlaces() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/v1/passenger/saved-places');
      final body = response.data;

      if (body == null) {
        throw const ApiException(message: 'Saved places response is empty.');
      }

      final success = body['success'] == true;
      final code = body['code'] is int
          ? body['code'] as int
          : int.tryParse(body['code']?.toString() ?? '');
      final message = (body['message'] ?? 'Unable to fetch saved places').toString();

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
      if (data is! List) {
        return const [];
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(SavedPlaceModel.fromJson)
          .where((item) => item.id.isNotEmpty)
          .toList(growable: false);
    } catch (error) {
      if (error is ApiException) rethrow;
      throw DioErrorMapper.map(error);
    }
  }

  Future<SavedPlaceModel> fetchSavedPlace(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/passenger/saved-places/$id',
      );
      final body = response.data;

      if (body == null) {
        throw const ApiException(message: 'Saved place response is empty.');
      }

      final success = body['success'] == true;
      final code = body['code'] is int
          ? body['code'] as int
          : int.tryParse(body['code']?.toString() ?? '');
      final message = (body['message'] ?? 'Unable to fetch saved place').toString();

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
        throw const ApiException(message: 'Saved place data is empty.');
      }

      return SavedPlaceModel.fromJson(data);
    } catch (error) {
      if (error is ApiException) rethrow;
      throw DioErrorMapper.map(error);
    }
  }

  Future<SavedPlaceModel> createSavedPlace(SavedPlaceModel model) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/passenger/saved-places',
        data: model.toCreatePayload(),
      );
      final body = response.data;

      if (body == null) {
        throw const ApiException(message: 'Saved place response is empty.');
      }

      final success = body['success'] == true;
      final code = body['code'] is int
          ? body['code'] as int
          : int.tryParse(body['code']?.toString() ?? '');
      final message = (body['message'] ?? 'Unable to create saved place').toString();

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
        return SavedPlaceModel.fromJson(data);
      }

      return model;
    } catch (error) {
      if (error is ApiException) rethrow;
      throw DioErrorMapper.map(error);
    }
  }

  Future<SavedPlaceModel> updateSavedPlace(String id, SavedPlaceModel model) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/v1/passenger/saved-places/$id',
        data: model.toCreatePayload(),
      );
      final body = response.data;

      if (body == null) {
        throw const ApiException(message: 'Saved place response is empty.');
      }

      final success = body['success'] == true;
      final code = body['code'] is int
          ? body['code'] as int
          : int.tryParse(body['code']?.toString() ?? '');
      final message = (body['message'] ?? 'Unable to update saved place').toString();

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
        return SavedPlaceModel.fromJson(data);
      }

      return model;
    } catch (error) {
      if (error is ApiException) rethrow;
      throw DioErrorMapper.map(error);
    }
  }

  Future<void> deleteSavedPlace(String id) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        '/v1/passenger/saved-places/$id',
      );
      final body = response.data;

      if (body == null) {
        return;
      }

      final success = body['success'] == true;
      final code = body['code'] is int
          ? body['code'] as int
          : int.tryParse(body['code']?.toString() ?? '');

      if (!success || (code != null && code >= 400)) {
        throw ApiException(
          message: (body['message'] ?? 'Unable to delete saved place').toString(),
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

  Future<void> setDefaultPlace(String id) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/v1/passenger/saved-places/$id/set-default',
      );
      final body = response.data;

      if (body == null) {
        return;
      }

      final success = body['success'] == true;
      final code = body['code'] is int
          ? body['code'] as int
          : int.tryParse(body['code']?.toString() ?? '');

      if (!success || (code != null && code >= 400)) {
        throw ApiException(
          message: (body['message'] ?? 'Unable to update default place').toString(),
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
}
