import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/workout_session.dart';

class HomeCandlestickWidget extends StatefulWidget {
  final List<WorkoutSession> sessions;
  final VoidCallback onTap;

  const HomeCandlestickWidget({
    super.key,
    required this.sessions,
    required this.onTap,
  });

  @override
  State<HomeCandlestickWidget> createState() =>
      _HomeCandlestickWidgetState();
}

class _HomeCandlestickWidgetState extends State<HomeCandlestickWidget> {
  static final _picks = [
    ('squat', 'Kniebeuge'),
    ('bench', 'Bankdrücken'),
    ('deadlift', 'Kreuzheben'),
    ('ohp', 'OHP'),
  ];
  int _pickIndex = 0;

  List<_MiniCandle> _buildCandles() {
    final exerciseId = _picks[_pickIndex].$1;
    final relevant = widget.sessions
        .where((s) => s.logFor(exerciseId) != null)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (relevant.isEmpty) return [];

    final candles = <_MiniCandle>[];
    double prev = 0;
    for (final s in relevant.take(16)) {
      final log = s.logFor(exerciseId)!;
      if (log.sets.isEmpty) continue;
      final weights = log.sets.map((w) => w.weightKg).toList();
      final best = weights.reduce(math.max);
      candles.add(_MiniCandle(
        date: s.date,
        close: best,
        open: prev == 0 ? best : prev,
      ));
      prev = best;
    }
    return candles;
  }

  @override
  Widget build(BuildContext context) {
    final candles = _buildCandles();
    final exerciseName = _picks[_pickIndex].$2;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.timerRingBackground),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Progression', style: AppTypography.label),
                const Spacer(),
                Text('→ Details',
                    style: AppTypography.label
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 8),
            // Exercise pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_picks.length, (i) {
                  final selected = i == _pickIndex;
                  return GestureDetector(
                    onTap: () => setState(() { _pickIndex = i; }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.textPrimary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary
                                  .withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        _picks[i].$2,
                        style: AppTypography.label.copyWith(
                          color: selected
                              ? Colors.black
                              : AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            // Chart
            SizedBox(
              height: 120,
              child: candles.isEmpty
                  ? Center(
                      child: Text(
                        'Noch kein Training für $exerciseName',
                        style: AppTypography.label,
                      ),
                    )
                  : CustomPaint(
                      size: Size.infinite,
                      painter: _MiniChartPainter(candles: candles),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Intercept tap so pill taps don't bubble up to the GestureDetector parent
extension on GestureDetector {
  // ignore: unused_element
}

class _MiniCandle {
  final DateTime date;
  final double open;
  final double close;

  const _MiniCandle(
      {required this.date, required this.open, required this.close});

  bool get isGreen => close > open;
  // green = progress, red = same or regressed
  Color get color =>
      isGreen ? const Color(0xFF4CAF50) : const Color(0xFFEF5350);
}

class _MiniChartPainter extends CustomPainter {
  final List<_MiniCandle> candles;

  _MiniChartPainter({required this.candles});

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    const leftPad = 0.0;
    const rightPad = 0.0;
    const topPad = 6.0;
    const bottomPad = 18.0;

    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - bottomPad;

    final allW = candles.expand((c) => [c.open, c.close]).toList();
    final minW = allW.reduce(math.min);
    final maxW = allW.reduce(math.max);
    final range = (maxW - minW).clamp(2.5, double.infinity);
    final yMin = minW - range * 0.15;
    final yMax = maxW + range * 0.15;
    final yRange = yMax - yMin;

    double toY(double w) =>
        topPad + chartH * (1 - (w - yMin) / yRange);
    double toX(int i) =>
        leftPad + (i + 0.5) * (chartW / candles.length);

    final n = candles.length;
    final slotW = chartW / n;
    final bodyW = (slotW * 0.55).clamp(4.0, 18.0);

    // Subtle grid
    final gridPaint = Paint()
      ..color = AppColors.timerRingBackground
      ..strokeWidth = 0.5;
    for (var g = 0; g <= 3; g++) {
      final y = topPad + chartH * g / 3;
      canvas.drawLine(Offset(leftPad, y), Offset(size.width, y), gridPaint);
    }

    // Candles
    for (var i = 0; i < n; i++) {
      final c = candles[i];
      final x = toX(i);
      final paint = Paint()..color = c.color;

      final openY = toY(c.open);
      final closeY = toY(c.close);
      final bodyTop = math.min(openY, closeY);
      final bodyH = (openY - closeY).abs().clamp(3.0, double.infinity);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - bodyW / 2, bodyTop, bodyW, bodyH),
          const Radius.circular(2),
        ),
        paint,
      );
    }

    // X labels (first and last)
    final labelStyle = TextStyle(
      color: AppColors.textSecondary,
      fontSize: 10,
      fontFamily: 'Inter',
    );

    void drawLabel(int i) {
      final d = candles[i].date;
      final text = '${d.day}.${d.month}';
      final tp = TextPainter(
        text: TextSpan(text: text, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = toX(i);
      tp.paint(
          canvas, Offset(x - tp.width / 2, size.height - bottomPad + 4));
    }

    drawLabel(0);
    if (n > 1) drawLabel(n - 1);
    if (n > 3) drawLabel(n ~/ 2);
  }

  @override
  bool shouldRepaint(_MiniChartPainter old) => old.candles != candles;
}
