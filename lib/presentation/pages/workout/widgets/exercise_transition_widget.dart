import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../providers/rest_timer_provider.dart';
import '../../../providers/workout_session_provider.dart';
import '../../../widgets/ring_timer_widget.dart';

class ExerciseTransitionWidget extends ConsumerWidget {
  const ExerciseTransitionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(restTimerProvider);
    final session = ref.watch(workoutSessionProvider);
    final nextEx = session.currentExercise;
    final advice = session.currentAdvice;
    final targetWeight = advice?.recommendedWeight ?? 0.0;
    final canProgress = advice?.canProgress ?? false;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Nächste Übung', style: AppTypography.label),
            const SizedBox(height: 8),
            Text(nextEx.name,
                style: AppTypography.headingLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 32),
            RingTimerWidget(
              remainingSeconds: timer.remainingSeconds,
              progress: timer.progress,
              size: 220,
            ),
            const SizedBox(height: 32),
            // Weight loading info
            if (targetWeight > 0 && !nextEx.isTimeBased) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: canProgress
                      ? const Color(0xFF1A2E1A)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: canProgress
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.6)
                        : AppColors.timerRingBackground,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Stange aufladen auf',
                      style: AppTypography.label.copyWith(
                        color: canProgress
                            ? const Color(0xFF4CAF50)
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _weightStr(targetWeight),
                      style: AppTypography.headingLarge.copyWith(
                        color: canProgress
                            ? const Color(0xFF4CAF50)
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (canProgress && advice != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '+${_weightStr(advice.progressionKg)} gegenüber letztem Mal',
                          style: AppTypography.label,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _weightStr(double w) =>
      '${w % 1 == 0 ? w.toInt() : w} kg';
}
