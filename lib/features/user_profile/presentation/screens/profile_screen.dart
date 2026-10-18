import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/horizontal_product_list.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_header.dart';
import '../widgets/tag_section.dart';

/// Profil ekranı: sadece yerleşim. Davranış ProfileController'da.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileHeader(
                  username: controller.username,
                  onSettingsPressed: () => controller.onSettingsPressed(context),
                ),
                const SizedBox(height: 20),
                TagSection(
                  title: AppStrings.allergies,
                  tags: controller.allergies,
                  tagColor: AppColors.dangerBorder,
                  onRemove: controller.onRemoveAllergy,
                  onAdd: () => controller.onAddAllergyPressed(context),
                ),
                const SizedBox(height: 20),
                TagSection(
                  title: AppStrings.dietaryPreference,
                  tags: controller.dietaryPreferences,
                  tagColor: AppColors.successBackground,
                  onRemove: controller.onRemoveDiet,
                  onAdd: () => controller.onAddDietPressed(context),
                ),
                const SizedBox(height: 28),
                const Text(
                  AppStrings.suggestedForYou,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 2),
                const Text(
                  AppStrings.suggestedSubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                HorizontalProductList(
                  products: controller.suggestedProducts,
                  emptyMessage: AppStrings.noScansYet,
                  onProductTap: (p) => controller.onProductTapped(context, p),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
