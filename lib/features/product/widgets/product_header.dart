import 'package:flutter/material.dart';

import '../../../data/models/product.dart';
import 'product_style.dart';

/// Görsel, ad, marka • miktar ve Nutri-Score / NOVA rozetleri.
class ProductHeader extends StatelessWidget {
  const ProductHeader({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (product.brand.isNotEmpty) product.brand,
      if (product.quantity.isNotEmpty) product.quantity,
    ].join(' • ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 200,
            width: double.infinity,
            color: ProductColors.card,
            child: _image(product.imageUrl),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          product.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: ProductColors.textPrimary,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: ProductColors.textSecondary),
          ),
        ],
        if (product.nutriScore != null || product.novaGroup != null) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (product.nutriScore != null)
                _Pill(
                  'Nutri-Score ${product.nutriScore}',
                  _nutriColor(product.nutriScore!),
                ),
              if (product.novaGroup != null)
                _Pill('NOVA ${product.novaGroup}', _novaColor(product.novaGroup!)),
            ],
          ),
        ],
      ],
    );
  }

  static Widget _image(String? url) {
    const placeholder = Center(child: Text('🍽️', style: TextStyle(fontSize: 56)));
    if (url == null || url.isEmpty) return placeholder;
    return Image.network(
      url,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => placeholder,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : placeholder,
    );
  }

  static Color _nutriColor(String grade) => switch (grade) {
        'A' => const Color(0xFF16A34A),
        'B' => const Color(0xFF65A30D),
        'C' => ProductColors.warning,
        'D' => const Color(0xFFEA580C),
        _ => ProductColors.danger,
      };

  static Color _novaColor(int group) => switch (group) {
        1 || 2 => const Color(0xFF16A34A),
        3 => ProductColors.warning,
        _ => ProductColors.danger,
      };
}

class _Pill extends StatelessWidget {
  const _Pill(this.text, this.color);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
