import 'package:flutter/material.dart';

/// Tasarımdaki "Renkler" paletinin birebir karşılığı.
/// Ekranlarda renk yazmak yerine daima buradan kullan: AppColors.primary
class AppColors {
  AppColors._();

  // Marka ve vurgu
  static const Color primary = Color(0xFF10B981); // Primary / 500
  static const Color primaryDark = Color(0xFF059669); // Primary / 600 (hover/pressed)
  static const Color primaryLight = Color(0xFFECFDF5); // Primary / Light

  // Durum renkleri
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerBackground = Color(0xFFFEF2F2);
  static const Color dangerBorder = Color(0xFFFCA5A5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBackground = Color(0xFFFFFBEB);
  static const Color success = Color(0xFF10B981);
  static const Color successBackground = Color(0xFFA7F3D0);

  // Zemin ve yüzey
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);

  // Metin
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textPlaceholder = Color(0xFF94A3B8);
}
