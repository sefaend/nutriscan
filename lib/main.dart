import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/constants/app_config.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/data/firebase_auth_service.dart';
import 'features/auth/data/mock_auth_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AuthService authService;
  if (AppConfig.useMockAuth) {
    authService = MockAuthService();
  } else {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    authService = FirebaseAuthService();
  }

  runApp(NutriScanApp(authService: authService));
}
