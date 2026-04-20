import 'package:injectable/injectable.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class RegisterPassengerUseCase {
  final AuthRepository _authRepository;

  const RegisterPassengerUseCase(this._authRepository);

  Future<User> call({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) {
    return _authRepository.registerPassenger(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
  }
}
