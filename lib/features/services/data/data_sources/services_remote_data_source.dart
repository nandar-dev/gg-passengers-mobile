import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/service_model.dart';

@lazySingleton
class ServicesRemoteDataSource {
  final Dio _dio;

  ServicesRemoteDataSource(this._dio);

  Future<List<ServiceModel>> fetchServices() async {
    try {
      final response = await _dio.get('/v1/services');
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch services');
      }
    } catch (e) {
      rethrow;
    }
  }
}
