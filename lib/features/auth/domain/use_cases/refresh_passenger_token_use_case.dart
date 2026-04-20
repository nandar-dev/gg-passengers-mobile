import 'package:injectable/injectable.dart';

import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class RefreshPassengerTokenUseCase {
  final AuthRepository _authRepository;

  const RefreshPassengerTokenUseCase(this._authRepository);

  Future<AuthSession> call() {
    return _authRepository.refreshPassengerToken();
  }
}
