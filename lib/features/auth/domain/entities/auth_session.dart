import 'package:equatable/equatable.dart';

import 'user.dart';

class AuthSession extends Equatable {
  final User passenger;
  final String token;
  final String tokenType;

  const AuthSession({
    required this.passenger,
    required this.token,
    required this.tokenType,
  });

  @override
  List<Object?> get props => [passenger, token, tokenType];
}
