import 'package:flutter/material.dart';

import 'home_style.dart';

/// Avatar + "Hoş geldin, Buse 👋" + bildirim zili.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.name,
    required this.onNotificationsPressed,
  });

  /// Giriş yapılmamışsa null.
  final String? name;
  final VoidCallback onNotificationsPressed;

  @override
  Widget build(BuildContext context) {
    final shown = _capitalize(name ?? '');
    return Row(
      children: [
        _Avatar(initial: shown.isEmpty ? null : shown.substring(0, 1)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            shown.isEmpty ? 'Hoş geldin 👋' : 'Hoş geldin, $shown 👋',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: HomeColors.textPrimary,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Bildirimler',
          onPressed: onNotificationsPressed,
          icon: const Icon(
            Icons.notifications_none_rounded,
            size: 28,
            color: HomeColors.primaryDark,
          ),
        ),
      ],
    );
  }

  /// Türkçe'de "i" → "İ" olmalı (Dart varsayılanı "I" yapar).
  static String _capitalize(String s) {
    final text = s.trim();
    if (text.isEmpty) return text;
    final first = text.substring(0, 1);
    final upper = first == 'i' ? 'İ' : first.toUpperCase();
    return upper + text.substring(1);
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial});

  final String? initial;

  @override
  Widget build(BuildContext context) {
    // TODO(profile): Kullanıcının profil fotoğrafı gelince burada gösterilecek.
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: HomeColors.primaryLight,
        shape: BoxShape.circle,
        border: Border.all(color: HomeColors.mint, width: 2),
      ),
      child: initial == null
          ? const Icon(Icons.person_rounded, color: HomeColors.primaryDark)
          : Text(
              initial!,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: HomeColors.primaryDark,
              ),
            ),
    );
  }
}
