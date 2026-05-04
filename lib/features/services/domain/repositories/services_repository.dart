import '../entities/service_entity.dart';

abstract class ServicesRepository {
  Future<List<AppService>> getServices({bool forceRefresh = false});
}
