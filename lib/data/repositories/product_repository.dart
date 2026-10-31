import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';

/// Firestore `products/{barcode}` okuma işleri + bellek içi cache.
/// Aynı barkod için uygulama açıkken Firestore'dan tekrar okunmaz.
class ProductRepository {
  ProductRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  final Map<String, Product?> _cache = {};
  List<Product>? _trending;

  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection('products');

  /// Barkoddan ürünü getirir; veritabanında yoksa null.
  Future<Product?> getByBarcode(String barcode) async {
    if (_cache.containsKey(barcode)) return _cache[barcode];
    final snap = await _products.doc(barcode).get();
    final data = snap.data();
    final product = (snap.exists && data != null)
        ? Product.fromMap(snap.id, data)
        : null;
    _cache[barcode] = product;
    return product;
  }

  /// Ürün adı ya da markası [query] ile BAŞLAYAN ürünler (en çok [limit] tane).
  ///
  /// Firestore'da "içinde geçen" araması yok, sadece "ile başlayan" var ve
  /// büyük/küçük harfe duyarlı. Bu yüzden yazılanın birkaç yazım biçimi
  /// (küçük, BÜYÜK, Baş Harfi Büyük) ayrı ayrı sorulur.
  /// TODO(search): Verideki `name`'in küçük harfli bir kopyası (name_lower)
  /// import edilirse tek sorguyla ve harf farkından bağımsız aranabilir.
  Future<List<Product>> searchByName(String query, {int limit = 20}) async {
    final q = query.trim();
    if (q.isEmpty) return const [];

    final variants = <String>{
      q,
      q.toLowerCase(),
      q.toUpperCase(),
      _titleCase(q),
      _upperFirst(q.toLowerCase()),
    };

    final snaps = await Future.wait([
      for (final field in const ['name', 'brand'])
        for (final v in variants)
          _products
              .where(field, isGreaterThanOrEqualTo: v)
              .where(field, isLessThan: '$v\uf8ff')
              .limit(limit)
              .get(),
    ]);

    final found = <String, Product>{};
    for (final snap in snaps) {
      for (final doc in snap.docs) {
        found[doc.id] = Product.fromMap(doc.id, doc.data());
      }
    }
    for (final p in found.values) {
      _cache[p.barcode] = p;
    }
    final list = found.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list.take(limit).toList();
  }

  static String _upperFirst(String s) {
    if (s.isEmpty) return s;
    final first = s.substring(0, 1);
    // Türkçe: "i" büyüyünce "İ" olur (Dart "I" yapar).
    final upper = first == 'i' ? 'İ' : first.toUpperCase();
    return upper + s.substring(1);
  }

  static String _titleCase(String s) => s
      .toLowerCase()
      .split(' ')
      .map(_upperFirst)
      .join(' ');

  /// Ana sayfadaki "Trend Ürünler" için ürünler.
  ///
  /// TODO(trending): Henüz tarama sayısı tutulmadığı için şimdilik Nutri-Score'u
  /// A olan ürünlerden [limit] tanesi döner. Popülerlik verisi gelince sadece
  /// bu fonksiyon değişir.
  Future<List<Product>> getTrending({int limit = 10}) async {
    final cached = _trending;
    if (cached != null) return cached;

    final query = await _products
        .where('nutriscore_final', isEqualTo: 'A')
        .limit(limit)
        .get();
    final list = [
      for (final doc in query.docs) Product.fromMap(doc.id, doc.data()),
    ];
    for (final p in list) {
      _cache[p.barcode] = p;
    }
    return _trending = list;
  }
}

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepository(),
);
