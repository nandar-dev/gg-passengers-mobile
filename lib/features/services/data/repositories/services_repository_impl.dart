import 'package:injectable/injectable.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/services_repository.dart';
import '../data_sources/services_local_data_source.dart';
import '../data_sources/services_remote_data_source.dart';
import '../models/service_model.dart';

@LazySingleton(as: ServicesRepository)
class ServicesRepositoryImpl implements ServicesRepository {
  final ServicesRemoteDataSource _remoteDataSource;
  final ServicesLocalDataSource _localDataSource;
  
  static const Duration _cacheMaxAge = Duration(hours: 24);

  ServicesRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<List<AppService>> getServices({bool forceRefresh = false}) async {
    // 1. Check local cache first
    final cachedModels = _localDataSource.getCachedServices();
    
    if (cachedModels.isNotEmpty && !forceRefresh) {
      // If cache is stale, refresh in background
      if (_localDataSource.isCacheStale(_cacheMaxAge)) {
        _refreshAndCache();
      }
      return cachedModels.map((m) => m.toDomain()).toList();
    }

    // 2. Fetch from remote if no cache or forceRefresh
    return _refreshAndCache();
  }

  Future<List<AppService>> _refreshAndCache() async {
    try {
      final remoteModels = await _remoteDataSource.fetchServices();
      await _localDataSource.cacheServices(remoteModels);
      return remoteModels.map((m) => m.toDomain()).toList();
    } catch (e) {
      // If remote fails, fallback to expired cache if available
      final cachedModels = _localDataSource.getCachedServices();
      if (cachedModels.isNotEmpty) {
        return cachedModels.map((m) => m.toDomain()).toList();
      }
      rethrow;
    }
  }
}
