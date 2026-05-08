import '../repositories/workout_repository.dart';

class ShouldShowMonthlyProgress {
  final WorkoutRepository _repo;
  const ShouldShowMonthlyProgress(this._repo);

  Future<bool> execute() async {
    final now = DateTime.now();
    final firstOfThisMonth = DateTime(now.year, now.month, 1);
    final firstOfPrevMonth = DateTime(now.year, now.month - 1, 1);

    final sessions = await _repo.getAllSessions();

    final hasTrainedThisMonth = sessions.any((s) =>
        s.date.isAfter(firstOfThisMonth.subtract(const Duration(seconds: 1))));
    if (hasTrainedThisMonth) return false;

    final prevMonthCount = sessions
        .where((s) =>
            s.date.isAfter(firstOfPrevMonth.subtract(const Duration(seconds: 1))) &&
            s.date.isBefore(firstOfThisMonth))
        .length;

    return prevMonthCount >= 2;
  }
}
