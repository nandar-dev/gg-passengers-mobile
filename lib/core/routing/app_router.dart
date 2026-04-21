import 'package:go_router/go_router.dart';

import '../session/app_session_state.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/otp_verification_screen.dart';
import '../../screens/auth/reset_password_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/auth/verify_reset_otp_screen.dart';
import '../../screens/booking/ride_category_screen.dart';
import '../../screens/booking/search_location_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/payments/payments_screen.dart';
import '../../screens/profile/about_screen.dart';
import '../../screens/profile/profile_edit_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/profile/promotions_screen.dart';
import '../../screens/profile/settings_screen.dart';
import '../../screens/profile/support_screen.dart';
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
        location == RouteNames.forgotPassword ||
        location == RouteNames.verifyResetOtp ||
        location == RouteNames.resetPassword ||
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
      path: RouteNames.forgotPassword,
      name: 'forgotPassword',
      builder: (context, state) {
        String? login;

        final extra = state.extra;
        if (extra is String && extra.trim().isNotEmpty) {
          login = extra;
        }

        return ForgotPasswordScreen(initialLogin: login);
      },
    ),
    GoRoute(
      path: RouteNames.verifyResetOtp,
      name: 'verifyResetOtp',
      builder: (context, state) {
        String? login;

        final extra = state.extra;
        if (extra is String && extra.trim().isNotEmpty) {
          login = extra;
        }

        return VerifyResetOtpScreen(initialLogin: login);
      },
    ),
    GoRoute(
      path: RouteNames.resetPassword,
      name: 'resetPassword',
      builder: (context, state) {
        String? login;
        String? resetToken;

        final extra = state.extra;
        if (extra is Map<String, dynamic>) {
          final valueLogin = extra['login'];
          final valueResetToken = extra['resetToken'];

          if (valueLogin is String && valueLogin.trim().isNotEmpty) {
            login = valueLogin;
          }

          if (valueResetToken is String && valueResetToken.trim().isNotEmpty) {
            resetToken = valueResetToken;
          }
        }

        return ResetPasswordScreen(
          initialLogin: login,
          resetToken: resetToken,
        );
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
        return const OTPVerificationScreen();
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
      path: RouteNames.profileEdit,
      name: 'profileEdit',
      builder: (context, state) {
        return const ProfileEditScreen();
      },
    ),
    GoRoute(
      path: RouteNames.promotions,
      name: 'promotions',
      builder: (context, state) {
        return const PromotionsScreen();
      },
    ),
    GoRoute(
      path: RouteNames.support,
      name: 'support',
      builder: (context, state) {
        return const SupportScreen();
      },
    ),
    GoRoute(
      path: RouteNames.about,
      name: 'about',
      builder: (context, state) {
        return const AboutScreen();
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
