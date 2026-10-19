import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_strings.dart';
import 'auth_service.dart';

/// Firebase Auth ile gerçek giriş/kayıt.
/// AppConfig.useMockAuth = false olduğunda kullanılır.
class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  AuthUser? _toAuthUser(User? user) {
    if (user == null) return null;
    final email = user.email ?? '';
    final name = (user.displayName?.trim().isNotEmpty ?? false)
        ? user.displayName!.trim()
        : email.split('@').first;
    return AuthUser(uid: user.uid, username: name, email: email);
  }

  @override
  AuthUser? get currentUser => _toAuthUser(_auth.currentUser);

  // userChanges: kayıttan sonra kullanıcı adı güncellenince de tetiklenir.
  @override
  Stream<AuthUser?> get authStateChanges =>
      _auth.userChanges().map(_toAuthUser);

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e.code));
    }
  }

  @override
  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.updateDisplayName(username);
      await cred.user?.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e.code));
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  String _messageFor(String code) {
    switch (code) {
      case 'invalid-email':
        return AppStrings.invalidEmail;
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return AppStrings.shortPassword;
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return AppStrings.genericError;
    }
  }
}
