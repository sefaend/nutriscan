/// Giriş yapmış kullanıcının arayüzün ihtiyacı olan kısa hali.
class AuthUser {
  const AuthUser({
    required this.uid,
    required this.username,
    required this.email,
  });

  final String uid;
  final String username;
  final String email;
}

/// Arayüzde gösterilecek hazır hata mesajı taşır.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Arayüzün konuştuğu giriş/kayıt sözleşmesi.
/// Gerçek (Firebase) ve sahte (mock) uygulama aynı sözleşmeyi kullanır.
abstract class AuthService {
  AuthUser? get currentUser;
  Stream<AuthUser?> get authStateChanges;

  Future<void> signIn({required String email, required String password});

  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  });

  Future<void> signOut();
}
