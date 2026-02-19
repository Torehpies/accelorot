// lib/ui/machine_detail_screen/widgets/activity_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/activity_log_item.dart';
import '../../core/widgets/sample_cards/data_card.dart';

/// A single activity card row using DataCard styling.
class ActivityListItem extends StatelessWidget {
  final ActivityLogItem item;
  final VoidCallback? onTap;

  const ActivityListItem({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DataCard<ActivityLogItem>(
      data: item,
      icon: item.icon,
      iconBgColor: item.statusColor.withValues(alpha: 0.2),
      iconColor: item.statusColor,
      title: item.title,
      description: '${item.operatorName} · ${item.formattedTimestamp}',
      status: null, // Hide status pill
      onTap: onTap,
    );
  }
}

/// A column of activity list items with a header. Useful for non-scrollable contexts.
class ActivityList extends StatelessWidget {
  final List<ActivityLogItem> activities;
  final VoidCallback? onViewAll;

  const ActivityList({
    super.key,
    required this.activities,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Activities',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: activities.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) =>
              ActivityListItem(item: activities[index]),
        ),
      ],
    );
  }
}
