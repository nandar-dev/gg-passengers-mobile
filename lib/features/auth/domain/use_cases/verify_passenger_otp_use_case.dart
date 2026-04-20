import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

@lazySingleton
class VerifyPassengerOtpUseCase {
  final AuthRepository _authRepository;

  const VerifyPassengerOtpUseCase(this._authRepository);

  Future<void> call({
    required String otpCode,
  }) {
    return _authRepository.verifyPassengerOtp(
      otpCode: otpCode,
    );
  }
}
