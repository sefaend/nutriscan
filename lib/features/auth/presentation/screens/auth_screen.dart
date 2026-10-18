import 'package:flutter/material.dart';

import '../../data/auth_service.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

/// Giriş yapılmamışken görünen sayfa: Sign In <-> Sign Up arasında geçiş yapar.
/// (Navigator.push yerine kendi içinde değiştirir; böylece giriş yapılınca
/// AuthGate ana ekrana sorunsuzca geçer.)
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _showSignUp = false;

  void _toggle() => setState(() => _showSignUp = !_showSignUp);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _showSignUp
                  ? SignUpScreen(
                      key: const ValueKey('sign-up'),
                      authService: widget.authService,
                      onGoToSignIn: _toggle,
                    )
                  : SignInScreen(
                      key: const ValueKey('sign-in'),
                      authService: widget.authService,
                      onGoToSignUp: _toggle,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
