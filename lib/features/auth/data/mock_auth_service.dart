import 'dart:async';

import 'auth_service.dart';

/// Firebase olmadan arayüzü denemek için sahte servis.
/// Her e-posta/şifre ile giriş yapılır; veri hiçbir yere kaydedilmez.
class MockAuthService implements AuthService {
  final StreamController<AuthUser?> _controller =
      StreamController<AuthUser?>.broadcast();
  AuthUser? _user;

  @override
  AuthUser? get currentUser => _user;

  @override
  Stream<AuthUser?> get authStateChanges => _controller.stream;

  void _set(AuthUser? user) {
    _user = user;
    _controller.add(user);
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _set(AuthUser(uid: 'mock', username: email.split('@').first, email: email));
  }

  @override
  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _set(AuthUser(uid: 'mock', username: username, email: email));
  }

  @override
  Future<void> signOut() async => _set(null);
}
