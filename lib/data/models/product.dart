/// Firestore `products/{barcode}` belgesinin uygulamadaki karşılığı.
/// Firebase'e bağımlı değildir; belgeyi Map olarak alır.
/// Yeni alan gerekirse buraya eklenir.
class Product {
  const Product({
    required this.barcode,
    required this.name,
    this.brand = '',
    this.imageUrl,
    this.allergens = const [],
    this.traces = const [],
    this.novaGroup,
    this.nutriScore,
    this.quantity = '',
    this.ingredients = '',
    this.energyKcal,
    this.fat,
    this.saturatedFat,
    this.carbs,
    this.sugars,
    this.fiber,
    this.protein,
    this.salt,
  });

  final String barcode;
  final String name;
  final String brand;
  final String? imageUrl;

  /// Üründeki alerjenler (Firestore'daki yazımıyla).
  final List<String> allergens;

  /// "İz miktarda içerebilir" alerjenler.
  final List<String> traces;

  /// NOVA işlenmişlik grubu 1-4 (bilinmiyorsa null).
  final int? novaGroup;

  /// Nutri-Score harfi A-E (bilinmiyorsa null).
  final String? nutriScore;

  /// Ambalaj miktarı (ör. "35g"); yoksa boş.
  final String quantity;

  /// İçindekiler metni; yoksa boş.
  final String ingredients;

  /// Besin değerleri, 100 g başına (bilinmiyorsa null).
  final double? energyKcal;
  final double? fat;
  final double? saturatedFat;
  final double? carbs;
  final double? sugars;
  final double? fiber;
  final double? protein;
  final double? salt;

  factory Product.fromMap(String barcode, Map<String, dynamic> map) {
    final name = _text(map['name']);
    return Product(
      barcode: barcode,
      name: name.isEmpty ? barcode : name,
      brand: _text(map['brand']),
      imageUrl: _text(map['image_url']).isEmpty ? null : _text(map['image_url']),
      allergens: _list(map['allergens']),
      traces: _list(map['traces']),
      novaGroup: _nova(map['nova_final']),
      nutriScore: _grade(map['nutriscore_final']),
      quantity: _text(map['quantity']),
      ingredients: _ingredients(map),
      energyKcal: _double(map['energy_kcal_100g']),
      fat: _double(map['fat_100g']),
      saturatedFat: _double(map['saturated_fat_100g']),
      carbs: _double(map['carbohydrates_100g']),
      sugars: _double(map['sugars_100g']),
      fiber: _double(map['fiber_100g']),
      protein: _double(map['proteins_100g']),
      salt: _double(map['salt_100g']),
    );
  }

  /// Kullanıcının alerjilerinden herhangi biri üründe (ya da iz olarak) var mı?
  /// Güvenlik için "iz miktarı" da risk sayılır. Karşılaştırma küçük/büyük harf
  /// ve boşluk farkını yok sayar; yazımın (ör. "milk") iki tarafta aynı olması
  /// gerekir — bkz. ARCHITECTURE.md "Alerjen yazımı".
  bool conflictsWith(Iterable<String> userAllergens) =>
      conflictingWith(userAllergens).isNotEmpty;

  /// Kullanıcının alerjilerinden üründe (ya da iz olarak) bulunanlar.
  /// Değerler küçük harfe çevrilmiş halde döner.
  List<String> conflictingWith(Iterable<String> userAllergens) {
    final mine = userAllergens.map(_norm).where((e) => e.isNotEmpty).toSet();
    if (mine.isEmpty) return const [];
    return allergens
        .followedBy(traces)
        .map(_norm)
        .where(mine.contains)
        .toSet()
        .toList();
  }

  static String _norm(String s) => s.trim().toLowerCase();

  static String _text(Object? v) => v == null ? '' : v.toString().trim();

  /// `ingredients_text` alanı (Open Food Facts'in vurgu işareti `_` temizlenir).
  /// Yoksa `ingredients[]` listesi varsa virgülle birleştirilir.
  static String _ingredients(Map<String, dynamic> map) {
    final text = _text(map['ingredients_text']).replaceAll('_', '').trim();
    if (text.isNotEmpty) return text;
    final raw = map['ingredients'];
    return raw is List ? _list(raw).join(', ') : '';
  }

  static double? _double(Object? v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim().replaceAll(',', '.'));
    return null;
  }

  static List<String> _list(Object? v) {
    if (v is List) {
      return v.map(_text).where((e) => e.isNotEmpty).toList();
    }
    if (v is String) {
      return v
          .split(RegExp(r'[,;|]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static int? _nova(Object? v) {
    if (v is! num) return null;
    final n = v.toInt();
    return (n >= 1 && n <= 4) ? n : null;
  }

  static String? _grade(Object? v) {
    final g = _text(v).toUpperCase();
    return RegExp(r'^[A-E]$').hasMatch(g) ? g : null;
  }
}
