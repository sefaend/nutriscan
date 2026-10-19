import '../../../../core/widgets/product_card.dart';

/// Ana sayfadaki bir tarama kaydı.
/// TODO(data): Firebase/ProductModel hazır olunca bu sınıf onlara bağlanacak.
class ScanItem {
  const ScanItem({
    required this.barcode,
    required this.name,
    required this.scannedAt,
    this.imageUrl,
    this.hasAllergenRisk = false,
  });

  final String barcode;
  final String name;
  final DateTime scannedAt;
  final String? imageUrl;
  final bool hasAllergenRisk;

  ProductPreview get preview => ProductPreview(
        barcode: barcode,
        name: name,
        imageUrl: imageUrl,
        hasAllergenRisk: hasAllergenRisk,
      );
}
