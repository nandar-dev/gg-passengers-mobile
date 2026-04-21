import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/domain/use_cases/refresh_passenger_token_use_case.dart';
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
  
  runApp(
    const ProviderScope(
      child: GGTaxiApp(),
    ),
  );
}

Future<void> _bootstrapSession() async {
  final tokenStorage = getIt<TokenStorage>();
  final currentToken = await tokenStorage.readAccessToken();

  if (currentToken == null || currentToken.isEmpty) {
    return;
  }

  try {
    await getIt<RefreshPassengerTokenUseCase>().call();
    appSessionState.clearForcedLogout();
  } catch (_) {
    await tokenStorage.clearAccessToken();
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
