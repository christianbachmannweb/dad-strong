import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/exercise.dart';
import '../../../providers/workout_session_provider.dart';
import '../../../widgets/effort_marker_widget.dart';
import '../../../widgets/scroll_picker_widget.dart';

class SetScreenWidget extends ConsumerWidget {
  const SetScreenWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(workoutSessionProvider);
    final notifier = ref.read(workoutSessionProvider.notifier);
    final ex = session.currentExercise;

    final sideLabel = ex.isBilateral
        ? (session.isFirstSide ? ' — Links' : ' — Rechts')
        : '';
    final setLabel =
        'Satz ${session.setIndex + 1} / ${ex.workSets}$sideLabel';

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(ex.name, style: AppTypography.headingMedium),
                const SizedBox(height: 4),
                Text(setLabel,
                    style: AppTypography.label),
                const SizedBox(height: 48),
                if (ex.isTimeBased)
                  _TimedSetInfo(ex: ex)
                else
                  _RepWeightPickers(
                    ex: ex,
                    session: session,
                    notifier: notifier,
                  ),
                const SizedBox(height: 32),
                EffortMarkerWidget(
                  current: session.selectedEffort,
                  onChanged: notifier.updateEffort,
                ),
                if (ex.repMin > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Zielbereich: ${ex.repMin}–${ex.repMax} Wdh.',
                      style: AppTypography.label,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
          child: GestureDetector(
            onTap: notifier.startRest,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.textPrimary),
              ),
              child: Text(
                'Fertig — Pause starten',
                style: AppTypography.headingMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimedSetInfo extends StatelessWidget {
  final Exercise ex;

  const _TimedSetInfo({required this.ex});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('60 Sekunden', style: AppTypography.displayLarge),
        const SizedBox(height: 8),
        Text('Tragen', style: AppTypography.label),
      ],
    );
  }
}

class _RepWeightPickers extends StatelessWidget {
  final Exercise ex;
  final WorkoutSessionState session;
  final WorkoutSessionNotifier notifier;

  const _RepWeightPickers({
    required this.ex,
    required this.session,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final reps = List.generate(ex.repMax + 5, (i) => '${i + 1}');
    final weights = _buildWeightList();

    final repIndex = (session.selectedReps - 1).clamp(0, reps.length - 1);
    final weightIndex = weights.indexWhere(
      (w) => (double.tryParse(w) ?? -1) == session.selectedWeight,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text('Wdh.', style: AppTypography.label),
            const SizedBox(height: 8),
            ScrollPickerWidget(
              items: reps,
              initialIndex: repIndex < 0 ? 0 : repIndex,
              onChanged: (i) => notifier.updateReps(i + 1),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Text('×',
            style: AppTypography.headingLarge
                .copyWith(color: AppColors.textSecondary)),
        const SizedBox(width: 16),
        Column(
          children: [
            Text('Gewicht (kg)', style: AppTypography.label),
            const SizedBox(height: 8),
            ScrollPickerWidget(
              items: weights,
              initialIndex: weightIndex < 0 ? 0 : weightIndex,
              onChanged: (i) =>
                  notifier.updateWeight(double.parse(weights[i])),
              width: 140,
            ),
          ],
        ),
      ],
    );
  }

  List<String> _buildWeightList() {
    final list = <String>[];
    if (ex.type == ExerciseType.bodyweight) {
      return ['BK'];
    }
    // 2.5 kg increments from 0 to 200
    for (var w = 0.0; w <= 200.0; w += 2.5) {
      list.add(w == w.toInt() ? w.toInt().toString() : w.toString());
    }
    return list;
  }
}
