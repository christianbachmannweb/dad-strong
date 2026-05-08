import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/training_type.dart';
import '../../../domain/entities/workout_session.dart';
import '../../providers/training_history_provider.dart';
import '../../providers/workout_session_provider.dart';
import 'widgets/home_chart_widget.dart';
import 'widgets/streak_widget.dart';

@RoutePage()
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(trainingHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: historyAsync.when(
            data: (sessions) {
              final lastType =
                  sessions.isEmpty ? null : sessions.last.type;
              final nextType = lastType == TrainingType.b
                  ? TrainingType.a
                  : TrainingType.b;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dad Strong', style: AppTypography.headingLarge),
                  const SizedBox(height: 4),
                  if (sessions.isNotEmpty)
                    Text(
                      'Letztes Training: ${sessions.last.type.label} — ${_formatDate(sessions.last.date)}',
                      style: AppTypography.label,
                    ),
                  const SizedBox(height: 32),
                  _TrainingButton(
                    label: 'Training A',
                    subtitle:
                        'Kniebeuge · Bankdrücken · Rudern · BSS · Farmer',
                    isNext: nextType == TrainingType.a,
                    onTap: () =>
                        _startWorkout(context, ref, TrainingType.a, sessions),
                  ),
                  const SizedBox(height: 16),
                  _TrainingButton(
                    label: 'Training B',
                    subtitle: 'Kreuzheben · OHP · Klimmzüge · Step-Up',
                    isNext: nextType == TrainingType.b,
                    onTap: () =>
                        _startWorkout(context, ref, TrainingType.b, sessions),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => context.router
                        .push(const ProgressionChartRoute()),
                    child: StreakWidget(sessions: sessions),
                  ),
                  const SizedBox(height: 16),
                  HomeCandlestickWidget(
                    sessions: sessions,
                    onTap: () => context.router
                        .push(const ProgressionChartRoute()),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child:
                  CircularProgressIndicator(color: AppColors.textPrimary),
            ),
            error: (e, _) => Text('Fehler: $e',
                style:
                    AppTypography.bodyMedium.copyWith(color: Colors.red)),
          ),
        ),
      ),
    );
  }

  void _startWorkout(BuildContext context, WidgetRef ref,
      TrainingType type, List<WorkoutSession> sessions) {
    final lastSession = sessions.isEmpty
        ? null
        : sessions.lastWhere(
            (s) => s.type == type,
            orElse: () => sessions.last,
          );

    ref.read(workoutSessionProvider.notifier).startSession(
          type,
          lastSession: lastSession,
        );
    context.router.push(WorkoutRoute(trainingType: type));
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

class _TrainingButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isNext;
  final VoidCallback onTap;

  const _TrainingButton({
    required this.label,
    required this.subtitle,
    required this.isNext,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isNext ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isNext ? AppColors.textPrimary : AppColors.textSecondary,
            width: isNext ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(label, style: AppTypography.headingMedium),
                if (isNext) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'NÄCHSTES',
                      style: AppTypography.label.copyWith(
                        color: Colors.black,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTypography.label),
          ],
        ),
      ),
    );
  }
}
