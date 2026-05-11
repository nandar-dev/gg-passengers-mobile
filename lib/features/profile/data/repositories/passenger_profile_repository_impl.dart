import 'package:injectable/injectable.dart';

import '../../domain/entities/passenger_profile.dart';
import '../../domain/repositories/passenger_profile_repository.dart';
import '../data_sources/passenger_profile_remote_data_source.dart';

@LazySingleton(as: PassengerProfileRepository)
class PassengerProfileRepositoryImpl implements PassengerProfileRepository {
  final PassengerProfileRemoteDataSource _remoteDataSource;

  PassengerProfileRepositoryImpl(this._remoteDataSource);

  PassengerProfile? _cachedProfile;

  @override
  Future<PassengerProfile> getProfile({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedProfile != null) {
      return _cachedProfile!;
    }

    final model = await _remoteDataSource.fetchProfile();
    final profile = model.toDomain();
    _cachedProfile = profile;
    return profile;
  }

  @override
  Future<PassengerProfile> updateProfile({
    required String fullName,
    required String email,
    required String phone,
    String? avatarFilePath,
  }) async {
    final model = await _remoteDataSource.updateProfile(
      fullName: fullName,
      email: email,
      phone: phone,
      avatarFilePath: avatarFilePath,
    );
    final profile = model.toDomain();
    _cachedProfile = profile;
    return profile;
  }
}
