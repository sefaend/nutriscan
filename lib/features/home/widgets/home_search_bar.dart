import 'package:flutter/material.dart';

import 'home_style.dart';

/// "Ürün veya barkod ara..." kutusu; sağdaki ikon kamerayı açar.
/// Yazılan metni (ve temizlemeyi) ekran yönetsin diye controller dışarıdan gelir.
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.onChanged,
    required this.onScanPressed,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String> onChanged;
  final VoidCallback onScanPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 17, color: HomeColors.textPrimary),
      cursorColor: HomeColors.primary,
      decoration: InputDecoration(
        hintText: 'Ürün veya barkod ara...',
        hintStyle: const TextStyle(
          fontSize: 17,
          color: HomeColors.textPlaceholder,
        ),
        filled: true,
        fillColor: const Color(0xFFEAEFF2),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        prefixIcon: const Icon(
          Icons.search_rounded,
          size: 26,
          color: HomeColors.textSecondary,
        ),
        suffixIcon: IconButton(
          tooltip: 'Barkod tara',
          onPressed: onScanPressed,
          icon: const Icon(
            Icons.qr_code_scanner_rounded,
            size: 26,
            color: HomeColors.textSecondary,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: HomeColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
