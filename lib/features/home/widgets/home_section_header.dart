import 'package:flutter/material.dart';

import 'home_style.dart';

/// Bölüm başlığı: [ikon] Başlık ............ Sağdaki bağlantı.
class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.leading,
  });

  final String title;

  /// Sağdaki bağlantı (ör. "Tümünü Gör"). İkisi de verilmezse gösterilmez.
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Başlığın solundaki ikon/emoji (isteğe bağlı).
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 8)],
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: HomeColors.textPrimary,
            ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: HomeColors.primaryDark,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
