import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/exercise.dart';
import '../../../providers/workout_session_provider.dart';

class ActiveSetWidget extends ConsumerWidget {
  const ActiveSetWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(workoutSessionProvider);
    final notifier = ref.read(workoutSessionProvider.notifier);
    final ex = session.currentExercise;

    final sideLabel = ex.isBilateral
        ? (session.isFirstSide ? ' · Links' : ' · Rechts')
        : '';
    final setLabel = ex.workSets > 1
        ? 'Satz ${session.setIndex + 1} / ${ex.workSets}$sideLabel'
        : 'Arbeitssatz$sideLabel';

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            children: [
              Text(ex.name, style: AppTypography.headingMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(setLabel, style: AppTypography.label),
            ],
          ),
        ),
        // Big center done button
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: notifier.startRest,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.textPrimary,
                    width: 2,
                  ),
                  color: AppColors.surface,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Fertig',
                        style: AppTypography.headingMedium),
                    const SizedBox(height: 4),
                    Text('→ Pause',
                        style: AppTypography.label),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Target weight reminder at bottom
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
          child: Text(
            'Ziel: ${_weightStr(session.selectedWeight)}${ex.type == ExerciseType.dumbbell ? ' pro KH' : ''} · ${ex.repMin}–${ex.repMax} Wdh.',
            style: AppTypography.label,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  String _weightStr(double w) =>
      '${w % 1 == 0 ? w.toInt() : w} kg';
}
