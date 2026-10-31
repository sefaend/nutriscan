import 'package:flutter/material.dart';

import 'home_style.dart';

/// "Alerjenlerin" altındaki yatay kaydırılan renkli çipler.
/// [allergens] Firestore'daki yazımıyla gelir (ör. "milk"); bilinenlerin Türkçe
/// adı ve emojisi gösterilir, bilinmeyenler olduğu gibi yazılır.
class AllergenChips extends StatelessWidget {
  const AllergenChips({
    super.key,
    required this.allergens,
    this.horizontalPadding = 20,
  });

  final List<String> allergens;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    if (allergens.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: const Text(
          'Henüz alerjen eklemedin. Profilinden ekleyebilirsin.',
          style: TextStyle(fontSize: 14, color: HomeColors.textSecondary),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: [
          for (final a in allergens)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _AllergenChip(display: _display(a)),
            ),
        ],
      ),
    );
  }

  static _Display _display(String raw) {
    final key = raw.trim().toLowerCase();
    return _known[key] ??
        _Display(
          key.isEmpty ? raw : key[0].toUpperCase() + key.substring(1),
          '⚠️',
          _Tone.orange,
        );
  }

  static const Map<String, _Display> _known = {
    'gluten': _Display('Gluten', '🌾', _Tone.yellow),
    'milk': _Display('Laktoz', '🥛', _Tone.blue),
    'peanuts': _Display('Yer Fıstığı', '🥜', _Tone.orange),
    'eggs': _Display('Yumurta', '🥚', _Tone.green),
    'soybeans': _Display('Soya', '🫘', _Tone.purple),
    'nuts': _Display('Kuruyemiş', '🌰', _Tone.orange),
    'fish': _Display('Balık', '🐟', _Tone.blue),
    'sesame-seeds': _Display('Susam', '🌿', _Tone.yellow),
    'mustard': _Display('Hardal', '🟡', _Tone.yellow),
    'celery': _Display('Kereviz', '🥬', _Tone.green),
    'crustaceans': _Display('Kabuklu Deniz Ürünü', '🦐', _Tone.orange),
    'molluscs': _Display('Yumuşakça', '🐚', _Tone.blue),
    'lupin': _Display('Acı Bakla', '🌸', _Tone.purple),
    'sulphur-dioxide-and-sulphites': _Display('Sülfit', '🍷', _Tone.purple),
  };
}

enum _Tone { yellow, blue, orange, green, purple }

class _Display {
  const _Display(this.label, this.emoji, this.tone);

  final String label;
  final String emoji;
  final _Tone tone;
}

class _AllergenChip extends StatelessWidget {
  const _AllergenChip({required this.display});

  final _Display display;

  @override
  Widget build(BuildContext context) {
    final colors = _ToneColors.of(display.tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border, width: 1.5),
      ),
      child: Text(
        '${display.label} ${display.emoji}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colors.text,
        ),
      ),
    );
  }
}

class _ToneColors {
  const _ToneColors(this.background, this.border, this.text);

  final Color background;
  final Color border;
  final Color text;

  static _ToneColors of(_Tone tone) => switch (tone) {
        _Tone.yellow => const _ToneColors(
            Color(0xFFFEF6D8), Color(0xFFE9C46A), Color(0xFF6B4E0A)),
        _Tone.blue => const _ToneColors(
            Color(0xFFE4F1FB), Color(0xFF7DB8E8), Color(0xFF1E4E79)),
        _Tone.orange => const _ToneColors(
            Color(0xFFFFEBDD), Color(0xFFF0A878), Color(0xFF7A3B12)),
        _Tone.green => const _ToneColors(
            Color(0xFFE3F7EA), Color(0xFF86D6A5), Color(0xFF166534)),
        _Tone.purple => const _ToneColors(
            Color(0xFFF1E9FB), Color(0xFFB99AE3), Color(0xFF4C2A7A)),
      };
}
