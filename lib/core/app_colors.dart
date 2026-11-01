import 'package:flutter/material.dart';

class AppColors extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;
  static ThemeData get lightTheme => ThemeData(
    colorScheme: const ColorScheme.light(
      // Main Colors
      primary: Color(0xFF10B981),
      onPrimary: Color(0xFF059669),
      primaryContainer: Color(0xFFECFDF5),

      // Status Colors
      error: Color(0xFFEF4444),
      onError: Color(0xFFFEF2F2),
      onErrorContainer: Color(0xFFFCA5A5),
      onSecondary: Color(0xFFF59E0B),
      onSecondaryContainer: Color(0xFFFFFBEB),
      onSurfaceVariant: Color(0xFFA7F3D0),

      // Background/Surface Colors
      surface: Color(0xFFF8FAFC),
      onSurface: Color(0xFFFFFFFF),
      surfaceContainer: Color(0xFFE2E8F0),

      tertiary: Color(0xFF111827),
      tertiaryContainer: Color(0xFF64748B),
      onTertiary: Color(0xFF94A3B8),
    ),
  );
}
