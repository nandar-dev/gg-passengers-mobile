import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../domain/entities/payment_method.dart';
import '../../domain/repositories/payment_methods_repository.dart';
import '../data_sources/payment_methods_local_data_source.dart';
import '../data_sources/payment_methods_remote_data_source.dart';

@LazySingleton(as: PaymentMethodsRepository)
class PaymentMethodsRepositoryImpl implements PaymentMethodsRepository {
  final PaymentMethodsRemoteDataSource _remoteDataSource;
  final PaymentMethodsLocalDataSource _localDataSource;

  PaymentMethodsRepositoryImpl(this._remoteDataSource, this._localDataSource);

  List<PaymentMethod>? _cachedMethods;
  static const Duration _cacheMaxAge = Duration(hours: 6);

  @override
  Future<List<PaymentMethod>> getPaymentMethods({
    bool forceRefresh = false,
  }) async {
    final localMethods = _localDataSource
        .readPaymentMethods()
        .map((model) => model.toDomain())
        .toList(growable: false);
    final hasLocal = localMethods.isNotEmpty;

    if (hasLocal) {
      _cachedMethods = localMethods;
    }

    final hasMemoryCache = _cachedMethods != null && _cachedMethods!.isNotEmpty;

    if (!forceRefresh && hasLocal) {
      if (_localDataSource.isCacheStale(_cacheMaxAge)) {
        unawaited(_refreshAndCache());
      }
      return localMethods;
    }

    if (!forceRefresh && hasMemoryCache) {
      return _cachedMethods!;
    }

    try {
      final remoteMethods = await _remoteDataSource.fetchPaymentMethods();
      final methods = remoteMethods
          .map((model) => model.toDomain())
          .toList(growable: false);

      if (methods.isNotEmpty) {
        await _localDataSource.savePaymentMethods(remoteMethods);
        _cachedMethods = methods;
      }

      if (methods.isNotEmpty) {
        return methods;
      }

      if (hasLocal) {
        return localMethods;
      }

      if (hasMemoryCache) {
        return _cachedMethods!;
      }

      return const [];
    } catch (error) {
      if (hasLocal) {
        return localMethods;
      }

      if (hasMemoryCache) {
        return _cachedMethods!;
      }

      rethrow;
    }
  }

  Future<void> _refreshAndCache() async {
    try {
      final remoteMethods = await _remoteDataSource.fetchPaymentMethods();
      if (remoteMethods.isEmpty) {
        return;
      }

      await _localDataSource.savePaymentMethods(remoteMethods);
      _cachedMethods = remoteMethods
          .map((model) => model.toDomain())
          .toList(growable: false);
    } catch (_) {
      // Ignore silent refresh failures and keep cached values.
    }
  }
}
