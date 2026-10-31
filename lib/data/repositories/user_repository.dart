import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/history_item.dart';

/// Kullanıcıya ait veriler:
///   users/{uid}                    -> allergens[]
///   users/{uid}/history/{barcode}  -> name, scannedAt
class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  /// Kullanıcının seçtiği alerjenler; değişince yeni liste yayınlar.
  Stream<List<String>> watchAllergens(String uid) {
    return _userDoc(uid).snapshots().map((snap) {
      final raw = snap.data()?['allergens'];
      if (raw is! List) return <String>[];
      return [
        for (final e in raw)
          if (e.toString().trim().isNotEmpty) e.toString().trim(),
      ];
    });
  }

  /// Son [within] içinde taranan ürünler, en yeni başta.
  Stream<List<HistoryItem>> watchHistory(
    String uid, {
    Duration within = const Duration(days: 7),
    int limit = 50,
  }) {
    final since = Timestamp.fromDate(DateTime.now().subtract(within));
    return _userDoc(uid)
        .collection('history')
        .where('scannedAt', isGreaterThanOrEqualTo: since)
        .orderBy('scannedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((query) {
      final items = <HistoryItem>[];
      for (final doc in query.docs) {
        final data = doc.data();
        final at = data['scannedAt'];
        // Sunucu saati henüz yazılmamış belgeler (null) sonraki güncellemede gelir.
        if (at is! Timestamp) continue;
        items.add(HistoryItem(
          barcode: doc.id,
          name: (data['name'] ?? doc.id).toString(),
          scannedAt: at.toDate(),
        ));
      }
      return items;
    });
  }

  /// Taranan ürünü geçmişe yazar (aynı barkod tekrar taranırsa zamanı güncellenir).
  /// Scanner/ürün sayfası taramadan sonra çağıracak.
  Future<void> addToHistory(
    String uid, {
    required String barcode,
    required String name,
  }) {
    return _userDoc(uid).collection('history').doc(barcode).set({
      'name': name,
      'scannedAt': FieldValue.serverTimestamp(),
    });
  }
}

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(),
);
