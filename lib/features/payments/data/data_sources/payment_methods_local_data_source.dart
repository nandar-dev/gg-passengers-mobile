import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/payment_method_model.dart';

@lazySingleton
class PaymentMethodsLocalDataSource {
  static const String _methodsCacheKey = 'payments.methods.cache';
  static const String _cacheUpdatedAtKey = 'payments.methods.cache.updated_at';

  final SharedPreferences _prefs;

  const PaymentMethodsLocalDataSource(this._prefs);

  List<PaymentMethodModel> readPaymentMethods() {
    final raw = _prefs.getString(_methodsCacheKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(PaymentMethodModel.fromJson)
          .where((item) => item.id.isNotEmpty && item.name.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> savePaymentMethods(List<PaymentMethodModel> methods) async {
    if (methods.isEmpty) return;

    await _prefs.setString(
      _methodsCacheKey,
      jsonEncode(methods.map((method) => method.toJson()).toList(growable: false)),
    );
    await _prefs.setInt(_cacheUpdatedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  bool isCacheStale(Duration maxAge) {
    final updatedAt = _prefs.getInt(_cacheUpdatedAtKey);
    if (updatedAt == null) {
      return true;
    }

    final age = DateTime.now().millisecondsSinceEpoch - updatedAt;
    return age > maxAge.inMilliseconds;
  }
}