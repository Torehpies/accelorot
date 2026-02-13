// lib/ui/core/widgets/containers/mobile_tab_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../themes/app_theme.dart';

class MobileTabSelector extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const MobileTabSelector({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.background2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey, width: 1.5),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isSelected = index == selectedIndex;
          final isFirst = index == 0;
          final isLast = index == labels.length - 1;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isSelected) {
                  HapticFeedback.selectionClick();
                  onChanged(index);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.green100 : Colors.transparent,
                  borderRadius: BorderRadius.horizontal(
                    left: isFirst ? const Radius.circular(10) : Radius.zero,
                    right: isLast ? const Radius.circular(10) : Radius.zero,
                  ),
                ),
                alignment: Alignment.center,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  child: Text(labels[index]),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}