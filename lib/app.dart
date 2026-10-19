import 'package:flutter/material.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/presentation/screens/auth_gate.dart';

/// Uygulamanın kökü: tema + ilk ekran (giriş yapılmışsa ana sayfa).
class NutriScanApp extends StatelessWidget {
  const NutriScanApp({super.key, required this.authService});

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AuthGate(authService: authService),
    );
  }
}
