// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [MonthlyProgressPage]
class MonthlyProgressRoute extends PageRouteInfo<void> {
  const MonthlyProgressRoute({List<PageRouteInfo>? children})
    : super(MonthlyProgressRoute.name, initialChildren: children);

  static const String name = 'MonthlyProgressRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MonthlyProgressPage();
    },
  );
}

/// generated route for
/// [ProgressionChartPage]
class ProgressionChartRoute extends PageRouteInfo<void> {
  const ProgressionChartRoute({List<PageRouteInfo>? children})
    : super(ProgressionChartRoute.name, initialChildren: children);

  static const String name = 'ProgressionChartRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProgressionChartPage();
    },
  );
}

/// generated route for
/// [SummaryPage]
class SummaryRoute extends PageRouteInfo<SummaryRouteArgs> {
  SummaryRoute({
    Key? key,
    required List<ExerciseLog> completedLogs,
    required TrainingType trainingType,
    required int durationSeconds,
    List<PageRouteInfo>? children,
  }) : super(
         SummaryRoute.name,
         args: SummaryRouteArgs(
           key: key,
           completedLogs: completedLogs,
           trainingType: trainingType,
           durationSeconds: durationSeconds,
         ),
         initialChildren: children,
       );

  static const String name = 'SummaryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SummaryRouteArgs>();
      return SummaryPage(
        key: args.key,
        completedLogs: args.completedLogs,
        trainingType: args.trainingType,
        durationSeconds: args.durationSeconds,
      );
    },
  );
}

class SummaryRouteArgs {
  const SummaryRouteArgs({
    this.key,
    required this.completedLogs,
    required this.trainingType,
    required this.durationSeconds,
  });

  final Key? key;

  final List<ExerciseLog> completedLogs;

  final TrainingType trainingType;

  final int durationSeconds;

  @override
  String toString() {
    return 'SummaryRouteArgs{key: $key, completedLogs: $completedLogs, trainingType: $trainingType, durationSeconds: $durationSeconds}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SummaryRouteArgs) return false;
    return key == other.key &&
        const ListEquality<ExerciseLog>().equals(
          completedLogs,
          other.completedLogs,
        ) &&
        trainingType == other.trainingType &&
        durationSeconds == other.durationSeconds;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      const ListEquality<ExerciseLog>().hash(completedLogs) ^
      trainingType.hashCode ^
      durationSeconds.hashCode;
}

/// generated route for
/// [WorkoutPage]
class WorkoutRoute extends PageRouteInfo<WorkoutRouteArgs> {
  WorkoutRoute({
    required TrainingType trainingType,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         WorkoutRoute.name,
         args: WorkoutRouteArgs(trainingType: trainingType, key: key),
         initialChildren: children,
       );

  static const String name = 'WorkoutRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<WorkoutRouteArgs>();
      return WorkoutPage(trainingType: args.trainingType, key: args.key);
    },
  );
}

class WorkoutRouteArgs {
  const WorkoutRouteArgs({required this.trainingType, this.key});

  final TrainingType trainingType;

  final Key? key;

  @override
  String toString() {
    return 'WorkoutRouteArgs{trainingType: $trainingType, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkoutRouteArgs) return false;
    return trainingType == other.trainingType && key == other.key;
  }

  @override
  int get hashCode => trainingType.hashCode ^ key.hashCode;
}
