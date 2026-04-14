import 'package:flutter/material.dart';

import 'authservice.dart';

/// Bridges AuthService with GoRouter's refreshListenable.
/// GoRouter re-runs its redirect whenever this notifies.
class AuthNotifier extends ChangeNotifier {
  static final AuthNotifier _instance = AuthNotifier._internal();
  factory AuthNotifier() => _instance;
  AuthNotifier._internal();

  bool _isLoggedIn = false;
  bool _isInitialized = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get isInitialized => _isInitialized;

  /// Called once in main() — loads tokens, then tells GoRouter to re-check.
  Future<void> init() async {
    await AuthService().init();
    _isLoggedIn = AuthService().isLoggedIn;
    _isInitialized = true;
    notifyListeners(); // 🔔 GoRouter re-runs redirect after tokens load
  }

  /// Call this right after a successful login + saveTokens().
  void onLogin() {
    _isLoggedIn = true;
    notifyListeners();
  }

  /// Call this on logout.
  void onLogout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}
