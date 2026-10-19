import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/auth_service.dart';
import '../controllers/sign_up_controller.dart';
import '../widgets/auth_card.dart';
import '../widgets/auth_error_text.dart';
import '../widgets/auth_switch_link.dart';
import '../widgets/social_login_row.dart';

/// Sadece yerleşim (layout). Tüm işler SignUpController'da.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    super.key,
    required this.authService,
    required this.onGoToSignIn,
  });

  final AuthService authService;
  final VoidCallback onGoToSignIn;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final SignUpController _controller =
      SignUpController(authService: widget.authService);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return AuthCard(
          title: AppStrings.signUp,
          child: Form(
            key: _controller.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: _controller.usernameController,
                  hint: AppStrings.usernameHint,
                  validator: _controller.validateUsername,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _controller.emailController,
                  hint: AppStrings.signUpEmailHint,
                  keyboardType: TextInputType.emailAddress,
                  validator: _controller.validateEmail,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _controller.passwordController,
                  hint: AppStrings.signUpPasswordHint,
                  isPassword: true,
                  validator: _controller.validatePassword,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _controller.passwordAgainController,
                  hint: AppStrings.passwordAgainHint,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: _controller.validatePasswordAgain,
                  onSubmitted: (_) => _controller.onSignUpPressed(),
                ),
                AuthErrorText(message: _controller.errorMessage),
                PrimaryButton(
                  label: AppStrings.signUp,
                  isLoading: _controller.isLoading,
                  onPressed: _controller.onSignUpPressed,
                ),
                const SizedBox(height: 8),
                const Text(AppStrings.or),
                const SizedBox(height: 8),
                SocialLoginRow(onPressed: _controller.onSocialPressed),
                const SizedBox(height: 4),
                AuthSwitchLink(
                  label: AppStrings.haveAccount,
                  onTap: widget.onGoToSignIn,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
