import 'exercise_log.dart';
import 'training_type.dart';

class WorkoutSession {
  final String id;
  final TrainingType type;
  final DateTime date;
  final int totalDurationSeconds;
  final List<ExerciseLog> exerciseLogs;

  const WorkoutSession({
    required this.id,
    required this.type,
    required this.date,
    required this.totalDurationSeconds,
    required this.exerciseLogs,
  });

  ExerciseLog? logFor(String exerciseId) {
    try {
      return exerciseLogs.firstWhere((l) => l.exerciseId == exerciseId);
    } catch (_) {
      return null;
    }
  }
}
