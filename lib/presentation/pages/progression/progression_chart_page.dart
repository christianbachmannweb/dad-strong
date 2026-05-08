import 'dart:math' as math;
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/exercises_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/workout_session.dart';
import '../../providers/training_history_provider.dart';

// ─── Data model ───────────────────────────────────────────────────────────────

class _Candle {
  final DateTime date;
  final double open;   // previous session best weight
  final double close;  // this session best weight
  final double high;   // max weight in session
  final double low;    // min weight in session
  final int bestReps;

  const _Candle({
    required this.date,
    required this.open,
    required this.close,
    required this.high,
    required this.low,
    required this.bestReps,
  });

  bool get isGreen => close >= open;
  Color get color => close > open
      ? const Color(0xFF4CAF50)
      : close < open
          ? const Color(0xFFEF5350)
          : const Color(0xFF888888);
}

enum _Range { w4, w12, m6, all }

extension on _Range {
  String get label => switch (this) {
        _Range.w4 => '4 Wochen',
        _Range.w12 => '12 Wochen',
        _Range.m6 => '6 Monate',
        _Range.all => 'Gesamt',
      };

  DateTime? get cutoff {
    final now = DateTime.now();
    return switch (this) {
      _Range.w4 => now.subtract(const Duration(days: 28)),
      _Range.w12 => now.subtract(const Duration(days: 84)),
      _Range.m6 => DateTime(now.year, now.month - 6, now.day),
      _Range.all => null,
    };
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────

@RoutePage()
class ProgressionChartPage extends ConsumerStatefulWidget {
  const ProgressionChartPage({super.key});

  @override
  ConsumerState<ProgressionChartPage> createState() =>
      _ProgressionChartPageState();
}

class _ProgressionChartPageState
    extends ConsumerState<ProgressionChartPage> {
  _Range _range = _Range.w12;
  int _exerciseIndex = 0;

  static final _allExercises = [
    ...ExercisesData.trainingA,
    ...ExercisesData.trainingB,
  ];

  Exercise get _exercise => _allExercises[_exerciseIndex];

  List<_Candle> _buildCandles(
      List<WorkoutSession> sessions, Exercise ex) {
    final cutoff = _range.cutoff;
    final relevant = sessions
        .where((s) => s.logFor(ex.id) != null)
        .where((s) => cutoff == null || s.date.isAfter(cutoff))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (relevant.isEmpty) return [];

    final candles = <_Candle>[];
    double prevBest = 0;

    for (final session in relevant) {
      final log = session.logFor(ex.id)!;
      if (log.sets.isEmpty) continue;

      final weights = log.sets.map((s) => s.weightKg).toList();
      final high = weights.reduce(math.max);
      final low = weights.reduce(math.min);
      final best = high;
      final bestReps = log.sets
          .firstWhere((s) => s.weightKg == best,
              orElse: () => log.sets.first)
          .reps;

      candles.add(_Candle(
        date: session.date,
        open: prevBest == 0 ? best : prevBest,
        close: best,
        high: high,
        low: low,
        bestReps: bestReps,
      ));
      prevBest = best;
    }
    return candles;
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(trainingHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: Text('Progression', style: AppTypography.bodyLarge),
        elevation: 0,
      ),
      body: SafeArea(
        child: historyAsync.when(
          data: (sessions) {
            final candles = _buildCandles(sessions, _exercise);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise pills
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _allExercises.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => _Pill(
                      label: _allExercises[i].name,
                      selected: i == _exerciseIndex,
                      onTap: () => setState(() => _exerciseIndex = i),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Chart
                Expanded(
                  child: candles.isEmpty
                      ? Center(
                          child: Text(
                            'Noch keine Daten für ${_exercise.name}',
                            style: AppTypography.bodyLarge
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _CandlestickChart(candles: candles),
                        ),
                ),
                const SizedBox(height: 16),
                // Range pills
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _Range.values
                          .map((r) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _Pill(
                                  label: r.label,
                                  selected: r == _range,
                                  onTap: () => setState(() => _range = r),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.textPrimary),
          ),
          error: (e, _) => Center(
            child: Text('Fehler: $e',
                style:
                    AppTypography.bodyMedium.copyWith(color: Colors.redAccent)),
          ),
        ),
      ),
    );
  }
}

// ─── Pill chip ─────────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Pill(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.textPrimary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTypography.label.copyWith(
            color: selected ? Colors.black : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ─── Candlestick chart ─────────────────────────────────────────────────────────

class _CandlestickChart extends StatefulWidget {
  final List<_Candle> candles;

  const _CandlestickChart({required this.candles});

  @override
  State<_CandlestickChart> createState() => _CandlestickChartState();
}

class _CandlestickChartState extends State<_CandlestickChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final selected =
        _selectedIndex != null ? widget.candles[_selectedIndex!] : null;

    return Column(
      children: [
        // Tooltip
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 48,
          child: selected == null
              ? const SizedBox.shrink()
              : Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_formatDate(selected.date),
                          style: AppTypography.label),
                      const SizedBox(width: 16),
                      Text(
                        '${selected.close.toStringAsFixed(selected.close % 1 == 0 ? 0 : 1)} kg',
                        style: AppTypography.bodyLarge
                            .copyWith(color: selected.color),
                      ),
                      if (selected.bestReps > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '× ${selected.bestReps} Wdh.',
                          style: AppTypography.label,
                        ),
                      ],
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 8),
        // Chart area
        Expanded(
          child: GestureDetector(
            onTapDown: (details) => _onTap(details.localPosition),
            onPanUpdate: (details) => _onTap(details.localPosition),
            onPanEnd: (_) {},
            child: CustomPaint(
              painter: _ChartPainter(
                candles: widget.candles,
                selectedIndex: _selectedIndex,
              ),
              size: Size.infinite,
            ),
          ),
        ),
      ],
    );
  }

  void _onTap(Offset localPos) {
    // Let the painter compute which candle is nearest
    setState(() {
      // painter will handle via selected index; we compute it here
      _selectedIndex = null; // reset to force repaint lookup
    });

    const leftPad = 44.0;
    const rightPad = 8.0;

    final count = widget.candles.length;
    if (count == 0) return;

    // We can't get the RenderBox size here directly without a key,
    // so we use the context's size
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final size = box.size;
    final chartWidth = size.width - leftPad - rightPad;
    final slotWidth = chartWidth / count;

    final rawIndex =
        ((localPos.dx - leftPad) / slotWidth).floor().clamp(0, count - 1);
    setState(() => _selectedIndex = rawIndex);
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun',
      'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez'
    ];
    return '${d.day}. ${months[d.month - 1]}';
  }
}

// ─── CustomPainter ─────────────────────────────────────────────────────────────

class _ChartPainter extends CustomPainter {
  final List<_Candle> candles;
  final int? selectedIndex;

  _ChartPainter({required this.candles, this.selectedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    const leftPad = 44.0;
    const rightPad = 8.0;
    const topPad = 12.0;
    const bottomPad = 28.0;

    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - bottomPad;

    // Y range
    final allWeights = candles
        .expand((c) => [c.open, c.close, c.high, c.low])
        .where((w) => w > 0)
        .toList();
    if (allWeights.isEmpty) return;

    final minW = allWeights.reduce(math.min);
    final maxW = allWeights.reduce(math.max);
    final range = (maxW - minW).clamp(5.0, double.infinity);
    final yMin = minW - range * 0.1;
    final yMax = maxW + range * 0.1;
    final yRange = yMax - yMin;

    double toY(double w) =>
        topPad + chartH * (1 - (w - yMin) / yRange);
    double toX(int i) =>
        leftPad + (i + 0.5) * (chartW / candles.length);

    // Grid lines + Y labels
    final gridPaint = Paint()
      ..color = AppColors.timerRingBackground
      ..strokeWidth = 0.5;
    final labelStyle = AppTypography.label.copyWith(
      fontSize: 11,
      color: AppColors.textSecondary,
    );

    const gridCount = 5;
    for (var g = 0; g <= gridCount; g++) {
      final w = yMin + yRange * g / gridCount;
      final y = toY(w);
      canvas.drawLine(
          Offset(leftPad, y), Offset(size.width - rightPad, y), gridPaint);

      // Y label
      final tp = TextPainter(
        text: TextSpan(
          text: '${w.round()} kg',
          style: labelStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: leftPad - 4);
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // X axis labels (show every Nth depending on candle count)
    final n = candles.length;
    final xStep = (n / 5).ceil().clamp(1, n);
    for (var i = 0; i < n; i += xStep) {
      final c = candles[i];
      final x = toX(i);
      final tp = TextPainter(
        text: TextSpan(text: _shortDate(c.date), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
          canvas, Offset(x - tp.width / 2, size.height - bottomPad + 4));
    }

    // Candles
    final slotW = chartW / n;
    final bodyW = (slotW * 0.5).clamp(3.0, 14.0);
    final wickW = 1.5;

    for (var i = 0; i < n; i++) {
      final c = candles[i];
      final x = toX(i);
      final isSelected = i == selectedIndex;

      final paint = Paint()
        ..color = isSelected
            ? c.color
            : c.color.withValues(alpha: 0.85)
        ..strokeWidth = wickW;

      // Wick (high to low)
      final highY = toY(c.high);
      final lowY = toY(c.low);
      canvas.drawLine(Offset(x, highY), Offset(x, lowY), paint);

      // Body
      final openY = toY(c.open);
      final closeY = toY(c.close);
      final bodyTop = math.min(openY, closeY);
      final bodyBottom = math.max(openY, closeY);
      final bodyHeight = (bodyBottom - bodyTop).clamp(2.0, double.infinity);

      if (isSelected) {
        // Selection highlight
        canvas.drawRect(
          Rect.fromLTWH(x - bodyW / 2 - 2, bodyTop - 2,
              bodyW + 4, bodyHeight + 4),
          Paint()..color = c.color.withValues(alpha: 0.15),
        );
      }

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - bodyW / 2, bodyTop, bodyW, bodyHeight),
          const Radius.circular(2),
        ),
        Paint()..color = c.color,
      );
    }
  }

  String _shortDate(DateTime d) {
    const months = [
      'J', 'F', 'M', 'A', 'M', 'J',
      'J', 'A', 'S', 'O', 'N', 'D'
    ];
    return '${d.day}.${months[d.month - 1]}';
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.candles != candles || old.selectedIndex != selectedIndex;
}
