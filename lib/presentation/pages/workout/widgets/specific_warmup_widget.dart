import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/warmup_calculator.dart';
import '../../../../domain/entities/exercise.dart';

class SpecificWarmupWidget extends StatefulWidget {
  final Exercise exercise;
  final double lastWeightKg;
  final VoidCallback onComplete;

  const SpecificWarmupWidget({
    super.key,
    required this.exercise,
    required this.lastWeightKg,
    required this.onComplete,
  });

  @override
  State<SpecificWarmupWidget> createState() => _SpecificWarmupWidgetState();
}

class _SpecificWarmupWidgetState extends State<SpecificWarmupWidget> {
  late List<WarmupStep> _steps;
  int _stepIndex = 0;

  @override
  void initState() {
    super.initState();
    _steps = widget.exercise.specificWarmupSets == 2
        ? calculateShortWarmupSteps(widget.lastWeightKg)
        : calculateWarmupSteps(widget.lastWeightKg);
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_stepIndex];
    final isLast = _stepIndex == _steps.length - 1;
    final total = _steps.length;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Spezifisches Aufwärmen', style: AppTypography.label),
            const SizedBox(height: 8),
            Text(widget.exercise.name, style: AppTypography.headingMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 40),
            // Step indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(total, (i) => Container(
                width: i == _stepIndex ? 20 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: i == _stepIndex
                      ? AppColors.textPrimary
                      : AppColors.timerRingBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
            const SizedBox(height: 32),
            Text(
              '${ _stepIndex + 1} / $total',
              style: AppTypography.label,
            ),
            const SizedBox(height: 12),
            Text(
              _weightStr(step.weightKg),
              style: AppTypography.displayLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${step.repsLabel} Wdh.',
              style: AppTypography.headingMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 56),
            GestureDetector(
              onTap: () {
                if (isLast) {
                  widget.onComplete();
                } else {
                  setState(() => _stepIndex++);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 48, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.textPrimary),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isLast ? 'Fertig →' : 'Nächster Satz →',
                  style: AppTypography.headingMedium,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_stepIndex > 0)
              TextButton(
                onPressed: () => setState(() => _stepIndex--),
                child: Text(
                  'Zurück',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _weightStr(double w) =>
      '${w % 1 == 0 ? w.toInt() : w} kg';
}
