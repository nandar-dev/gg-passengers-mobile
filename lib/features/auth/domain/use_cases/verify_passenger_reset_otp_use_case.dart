import '../repositories/auth_repository.dart';

class VerifyPassengerResetOtpUseCase {
  final AuthRepository _authRepository;

  const VerifyPassengerResetOtpUseCase(this._authRepository);

  Future<String> call({
    required String login,
    required String otp,
  }) {
    return _authRepository.verifyPassengerResetOtp(
      login: login,
      otp: otp,
    );
  }
}
