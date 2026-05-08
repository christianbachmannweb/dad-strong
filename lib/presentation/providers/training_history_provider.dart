import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/training_type.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/usecases/get_monthly_progress.dart';
import 'workout_repository_provider.dart';

final trainingHistoryProvider =
    FutureProvider<List<WorkoutSession>>((ref) async {
  final repo = ref.read(workoutRepositoryProvider);
  return repo.getAllSessions();
});

final lastSessionForTypeProvider =
    FutureProvider.family<WorkoutSession?, TrainingType>((ref, type) async {
  final repo = ref.read(workoutRepositoryProvider);
  return repo.getLastSessionForType(type);
});

final monthlyProgressProvider =
    FutureProvider.autoDispose<Map<String, double>?>((ref) async {
  final repo = ref.read(workoutRepositoryProvider);
  return GetMonthlyProgress(repo).execute();
});
