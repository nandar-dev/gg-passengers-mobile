import 'package:flutter/foundation.dart';

class AppSessionState extends ChangeNotifier {
  bool _forceLogout = false;

  bool get forceLogout => _forceLogout;

  void markForcedLogout() {
    if (_forceLogout) return;
    _forceLogout = true;
    notifyListeners();
  }

  void clearForcedLogout() {
    if (!_forceLogout) return;
    _forceLogout = false;
    notifyListeners();
  }
}

final appSessionState = AppSessionState();
