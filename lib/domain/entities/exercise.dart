enum ExerciseType { barbell, dumbbell, bodyweight, timedCarry }

class Exercise {
  final String id;
  final String name;
  final int workSets;
  final int repMin;
  final int repMax;
  final int progressionThreshold;
  final ExerciseType type;
  final bool isBilateral;
  final bool isTimeBased;
  // 0 = no warmup, 2 = short (60%×5 + 80%×3), 5 = full (bar + 50/70/70/90%)
  final int specificWarmupSets;

  const Exercise({
    required this.id,
    required this.name,
    required this.workSets,
    required this.repMin,
    required this.repMax,
    required this.progressionThreshold,
    required this.type,
    this.isBilateral = false,
    this.isTimeBased = false,
    this.specificWarmupSets = 0,
  });

  bool get hasSpecificWarmup => specificWarmupSets > 0;
}
