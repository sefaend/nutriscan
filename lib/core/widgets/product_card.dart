import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Kartta gösterilecek en az bilgi. Ana sayfa ve profil ortak kullanır.
/// (İleride product_detail'in ProductModel'inden dönüştürülebilir.)
class ProductPreview {
  const ProductPreview({
    required this.barcode,
    required this.name,
    this.imageUrl,
    this.hasAllergenRisk = false,
  });

  final String barcode;
  final String name;
  final String? imageUrl;
  final bool hasAllergenRisk;
}

/// Tasarımdaki siyah, yuvarlak köşeli "Ürün resmi" kartı.
/// Alerjen riski varsa kırmızı çerçeve ve uyarı rozeti çıkar.
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.onTap});

  static const double width = 96;
  static const double height = 130;

  final ProductPreview product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: product.hasAllergenRisk
              ? const BorderSide(color: AppColors.danger, width: 2)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildImage(),
              if (product.hasAllergenRisk)
                const Positioned(
                  top: 6,
                  right: 6,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: AppColors.danger,
                    child: Icon(
                      Icons.priority_high_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final url = product.imageUrl;
    if (url == null || url.isEmpty) return _placeholder();
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Text(
          product.name,
          textAlign: TextAlign.center,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}
