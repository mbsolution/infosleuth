import 'package:flutter/material.dart';

/// Stubbed Auth service – no external dependencies.
class AuthService with ChangeNotifier {
  bool get isLoggedIn => false;

  /// No-op sign in
  Future<void> signInWithGoogle() async {}

  /// No-op sign in
  Future<void> signInWithApple() async {}

  /// No-op sign out
  Future<void> signOut() async {}
}
