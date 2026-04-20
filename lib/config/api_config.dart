import 'app_environment.dart';

class ApiConfig {
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final String? apiKey;
  final String? googleMapsApiKey;

  const ApiConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 20),
    this.receiveTimeout = const Duration(seconds: 20),
    this.apiKey,
    this.googleMapsApiKey,
  });

  static String defaultBaseUrlForEnvironment(AppEnvironment environment) {
    switch (environment) {
      case AppEnvironment.dev:
        return 'https://dev.api.ggtaxi.example.com';
      case AppEnvironment.staging:
        return 'https://staging.api.ggtaxi.example.com';
      case AppEnvironment.prod:
        return 'https://api.ggtaxi.example.com';
    }
  }

  factory ApiConfig.forEnvironment(AppEnvironment environment) {
    return ApiConfig(baseUrl: defaultBaseUrlForEnvironment(environment));
  }
}
