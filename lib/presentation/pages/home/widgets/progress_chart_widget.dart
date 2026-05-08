import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class ProgressChartWidget extends StatelessWidget {
  /// exerciseId → percentage change (positive = progress)
  final Map<String, double> progress;

  const ProgressChartWidget({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    if (progress.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.timerRingBackground),
        ),
        child: Text(
          'Kein Fortschritt für diesen Monat',
          style: AppTypography.label,
        ),
      );
    }

    final maxAbs =
        progress.values.map((v) => v.abs()).reduce(math.max).clamp(1.0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.timerRingBackground),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fortschritt diesen Monat', style: AppTypography.label),
          const SizedBox(height: 12),
          ...progress.entries.map((e) {
            final pct = e.value;
            final barFraction = pct.abs() / maxAbs;
            final isPositive = pct >= 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.key,
                          style: AppTypography.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${isPositive ? '+' : ''}${pct.toStringAsFixed(1)}%',
                        style: AppTypography.label.copyWith(
                          color: isPositive
                              ? Colors.greenAccent
                              : Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: barFraction,
                      minHeight: 4,
                      backgroundColor: AppColors.timerRingBackground,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isPositive ? Colors.greenAccent : Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
