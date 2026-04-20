import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/use_cases/verify_passenger_otp_use_case.dart';

final verifyPassengerOtpNotifierProvider =
    AsyncNotifierProvider<VerifyPassengerOtpNotifier, bool>(
  VerifyPassengerOtpNotifier.new,
);

class VerifyPassengerOtpNotifier extends AsyncNotifier<bool> {
  late final VerifyPassengerOtpUseCase _verifyPassengerOtpUseCase;

  @override
  Future<bool> build() async {
    _verifyPassengerOtpUseCase = getIt<VerifyPassengerOtpUseCase>();
    return false;
  }

  Future<bool> verifyPassengerOtp({
    required String otpCode,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
      () async {
        await _verifyPassengerOtpUseCase(
          otpCode: otpCode,
        );
        return true;
      },
    );

    return state.value ?? false;
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
