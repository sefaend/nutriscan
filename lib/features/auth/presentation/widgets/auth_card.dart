import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Giriş/kayıt formunu saran gri-mavi kart ve başlık.
class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}
