import 'package:flutter/material.dart';

import 'home_style.dart';

/// Bir bölüm yüklenirken gösterilen kutu.
class SectionLoading extends StatelessWidget {
  const SectionLoading({super.key, this.height = 120});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: const Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: HomeColors.primary,
          ),
        ),
      ),
    );
  }
}

/// Bir bölüm yüklenemeyince gösterilen mesaj + "Tekrar dene".
class SectionError extends StatelessWidget {
  const SectionError({super.key, required this.onRetry, this.height = 120});

  final VoidCallback onRetry;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: HomeColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HomeColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Veriler yüklenemedi.',
            style: TextStyle(color: HomeColors.textSecondary),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Tekrar dene',
              style: TextStyle(color: HomeColors.primaryDark),
            ),
          ),
        ],
      ),
    );
  }
}
