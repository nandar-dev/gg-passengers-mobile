import 'package:go_router/go_router.dart';

import '../session/app_session_state.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/otp_verification_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/booking/ride_category_screen.dart';
import '../../screens/booking/search_location_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/payments/payments_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/profile/settings_screen.dart';
import '../../screens/ride/ride_history_screen.dart';
import '../../screens/ride/ride_review_screen.dart';
import '../../screens/ride/ride_tracking_screen.dart';
import '../../screens/splash_screen.dart';
import 'route_names.dart';

/// Global GoRouter instance
final goRouter = GoRouter(
  initialLocation: RouteNames.splash,
  refreshListenable: appSessionState,
  redirect: (context, state) {
    if (!appSessionState.forceLogout) {
      return null;
    }

    final location = state.matchedLocation;
    final isAuthRoute =
        location == RouteNames.login ||
        location == RouteNames.signup ||
        location == RouteNames.otpVerification;

    if (!isAuthRoute) {
      return RouteNames.login;
    }

    appSessionState.clearForcedLogout();

    return null;
  },
  routes: [
    GoRoute(
      path: RouteNames.splash,
      name: 'splash',
      builder: (context, state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: RouteNames.onboarding,
      name: 'onboarding',
      builder: (context, state) {
        return const OnboardingScreen();
      },
    ),
    GoRoute(
      path: RouteNames.login,
      name: 'login',
      builder: (context, state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: RouteNames.signup,
      name: 'signup',
      builder: (context, state) {
        return const SignUpScreen();
      },
    ),
    GoRoute(
      path: RouteNames.otpVerification,
      name: 'otpVerification',
      builder: (context, state) {
        String phone = '';

        final extra = state.extra;
        if (extra is String) {
          phone = extra;
        } else if (extra is Map<String, dynamic>) {
          phone = (extra['phone'] as String?) ?? '';
        }

        return OTPVerificationScreen(
          phone: phone,
        );
      },
    ),
    GoRoute(
      path: RouteNames.home,
      name: 'home',
      builder: (context, state) {
        return const HomeScreen();
      },
      routes: [
        GoRoute(
          path: 'search-location',
          name: 'searchLocation',
          builder: (context, state) {
            return const SearchLocationScreen();
          },
        ),
        GoRoute(
          path: 'ride-category',
          name: 'rideCategory',
          builder: (context, state) {
            return const RideCategoryScreen();
          },
        ),
        GoRoute(
          path: 'ride-tracking',
          name: 'rideTracking',
          builder: (context, state) {
            return const RideTrackingScreen();
          },
        ),
        GoRoute(
          path: 'ride-review',
          name: 'rideReview',
          builder: (context, state) {
            return const RideReviewScreen();
          },
        ),
      ],
    ),
    GoRoute(
      path: RouteNames.payments,
      name: 'payments',
      builder: (context, state) {
        return const PaymentsScreen();
      },
    ),
    GoRoute(
      path: RouteNames.rideHistory,
      name: 'rideHistory',
      builder: (context, state) {
        return const RideHistoryScreen();
      },
    ),
    GoRoute(
      path: RouteNames.profile,
      name: 'profile',
      builder: (context, state) {
        return const ProfileScreen();
      },
    ),
    GoRoute(
      path: RouteNames.settings,
      name: 'settings',
      builder: (context, state) {
        return const SettingsScreen();
      },
    ),
  ],
);
