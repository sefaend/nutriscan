import 'package:flutter/material.dart';

import 'home_style.dart';
import 'nova_badge.dart';

/// Kartın alt satırındaki durum: alerjen riski var mı?
enum ProductStatus { safe, risky, unknown }

/// Ana sayfa ürün kartı: görsel + NOVA rozeti + ad + "Açıklama • Güvenli/Riskli".
/// Veri modeline bağımlı değildir; ekran gerekli bilgileri hazır verir.
class HomeProductCard extends StatelessWidget {
  const HomeProductCard({
    super.key,
    required this.name,
    required this.descriptor,
    required this.status,
    required this.width,
    required this.imageHeight,
    this.novaGroup,
    this.imageUrl,
    this.onTap,
  });

  final String name;
  final String descriptor;
  final ProductStatus status;
  final double width;
  final double imageHeight;
  final int? novaGroup;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: HomeColors.surface,
        borderRadius: radius,
        border: Border.all(color: const Color(0xFFE3EAEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _ProductImage(
                  imageUrl: imageUrl,
                  novaGroup: novaGroup,
                  height: imageHeight,
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: HomeColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: descriptor),
                      if (status != ProductStatus.unknown) ...[
                        const TextSpan(text: ' • '),
                        TextSpan(
                          text: status == ProductStatus.risky
                              ? 'Riskli'
                              : 'Güvenli',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: status == ProductStatus.risky
                                ? HomeColors.danger
                                : HomeColors.primaryDark,
                          ),
                        ),
                      ],
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: HomeColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.imageUrl,
    required this.novaGroup,
    required this.height,
  });

  final String? imageUrl;
  final int? novaGroup;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _picture(),
            if (novaGroup != null)
              Positioned(
                top: 8,
                left: 8,
                child: NovaBadge(group: novaGroup!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _picture() {
    final url = imageUrl;
    if (url == null || url.isEmpty) return _placeholder();
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : _placeholder(),
    );
  }

  Widget _placeholder() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
        ),
      ),
      child: Center(child: Text('🍽️', style: TextStyle(fontSize: 40))),
    );
  }
}
