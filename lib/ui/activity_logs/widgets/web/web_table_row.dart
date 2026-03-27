import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/activity_log_item.dart';
import '../../../../data/providers/machine_providers.dart';
import '../../../../data/providers/batch_providers.dart';
import '../../models/unified_activity_config.dart';
import '../../models/activity_enums.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/themes/web_text_styles.dart';
import '../../../core/themes/web_colors.dart';
import '../../../core/widgets/table/table_row.dart';
import '../../../core/widgets/table/table_action_buttons.dart';

/// Displays: Machine/Batch, Title, Category, Type, Value, Date, and Actions
class ActivityTableRow extends ConsumerWidget {
  final ActivityLogItem item;
  final ValueChanged<ActivityLogItem> onViewDetails;

  const ActivityTableRow({
    super.key,
    required this.item,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access machine and batch data for name lookups
    final machinesAsync = ref.watch(userTeamMachinesProvider);
    final batchesAsync = ref.watch(userTeamBatchesProvider);

    // Get display machine name (prioritize item.machineName, then lookup, NO ID fallback)
    final machineName = item.machineName ??
        machinesAsync.whenOrNull(
          data: (machines) {
            final machine = machines.where((m) => m.id == item.machineId).firstOrNull;
            return machine?.machineName;
          },
        );

    // Get display batch name:
    // 1. Use item.batchName if available
    // 2. Lookup by item.batchId in batches provider
    // 3. If no batchId, find the machine's active batch as fallback
    final batchName = item.batchName ??
        batchesAsync.whenOrNull(
          data: (batches) {
            if (item.batchId != null) {
              // Direct lookup by batchId
              return batches.where((b) => b.id == item.batchId).firstOrNull?.displayName;
            }
            // Fallback: find active batch for this machine
            if (item.machineId != null) {
              final activeBatch = batches
                  .where((b) => b.machineId == item.machineId && b.isActive)
                  .firstOrNull;
              return activeBatch?.displayName;
            }
            return null;
          },
        );

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
        // Machine / Batch Column
        TableCellWidget(
          flex: 2,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (machineName != null)
                  Text(
                    machineName,
                    style: WebTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (batchName != null) ...[
                  if (machineName != null) const SizedBox(height: 2),
                  Text(
                    batchName,
                    style: WebTextStyles.body.copyWith(
                      fontSize: 11,
                      color: WebColors.textLabel,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (machineName == null && batchName == null)
                  const Text('—', style: WebTextStyles.body),
              ],
            ),
          ),
        ),

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
            child: TableActionButtons(
              actions: [
                TableActionButton(
                  icon: Icons.open_in_new,
                  tooltip: 'View Details',
                  onPressed: () => onViewDetails(item),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
