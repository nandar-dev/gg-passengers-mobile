import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/payment_method_model.dart';

@lazySingleton
class PaymentMethodsRemoteDataSource {
  final Dio _dio;

  const PaymentMethodsRemoteDataSource(this._dio);

  Future<List<PaymentMethodModel>> fetchPaymentMethods() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/v1/payment-methods');
      final body = response.data;

      if (body == null) {
        throw const ApiException(message: 'Payment methods response is empty.');
      }

      final success = body['success'] == true;
      final code = body['code'] is int
          ? body['code'] as int
          : int.tryParse(body['code']?.toString() ?? '');
      final message = (body['message'] ?? 'Unable to fetch payment methods').toString();

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
          .map(PaymentMethodModel.fromJson)
          .where((item) => item.id.isNotEmpty && item.name.isNotEmpty)
          .toList(growable: false);
    } catch (error) {
      if (error is ApiException) rethrow;
      throw DioErrorMapper.map(error);
    }
  }
}
