import 'package:flutter/material.dart';

import 'home_style.dart';

/// Ürün görselinin sol üstündeki "NOVA 1…4" rozeti.
/// NOVA 1-2 yeşil (doğal), 3 turuncu, 4 kırmızı (ultra işlenmiş).
class NovaBadge extends StatelessWidget {
  const NovaBadge({super.key, required this.group});

  final int group;

  Color get _color => switch (group) {
        1 || 2 => const Color(0xFF16A34A),
        3 => HomeColors.warning,
        _ => HomeColors.danger,
      };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'NOVA grup $group',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color: _color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'NOVA $group',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
