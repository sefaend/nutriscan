import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'product_card.dart';

/// Yatay kaydırılan ürün kartı listesi (altında kaydırma çubuğu ile).
class HorizontalProductList extends StatefulWidget {
  const HorizontalProductList({
    super.key,
    required this.products,
    required this.emptyMessage,
    this.onProductTap,
  });

  final List<ProductPreview> products;
  final String emptyMessage;
  final ValueChanged<ProductPreview>? onProductTap;

  @override
  State<HorizontalProductList> createState() => _HorizontalProductListState();
}

class _HorizontalProductListState extends State<HorizontalProductList> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return Container(
        height: ProductCard.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          widget.emptyMessage,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return Scrollbar(
      controller: _scroll,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            for (final p in widget.products)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ProductCard(
                  product: p,
                  onTap: widget.onProductTap == null
                      ? null
                      : () => widget.onProductTap!(p),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
