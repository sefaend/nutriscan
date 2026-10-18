import 'package:flutter/material.dart';

/// Arayüzden diğer arkadaşların ekranlarına geçişin TEK noktası.
///
/// Şu an ilgili ekranlar projede olmadığı için bilgi mesajı gösterir.
/// Arkadaşların dosyaları projeye eklenince sadece aşağıdaki iki TODO'yu
/// doldurman yeterli; başka hiçbir arayüz dosyasına dokunmana gerek yok.
class AppNavigator {
  AppNavigator._();

  /// Ortadaki kamera butonuna basılınca çağrılır.
  static void openScanner(BuildContext context) {
    // TODO(scanner): Barkod okuyucu arkadaşın ekranı hazır olunca:
    // import '../../features/scanner/presentation/screens/barcode_scanner_screen.dart';
    // Navigator.of(context).push(
    //   MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    // );
    _notConnected(context, 'Barcode scanner');
  }

  /// Ana sayfadaki bir ürün kartına basılınca çağrılır.
  static void openProductDetail(
    BuildContext context, {
    required String barcode,
  }) {
    // TODO(product_detail): Ürün detay ekranı hazır olunca:
    // Navigator.of(context).push(
    //   MaterialPageRoute(builder: (_) => ProductDetailScreen(barcode: barcode)),
    // );
    _notConnected(context, 'Product detail ($barcode)');
  }

  static void _notConnected(BuildContext context, String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$what is not connected yet.')));
  }
}
