import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';
import 'auth_form_controller.dart';

/// Sign In ekranının tüm mantığı. Ekran sadece buradaki isimleri çağırır.
class SignInController extends AuthFormController {
  SignInController({required super.authService});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? validateEmail(String? value) => Validators.email(value);
  String? validatePassword(String? value) => Validators.password(value);

  Future<void> onSignInPressed() async {
    if (!validateForm()) return;
    await runAuthAction(
      () => authService.signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
