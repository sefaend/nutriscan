/// Firestore `users/{uid}/history/{barcode}` belgesinin karşılığı:
/// kullanıcının taradığı bir ürün ve ne zaman taradığı.
class HistoryItem {
  const HistoryItem({
    required this.barcode,
    required this.name,
    required this.scannedAt,
  });

  final String barcode;
  final String name;
  final DateTime scannedAt;
}
