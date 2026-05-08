import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/exercise_log.dart';
import '../../../domain/entities/training_type.dart';
import '../../../domain/entities/workout_session.dart';
import '../../../domain/usecases/save_workout_session.dart';
import '../../providers/workout_repository_provider.dart';
import 'package:uuid/uuid.dart';

@RoutePage()
class SummaryPage extends ConsumerStatefulWidget {
  final List<ExerciseLog> completedLogs;
  final TrainingType trainingType;
  final int durationSeconds;

  const SummaryPage({
    super.key,
    required this.completedLogs,
    required this.trainingType,
    required this.durationSeconds,
  });

  @override
  ConsumerState<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends ConsumerState<SummaryPage> {
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _saveSession();
  }

  Future<void> _saveSession() async {
    if (_saved) return;
    _saved = true;
    final session = WorkoutSession(
      id: const Uuid().v4(),
      type: widget.trainingType,
      date: DateTime.now(),
      totalDurationSeconds: widget.durationSeconds,
      exerciseLogs: widget.completedLogs,
    );
    final repo = ref.read(workoutRepositoryProvider);
    await SaveWorkoutSession(repo).execute(session);
  }

  @override
  Widget build(BuildContext context) {
    final minutes = widget.durationSeconds ~/ 60;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Training ${widget.trainingType.label} abgeschlossen',
                  style: AppTypography.headingLarge),
              const SizedBox(height: 8),
              Text('$minutes Minuten', style: AppTypography.label),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: widget.completedLogs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (_, i) {
                    final log = widget.completedLogs[i];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.exerciseId,
                            style: AppTypography.bodyLarge),
                        const SizedBox(height: 4),
                        ...log.sets.map((s) => Padding(
                              padding: const EdgeInsets.only(left: 16, top: 2),
                              child: Text(s.displayLabel,
                                  style: AppTypography.label),
                            )),
                      ],
                    );
                  },
                ),
              ),
              GestureDetector(
                onTap: () =>
                    context.router.popUntilRoot(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.textPrimary),
                  ),
                  child: Text(
                    'Fertig',
                    style: AppTypography.headingMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
