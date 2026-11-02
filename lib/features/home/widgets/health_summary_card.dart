import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'home_style.dart';

/// "Günlük Sağlık Özetin": solda NutriScore halkası, sağda yorum + haftalık oran.
/// Yüzdeler 0-100; o gün/hafta hiç tarama yoksa null.
class HealthSummaryCard extends StatelessWidget {
  const HealthSummaryCard({
    super.key,
    required this.todayPercent,
    required this.weeklyPercent,
  });

  final int? todayPercent;
  final int? weeklyPercent;

  @override
  Widget build(BuildContext context) {
    final today = todayPercent;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE6F8EF), Color(0xFFD9EAE3)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFBFDCCF)),
      ),
      child: Row(
        children: [
          _ScoreRing(percent: today),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title(today),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: HomeColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _message(today),
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: HomeColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Haftalık: ${weeklyPercent == null ? '–' : '%$weeklyPercent'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: HomeColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _title(int? p) {
    if (p == null) return 'Bugün henüz tarama yok';
    if (p >= 75) return 'Harika gidiyorsun! 🎉';
    if (p >= 50) return 'Fena değil, devam et! 💪';
    return 'Biraz daha dikkat et! 👀';
  }

  static String _message(int? p) {
    if (p == null) {
      return 'İlk ürününü tara, sağlık özetin burada görünsün.';
    }
    return 'Bugün taradığın ürünlerin %$p${_possessive(p)} '
        'güvenli ve temiz içerikli.';
  }

  /// Yüzde sayısına Türkçe iyelik eki: 82'si, 80'i, 100'ü ...
  static String _possessive(int n) {
    const byLastDigit = {
      1: "'i", 2: "'si", 3: "'ü", 4: "'ü", 5: "'i",
      6: "'sı", 7: "'si", 8: "'i", 9: "'u",
    };
    const byTens = {
      0: "'ı", 10: "'u", 20: "'si", 30: "'u", 40: "'ı",
      50: "'si", 60: "'ı", 70: "'i", 80: "'i", 90: "'ı", 100: "'ü",
    };
    final last = n % 10;
    return last == 0 ? byTens[n]! : byLastDigit[last]!;
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.percent});

  final int? percent;

  static const double _size = 96;

  @override
  Widget build(BuildContext context) {
    final p = percent;
    return Semantics(
      label: p == null ? 'NutriScore yok' : 'NutriScore yüzde $p',
      child: ExcludeSemantics(
        child: SizedBox(
          width: _size,
          height: _size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: (p ?? 0) / 100),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => CustomPaint(
                  size: const Size.square(_size),
                  painter: _RingPainter(progress: value),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'NutriScore',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: HomeColors.textPrimary,
                    ),
                  ),
                  Text(
                    p == null ? '–' : '%$p',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: HomeColors.textPrimary,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress});

  final double progress;

  static const double _stroke = 9;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(_stroke / 2);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..color = HomeColors.primary.withValues(alpha: 0.15);
    canvas.drawArc(rect, 0, 2 * math.pi, false, track);

    if (progress <= 0) return;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        colors: [Color(0xFF86EFC0), HomeColors.primary],
        transform: GradientRotation(-math.pi / 2),
      ).createShader(rect);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
