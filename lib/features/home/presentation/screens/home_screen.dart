import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../controllers/home_controller.dart';
import '../widgets/greeting_header.dart';
import '../widgets/scan_section.dart';

/// Ana ekran: sadece yerleşim. Veri ve davranış HomeController'da.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.controller,
    required this.username,
  });

  final HomeController controller;
  final String username;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GreetingHeader(username: username),
                const SizedBox(height: 28),
                ScanSection(
                  title: AppStrings.todaySearches,
                  summary: controller.todaySummary,
                  products: controller.todayProducts,
                  onProductTap: (p) => controller.onProductTapped(context, p),
                ),
                const SizedBox(height: 20),
                ScanSection(
                  title: AppStrings.history,
                  summary: controller.historySummary,
                  products: controller.historyProducts,
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
