import '../repositories/auth_repository.dart';

class ResetPassengerPasswordUseCase {
  final AuthRepository _authRepository;

  const ResetPassengerPasswordUseCase(this._authRepository);

  Future<void> call({
    required String login,
    required String resetToken,
    required String newPassword,
    required String newPasswordConfirmation,
  }) {
    return _authRepository.resetPassengerPassword(
      login: login,
      resetToken: resetToken,
      newPassword: newPassword,
      newPasswordConfirmation: newPasswordConfirmation,
    );
  }
}
