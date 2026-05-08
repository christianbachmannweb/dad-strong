import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/training_history_provider.dart';

@RoutePage()
class MonthlyProgressPage extends ConsumerWidget {
  const MonthlyProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(monthlyProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: Text('Monatlicher Fortschritt', style: AppTypography.bodyLarge),
        elevation: 0,
      ),
      body: SafeArea(
        child: progressAsync.when(
          data: (progress) {
            if (progress == null || progress.isEmpty) {
              return Center(
                child: Text(
                  'Noch keine Daten',
                  style: AppTypography.bodyLarge
                      .copyWith(color: AppColors.textSecondary),
                ),
              );
            }
            return ListView.separated(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              itemCount: progress.entries.length,
              separatorBuilder: (_, _) =>
                  const Divider(color: AppColors.surface, height: 24),
              itemBuilder: (_, i) {
                final entry = progress.entries.elementAt(i);
                final pct = entry.value;
                final isPositive = pct >= 0;

                return Row(
                  children: [
                    Expanded(
                      child: Text(entry.key,
                          style: AppTypography.bodyLarge),
                    ),
                    Text(
                      '${isPositive ? '+' : ''}${pct.toStringAsFixed(1)}%',
                      style: AppTypography.headingMedium.copyWith(
                        color: isPositive ? Colors.greenAccent : Colors.redAccent,
                      ),
                    ),
                  ],
                );
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.textPrimary),
          ),
          error: (e, _) => Center(
            child: Text('Fehler: $e',
                style: AppTypography.bodyMedium
                    .copyWith(color: Colors.redAccent)),
          ),
        ),
      ),
    );
  }
}
