import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  static bool _loaded = false;

  static Future<void> load({required String fileName}) async {
    if (_loaded) return;

    try {
      await dotenv.load(fileName: fileName);
    } catch (_) {
      // Keep running with defaults and dart-define values when env file is absent.
    }

    _loaded = true;
  }

  static String? get apiBaseUrl => _resolveString(
    key: 'API_BASE_URL',
    dartDefine: const String.fromEnvironment('API_BASE_URL', defaultValue: ''),
  );

  static int? get apiConnectTimeoutMs => _resolveInt(
    key: 'API_CONNECT_TIMEOUT_MS',
    dartDefine: const String.fromEnvironment('API_CONNECT_TIMEOUT_MS', defaultValue: ''),
  );

  static int? get apiReceiveTimeoutMs => _resolveInt(
    key: 'API_RECEIVE_TIMEOUT_MS',
    dartDefine: const String.fromEnvironment('API_RECEIVE_TIMEOUT_MS', defaultValue: ''),
  );

  static String? get apiKey => _resolveString(
    key: 'API_KEY',
    dartDefine: const String.fromEnvironment('API_KEY', defaultValue: ''),
  );

  static String? get googleMapsApiKey => _resolveString(
    key: 'GOOGLE_MAPS_API_KEY',
    dartDefine: const String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: ''),
  );

  static bool get enableNetworkLogs {
    final String value = _resolveString(
          key: 'ENABLE_NETWORK_LOGS',
          dartDefine: const String.fromEnvironment('ENABLE_NETWORK_LOGS', defaultValue: ''),
        ) ??
        'true';
    return value.toLowerCase() == 'true' || value == '1';
  }

  static String? _resolveString({required String key, required String dartDefine}) {
    final String? envValue = dotenv.maybeGet(key);
    if (envValue != null && envValue.trim().isNotEmpty) {
      return envValue.trim();
    }

    if (dartDefine.trim().isNotEmpty) {
      return dartDefine.trim();
    }

    return null;
  }

  static int? _resolveInt({required String key, required String dartDefine}) {
    final String? value = _resolveString(key: key, dartDefine: dartDefine);
    if (value == null) return null;
    return int.tryParse(value);
  }
}
