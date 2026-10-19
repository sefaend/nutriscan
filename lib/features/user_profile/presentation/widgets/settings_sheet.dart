import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

/// Sağ üstteki dişli ikonuna basınca açılan alt panel.
Future<void> showSettingsSheet(
  BuildContext context, {
  required VoidCallback onSignOut,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.danger),
              title: const Text(
                AppStrings.signOut,
                style: TextStyle(color: AppColors.danger),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                onSignOut();
              },
            ),
          ],
        ),
      );
    },
  );
}
