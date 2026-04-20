import 'package:dio/dio.dart';

import '../../../config/app_config.dart';
import '../token_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;

  AuthInterceptor(this._tokenStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String? token = await _tokenStorage.readAccessToken();

    if (token != null && token.isNotEmpty) {
      final bearerToken = 'Bearer $token';
      options.headers['Authorization'] = bearerToken;
      options.headers['Token'] = bearerToken;
    }

    final String? apiKey = AppConfig.current.api.apiKey;
    if (apiKey != null && apiKey.isNotEmpty) {
      options.headers['x-api-key'] = apiKey;
    }

    handler.next(options);
  }
}
