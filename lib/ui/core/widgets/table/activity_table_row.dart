// lib/ui/core/widgets/table/activity_table_row.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/activity_log_item.dart';
import '../../../activity_logs/models/unified_activity_config.dart';
import '../../constants/spacing.dart';
import '../../themes/web_text_styles.dart';
import 'table_badge.dart';
import 'table_chip.dart';

import 'table_cell.dart';
import 'table_row.dart';

/// Single table row for activity log items
class ActivityTableRow extends StatelessWidget {
  final ActivityLogItem item;
  final ValueChanged<ActivityLogItem> onViewDetails;

  const ActivityTableRow({
    super.key,
    required this.item,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final categoryName = UnifiedActivityConfig.getCategoryNameFromActivityType(item.type);
    final typeColor = UnifiedActivityConfig.getColorForType(item.category);

    return GenericTableRow(
      onTap: () => onViewDetails(item),
      cellSpacing: AppSpacing.md,
      cells: [
        // Title Column
        TableCellWidget(
          flex: 2,
          child: Text(
            item.title,
            style: WebTextStyles.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        
        // Category Badge
        TableCellWidget(
          flex: 2,
          child: Center(
            child: TableBadge(text: categoryName),
          ),
        ),
        
        // Type Chip
        TableCellWidget(
          flex: 2,
          child: Center(
            child: TableChip(text: item.category, color: typeColor),
          ),
        ),
        
        // Value Column
        TableCellWidget(
          flex: 2,
          child: Text(
            item.value,
            style: WebTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ),
        
        // Date Added Column
        TableCellWidget(
          flex: 2,
          child: Text(
            DateFormat('MM/dd/yyyy').format(item.timestamp),
            style: WebTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ),
        
        // Actions Column
        TableCellWidget(
          flex: 1,
          child: Center(
            child: IconButton(
              icon: const Icon(Icons.open_in_new, size: 18),
              color: const Color(0xFF6B7280),
              onPressed: () => onViewDetails(item),
            ),
          ),
        ),
      ],
    );
  }
}