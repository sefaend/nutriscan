import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';
import 'auth_form_controller.dart';

/// Sign Up ekranının tüm mantığı. Ekran sadece buradaki isimleri çağırır.
class SignUpController extends AuthFormController {
  SignUpController({required super.authService});

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordAgainController = TextEditingController();

  String? validateUsername(String? value) => Validators.username(value);
  String? validateEmail(String? value) => Validators.email(value);
  String? validatePassword(String? value) => Validators.password(value);
  String? validatePasswordAgain(String? value) =>
      Validators.passwordAgain(value, passwordController.text);

  Future<void> onSignUpPressed() async {
    if (!validateForm()) return;
    await runAuthAction(
      () => authService.signUp(
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordAgainController.dispose();
    super.dispose();
  }
}
