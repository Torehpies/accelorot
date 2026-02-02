// lib/ui/reports/widgets/reports_priority_badge.dart

import 'package:flutter/material.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';

/// Outline-only badge for priority display (no background fill)
class ReportsPriorityBadge extends StatelessWidget {
  final String priority;

  const ReportsPriorityBadge({super.key, required this.priority});

  Color get priorityColor {
    switch (priority.toLowerCase()) {
      case 'high':
        return WebColors.error;
      case 'medium':
        return WebColors.warning;
      case 'low':
        return WebColors.success;
      default:
        return WebColors.neutral;
    }
  }

  String get displayText {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'High';
      case 'medium':
        return 'Medium';
      case 'low':
        return 'Low';
      default:
        return priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: priorityColor, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        displayText,
        style: WebTextStyles.label.copyWith(fontSize: 12, color: priorityColor),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
