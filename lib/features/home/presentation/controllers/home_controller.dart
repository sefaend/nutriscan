import 'package:flutter/material.dart';

import '../../../../core/utils/app_navigator.dart';
import '../../../../core/widgets/product_card.dart';
import '../../data/mock_scan_history.dart';
import '../../data/models/scan_item.dart';

/// Ana ekranın tüm mantığı: hangi kartlar görünür, özet cümleleri, kart tıklama.
class HomeController extends ChangeNotifier {
  HomeController({List<ScanItem>? initialScans})
      : _scans = List.of(initialScans ?? MockScanHistory.build())
          ..sort((a, b) => b.scannedAt.compareTo(a.scannedAt));

  /// History bölümünde en fazla kaç ürün gösterilir.
  static const int historyLimit = 5;

  final List<ScanItem> _scans; // en yeni başta

  List<ScanItem> get _todayScans {
    final now = DateTime.now();
    return _scans
        .where((s) =>
            s.scannedAt.year == now.year &&
            s.scannedAt.month == now.month &&
            s.scannedAt.day == now.day)
        .toList();
  }

  List<ProductPreview> get todayProducts =>
      _todayScans.map((s) => s.preview).toList();

  List<ProductPreview> get historyProducts =>
      _scans.take(historyLimit).map((s) => s.preview).toList();

  String get todaySummary {
    final today = _todayScans;
    return 'You scanned ${_products(today.length)} today. '
        '${_risks(_riskCount(today))}.';
  }

  String get historySummary =>
      'You have scanned ${_products(_scans.length)} so far. '
      '${_risks(_riskCount(_scans))}.';

  int _riskCount(List<ScanItem> items) =>
      items.where((s) => s.hasAllergenRisk).length;

  String _products(int n) => n == 1 ? '1 product' : '$n products';
  String _risks(int n) => n > 1 ? '$n allergen risks' : '$n allergen risk';

  void onProductTapped(BuildContext context, ProductPreview product) {
    AppNavigator.openProductDetail(context, barcode: product.barcode);
  }
}
