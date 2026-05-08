import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout_session_model.dart';

class WorkoutLocalDatasource {
  static const _sessionsBoxName = 'workout_sessions';
  static const _metaBoxName = 'meta';
  static const _seededKey = 'seeded';

  Box<WorkoutSessionModel> get _sessionsBox =>
      Hive.box<WorkoutSessionModel>(_sessionsBoxName);

  Box<dynamic> get _metaBox => Hive.box<dynamic>(_metaBoxName);

  static Future<void> openBoxes() async {
    await Hive.openBox<WorkoutSessionModel>(_sessionsBoxName);
    await Hive.openBox<dynamic>(_metaBoxName);
  }

  Future<void> saveSession(WorkoutSessionModel model) async {
    await _sessionsBox.put(model.id, model);
  }

  List<WorkoutSessionModel> getAllSessions() {
    return _sessionsBox.values.toList();
  }

  bool isFirstRun() =>
      !(_metaBox.get(_seededKey, defaultValue: false) as bool);

  Future<void> markSeeded() => _metaBox.put(_seededKey, true);
}
