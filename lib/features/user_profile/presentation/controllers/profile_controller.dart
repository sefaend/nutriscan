import 'package:flutter/material.dart';

import '../../../../core/utils/app_navigator.dart';
import '../../../../core/widgets/product_card.dart';
import '../widgets/add_item_dialog.dart';
import '../widgets/settings_sheet.dart';

/// Profil ekranının tüm mantığı: alerji/diyet ekle-sil, ayarlar, öneriler.
///
/// TODO(user_profile): Şu an veriler bellekte tutuluyor ve örnek değerlerle
/// başlıyor. Buse'nin UserProfileRepository'si hazır olunca
/// _allergies / _dietaryPreferences oraya bağlanacak (okuma + kaydetme).
class ProfileController extends ChangeNotifier {
  ProfileController({required this.username, required this.onSignOut});

  final String username;
  final VoidCallback onSignOut;

  static const List<String> allergySuggestions = [
    'Gluten', 'Lactose', 'Nuts', 'Peanuts', 'Egg', 'Fish',
    'Soy', 'Sesame', 'Shellfish', 'Mustard', 'Celery',
  ];
  static const List<String> dietSuggestions = [
    'Vegan', 'Vegetarian', 'Diabetic', 'Low sodium',
    'Low sugar', 'Halal', 'Kosher', 'Keto',
  ];

  final List<String> _allergies = ['Gluten', 'Lactose', 'Nuts', 'Egg', 'Fish'];
  final List<String> _dietaryPreferences = [
    'Vegan', 'Vegetarian', 'Diabetic', 'Low sodium',
  ];

  List<String> get allergies => List.unmodifiable(_allergies);
  List<String> get dietaryPreferences => List.unmodifiable(_dietaryPreferences);

  /// "Suggested For You" bölümü. TODO: öneri algoritması/veri bağlanınca dolacak.
  List<ProductPreview> get suggestedProducts => const [
        ProductPreview(barcode: '8690000000001', name: 'Gluten-free Bar'),
        ProductPreview(barcode: '8690000000002', name: 'Oat Milk 1L'),
        ProductPreview(barcode: '8690000000003', name: 'Rice Crackers'),
        ProductPreview(barcode: '8690000000004', name: 'Low Sodium Soup'),
      ];

  // ---- Alerjiler ----
  Future<void> onAddAllergyPressed(BuildContext context) async {
    final value = await showAddItemDialog(
      context,
      title: 'Add allergy',
      suggestions: _remaining(allergySuggestions, _allergies),
    );
    if (value != null) _add(_allergies, value);
  }

  void onRemoveAllergy(String allergy) => _remove(_allergies, allergy);

  // ---- Diyet tercihleri ----
  Future<void> onAddDietPressed(BuildContext context) async {
    final value = await showAddItemDialog(
      context,
      title: 'Add dietary preference',
      suggestions: _remaining(dietSuggestions, _dietaryPreferences),
    );
    if (value != null) _add(_dietaryPreferences, value);
  }

  void onRemoveDiet(String diet) => _remove(_dietaryPreferences, diet);

  // ---- Diğer ----
  void onSettingsPressed(BuildContext context) {
    showSettingsSheet(context, onSignOut: onSignOut);
  }

  void onProductTapped(BuildContext context, ProductPreview product) {
    AppNavigator.openProductDetail(context, barcode: product.barcode);
  }

  // ---- yardımcılar ----
  List<String> _remaining(List<String> all, List<String> current) {
    final lower = current.map((e) => e.toLowerCase()).toSet();
    return all.where((e) => !lower.contains(e.toLowerCase())).toList();
  }

  void _add(List<String> list, String value) {
    final v = value.trim();
    if (v.isEmpty) return;
    if (list.any((e) => e.toLowerCase() == v.toLowerCase())) return;
    list.add(v);
    notifyListeners();
  }

  void _remove(List<String> list, String value) {
    list.remove(value);
    notifyListeners();
  }
}
