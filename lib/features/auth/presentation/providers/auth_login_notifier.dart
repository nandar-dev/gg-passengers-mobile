import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/use_cases/login_passenger_use_case.dart';

final loginPassengerNotifierProvider =
    AsyncNotifierProvider<LoginPassengerNotifier, AuthSession?>(
  LoginPassengerNotifier.new,
);

class LoginPassengerNotifier extends AsyncNotifier<AuthSession?> {
  late final LoginPassengerUseCase _loginPassengerUseCase;

  @override
  Future<AuthSession?> build() async {
    _loginPassengerUseCase = getIt<LoginPassengerUseCase>();
    return null;
  }

  Future<AuthSession?> loginPassenger({
    required String login,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
      () => _loginPassengerUseCase(
        login: login,
        password: password,
      ),
    );

    return state.value;
  }

  String? toReadableError() {
    final currentError = state.asError?.error;
    if (currentError == null) return null;

    if (currentError is ApiException) {
      return currentError.message;
    }

    return 'Unable to login. Please try again.';
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
