import 'package:injectable/injectable.dart';

import '../entities/passenger_profile.dart';
import '../repositories/passenger_profile_repository.dart';

@lazySingleton
class UpdatePassengerProfileUseCase {
  final PassengerProfileRepository _repository;

  const UpdatePassengerProfileUseCase(this._repository);

  Future<PassengerProfile> call({
    required String fullName,
    required String email,
    required String phone,
    String? avatarFilePath,
  }) {
    return _repository.updateProfile(
      fullName: fullName,
      email: email,
      phone: phone,
      avatarFilePath: avatarFilePath,
    );
  }
}
