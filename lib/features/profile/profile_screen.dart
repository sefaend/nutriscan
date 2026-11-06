import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/data/repositories/auth_repository.dart';
import 'package:nutri_scan/data/repositories/user_repository.dart';
import 'package:nutri_scan/features/profile/widgets/selection_sheet.dart';
import 'package:nutri_scan/router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // products_A_layer.csv veri setindeki alerjenler
  final Map<String, String> _datasetAllergens = {
    'gluten': 'Gluten',
    'milk': 'Milk (Lactose)',
    'eggs': 'Eggs',
    'nuts': 'Tree Nuts',
    'peanuts': 'Peanuts',
    'soybeans': 'Soybeans',
    'fish': 'Fish',
    'crustaceans': 'Crustaceans',
    'molluscs': 'Molluscs',
    'sesame-seeds': 'Sesame',
    'mustard': 'Mustard',
    'celery': 'Celery',
    'lupin': 'Lupin',
    'sulphur-dioxide-and-sulphites': 'Sulphites',
  };

  // products_A_layer.csv veri setindeki beslenme tercihleri
  final Map<String, String> _datasetDietaryPreferences = {
    'vegan': 'Vegan',
    'vegetarian': 'Vegetarian',
    'halal': 'Halal',
    'kosher': 'Kosher',
    'organic': 'Organic',
    'low-sugar': 'Low Sugar',
    'no-added-sugar': 'No Added Sugar',
    'low-fat': 'Low Fat',
    'low-salt': 'Low Salt / Sodium',
  };

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) =>
          Scaffold(body: Center(child: Text('Auth Error: $err'))),
      data: (appUser) {
        if (appUser == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'PROFILE SCREEN',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please sign in to view your profile.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () => context.push(AppRoutes.login),
                    child: const Text('Login Test Button'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => context.push(AppRoutes.signup),
                    child: const Text('Sign Up Test Button'),
                  ),
                ],
              ),
            ),
          );
        }

        final uid = appUser.uid;
        final username = appUser.name.isNotEmpty ? appUser.name : 'User';

        final allergensAsync = ref.watch(userAllergensProvider);
        final dietaryAsync = ref.watch(userDietaryPreferencesProvider);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(
                          Icons.settings_outlined,
                          size: 28,
                          color: Colors.black,
                        ),
                        onPressed: () => _showSettingsBottomSheet(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: CircleAvatar(
                        radius: 65,
                        backgroundColor: const Color(0xFFE0E0E0),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          size: 65,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        username,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    const Text(
                      'Allergies',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    allergensAsync.when(
                      data: (allergies) {
                        return Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ...allergies.map(
                              (item) => _buildChip(
                                label: _datasetAllergens[item] ?? item,
                                backgroundColor: const Color(0xFFFBB4B4),
                                textColor: Colors.black,
                                onDelete: () {
                                  ref
                                      .read(userRepositoryProvider)
                                      .removeAllergen(uid, item);
                                },
                              ),
                            ),
                            _buildAddButton(
                              backgroundColor: const Color(0xFFFBB4B4),
                              onPressed: () {
                                _showSelectionBottomSheet(
                                  context: context,
                                  title: 'Select Allergy',
                                  options: _datasetAllergens,
                                  currentSelections: allergies,
                                  onSelect: (selectedKey) {
                                    ref
                                        .read(userRepositoryProvider)
                                        .addAllergen(uid, selectedKey);
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (err, stack) => Text('Error: $err'),
                    ),
                    const SizedBox(height: 36),

                    const Text(
                      'Dietary Preference',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    dietaryAsync.when(
                      data: (preferences) {
                        return Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ...preferences.map(
                              (item) => _buildChip(
                                label: _datasetDietaryPreferences[item] ?? item,
                                backgroundColor: const Color(0xFFB5F2D6),
                                textColor: Colors.black,
                                onDelete: () {
                                  ref
                                      .read(userRepositoryProvider)
                                      .removeDietaryPreference(uid, item);
                                },
                              ),
                            ),
                            _buildAddButton(
                              backgroundColor: const Color(0xFFB5F2D6),
                              onPressed: () {
                                _showSelectionBottomSheet(
                                  context: context,
                                  title: 'Select Dietary Preference',
                                  options: _datasetDietaryPreferences,
                                  currentSelections: preferences,
                                  onSelect: (selectedKey) {
                                    ref
                                        .read(userRepositoryProvider)
                                        .addDietaryPreference(uid, selectedKey);
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (err, stack) => Text('Error: $err'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChip({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton({
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add_rounded, size: 18, color: Colors.black),
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Divider(),
              ListTile(
                leading: const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  Navigator.of(sheetContext, rootNavigator: true).pop();
                  await ref.read(authRepositoryProvider).signOut();
                  if (context.mounted) context.go(AppRoutes.login);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSelectionBottomSheet({
    required BuildContext context,
    required String title,
    required Map<String, String> options,
    required List<String> currentSelections,
    required Function(String key) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SelectionSheet(
        title: title,
        options: options,
        currentSelections: currentSelections,
        onSelect: onSelect,
      ),
    );
  }
}
