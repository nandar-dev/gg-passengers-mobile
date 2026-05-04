import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/service_model.dart';

@lazySingleton
class ServicesLocalDataSource {
  static const String _servicesCacheKey = 'services.cache';
  static const String _servicesTimestampKey = 'services.cache.timestamp';
  final SharedPreferences _prefs;

  ServicesLocalDataSource(this._prefs);

  List<ServiceModel> getCachedServices() {
    final String? jsonString = _prefs.getString(_servicesCacheKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => ServiceModel.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> cacheServices(List<ServiceModel> services) async {
    final String encoded = jsonEncode(services.map((s) => s.toJson()).toList());
    await _prefs.setString(_servicesCacheKey, encoded);
    await _prefs.setInt(_servicesTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  bool isCacheStale(Duration maxAge) {
    final int? timestamp = _prefs.getInt(_servicesTimestampKey);
    if (timestamp == null) return true;

    final DateTime lastUpdate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(lastUpdate) > maxAge;
  }
}
