import '../entities/passenger_profile.dart';

abstract class PassengerProfileRepository {
  Future<PassengerProfile> getProfile({bool forceRefresh = false});

  Future<PassengerProfile> updateProfile({
    required String fullName,
    required String email,
    required String phone,
    String? avatarFilePath,
  });
}
