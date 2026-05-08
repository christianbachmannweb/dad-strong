import '../entities/training_type.dart';
import '../entities/workout_session.dart';

abstract interface class WorkoutRepository {
  Future<void> saveSession(WorkoutSession session);
  Future<List<WorkoutSession>> getAllSessions();
  Future<WorkoutSession?> getLastSessionForType(TrainingType type);
  Future<bool> isFirstRun();
  Future<void> markSeeded();
}
