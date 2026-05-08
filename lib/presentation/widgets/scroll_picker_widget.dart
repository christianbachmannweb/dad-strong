import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ScrollPickerWidget extends StatefulWidget {
  final List<String> items;
  final int initialIndex;
  final void Function(int index) onChanged;
  final double itemExtent;
  final double width;

  const ScrollPickerWidget({
    super.key,
    required this.items,
    required this.initialIndex,
    required this.onChanged,
    this.itemExtent = 52,
    this.width = 120,
  });

  @override
  State<ScrollPickerWidget> createState() => _ScrollPickerWidgetState();
}

class _ScrollPickerWidgetState extends State<ScrollPickerWidget> {
  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        FixedExtentScrollController(initialItem: widget.initialIndex);
  }

  @override
  void didUpdateWidget(ScrollPickerWidget old) {
    super.didUpdateWidget(old);
    if (old.initialIndex != widget.initialIndex &&
        _controller.selectedItem != widget.initialIndex) {
      _controller.jumpToItem(widget.initialIndex);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.itemExtent * 3,
      child: ListWheelScrollView.useDelegate(
        controller: _controller,
        itemExtent: widget.itemExtent,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: widget.onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: widget.items.length,
          builder: (context, index) {
            final isSelected = index == _controller.selectedItem;
            return Center(
              child: Text(
                widget.items[index],
                style: isSelected
                    ? AppTypography.headingMedium
                    : AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
