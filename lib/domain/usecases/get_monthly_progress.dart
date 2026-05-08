import '../repositories/workout_repository.dart';

class GetMonthlyProgress {
  final WorkoutRepository _repo;
  const GetMonthlyProgress(this._repo);

  Future<Map<String, double>?> execute() async {
    final now = DateTime.now();
    final firstOfPrevMonth = DateTime(now.year, now.month - 1, 1);
    final firstOfThisMonth = DateTime(now.year, now.month, 1);

    final allSessions = await _repo.getAllSessions();

    final prevMonthSessions = allSessions
        .where((s) =>
            s.date.isAfter(firstOfPrevMonth.subtract(const Duration(seconds: 1))) &&
            s.date.isBefore(firstOfThisMonth))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (prevMonthSessions.length < 2) return null;

    final firstWeekEnd = firstOfPrevMonth.add(const Duration(days: 7));
    final lastWeekStart = firstOfThisMonth.subtract(const Duration(days: 7));

    final firstWeek =
        prevMonthSessions.where((s) => s.date.isBefore(firstWeekEnd)).toList();
    final lastWeek =
        prevMonthSessions.where((s) => s.date.isAfter(lastWeekStart)).toList();

    if (firstWeek.isEmpty || lastWeek.isEmpty) return null;

    final allExerciseIds = allSessions
        .expand((s) => s.exerciseLogs.map((l) => l.exerciseId))
        .toSet();

    final result = <String, double>{};
    for (final id in allExerciseIds) {
      final startBest = firstWeek
          .expand((s) => s.exerciseLogs.where((l) => l.exerciseId == id))
          .map((l) => l.bestWeightKg)
          .fold(0.0, (a, b) => a > b ? a : b);

      final endBest = lastWeek
          .expand((s) => s.exerciseLogs.where((l) => l.exerciseId == id))
          .map((l) => l.bestWeightKg)
          .fold(0.0, (a, b) => a > b ? a : b);

      if (startBest > 0) {
        result[id] = (endBest - startBest) / startBest;
      }
    }

    return result.isEmpty ? null : result;
  }
}
