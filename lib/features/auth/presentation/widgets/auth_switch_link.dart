import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Kartın en altındaki "I don't have an account!" / "Do you have an account?"
class AuthSwitchLink extends StatelessWidget {
  const AuthSwitchLink({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
