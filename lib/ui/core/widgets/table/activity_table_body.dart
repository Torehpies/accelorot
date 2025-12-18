// lib/ui/core/widgets/table/activity_table_body.dart

import 'package:flutter/material.dart';
import '../../../../data/models/activity_log_item.dart';
import '../shared/empty_state.dart';
import 'activity_table_row.dart';

/// Table body with ListView and empty state handling
class ActivityTableBody extends StatelessWidget {
  final List<ActivityLogItem> items;
  final ValueChanged<ActivityLogItem> onViewDetails;

  const ActivityTableBody({
    super.key,
    required this.items,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyState();
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        color: Color(0xFFE5E7EB),
      ),
      itemBuilder: (context, index) {
        return ActivityTableRow(
          item: items[index],
          onViewDetails: onViewDetails,
        );
      },
    );
  }
}