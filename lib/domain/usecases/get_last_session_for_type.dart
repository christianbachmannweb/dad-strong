import '../entities/training_type.dart';
import '../entities/workout_session.dart';
import '../repositories/workout_repository.dart';

class GetLastSessionForType {
  final WorkoutRepository _repo;
  const GetLastSessionForType(this._repo);

  Future<WorkoutSession?> execute(TrainingType type) =>
      _repo.getLastSessionForType(type);
}
