import '../entities/workout_session.dart';
import '../repositories/workout_repository.dart';

class SaveWorkoutSession {
  final WorkoutRepository _repo;
  const SaveWorkoutSession(this._repo);

  Future<void> execute(WorkoutSession session) => _repo.saveSession(session);
}
