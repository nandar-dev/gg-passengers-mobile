import '../entities/user.dart';
import '../entities/auth_session.dart';

/// Handle phone-based authentication flow
/// Features: Request OTP, Verify OTP, Get current user
abstract class AuthRepository {
  Future<User> registerPassenger({
    required String name,
    required String email,
    required String phone,
    required String password,
  });

  Future<AuthSession> loginPassenger({
    required String login,
    required String password,
  });

  Future<void> verifyPassengerOtp({
    required String otpCode,
  });

  Future<void> resendPassengerOtp();

  Future<void> forgotPassengerPassword({
    required String login,
  });

  Future<String> verifyPassengerResetOtp({
    required String login,
    required String otp,
  });

  Future<void> resetPassengerPassword({
    required String login,
    required String resetToken,
    required String newPassword,
    required String newPasswordConfirmation,
  });

  Future<AuthSession> refreshPassengerToken();

  /// Request OTP for phone number
  Future<bool> requestOTP(String phoneNumber);

  /// Verify OTP and authenticate
  Future<String> verifyOTP(String phoneNumber, String otp);

  /// Get current authenticated user
  Future<User?> getCurrentUser();

  /// Update user profile
  Future<User> updateUserProfile({
    required String firstName,
    required String lastName,
    String? email,
    String? profileImageUrl,
  });

  /// Logout current user
  Future<void> logout();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();
}
