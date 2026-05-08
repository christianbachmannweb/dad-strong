import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/training_type.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/monthly_progress/monthly_progress_page.dart';
import '../../presentation/pages/summary/summary_page.dart';
import '../../presentation/pages/progression/progression_chart_page.dart';
import '../../presentation/pages/workout/view/workout_page.dart';
part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: HomeRoute.page, initial: true),
        AutoRoute(page: WorkoutRoute.page),
        AutoRoute(page: SummaryRoute.page),
        AutoRoute(page: MonthlyProgressRoute.page),
        AutoRoute(page: ProgressionChartRoute.page),
      ];
}
