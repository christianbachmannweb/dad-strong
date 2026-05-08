import '../../domain/entities/effort_level.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/training_type.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/entities/workout_set.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/workout_local_datasource.dart';
import '../models/exercise_log_model.dart';
import '../models/workout_session_model.dart';
import '../models/workout_set_model.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutLocalDatasource _datasource;
  const WorkoutRepositoryImpl(this._datasource);

  @override
  Future<void> saveSession(WorkoutSession session) =>
      _datasource.saveSession(_toModel(session));

  @override
  Future<List<WorkoutSession>> getAllSessions() async =>
      _datasource.getAllSessions().map(_toDomain).toList();

  @override
  Future<WorkoutSession?> getLastSessionForType(TrainingType type) async {
    final sessions = _datasource
        .getAllSessions()
        .where((m) => m.typeIndex == type.index)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    if (sessions.isEmpty) return null;
    return _toDomain(sessions.first);
  }

  @override
  Future<bool> isFirstRun() async => _datasource.isFirstRun();

  @override
  Future<void> markSeeded() => _datasource.markSeeded();

  WorkoutSession _toDomain(WorkoutSessionModel m) => WorkoutSession(
        id: m.id,
        type: TrainingType.values[m.typeIndex],
        date: m.date,
        totalDurationSeconds: m.totalDurationSeconds,
        exerciseLogs: m.exerciseLogs.map(_logToDomain).toList(),
      );

  ExerciseLog _logToDomain(ExerciseLogModel m) => ExerciseLog(
        exerciseId: m.exerciseId,
        sets: m.sets.map(_setToDomain).toList(),
      );

  WorkoutSet _setToDomain(WorkoutSetModel m) => WorkoutSet(
        setIndex: m.setIndex,
        reps: m.reps,
        weightKg: m.weightKg,
        durationSeconds: m.durationSeconds,
        effort: EffortLevel.values[m.effortIndex],
      );

  WorkoutSessionModel _toModel(WorkoutSession s) => WorkoutSessionModel(
        id: s.id,
        typeIndex: s.type.index,
        date: s.date,
        totalDurationSeconds: s.totalDurationSeconds,
        exerciseLogs: s.exerciseLogs.map(_logToModel).toList(),
      );

  ExerciseLogModel _logToModel(ExerciseLog l) => ExerciseLogModel(
        exerciseId: l.exerciseId,
        sets: l.sets.map(_setToModel).toList(),
      );

  WorkoutSetModel _setToModel(WorkoutSet s) => WorkoutSetModel(
        setIndex: s.setIndex,
        reps: s.reps,
        weightKg: s.weightKg,
        durationSeconds: s.durationSeconds,
        effortIndex: s.effort.index,
      );
}
