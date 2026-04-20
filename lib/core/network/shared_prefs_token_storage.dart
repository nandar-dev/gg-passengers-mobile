import 'package:shared_preferences/shared_preferences.dart';

import 'token_storage.dart';

class SharedPrefsTokenStorage implements TokenStorage {
  static const String _tokenKey = 'auth_access_token';

  final SharedPreferences _prefs;

  SharedPrefsTokenStorage(this._prefs);

  @override
  Future<String?> readAccessToken() async {
    return _prefs.getString(_tokenKey);
  }

  @override
  Future<void> saveAccessToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  @override
  Future<void> clearAccessToken() async {
    await _prefs.remove(_tokenKey);
  }
}
