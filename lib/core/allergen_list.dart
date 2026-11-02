/// Firestore'daki alerjen anahtarı (ör. "milk") -> ekranda gösterilecek Türkçe ad + emoji.
/// Anahtarlar ürünlerdeki `allergens` alanıyla aynı yazımda olmalıdır
/// (bkz. ARCHITECTURE.md "Alerjen yazımı").
const Map<String, ({String label, String emoji})> knownAllergens = {
  'gluten': (label: 'Gluten', emoji: '🌾'),
  'milk': (label: 'Laktoz', emoji: '🥛'),
  'peanuts': (label: 'Yer Fıstığı', emoji: '🥜'),
  'eggs': (label: 'Yumurta', emoji: '🥚'),
  'soybeans': (label: 'Soya', emoji: '🫘'),
  'nuts': (label: 'Kuruyemiş', emoji: '🌰'),
  'fish': (label: 'Balık', emoji: '🐟'),
  'sesame-seeds': (label: 'Susam', emoji: '🌿'),
  'mustard': (label: 'Hardal', emoji: '🟡'),
  'celery': (label: 'Kereviz', emoji: '🥬'),
  'crustaceans': (label: 'Kabuklu Deniz Ürünü', emoji: '🦐'),
  'molluscs': (label: 'Yumuşakça', emoji: '🐚'),
  'lupin': (label: 'Acı Bakla', emoji: '🌸'),
  'sulphur-dioxide-and-sulphites': (label: 'Sülfit', emoji: '🍷'),
};

/// Ekranda yazılacak ad ("Laktoz 🥛"). Bilinmeyen anahtar olduğu gibi yazılır.
String allergenLabel(String raw) {
  final key = raw.trim().toLowerCase();
  final known = knownAllergens[key];
  if (known == null) return key.isEmpty ? raw : '$key ⚠️';
  return '${known.label} ${known.emoji}';
}
