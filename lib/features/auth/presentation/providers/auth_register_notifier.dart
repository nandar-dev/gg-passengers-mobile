import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/user.dart';
import '../../domain/use_cases/register_passenger_use_case.dart';

final registerPassengerNotifierProvider =
    AsyncNotifierProvider<RegisterPassengerNotifier, User?>(
  RegisterPassengerNotifier.new,
);

class RegisterPassengerNotifier extends AsyncNotifier<User?> {
  late final RegisterPassengerUseCase _registerPassengerUseCase;

  @override
  Future<User?> build() async {
    _registerPassengerUseCase = getIt<RegisterPassengerUseCase>();
    return null;
  }

  Future<User?> registerPassenger({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => _registerPassengerUseCase(
        name: name,
        email: email,
        phone: phone,
        password: password,
      ));

    return state.value;
  }

  String? toReadableError() {
    final currentError = state.asError?.error;
    if (currentError == null) return null;

    if (currentError is ApiException) {
      return currentError.message;
    }

    return 'Unable to create account. Please try again.';
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

  void reset() {
    state = const AsyncValue.data(null);
  }
}
