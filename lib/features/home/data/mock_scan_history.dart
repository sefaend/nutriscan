import 'models/scan_item.dart';

/// GEÇİCİ örnek veri: tasarımdaki sayılarla aynı (bugün 3, toplam 10, 5 riskli).
/// Gerçek tarama geçmişi bağlanınca bu dosya silinebilir.
class MockScanHistory {
  MockScanHistory._();

  static List<ScanItem> build() {
    final now = DateTime.now();
    ScanItem item(String name, Duration ago, {bool risk = false}) => ScanItem(
          barcode: '8690000${name.hashCode.abs() % 100000}',
          name: name,
          scannedAt: now.subtract(ago),
          hasAllergenRisk: risk,
        );

    return [
      item('Çikolatalı Gofret', const Duration(minutes: 10)),
      item('Tam Buğday Bisküvi', const Duration(minutes: 40)),
      item('Yoğurt 500g', const Duration(minutes: 90)),
      item('Fındıklı Bar', const Duration(days: 1), risk: true),
      item('Süt 1L', const Duration(days: 1, hours: 2), risk: true),
      item('Cips', const Duration(days: 2), risk: true),
      item('Karışık Kuruyemiş', const Duration(days: 2, hours: 5), risk: true),
      item('Meyve Suyu', const Duration(days: 3)),
      item('Mısır Gevreği', const Duration(days: 3, hours: 4), risk: true),
      item('Zeytinyağlı Sos', const Duration(days: 4)),
    ];
  }
}
