import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/use_cases/forgot_passenger_password_use_case.dart';
import '../../domain/use_cases/verify_passenger_reset_otp_use_case.dart';

final verifyPassengerResetOtpNotifierProvider =
    AsyncNotifierProvider<VerifyPassengerResetOtpNotifier, String?>(
  VerifyPassengerResetOtpNotifier.new,
);

class VerifyPassengerResetOtpNotifier extends AsyncNotifier<String?> {
  late final VerifyPassengerResetOtpUseCase _verifyPassengerResetOtpUseCase;
  late final ForgotPassengerPasswordUseCase _forgotPassengerPasswordUseCase;

  @override
  Future<String?> build() async {
    final authRepository = getIt<AuthRepository>();
    _verifyPassengerResetOtpUseCase = VerifyPassengerResetOtpUseCase(authRepository);
    _forgotPassengerPasswordUseCase = ForgotPassengerPasswordUseCase(authRepository);
    return null;
  }

  Future<String?> verifyResetOtp({
    required String login,
    required String otp,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
      () => _verifyPassengerResetOtpUseCase(
        login: login,
        otp: otp,
      ),
    );

    return state.value;
  }

  Future<bool> resendResetOtp({
    required String login,
  }) async {
    final currentToken = state.value;
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await _forgotPassengerPasswordUseCase(login: login);
      return currentToken;
    });

    return !state.hasError;
  }

  String? toReadableError() {
    final currentError = state.asError?.error;
    if (currentError == null) return null;

    if (currentError is ApiException) {
      return currentError.message;
    }

    return 'Unable to verify OTP. Please try again.';
  }

  Map<String, String> validationErrors() {
    final currentError = state.asError?.error;
    if (currentError is! ApiException || currentError.statusCode != 422) {
      return const <String, String>{};
    }

    final details = currentError.details;
    if (details == null) return const <String, String>{};

    final rawErrors = details['errors'];
    if (rawErrors is! Map<String, dynamic>) {
      return const <String, String>{};
    }

    final extracted = <String, String>{};

    rawErrors.forEach((key, value) {
      if (value is List && value.isNotEmpty && value.first is String) {
        final message = (value.first as String).trim();
        if (message.isNotEmpty) {
          extracted[key] = message;
        }
      } else if (value is String && value.trim().isNotEmpty) {
        extracted[key] = value.trim();
      }
    });

    return extracted;
  }
}
