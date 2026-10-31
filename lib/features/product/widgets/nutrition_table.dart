import 'package:flutter/material.dart';

import '../../../data/models/product.dart';
import 'product_style.dart';

/// 100 g başına besin değerleri; bilinmeyen satırlar gösterilmez.
class NutritionTable extends StatelessWidget {
  const NutritionTable(this.product, {super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, double?, String)>[
      ('Enerji', product.energyKcal, 'kcal'),
      ('Yağ', product.fat, 'g'),
      ('  Doymuş yağ', product.saturatedFat, 'g'),
      ('Karbonhidrat', product.carbs, 'g'),
      ('  Şeker', product.sugars, 'g'),
      ('Lif', product.fiber, 'g'),
      ('Protein', product.protein, 'g'),
      ('Tuz', product.salt, 'g'),
    ].where((r) => r.$2 != null).toList();

    if (rows.isEmpty) {
      return const Text(
        'Besin değeri bilgisi bulunamadı.',
        style: TextStyle(fontSize: 14, color: ProductColors.textSecondary),
      );
    }
    return Column(
      children: [
        for (final r in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  r.$1.trimLeft(),
                  style: TextStyle(
                    fontSize: 14,
                    color: ProductColors.textSecondary,
                    // Girintili satırlar (doymuş yağ, şeker) alt kalem sayılır.
                    fontStyle:
                        r.$1.startsWith(' ') ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
                Text(
                  '${_fmt(r.$2!)} ${r.$3}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ProductColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
}
