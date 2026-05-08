import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/datasources/workout_local_datasource.dart';
import 'data/models/exercise_log_model.dart';
import 'data/models/workout_session_model.dart';
import 'data/models/workout_set_model.dart';
import 'data/repositories/workout_repository_impl.dart';
import 'data/seed/seed_data.dart';
import 'presentation/app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(WorkoutSetModelAdapter());
  Hive.registerAdapter(ExerciseLogModelAdapter());
  Hive.registerAdapter(WorkoutSessionModelAdapter());
  await WorkoutLocalDatasource.openBoxes();

  final datasource = WorkoutLocalDatasource();
  if (datasource.isFirstRun()) {
    final repo = WorkoutRepositoryImpl(datasource);
    await repo.saveSession(seedSessionA());
    await repo.saveSession(seedSessionB());
    await datasource.markSeeded();
  }

  runApp(const ProviderScope(child: App()));
}
