import '../repositories/auth_repository.dart';

class ResendPassengerOtpUseCase {
  final AuthRepository _authRepository;

  const ResendPassengerOtpUseCase(this._authRepository);

  Future<void> call() {
    return _authRepository.resendPassengerOtp();
  }
}
