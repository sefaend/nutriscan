import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../data/auth_service.dart';

/// Giriş ve kayıt formlarının ortak mantığı: yükleniyor durumu, hata mesajı,
/// sosyal giriş butonları. Ekran bittiğinde (başarılı girişte) dispose
/// edilse bile güvenle çalışır.
abstract class AuthFormController extends ChangeNotifier {
  AuthFormController({required this.authService});

  final AuthService authService;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String? errorMessage;
  bool _disposed = false;

  bool validateForm() => formKey.currentState?.validate() ?? false;

  /// Servis çağrısını çalıştırır; yükleniyor/hata durumunu yönetir.
  Future<void> runAuthAction(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    _safeNotify();
    try {
      await action();
    } on AuthException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = AppStrings.genericError;
    }
    isLoading = false;
    _safeNotify();
  }

  /// A / f / G butonları. Sosyal giriş henüz bağlı değil.
  void onSocialPressed(String provider) {
    errorMessage = '$provider sign-in is coming soon.';
    _safeNotify();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
