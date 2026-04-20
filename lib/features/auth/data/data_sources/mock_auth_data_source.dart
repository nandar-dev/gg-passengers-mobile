import 'package:uuid/uuid.dart';
import 'package:gg/features/auth/data/models/user_model.dart';

/// Mock implementation of auth data source
/// Simulates API calls with delayed futures
class MockAuthDataSource {
  static const Duration _networkDelay = Duration(milliseconds: 800);

  Future<void> requestOTP(String phoneNumber) async {
    await Future.delayed(_networkDelay);
    // Simulates API call to request OTP
  }

  Future<String> verifyOTP(String phoneNumber, String otp) async {
    await Future.delayed(_networkDelay);
    // Any OTP is valid in mock mode
    return 'mock_token_${DateTime.now().millisecond}';
  }

  Future<UserModel> createUser(String phoneNumber) async {
    await Future.delayed(_networkDelay);
    return UserModel(
      id: const Uuid().v4(),
      phoneNumber: phoneNumber,
      isPhoneVerified: true,
      isProfileSetup: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<UserModel> updateUserProfile({
    required String userId,
    required String firstName,
    required String lastName,
    String? email,
    String? profileImageUrl,
  }) async {
    await Future.delayed(_networkDelay);
    return UserModel(
      id: userId,
      phoneNumber: 'mock_phone',
      firstName: firstName,
      lastName: lastName,
      email: email,
      profileImageUrl: profileImageUrl,
      isPhoneVerified: true,
      isProfileSetup: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(_networkDelay);
    // Return null if not authenticated
    return null;
  }

  Future<void> logout() async {
    await Future.delayed(_networkDelay);
  }
}
