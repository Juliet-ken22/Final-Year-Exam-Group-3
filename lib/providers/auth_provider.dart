import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _userEmail;

  String? get token => _token;
  String? get userEmail => _userEmail;

  bool get isLoggedIn => _token != null;

  // ─── LOGIN ─────────────────────────────
  void login({required String token, String? email}) {
    _token = token;
    _userEmail = email;
    notifyListeners();
  }

  // ─── LOGOUT ────────────────────────────
  void logout() {
    _token = null;
    _userEmail = null;
    notifyListeners();
  }
}