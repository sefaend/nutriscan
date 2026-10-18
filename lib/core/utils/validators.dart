import '../constants/app_strings.dart';

/// Form alanı kontrolleri. null dönerse alan geçerlidir.
class Validators {
  Validators._();

  static String? username(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return AppStrings.requiredField;
    if (v.length < 3) return AppStrings.shortUsername;
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return AppStrings.requiredField;
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
    return ok ? null : AppStrings.invalidEmail;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return AppStrings.requiredField;
    if (v.length < 6) return AppStrings.shortPassword;
    return null;
  }

  static String? passwordAgain(String? value, String original) {
    if ((value ?? '').isEmpty) return AppStrings.requiredField;
    return value == original ? null : AppStrings.passwordsDontMatch;
  }
}
