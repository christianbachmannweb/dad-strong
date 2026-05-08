import 'package:hive_flutter/hive_flutter.dart';
import 'exercise_log_model.dart';

class WorkoutSessionModel {
  final String id;
  final int typeIndex;
  final DateTime date;
  final int totalDurationSeconds;
  final List<ExerciseLogModel> exerciseLogs;

  const WorkoutSessionModel({
    required this.id,
    required this.typeIndex,
    required this.date,
    required this.totalDurationSeconds,
    required this.exerciseLogs,
  });
}

class WorkoutSessionModelAdapter extends TypeAdapter<WorkoutSessionModel> {
  @override
  final int typeId = 2;

  @override
  WorkoutSessionModel read(BinaryReader reader) {
    final id = reader.readString();
    final typeIndex = reader.readInt();
    final dateMs = reader.readInt();
    final duration = reader.readInt();
    final logCount = reader.readInt();
    final logs = List.generate(
      logCount,
      (_) => ExerciseLogModelAdapter().read(reader),
    );
    return WorkoutSessionModel(
      id: id,
      typeIndex: typeIndex,
      date: DateTime.fromMillisecondsSinceEpoch(dateMs),
      totalDurationSeconds: duration,
      exerciseLogs: logs,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSessionModel obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.typeIndex);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeInt(obj.totalDurationSeconds);
    writer.writeInt(obj.exerciseLogs.length);
    for (final log in obj.exerciseLogs) {
      ExerciseLogModelAdapter().write(writer, log);
    }
  }
}
