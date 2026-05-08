import '../../domain/entities/exercise.dart';
import '../../domain/entities/exercise_log.dart';
import 'warmup_calculator.dart';

class ProgressionAdvice {
  final double recommendedWeight;
  final bool canProgress;
  final double progressionKg;
  final double progressionPercent;
  final double lastWeight;
  final int lastBestReps;

  const ProgressionAdvice({
    required this.recommendedWeight,
    required this.canProgress,
    required this.progressionKg,
    required this.progressionPercent,
    required this.lastWeight,
    required this.lastBestReps,
  });
}

ProgressionAdvice calculateProgression(Exercise ex, ExerciseLog? lastLog) {
  if (lastLog == null || lastLog.sets.isEmpty) {
    final defaultWeight = ex.type == ExerciseType.barbell ? 20.0 : 10.0;
    return ProgressionAdvice(
      recommendedWeight: defaultWeight,
      canProgress: false,
      progressionKg: 0,
      progressionPercent: 0,
      lastWeight: 0,
      lastBestReps: 0,
    );
  }

  final lastWeight = lastLog.bestWeightKg;
  final lastBestReps = lastLog.bestReps;

  // Can progress only if ALL working sets hit the progression threshold
  final threshold = ex.progressionThreshold;
  final allSetsHitThreshold = threshold > 0 &&
      lastLog.sets.every((s) => s.reps >= threshold);

  if (!allSetsHitThreshold || threshold == 0) {
    return ProgressionAdvice(
      recommendedWeight: lastWeight,
      canProgress: false,
      progressionKg: 0,
      progressionPercent: 0,
      lastWeight: lastWeight,
      lastBestReps: lastBestReps,
    );
  }

  // Progression percentages based on exercise type and muscle group
  // Lower body (larger muscles) progress faster; upper body slower
  final pct = _progressionPercent(ex);
  final rawNext = lastWeight * (1 + pct);
  final nextWeight = roundToNearest2_5(rawNext).clamp(20.0, 500.0);
  final delta = nextWeight - lastWeight;

  return ProgressionAdvice(
    recommendedWeight: nextWeight,
    canProgress: true,
    progressionKg: delta,
    progressionPercent: pct * 100,
    lastWeight: lastWeight,
    lastBestReps: lastBestReps,
  );
}

double _progressionPercent(Exercise ex) {
  if (ex.type == ExerciseType.bodyweight) return 0;
  if (ex.type == ExerciseType.timedCarry) return 0.03;

  // Lower body barbell: squat, deadlift — bigger muscles, bigger jumps
  if (ex.id == 'squat' || ex.id == 'deadlift') return 0.05;

  // Upper body barbell: bench, ohp, row — 2.5%
  if (ex.type == ExerciseType.barbell) return 0.025;

  // Dumbbells
  if (ex.type == ExerciseType.dumbbell) return 0.04;

  return 0.025;
}
