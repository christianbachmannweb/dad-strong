import 'package:hive_flutter/hive_flutter.dart';
import 'workout_set_model.dart';

class ExerciseLogModel {
  final String exerciseId;
  final List<WorkoutSetModel> sets;

  const ExerciseLogModel({required this.exerciseId, required this.sets});
}

class ExerciseLogModelAdapter extends TypeAdapter<ExerciseLogModel> {
  @override
  final int typeId = 1;

  @override
  ExerciseLogModel read(BinaryReader reader) {
    final exerciseId = reader.readString();
    final setCount = reader.readInt();
    final sets = List.generate(
      setCount,
      (_) => WorkoutSetModelAdapter().read(reader),
    );
    return ExerciseLogModel(exerciseId: exerciseId, sets: sets);
  }

  @override
  void write(BinaryWriter writer, ExerciseLogModel obj) {
    writer.writeString(obj.exerciseId);
    writer.writeInt(obj.sets.length);
    for (final set in obj.sets) {
      WorkoutSetModelAdapter().write(writer, set);
    }
  }
}
