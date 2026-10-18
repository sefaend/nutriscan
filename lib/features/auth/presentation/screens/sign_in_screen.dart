import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/auth_service.dart';
import '../controllers/sign_in_controller.dart';
import '../widgets/auth_card.dart';
import '../widgets/auth_error_text.dart';
import '../widgets/auth_switch_link.dart';
import '../widgets/social_login_row.dart';

/// Sadece yerleşim (layout). Tüm işler SignInController'da.
class SignInScreen extends StatefulWidget {
  const SignInScreen({
    super.key,
    required this.authService,
    required this.onGoToSignUp,
  });

  final AuthService authService;
  final VoidCallback onGoToSignUp;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late final SignInController _controller =
      SignInController(authService: widget.authService);

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
          title: AppStrings.signIn,
          child: Form(
            key: _controller.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: _controller.emailController,
                  hint: AppStrings.emailHint,
                  keyboardType: TextInputType.emailAddress,
                  validator: _controller.validateEmail,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _controller.passwordController,
                  hint: AppStrings.passwordHint,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: _controller.validatePassword,
                  onSubmitted: (_) => _controller.onSignInPressed(),
                ),
                AuthErrorText(message: _controller.errorMessage),
                PrimaryButton(
                  label: AppStrings.signIn,
                  isLoading: _controller.isLoading,
                  onPressed: _controller.onSignInPressed,
                ),
                const SizedBox(height: 8),
                const Text(AppStrings.or),
                const SizedBox(height: 8),
                SocialLoginRow(onPressed: _controller.onSocialPressed),
                const SizedBox(height: 4),
                AuthSwitchLink(
                  label: AppStrings.noAccount,
                  onTap: widget.onGoToSignUp,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
