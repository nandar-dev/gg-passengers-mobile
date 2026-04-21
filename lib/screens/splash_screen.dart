import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/di/service_locator.dart';
import '../core/network/token_storage.dart';
import '../core/routing/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrapNavigation();
  }

  Future<void> _bootstrapNavigation() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final tokenStorage = getIt<TokenStorage>();
    final token = await tokenStorage.readAccessToken();
    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      context.go(RouteNames.home);
      return;
    }

    context.go(RouteNames.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFE8C00), Color(0xFFE07C00)],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_taxi_rounded, color: Colors.white, size: 64),
              SizedBox(height: 16),
              Text(
                'GG TAXI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
