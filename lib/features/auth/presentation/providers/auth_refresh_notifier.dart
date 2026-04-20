import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/use_cases/refresh_passenger_token_use_case.dart';

final refreshPassengerTokenNotifierProvider =
    AsyncNotifierProvider<RefreshPassengerTokenNotifier, AuthSession?>(
  RefreshPassengerTokenNotifier.new,
);

class RefreshPassengerTokenNotifier extends AsyncNotifier<AuthSession?> {
  late final RefreshPassengerTokenUseCase _refreshPassengerTokenUseCase;

  @override
  Future<AuthSession?> build() async {
    _refreshPassengerTokenUseCase = getIt<RefreshPassengerTokenUseCase>();
    return null;
  }

  Future<AuthSession?> refresh() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
      _refreshPassengerTokenUseCase.call,
    );

    return state.value;
  }

  String? toReadableError() {
    final currentError = state.asError?.error;
    if (currentError == null) return null;

    if (currentError is ApiException) {
      return currentError.message;
    }

    return 'Unable to refresh session. Please login again.';
  }
}
