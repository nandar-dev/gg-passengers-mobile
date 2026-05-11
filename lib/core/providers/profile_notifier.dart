import 'package:flutter/foundation.dart';

/// Shared live state for the current passenger's profile.
/// Populated on load and updated immediately on save so all
/// screens that listen will rebuild without a round-trip.
class ProfileNotifier extends ChangeNotifier {
  String _name = '';
  String _email = '';
  String? _avatarUrl;

  String get name => _name;
  String get email => _email;
  String? get avatarUrl => _avatarUrl;

  void update({
    required String name,
    required String email,
    String? avatarUrl,
  }) {
    _name = name;
    _email = email;
    _avatarUrl = avatarUrl;
    notifyListeners();
  }
}
