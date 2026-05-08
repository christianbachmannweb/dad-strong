import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/training_type.dart';
import '../../../providers/workout_session_provider.dart';
import '../widgets/active_set_widget.dart';
import '../widgets/exercise_transition_widget.dart';
import '../widgets/general_warmup_widget.dart';
import '../widgets/pre_set_advice_widget.dart';
import '../widgets/rest_screen_widget.dart';
import '../widgets/specific_warmup_widget.dart';

@RoutePage()
class WorkoutPage extends ConsumerWidget {
  final TrainingType trainingType;

  const WorkoutPage({required this.trainingType, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(workoutSessionProvider);
    final notifier = ref.read(workoutSessionProvider.notifier);

    if (session.phase == WorkoutPhase.complete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.router.replace(SummaryRoute(
          completedLogs: session.completedLogs,
          trainingType: session.trainingType,
          durationSeconds:
              DateTime.now().difference(session.startTime).inSeconds,
        ));
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: Text(
          'Training ${session.trainingType.label}',
          style: AppTypography.bodyLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: AppColors.surface,
                title: Text('Training beenden?',
                    style: AppTypography.headingMedium),
                content: Text(
                  'Willst du das Training wirklich beenden?',
                  style: AppTypography.bodyMedium,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Weitermachen',
                        style: AppTypography.label.copyWith(
                            color: AppColors.textSecondary)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text('Beenden',
                        style: AppTypography.label.copyWith(
                            color: Colors.red)),
                  ),
                ],
              ),
            );
            if (confirm == true && context.mounted) {
              context.router.maybePop();
            }
          },
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: _buildPhase(session, notifier),
      ),
    );
  }

  Widget _buildPhase(
    WorkoutSessionState session,
    WorkoutSessionNotifier notifier,
  ) {
    switch (session.phase) {
      case WorkoutPhase.generalWarmup:
        return GeneralWarmupWidget(
          onComplete: notifier.completeGeneralWarmup,
        );

      case WorkoutPhase.specificWarmup:
        return SpecificWarmupWidget(
          exercise: session.currentExercise,
          lastWeightKg: session.currentAdvice?.lastWeight ?? 20.0,
          onComplete: notifier.completeSpecificWarmup,
        );

      case WorkoutPhase.preSetAdvice:
        return const PreSetAdviceWidget();

      case WorkoutPhase.activeSet:
        return const ActiveSetWidget();

      case WorkoutPhase.resting:
        return const RestScreenWidget();

      case WorkoutPhase.bilateralResting:
        return const RestScreenWidget(isBilateral: true);

      case WorkoutPhase.exerciseTransition:
        return const ExerciseTransitionWidget();

      case WorkoutPhase.complete:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.textPrimary),
        );
    }
  }
}
