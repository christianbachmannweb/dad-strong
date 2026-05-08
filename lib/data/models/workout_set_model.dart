import 'package:hive_flutter/hive_flutter.dart';

class WorkoutSetModel {
  final int setIndex;
  final int reps;
  final double weightKg;
  final int durationSeconds;
  final int effortIndex;

  const WorkoutSetModel({
    required this.setIndex,
    required this.reps,
    required this.weightKg,
    required this.durationSeconds,
    required this.effortIndex,
  });
}

class WorkoutSetModelAdapter extends TypeAdapter<WorkoutSetModel> {
  @override
  final int typeId = 0;

  @override
  WorkoutSetModel read(BinaryReader reader) {
    return WorkoutSetModel(
      setIndex: reader.readInt(),
      reps: reader.readInt(),
      weightKg: reader.readDouble(),
      durationSeconds: reader.readInt(),
      effortIndex: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSetModel obj) {
    writer.writeInt(obj.setIndex);
    writer.writeInt(obj.reps);
    writer.writeDouble(obj.weightKg);
    writer.writeInt(obj.durationSeconds);
    writer.writeInt(obj.effortIndex);
  }
}
