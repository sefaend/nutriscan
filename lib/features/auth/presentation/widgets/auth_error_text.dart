import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Formun altında çıkan hata/bilgi yazısı. Mesaj yoksa yer kaplamaz.
class AuthErrorText extends StatelessWidget {
  const AuthErrorText({super.key, required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox(height: 12);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        message!,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.danger, fontSize: 12),
      ),
    );
  }
}
