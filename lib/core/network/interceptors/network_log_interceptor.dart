import 'package:dio/dio.dart';

import '../../../config/app_config.dart';

Interceptor createNetworkLogInterceptor() {
  return LogInterceptor(
    requestBody: true,
    responseBody: true,
    requestHeader: true,
    responseHeader: false,
    error: true,
    logPrint: (obj) {
      if (AppConfig.current.enableLogs) {
        // ignore: avoid_print
        print(obj);
      }
    },
  );
}
