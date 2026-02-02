// lib/ui/activity_logs/widgets/web/web_table_row.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/activity_log_item.dart';
import '../../models/unified_activity_config.dart';
import '../../models/activity_enums.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/themes/web_text_styles.dart';
import '../../../core/themes/web_colors.dart';
import '../../../core/widgets/table/table_row.dart';

/// Displays: Title, Category Badge, Type Chip, Value, Date, and Actions
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
    final categoryName = UnifiedActivityConfig.getCategoryNameFromActivityType(
      item.type,
    );

    // Parse the category string to enum, then get color
    final subType = ActivitySubType.fromString(item.category);
    final typeColor = UnifiedActivityConfig.getColorForSubType(subType);

    return GenericTableRow(
      onTap: null,
      hoverColor: WebColors.hoverBackground,
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

        // Category Column
        TableCellWidget(
          flex: 2,
          child: Text(
            categoryName,
            style: WebTextStyles.body,
            textAlign: TextAlign.center,
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
              color: WebColors.textLabel,
              onPressed: () => onViewDetails(item),
              tooltip: 'View Details',
            ),
          ),
        ),
      ],
    );
  }
}
