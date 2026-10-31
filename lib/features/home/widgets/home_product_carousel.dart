import 'package:flutter/material.dart';

import 'home_style.dart';

/// Yatay kaydırılan kartlar. Kenardan kenara uzanır; sağ kenarda kartlar yarım
/// görünerek kaydırılabilir olduğunu belli eder. Liste boşsa [emptyMessage].
class HomeProductCarousel extends StatelessWidget {
  const HomeProductCarousel({
    super.key,
    required this.cards,
    required this.emptyMessage,
    this.horizontalPadding = 20,
  });

  final List<Widget> cards;
  final String emptyMessage;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Container(
          height: 120,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: HomeColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: HomeColors.border),
          ),
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: HomeColors.textSecondary),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // Üst/alt boşluk kart gölgesinin kesilmemesi için.
      padding: EdgeInsets.fromLTRB(horizontalPadding, 4, horizontalPadding, 14),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final card in cards)
              Padding(padding: const EdgeInsets.only(right: 12), child: card),
          ],
        ),
      ),
    );
  }
}
