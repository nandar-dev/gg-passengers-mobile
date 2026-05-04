import 'package:gg/features/services/domain/entities/service_entity.dart';
import 'package:gg/features/services/domain/repositories/services_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetServicesUseCase {
  final ServicesRepository _repository;

  GetServicesUseCase(this._repository);

  Future<List<AppService>> call({bool forceRefresh = false}) {
    return _repository.getServices(forceRefresh: forceRefresh);
  }
}
