import 'package:flutter/material.dart';

import '../../../core/allergen_list.dart';
import '../../../data/models/product.dart';
import 'product_style.dart';

/// Kullanıcının alerjisine göre uyarı / "görünmüyor" kutusu.
class AllergenBanner extends StatelessWidget {
  const AllergenBanner({super.key, required this.conflicts});

  final List<String> conflicts;

  @override
  Widget build(BuildContext context) {
    final risky = conflicts.isNotEmpty;
    final color = risky ? ProductColors.danger : ProductColors.primaryDark;
    final text = risky
        ? 'Dikkat! Alerjenin bu üründe var ya da iz miktarda olabilir: '
            '${conflicts.map(allergenLabel).join(', ')}'
        : 'Seçtiğin alerjenler bu ürünün alerjen listesinde görünmüyor.';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            risky ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Üründeki alerjenler ve iz miktarlar (kullanıcının alerjisi kırmızı).
class ProductAllergens extends StatelessWidget {
  const ProductAllergens({super.key, required this.product, required this.mine});

  final Product product;
  final Set<String> mine;

  @override
  Widget build(BuildContext context) {
    if (product.allergens.isEmpty && product.traces.isEmpty) {
      return const Text(
        'Bilinen alerjen bilgisi yok.',
        style: TextStyle(fontSize: 14, color: ProductColors.textSecondary),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.allergens.isNotEmpty) _chips(product.allergens, ProductColors.warning),
        if (product.traces.isNotEmpty) ...[
          if (product.allergens.isNotEmpty) const SizedBox(height: 14),
          const Text(
            'İz miktarda içerebilir',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ProductColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          _chips(product.traces, ProductColors.textSecondary),
        ],
      ],
    );
  }

  /// Kullanıcının alerjisi olan çipler kırmızı, diğerleri [base] renkte.
  Widget _chips(List<String> items, Color base) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final a in items)
          _chip(allergenLabel(a), mine.contains(a.trim().toLowerCase()) ? ProductColors.danger : base),
      ],
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
