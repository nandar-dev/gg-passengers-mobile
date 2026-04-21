import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/use_cases/reset_passenger_password_use_case.dart';

final resetPassengerPasswordNotifierProvider =
    AsyncNotifierProvider<ResetPassengerPasswordNotifier, bool>(
  ResetPassengerPasswordNotifier.new,
);

class ResetPassengerPasswordNotifier extends AsyncNotifier<bool> {
  late final ResetPassengerPasswordUseCase _resetPassengerPasswordUseCase;

  @override
  Future<bool> build() async {
    final authRepository = getIt<AuthRepository>();
    _resetPassengerPasswordUseCase = ResetPassengerPasswordUseCase(authRepository);
    return false;
  }

  Future<bool> resetPassword({
    required String login,
    required String resetToken,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await _resetPassengerPasswordUseCase(
        login: login,
        resetToken: resetToken,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );

      return true;
    });

    return state.value ?? false;
  }

  String? toReadableError() {
    final currentError = state.asError?.error;
    if (currentError == null) return null;

    if (currentError is ApiException) {
      return currentError.message;
    }

    return 'Unable to reset password. Please try again.';
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
