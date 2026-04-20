import 'package:injectable/injectable.dart';

import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class LoginPassengerUseCase {
  final AuthRepository _authRepository;

  const LoginPassengerUseCase(this._authRepository);

  Future<AuthSession> call({
    required String login,
    required String password,
  }) {
    return _authRepository.loginPassenger(
      login: login,
      password: password,
    );
  }
}
