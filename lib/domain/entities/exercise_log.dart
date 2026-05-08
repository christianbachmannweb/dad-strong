import 'workout_set.dart';

class ExerciseLog {
  final String exerciseId;
  final List<WorkoutSet> sets;

  const ExerciseLog({required this.exerciseId, required this.sets});

  double get bestWeightKg => sets.isEmpty
      ? 0
      : sets.map((s) => s.weightKg).reduce((a, b) => a > b ? a : b);

  int get bestReps => sets.isEmpty
      ? 0
      : sets.map((s) => s.reps).reduce((a, b) => a > b ? a : b);
}
