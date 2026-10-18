import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// "or" yazısının altındaki A / f / G sosyal giriş butonları.
class SocialLoginRow extends StatelessWidget {
  const SocialLoginRow({super.key, required this.onPressed});

  /// 'Apple', 'Facebook' veya 'Google' ile çağrılır.
  final ValueChanged<String> onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialButton(
          provider: 'Apple',
          child: const Icon(Icons.apple, size: 30, color: AppColors.textPrimary),
          onPressed: onPressed,
        ),
        const SizedBox(width: 24),
        _SocialButton(
          provider: 'Facebook',
          child: const _Letter('f'),
          onPressed: onPressed,
        ),
        const SizedBox(width: 24),
        _SocialButton(
          provider: 'Google',
          child: const _Letter('G'),
          onPressed: onPressed,
        ),
      ],
    );
  }
}

class _Letter extends StatelessWidget {
  const _Letter(this.letter);
  final String letter;

  @override
  Widget build(BuildContext context) {
    return Text(
      letter,
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.provider,
    required this.child,
    required this.onPressed,
  });

  final String provider;
  final Widget child;
  final ValueChanged<String> onPressed;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: () => onPressed(provider),
      radius: 26,
      child: SizedBox(width: 36, height: 36, child: Center(child: child)),
    );
  }
}
