import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/progression_calculator.dart';
import '../../../providers/workout_session_provider.dart';

class PreSetAdviceWidget extends ConsumerWidget {
  const PreSetAdviceWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(workoutSessionProvider);
    final notifier = ref.read(workoutSessionProvider.notifier);
    final ex = session.currentExercise;
    final advice = session.currentAdvice;
    final setLabel = ex.workSets > 1
        ? '${ex.workSets} Arbeitssätze · ${ex.repMin}–${ex.repMax} Wdh.'
        : '${ex.workSets} Arbeitssatz · ${ex.repMin}–${ex.repMax} Wdh.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(ex.name, style: AppTypography.headingLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            if (!ex.isTimeBased)
              Text(setLabel,
                  style: AppTypography.label, textAlign: TextAlign.center),
            const SizedBox(height: 48),

            // Last session info
            if (advice != null && advice.lastWeight > 0) ...[
              _InfoCard(
                label: 'Letztes Mal',
                value: advice.lastBestReps > 0
                    ? '${_weightStr(advice.lastWeight)} × ${advice.lastBestReps} Wdh.'
                    : _weightStr(advice.lastWeight),
              ),
              const SizedBox(height: 12),
            ],

            // Recommendation
            if (advice != null) ...[
              advice.canProgress
                  ? _ProgressionCard(advice: advice)
                  : _SameWeightCard(
                      weight: advice.recommendedWeight,
                      lastBestReps: advice.lastBestReps,
                      progressionThreshold: ex.progressionThreshold,
                    ),
            ] else
              _SameWeightCard(
                  weight: 20, lastBestReps: 0, progressionThreshold: 0),

            const SizedBox(height: 64),

            GestureDetector(
              onTap: notifier.advanceFromAdvice,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.textPrimary),
                ),
                child: Text(
                  'Los geht\'s',
                  style: AppTypography.headingMedium,
                  textAlign: TextAlign.center,
                ),
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

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;

  const _InfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(label, style: AppTypography.label),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.headingMedium),
        ],
      ),
    );
  }
}

class _ProgressionCard extends StatelessWidget {
  final ProgressionAdvice advice;

  const _ProgressionCard({required this.advice});

  @override
  Widget build(BuildContext context) {
    final deltaStr = advice.progressionKg % 1 == 0
        ? '+${advice.progressionKg.toInt()} kg'
        : '+${advice.progressionKg} kg';
    final weightStr = advice.recommendedWeight % 1 == 0
        ? '${advice.recommendedWeight.toInt()} kg'
        : '${advice.recommendedWeight} kg';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          Text(
            'Du kannst steigern! 💪',
            style: AppTypography.label
                .copyWith(color: const Color(0xFF4CAF50)),
          ),
          const SizedBox(height: 8),
          Text(
            weightStr,
            style: AppTypography.headingLarge
                .copyWith(color: const Color(0xFF4CAF50)),
          ),
          const SizedBox(height: 4),
          Text(
            '$deltaStr · ${advice.progressionPercent.toStringAsFixed(1)}%',
            style: AppTypography.label,
          ),
        ],
      ),
    );
  }
}

class _SameWeightCard extends StatelessWidget {
  final double weight;
  final int lastBestReps;
  final int progressionThreshold;

  const _SameWeightCard({
    required this.weight,
    required this.lastBestReps,
    required this.progressionThreshold,
  });

  String get _motivationText {
    if (lastBestReps == 0) return 'Erste Session — leg los!';
    final nextTarget = lastBestReps + 1;
    final repsToGo = progressionThreshold - lastBestReps;
    if (repsToGo <= 1) {
      return 'Noch 1 Wdh bis zur Steigerung — schaffst du heute $nextTarget?';
    }
    if (repsToGo == 2) {
      return 'Nah dran! Peile heute $nextTarget Wdh an.';
    }
    return 'Letztes Mal $lastBestReps Wdh — heute $nextTarget anpeilen!';
  }

  @override
  Widget build(BuildContext context) {
    final weightStr =
        weight % 1 == 0 ? '${weight.toInt()} kg' : '$weight kg';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            lastBestReps > 0 ? 'Gleiches Gewicht' : 'Startgewicht',
            style: AppTypography.label,
          ),
          const SizedBox(height: 8),
          Text(weightStr, style: AppTypography.headingLarge),
          const SizedBox(height: 8),
          Text(
            _motivationText,
            style: AppTypography.label,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
