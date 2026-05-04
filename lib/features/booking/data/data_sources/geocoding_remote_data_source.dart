import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/geocoding_result_model.dart';

@lazySingleton
class GeocodingRemoteDataSource {
  final Dio _dio;

  const GeocodingRemoteDataSource(this._dio);

  Future<GeocodingResultModel> geocode(String query) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'addressdetails': 1,
          'limit': 1,
        },
        options: Options(
          headers: {
            'User-Agent': 'GG_TAXI/1.0 (support@gg.taxi)',
            'Accept-Language': 'en',
          },
        ),
      );

      final data = response.data;
      if (data == null || data.isEmpty) {
        throw const ApiException(message: 'No location found for that address.');
      }

      final first = data.first;
      if (first is! Map<String, dynamic>) {
        throw const ApiException(message: 'Unable to parse location data.');
      }

      final model = GeocodingResultModel.fromJson(first);
      if (model.lat == 0.0 && model.lng == 0.0) {
        throw const ApiException(message: 'Location coordinates are unavailable.');
      }

      return model;
    } catch (error) {
      if (error is ApiException) rethrow;
      throw DioErrorMapper.map(error);
    }
  }

  Future<GeocodingResultModel> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': lat,
          'lon': lng,
          'format': 'json',
        },
        options: Options(
          headers: {
            'User-Agent': 'GG_TAXI/1.0 (support@gg.taxi)',
            'Accept-Language': 'en',
          },
        ),
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException(message: 'Unable to reverse geocode location.');
      }

      final displayName = data['display_name']?.toString() ?? '';
      if (displayName.trim().isEmpty) {
        throw const ApiException(message: 'Address is unavailable for this location.');
      }

      return GeocodingResultModel(
        lat: lat,
        lng: lng,
        displayName: displayName,
      );
    } catch (error) {
      if (error is ApiException) rethrow;
      throw DioErrorMapper.map(error);
    }
  }

  Future<List<GeocodingResultModel>> search({
    required String query,
    double? lat,
    double? lng,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'q': query,
        'format': 'json',
        'addressdetails': 1,
        'limit': 6,
      };

      if (lat != null && lng != null) {
        const double delta = 0.2;
        final double left = lng - delta;
        final double right = lng + delta;
        final double top = lat + delta;
        final double bottom = lat - delta;
        params['viewbox'] = '$left,$top,$right,$bottom';
        params['bounded'] = 1;
      }

      final response = await _dio.get<List<dynamic>>(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: params,
        options: Options(
          headers: {
            'User-Agent': 'GG_TAXI/1.0 (support@gg.taxi)',
            'Accept-Language': 'en',
          },
        ),
      );

      final data = response.data;
      if (data == null || data.isEmpty) {
        return const <GeocodingResultModel>[];
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(GeocodingResultModel.fromJson)
          .where((item) => item.lat != 0.0 && item.lng != 0.0)
          .toList(growable: false);
    } catch (error) {
      if (error is ApiException) rethrow;
      throw DioErrorMapper.map(error);
    }
  }
}
