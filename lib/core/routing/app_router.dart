import 'package:go_router/go_router.dart';

import '../session/app_session_state.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/verify_reset_otp_screen.dart';
import '../../features/booking/presentation/screens/ride_category_screen.dart';
import '../../features/booking/presentation/screens/search_location_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/payments/presentation/screens/payments_screen.dart';
import '../../features/profile/presentation/screens/about_screen.dart';
import '../../features/profile/presentation/screens/profile_edit_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/promotions_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/support_screen.dart';
import '../../features/ride/presentation/screens/ride_history_screen.dart';
import '../../features/ride/presentation/screens/ride_review_screen.dart';
import '../../features/ride/presentation/screens/ride_tracking_screen.dart';
import '../../features/ride/presentation/models/ride_tracking_args.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/saved_places/presentation/screens/saved_places_screen.dart';
import '../../features/booking/presentation/models/booking_args.dart';
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
            String? serviceId;

            final extra = state.extra;
            if (extra is SearchLocationArgs) {
              serviceId = extra.serviceId;
            }

            return SearchLocationScreen(serviceId: serviceId);
          },
        ),
        GoRoute(
          path: 'ride-category',
          name: 'rideCategory',
          builder: (context, state) {
            RideCategoryArgs? args;

            final extra = state.extra;
            if (extra is RideCategoryArgs) {
              args = extra;
            }

            return RideCategoryScreen(args: args);
          },
        ),
        GoRoute(
          path: 'ride-tracking',
          name: 'rideTracking',
          builder: (context, state) {
            RideTrackingArgs? args;

            final extra = state.extra;
            if (extra is RideTrackingArgs) {
              args = extra;
            }

            return RideTrackingScreen(args: args);
          },
        ),
        GoRoute(
          path: 'ride-review',
          name: 'rideReview',
          builder: (context, state) {
            String? bookingId;

            final extra = state.extra;
            if (extra is String && extra.trim().isNotEmpty) {
              bookingId = extra;
            }

            return RideReviewScreen(bookingId: bookingId);
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
    GoRoute(
      path: RouteNames.savedPlaces,
      name: 'savedPlaces',
      builder: (context, state) {
        return const SavedPlacesScreen();
      },
    ),
  ],
);
