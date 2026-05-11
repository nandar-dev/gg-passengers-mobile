import 'package:injectable/injectable.dart';

import '../entities/passenger_profile.dart';
import '../repositories/passenger_profile_repository.dart';

@lazySingleton
class GetPassengerProfileUseCase {
  final PassengerProfileRepository _repository;

  const GetPassengerProfileUseCase(this._repository);

  Future<PassengerProfile> call({bool forceRefresh = false}) {
    return _repository.getProfile(forceRefresh: forceRefresh);
  }
}
