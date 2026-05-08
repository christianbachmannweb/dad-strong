import '../../domain/entities/exercise.dart';
import '../../domain/entities/training_type.dart';

abstract final class ExercisesData {
  static const List<Exercise> trainingA = [
    Exercise(
      id: 'squat',
      name: 'LH-Kniebeuge',
      workSets: 2,
      repMin: 4,
      repMax: 8,
      progressionThreshold: 8,
      type: ExerciseType.barbell,
      specificWarmupSets: 5, // full: bar + 50/70/70/90%
    ),
    Exercise(
      id: 'bench',
      name: 'LH-Bankdrücken',
      workSets: 2,
      repMin: 4,
      repMax: 8,
      progressionThreshold: 8,
      type: ExerciseType.barbell,
      specificWarmupSets: 2, // short: 60% × 5 + 80% × 3
    ),
    Exercise(
      id: 'row',
      name: 'LH-Rudern',
      workSets: 2,
      repMin: 4,
      repMax: 8,
      progressionThreshold: 8,
      type: ExerciseType.barbell,
      specificWarmupSets: 2,
    ),
    Exercise(
      id: 'bss',
      name: 'KH-Bulg. Split Squat',
      workSets: 1,
      repMin: 6,
      repMax: 10,
      progressionThreshold: 10,
      type: ExerciseType.dumbbell,
      isBilateral: true,
    ),
    Exercise(
      id: 'farmer',
      name: 'Farmer Walk',
      workSets: 1,
      repMin: 0,
      repMax: 0,
      progressionThreshold: 0,
      type: ExerciseType.timedCarry,
      isBilateral: true,
      isTimeBased: true,
    ),
  ];

  static const List<Exercise> trainingB = [
    Exercise(
      id: 'deadlift',
      name: 'LH-Kreuzheben',
      workSets: 2,
      repMin: 4,
      repMax: 6,
      progressionThreshold: 6,
      type: ExerciseType.barbell,
      specificWarmupSets: 5, // full: bar + 50/70/70/90%
    ),
    Exercise(
      id: 'ohp',
      name: 'LH-Schulterdrücken',
      workSets: 2,
      repMin: 4,
      repMax: 8,
      progressionThreshold: 8,
      type: ExerciseType.barbell,
      specificWarmupSets: 2, // short: 60% × 5 + 80% × 3
    ),
    Exercise(
      id: 'pullup',
      name: 'Klimmzüge',
      workSets: 2,
      repMin: 6,
      repMax: 10,
      progressionThreshold: 10,
      type: ExerciseType.bodyweight,
    ),
    Exercise(
      id: 'stepup',
      name: 'KH-Step-Up',
      workSets: 1,
      repMin: 6,
      repMax: 10,
      progressionThreshold: 10,
      type: ExerciseType.dumbbell,
      isBilateral: true,
    ),
  ];

  static List<Exercise> forType(TrainingType type) =>
      type == TrainingType.a ? trainingA : trainingB;
}
