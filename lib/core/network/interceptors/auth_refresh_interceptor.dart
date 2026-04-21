import 'package:dio/dio.dart';

import '../../../config/app_config.dart';
import '../../session/app_session_state.dart';
import '../token_storage.dart';

class AuthRefreshInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  Dio? _dio;
  Future<String?>? _refreshFuture;

  AuthRefreshInterceptor(this._tokenStorage);

  void attachDio(Dio dio) {
    _dio = dio;
  }

  bool _isAuthExcludedPath(String path) {
    return path.contains('/v1/auth/passenger/login') ||
        path.contains('/v1/auth/passenger/register') ||
      path.contains('/v1/auth/passenger/otp-verify') ||
      path.contains('/v1/auth/passenger/otp-resend') ||
      path.contains('/v1/auth/passenger/forgot-password') ||
      path.contains('/v1/auth/passenger/verify-reset-otp') ||
      path.contains('/v1/auth/passenger/reset-password') ||
        path.contains('/v1/auth/passenger/refresh');
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final requestOptions = err.requestOptions;

    if (statusCode != 401 || requestOptions.extra['retried'] == true) {
      handler.next(err);
      return;
    }

    if (_isAuthExcludedPath(requestOptions.path)) {
      handler.next(err);
      return;
    }

    final dio = _dio;
    if (dio == null) {
      handler.next(err);
      return;
    }

    String? currentToken;

    try {
      currentToken = await _tokenStorage.readAccessToken();
      if (currentToken == null || currentToken.isEmpty) {
        handler.next(err);
        return;
      }

      _refreshFuture ??= _refreshToken(currentToken);
      final refreshedToken = await _refreshFuture;
      _refreshFuture = null;

      if (refreshedToken == null || refreshedToken.isEmpty) {
        await _logoutSilently(currentToken);
        handler.next(err);
        return;
      }

      final retriedRequest = requestOptions.copyWith(
        headers: <String, dynamic>{
          ...requestOptions.headers,
          'Authorization': 'Bearer $refreshedToken',
          'Token': 'Bearer $refreshedToken',
        },
        extra: <String, dynamic>{...requestOptions.extra, 'retried': true},
      );

      final response = await dio.fetch<dynamic>(retriedRequest);
      handler.resolve(response);
    } catch (_) {
      _refreshFuture = null;
      if (currentToken != null && currentToken.isNotEmpty) {
        await _logoutSilently(currentToken);
      }
      handler.next(err);
    }
  }

  Future<String?> _refreshToken(String token) async {
    final apiConfig = AppConfig.current.api;
    final refreshDio = Dio(
      BaseOptions(
        baseUrl: apiConfig.baseUrl,
        connectTimeout: apiConfig.connectTimeout,
        receiveTimeout: apiConfig.receiveTimeout,
        headers: const <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    final bearerToken = 'Bearer $token';
    final response = await refreshDio.post<Map<String, dynamic>>(
      '/v1/auth/passenger/refresh',
      options: Options(
        headers: <String, String>{
          'Authorization': bearerToken,
          'Token': bearerToken,
        },
      ),
    );

    final data = response.data;
    if (data == null) return null;

    final success = data['success'] == true;
    final payload = data['data'];
    if (!success || payload is! Map<String, dynamic>) {
      return null;
    }

    final newToken = payload['token'] as String?;
    if (newToken == null || newToken.isEmpty) {
      return null;
    }

    await _tokenStorage.saveAccessToken(newToken);
    return newToken;
  }

  Future<void> _logoutSilently(String token) async {
    final apiConfig = AppConfig.current.api;
    final logoutDio = Dio(
      BaseOptions(
        baseUrl: apiConfig.baseUrl,
        connectTimeout: apiConfig.connectTimeout,
        receiveTimeout: apiConfig.receiveTimeout,
        headers: const <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    final bearerToken = 'Bearer $token';

    try {
      await logoutDio.post<dynamic>(
        '/v1/auth/passenger/logout',
        options: Options(
          headers: <String, String>{
            'Authorization': bearerToken,
            'Token': bearerToken,
          },
        ),
      );
    } catch (_) {
      // Ignore remote logout failure and ensure local session is invalidated.
    } finally {
      await _tokenStorage.clearAccessToken();
      appSessionState.markForcedLogout();
    }
  }
}
