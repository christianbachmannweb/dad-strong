import 'package:flutter_test/flutter_test.dart';
import 'package:dad_strong/domain/entities/training_type.dart';
import 'package:dad_strong/domain/entities/workout_session.dart';
import 'package:dad_strong/domain/usecases/should_show_monthly_progress.dart';
import 'package:dad_strong/domain/repositories/workout_repository.dart';

class _FakeRepo implements WorkoutRepository {
  final List<WorkoutSession> sessions;
  _FakeRepo(this.sessions);

  @override
  Future<List<WorkoutSession>> getAllSessions() async => sessions;
  @override
  Future<WorkoutSession?> getLastSessionForType(TrainingType t) async => null;
  @override
  Future<void> saveSession(WorkoutSession s) async {}
  @override
  Future<bool> isFirstRun() async => false;
  @override
  Future<void> markSeeded() async {}
}

WorkoutSession _session(DateTime date) => WorkoutSession(
      id: date.toString(),
      type: TrainingType.a,
      date: date,
      totalDurationSeconds: 3600,
      exerciseLogs: const [],
    );

void main() {
  final now = DateTime.now();
  final prevMonth = DateTime(now.year, now.month - 1);

  test('returns true when no sessions this month and 2+ last month', () async {
    final repo = _FakeRepo([
      _session(DateTime(prevMonth.year, prevMonth.month, 5)),
      _session(DateTime(prevMonth.year, prevMonth.month, 20)),
    ]);
    final result = await ShouldShowMonthlyProgress(repo).execute();
    expect(result, true);
  });

  test('returns false when already trained this month', () async {
    final repo = _FakeRepo([
      _session(DateTime(prevMonth.year, prevMonth.month, 5)),
      _session(DateTime(prevMonth.year, prevMonth.month, 20)),
      _session(DateTime(now.year, now.month, 1)),
    ]);
    final result = await ShouldShowMonthlyProgress(repo).execute();
    expect(result, false);
  });

  test('returns false when only 1 session last month', () async {
    final repo = _FakeRepo([
      _session(DateTime(prevMonth.year, prevMonth.month, 10)),
    ]);
    final result = await ShouldShowMonthlyProgress(repo).execute();
    expect(result, false);
  });
}
