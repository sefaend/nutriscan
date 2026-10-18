import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Dişli ikonu + yuvarlak avatar + kullanıcı adı.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.username,
    required this.onSettingsPressed,
  });

  final String username;
  final VoidCallback onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            tooltip: 'Settings',
            onPressed: onSettingsPressed,
            icon: const Icon(Icons.settings_outlined, size: 24),
          ),
        ),
        Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            color: AppColors.border,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_outline_rounded, size: 44),
        ),
        const SizedBox(height: 12),
        Text(
          username,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 26),
        ),
      ],
    );
  }
}
