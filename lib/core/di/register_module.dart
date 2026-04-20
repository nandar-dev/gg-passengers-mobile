import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/auth_refresh_interceptor.dart';
import '../network/interceptors/network_log_interceptor.dart';
import '../network/shared_prefs_token_storage.dart';
import '../network/token_storage.dart';

@module
abstract class RegisterModule {
  @preResolve
  Future<SharedPreferences> get sharedPreferences => SharedPreferences.getInstance();

  @lazySingleton
  TokenStorage tokenStorage(SharedPreferences prefs) => SharedPrefsTokenStorage(prefs);

  @lazySingleton
  AuthInterceptor authInterceptor(TokenStorage tokenStorage) => AuthInterceptor(tokenStorage);

  @lazySingleton
  AuthRefreshInterceptor authRefreshInterceptor(TokenStorage tokenStorage) =>
      AuthRefreshInterceptor(tokenStorage);

  @lazySingleton
  Dio dio(
    AuthInterceptor authInterceptor,
    AuthRefreshInterceptor authRefreshInterceptor,
  ) {
    final appApiConfig = AppConfig.current.api;

    final dio = Dio(
      BaseOptions(
        baseUrl: appApiConfig.baseUrl,
        connectTimeout: appApiConfig.connectTimeout,
        receiveTimeout: appApiConfig.receiveTimeout,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    authRefreshInterceptor.attachDio(dio);
    dio.interceptors.add(authInterceptor);
    dio.interceptors.add(authRefreshInterceptor);

    if (AppConfig.current.enableLogs) {
      dio.interceptors.add(createNetworkLogInterceptor());
    }

    return dio;
  }
}
