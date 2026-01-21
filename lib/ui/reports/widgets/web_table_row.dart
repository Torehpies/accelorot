// lib/ui/reports/widgets/web_table_row.dart

import 'package:flutter/material.dart';
import '../../../data/models/report.dart';
import '../../core/widgets/table/table_row.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../../core/constants/spacing.dart';
import 'reports_priority_badge.dart';

class WebTableRow extends StatelessWidget {
  final Report report;
  final VoidCallback onView;
  final VoidCallback onEdit;

  const WebTableRow({
    super.key,
    required this.report,
    required this.onView,
    required this.onEdit,
  });

  Color get statusColor {
    switch (report.status.toLowerCase()) {
      case 'open':
        return WebColors.info;
      case 'in_progress':
        return WebColors.warning;
      case 'completed':
        return WebColors.success;
      case 'on_hold':
        return WebColors.error;
      default:
        return WebColors.neutral;
    }
  }

  Color get categoryColor {
    switch (report.reportType.toLowerCase()) {
      case 'maintenance_issue':
        return WebColors.maintenance;
      case 'observation':
        return WebColors.observation;
      case 'safety_concern':
        return WebColors.safety;
      default:
        return WebColors.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GenericTableRow(
      onTap: null,
      hoverColor: WebColors.hoverBackground,
      cellSpacing: AppSpacing.md,
      cells: [
        // Title Column (flex: 2)
        TableCellWidget(
          flex: 2,
          child: Text(
            report.title,
            style: WebTextStyles.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        
        // Category Column (flex: 2)
        TableCellWidget(
          flex: 2,
          child: Text(
            report.reportTypeLabel,
            style: WebTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ),
        
        // Status Column (flex: 2) - Filled Chip
        TableCellWidget(
          flex: 2,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                report.statusLabel,
                style: WebTextStyles.label.copyWith(
                  fontSize: 12,
                  color: statusColor,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        
        // Priority Column (flex: 2) - Outline Badge
        TableCellWidget(
          flex: 2,
          child: Center(
            child: ReportsPriorityBadge(priority: report.priority),
          ),
        ),
        
        // Actions Column (flex: 1) - View and Edit buttons
        TableCellWidget(
          flex: 1,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.open_in_new, size: 18),
                  color: WebColors.textLabel,
                  onPressed: onView,
                  tooltip: 'View Details',
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  color: WebColors.textLabel,
                  onPressed: onEdit,
                  tooltip: 'Edit Report',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}