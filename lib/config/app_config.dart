import 'api_config.dart';
import 'app_constants.dart';
import 'app_environment.dart';
import 'env_config.dart';

class AppConfig {
  final AppEnvironment environment;
  final String appName;
  final ApiConfig api;
  final bool enableLogs;

  const AppConfig({
    required this.environment,
    required this.appName,
    required this.api,
    required this.enableLogs,
  });

  static late AppConfig current;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    const String envValue = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
    const String envFile = String.fromEnvironment('ENV_FILE', defaultValue: '');
    final AppEnvironment environment = _parseEnvironment(envValue);

    final String resolvedEnvFile = envFile.isNotEmpty
        ? envFile
        : 'assets/env/.env.${environment.name}';

    await EnvConfig.load(fileName: resolvedEnvFile);

    final String baseUrl = EnvConfig.apiBaseUrl ?? ApiConfig.defaultBaseUrlForEnvironment(environment);

    current = AppConfig(
      environment: environment,
      appName: AppConstants.appName,
      api: ApiConfig(
        baseUrl: baseUrl,
        connectTimeout: Duration(milliseconds: EnvConfig.apiConnectTimeoutMs ?? 20000),
        receiveTimeout: Duration(milliseconds: EnvConfig.apiReceiveTimeoutMs ?? 20000),
        apiKey: EnvConfig.apiKey,
        googleMapsApiKey: EnvConfig.googleMapsApiKey,
      ),
      enableLogs: environment != AppEnvironment.prod && EnvConfig.enableNetworkLogs,
    );
  }

  static bool get _isInitialized {
    try {
      // Accessing late var throws if not initialized.
      final AppEnvironment _ = current.environment;
      return true;
    } catch (_) {
      return false;
    }
  }

  static AppEnvironment _parseEnvironment(String value) {
    switch (value.toLowerCase()) {
      case 'prod':
      case 'production':
        return AppEnvironment.prod;
      case 'staging':
        return AppEnvironment.staging;
      case 'dev':
      case 'development':
      default:
        return AppEnvironment.dev;
    }
  }
}
