import 'package:uuid/uuid.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/training_type.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/entities/workout_set.dart';

final _uuid = Uuid();

WorkoutSession seedSessionA() => WorkoutSession(
      id: _uuid.v4(),
      type: TrainingType.a,
      date: DateTime(2026, 5, 5),
      totalDurationSeconds: 3900,
      exerciseLogs: [
        ExerciseLog(exerciseId: 'squat', sets: [
          const WorkoutSet(setIndex: 0, reps: 6, weightKg: 100),
          const WorkoutSet(setIndex: 1, reps: 5, weightKg: 100),
        ]),
        ExerciseLog(exerciseId: 'bench', sets: [
          const WorkoutSet(setIndex: 0, reps: 8, weightKg: 100),
          const WorkoutSet(setIndex: 1, reps: 8, weightKg: 100),
        ]),
        ExerciseLog(exerciseId: 'row', sets: [
          const WorkoutSet(setIndex: 0, reps: 8, weightKg: 100),
          const WorkoutSet(setIndex: 1, reps: 8, weightKg: 100),
        ]),
        ExerciseLog(exerciseId: 'bss', sets: [
          const WorkoutSet(setIndex: 0, reps: 3, weightKg: 60),
          const WorkoutSet(setIndex: 1, reps: 3, weightKg: 60),
        ]),
        ExerciseLog(exerciseId: 'farmer', sets: [
          const WorkoutSet(setIndex: 0, reps: 0, weightKg: 20, durationSeconds: 60),
          const WorkoutSet(setIndex: 1, reps: 0, weightKg: 20, durationSeconds: 60),
        ]),
      ],
    );

WorkoutSession seedSessionB() => WorkoutSession(
      id: _uuid.v4(),
      type: TrainingType.b,
      date: DateTime(2026, 5, 1),
      totalDurationSeconds: 3600,
      exerciseLogs: [
        ExerciseLog(exerciseId: 'deadlift', sets: [
          const WorkoutSet(setIndex: 0, reps: 6, weightKg: 100),
          const WorkoutSet(setIndex: 1, reps: 6, weightKg: 100),
        ]),
        ExerciseLog(exerciseId: 'ohp', sets: [
          const WorkoutSet(setIndex: 0, reps: 8, weightKg: 100),
          const WorkoutSet(setIndex: 1, reps: 8, weightKg: 100),
        ]),
        ExerciseLog(exerciseId: 'pullup', sets: [
          const WorkoutSet(setIndex: 0, reps: 8, weightKg: 0),
          const WorkoutSet(setIndex: 1, reps: 8, weightKg: 0),
        ]),
        ExerciseLog(exerciseId: 'stepup', sets: [
          const WorkoutSet(setIndex: 0, reps: 3, weightKg: 60),
          const WorkoutSet(setIndex: 1, reps: 3, weightKg: 60),
        ]),
      ],
    );
