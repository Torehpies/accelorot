import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';

class UnderlinedToggleButtons extends StatelessWidget {
  final List<String> labels;
  final List<bool> isSelected;
  final ValueChanged<int> onPressed;

  const UnderlinedToggleButtons({
    super.key,
    required this.labels,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(labels.length, (index) {
        final selected = isSelected[index];

        return GestureDetector(
          onTap: () => onPressed(index),
          child: Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labels[index],
                  style: baseStyle?.copyWith(
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  height: 2,
                  width: selected ? 40 : 0,
                  color: selected ? AppColors.green100 : Colors.transparent,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
