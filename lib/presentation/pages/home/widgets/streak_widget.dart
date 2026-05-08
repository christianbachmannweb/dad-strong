import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/workout_session.dart';

class StreakWidget extends StatelessWidget {
  final List<WorkoutSession> sessions;
  static const _goal = 12;

  const StreakWidget({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final streak = _computeStreak(sessions);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.timerRingBackground),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Streak', style: AppTypography.label),
                const SizedBox(height: 4),
                Text(
                  '$streak / $_goal Wochen',
                  style: AppTypography.headingMedium,
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: streak / _goal,
                    minHeight: 6,
                    backgroundColor: AppColors.timerRingBackground,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.timerRingActive),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            streak >= _goal ? '🏆' : _streakEmoji(streak),
            style: const TextStyle(fontSize: 32),
          ),
        ],
      ),
    );
  }

  String _streakEmoji(int streak) {
    if (streak == 0) return '💤';
    if (streak < 4) return '🔥';
    if (streak < 8) return '💪';
    return '⚡';
  }

  /// Count consecutive weeks (ending from the most recent week) with >= 2 sessions each.
  int _computeStreak(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) return 0;

    // Group sessions by ISO year+week key
    final weekMap = <String, int>{};
    for (final s in sessions) {
      final key = _isoWeekKey(s.date);
      weekMap[key] = (weekMap[key] ?? 0) + 1;
    }

    // Walk backwards week by week from current week
    var streak = 0;
    var date = DateTime.now();
    while (true) {
      final key = _isoWeekKey(date);
      final count = weekMap[key] ?? 0;
      if (count >= 2) {
        streak++;
        date = date.subtract(const Duration(days: 7));
      } else {
        break;
      }
    }
    return streak;
  }

  String _isoWeekKey(DateTime d) {
    // ISO week: Thursday of the week determines the year.
    final thursday = d.add(Duration(days: 4 - (d.weekday)));
    final weekOfYear =
        ((thursday.difference(DateTime(thursday.year)).inDays) / 7).floor() + 1;
    return '${thursday.year}-W${weekOfYear.toString().padLeft(2, '0')}';
  }
}
