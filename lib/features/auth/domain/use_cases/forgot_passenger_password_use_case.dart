import '../repositories/auth_repository.dart';

class ForgotPassengerPasswordUseCase {
  final AuthRepository _authRepository;

  const ForgotPassengerPasswordUseCase(this._authRepository);

  Future<void> call({
    required String login,
  }) {
    return _authRepository.forgotPassengerPassword(
      login: login,
    );
  }
}
