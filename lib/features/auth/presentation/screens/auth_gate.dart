import 'package:flutter/material.dart';

import '../../../main_shell/presentation/screens/main_shell_screen.dart';
import '../../data/auth_service.dart';
import 'auth_screen.dart';

/// Kapı görevlisi: kullanıcı giriş yapmışsa ana uygulama, yapmamışsa
/// Sign In / Sign Up ekranı gösterilir.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.authService});

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthUser?>(
      stream: authService.authStateChanges,
      initialData: authService.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) return AuthScreen(authService: authService);
        return MainShellScreen(
          key: ValueKey(user.uid),
          authService: authService,
          user: user,
        );
      },
    );
  }
}
