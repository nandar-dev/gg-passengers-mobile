import 'package:injectable/injectable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/token_storage.dart';
import '../../../../core/session/app_session_state.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  const AuthRepositoryImpl(this._remoteDataSource, this._tokenStorage);

  @override
  Future<User> registerPassenger({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _remoteDataSource.registerPassenger(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );

    return response.data.passenger.toDomain();
  }

  @override
  Future<AuthSession> loginPassenger({
    required String login,
    required String password,
  }) async {
    final response = await _remoteDataSource.loginPassenger(
      login: login,
      password: password,
    );

    final session = response.data.toDomain();
    await _tokenStorage.saveAccessToken(session.token);
    appSessionState.clearForcedLogout();
    return session;
  }

  @override
  Future<void> verifyPassengerOtp({
    required String otpCode,
  }) async {
    await _remoteDataSource.verifyPassengerOtp(
      otpCode: otpCode,
    );
  }

  @override
  Future<AuthSession> refreshPassengerToken() async {
    final currentToken = await _tokenStorage.readAccessToken();
    if (currentToken == null || currentToken.isEmpty) {
      throw const ApiException(
        message: 'No token available. Please login again.',
      );
    }

    final response = await _remoteDataSource.refreshPassengerToken(
      bearerToken: 'Bearer $currentToken',
    );

    final session = response.data.toDomain();
    await _tokenStorage.saveAccessToken(session.token);
    return session;
  }

  @override
  Future<User?> getCurrentUser() async {
    throw const ApiException(message: 'getCurrentUser is not implemented yet.');
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _tokenStorage.readAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> logout() async {
    final currentToken = await _tokenStorage.readAccessToken();

    try {
      if (currentToken != null && currentToken.isNotEmpty) {
        await _remoteDataSource.logoutPassenger(
          bearerToken: 'Bearer $currentToken',
        );
      }
    } finally {
      await _tokenStorage.clearAccessToken();
    }
  }

  @override
  Future<bool> requestOTP(String phoneNumber) async {
    throw const ApiException(message: 'requestOTP is not implemented yet.');
  }

  @override
  Future<User> updateUserProfile({
    required String firstName,
    required String lastName,
    String? email,
    String? profileImageUrl,
  }) async {
    throw const ApiException(message: 'updateUserProfile is not implemented yet.');
  }

  @override
  Future<String> verifyOTP(String phoneNumber, String otp) async {
    throw const ApiException(message: 'verifyOTP is not implemented yet.');
  }
}
