import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/horizontal_product_list.dart';
import '../../../../core/widgets/product_card.dart';

/// Başlık + italik özet cümlesi + yatay kart listesi.
/// "Today Searches" ve "History" bölümlerinin ortak parçası.
class ScanSection extends StatelessWidget {
  const ScanSection({
    super.key,
    required this.title,
    required this.summary,
    required this.products,
    required this.onProductTap,
  });

  final String title;
  final String summary;
  final List<ProductPreview> products;
  final ValueChanged<ProductPreview> onProductTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 2),
        Text(
          summary,
          style: const TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        HorizontalProductList(
          products: products,
          emptyMessage: AppStrings.noScansYet,
          onProductTap: onProductTap,
        ),
      ],
    );
  }
}
