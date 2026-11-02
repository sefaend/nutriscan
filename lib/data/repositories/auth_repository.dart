import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';

/// Giriş durumu. Ekranlar FirebaseAuth'a değil buraya sorar.
///
/// TODO(auth): giriş / çıkış / kayıt fonksiyonları buraya taşınınca
/// (şu an login/signup ekranları kendi içinde yapıyor) eklenecek.
class AuthRepository {
  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  /// Giriş/çıkışta ve kullanıcı adı güncellenince yeni değer yayınlar.
  Stream<AppUser?> authStateChanges() => _auth.userChanges().map(_toAppUser);

  AppUser? _toAppUser(User? user) {
    if (user == null) return null;
    final email = user.email ?? '';
    final displayName = user.displayName?.trim() ?? '';
    return AppUser(
      uid: user.uid,
      name: displayName.isNotEmpty ? displayName : email.split('@').first,
      email: email,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

/// Giriş yapmış kullanıcı (yoksa null).
final authStateProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);
