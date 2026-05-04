import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/network/api_exception.dart';
import 'features/auth/domain/use_cases/refresh_passenger_token_use_case.dart';
import 'features/payments/domain/use_cases/get_payment_methods_use_case.dart';
import 'features/services/domain/use_cases/get_services_use_case.dart';
import 'config/app_config.dart';
import 'core/di/service_locator.dart';
import 'core/network/token_storage.dart';
import 'core/routing/app_router.dart';
import 'core/session/app_session_state.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppConfig.initialize();

  // Initialize DI container
  await configureDependencies();

  await _bootstrapSession();

  _prefetchData();

  runApp(const ProviderScope(child: GGTaxiApp()));
}

void _prefetchData() {
  unawaited(_prefetchPaymentMethods());
  unawaited(_prefetchServices());
}

Future<void> _prefetchPaymentMethods() async {
  try {
    await getIt<GetPaymentMethodsUseCase>().call();
  } catch (_) {
    // Ignore startup prefetch errors. Screens will retry when opened.
  }
}

Future<void> _prefetchServices() async {
  try {
    await getIt<GetServicesUseCase>().call();
  } catch (_) {
    // Ignore startup prefetch errors.
  }
}

Future<void> _bootstrapSession() async {
  final tokenStorage = getIt<TokenStorage>();
  final currentToken = await tokenStorage.readAccessToken();

  if (currentToken == null || currentToken.isEmpty) {
    return;
  }

  try {
    // Attempt to refresh the token to validate it's still valid
    await getIt<RefreshPassengerTokenUseCase>().call();
    appSessionState.clearForcedLogout();
  } catch (error) {
    // Only clear token if it's explicitly unauthorized (401/403)
    if (error is ApiException &&
        (error.statusCode == 401 || error.statusCode == 403)) {
      await tokenStorage.clearAccessToken();
      return;
    }
    // For other errors (network, etc.), keep the token and let the user try again
    // This prevents unnecessary logouts due to temporary network issues
  }
}

class GGTaxiApp extends StatelessWidget {
  const GGTaxiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.current.appName,
      theme: AppTheme.lightTheme(),
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
    // return MaterialApp(
    //   title: AppConfig.current.appName,
    //   theme: AppTheme.lightTheme(),
    //   home: HomeScreen(),
    //   debugShowCheckedModeBanner: false,
    // );
  }
}
