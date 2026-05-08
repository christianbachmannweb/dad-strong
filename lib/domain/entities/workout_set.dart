import 'effort_level.dart';

class WorkoutSet {
  final int setIndex;
  final int reps;
  final double weightKg;
  final int durationSeconds;
  final EffortLevel effort;

  const WorkoutSet({
    required this.setIndex,
    required this.reps,
    required this.weightKg,
    this.durationSeconds = 0,
    this.effort = EffortLevel.none,
  });

  String get displayLabel {
    final effortSuffix =
        effort == EffortLevel.none ? '' : ' ${effort.label}';
    if (durationSeconds > 0) {
      final weightStr = weightKg == 0
          ? 'BK'
          : '${weightKg % 1 == 0 ? weightKg.toInt() : weightKg} kg';
      return '${durationSeconds}s × $weightStr$effortSuffix';
    }
    final weightStr = weightKg == 0
        ? 'BK'
        : '${weightKg % 1 == 0 ? weightKg.toInt() : weightKg} kg';
    return '$reps × $weightStr$effortSuffix';
  }
}
