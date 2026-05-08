import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/exercise.dart';
import '../../../providers/rest_timer_provider.dart';
import '../../../providers/workout_session_provider.dart';
import '../../../widgets/effort_marker_widget.dart';
import '../../../widgets/ring_timer_widget.dart';
import '../../../widgets/scroll_picker_widget.dart';

class RestScreenWidget extends ConsumerWidget {
  final bool isBilateral;

  const RestScreenWidget({super.key, this.isBilateral = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(restTimerProvider);
    final session = ref.watch(workoutSessionProvider);
    final notifier = ref.read(workoutSessionProvider.notifier);
    final ex = session.currentExercise;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          Text(
            isBilateral ? 'Seitenwechsel' : 'Pause',
            style: AppTypography.headingMedium,
          ),
          if (!isBilateral)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(ex.name, style: AppTypography.label),
            ),
          const SizedBox(height: 24),
          RingTimerWidget(
            remainingSeconds: timer.remainingSeconds,
            progress: timer.progress,
          ),
          // Input section — only during main rest, not bilateral
          if (!isBilateral) ...[
            const SizedBox(height: 32),
            Text('Was hast du gemacht?', style: AppTypography.label),
            const SizedBox(height: 16),
            if (ex.isTimeBased)
              Text(
                '60 Sekunden Carry',
                style: AppTypography.headingMedium,
              )
            else
              _RepWeightPickers(ex: ex, session: session, notifier: notifier),
            const SizedBox(height: 20),
            EffortMarkerWidget(
              current: session.selectedEffort,
              onChanged: notifier.updateEffort,
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
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
    if (ex.type == ExerciseType.bodyweight) {
      // Just rep picker, no weight
      final reps = List.generate(30, (i) => '${i + 1}');
      final repIndex = (session.selectedReps - 1).clamp(0, reps.length - 1);
      return Column(
        children: [
          Text('Wdh.', style: AppTypography.label),
          const SizedBox(height: 8),
          ScrollPickerWidget(
            items: reps,
            initialIndex: repIndex < 0 ? 0 : repIndex,
            onChanged: (i) => notifier.updateReps(i + 1),
          ),
        ],
      );
    }

    final reps = List.generate(ex.repMax + 8, (i) => '${i + 1}');
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
        const SizedBox(width: 12),
        Text('×',
            style: AppTypography.headingLarge
                .copyWith(color: AppColors.textSecondary)),
        const SizedBox(width: 12),
        Column(
          children: [
            Text(
              ex.type == ExerciseType.dumbbell ? 'kg pro KH' : 'Gewicht (kg)',
              style: AppTypography.label,
            ),
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
    for (var w = 0.0; w <= 200.0; w += 2.5) {
      list.add(w == w.toInt() ? w.toInt().toString() : w.toString());
    }
    return list;
  }
}
