import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/effort_level.dart';

class EffortMarkerWidget extends StatelessWidget {
  final EffortLevel current;
  final void Function(EffortLevel) onChanged;

  const EffortMarkerWidget({
    super.key,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: EffortLevel.values.map((level) {
        final isSelected = level == current;
        return GestureDetector(
          onTap: () => onChanged(level),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? (level == EffortLevel.none
                      ? AppColors.surface
                      : AppColors.effortGold)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? (level == EffortLevel.none
                        ? AppColors.textSecondary
                        : AppColors.effortGold)
                    : AppColors.textSecondary,
              ),
            ),
            child: Text(
              level.label,
              style: AppTypography.bodyLarge.copyWith(
                color: isSelected && level != EffortLevel.none
                    ? Colors.black
                    : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
