// lib/ui/activity_logs/widgets/web_date_filter_button.dart

import 'package:flutter/material.dart';
import '../models/activity_common.dart';

/// Date filter dropdown button
class WebDateFilterButton extends StatelessWidget {
  final ValueChanged<DateFilterRange> onFilterChanged;

  const WebDateFilterButton({
    super.key,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<DateFilterType>(
      icon: Icon(Icons.calendar_today, color: Colors.grey[700]),
      tooltip: 'Filter by date',
      onSelected: (type) {
        final now = DateTime.now();
        DateFilterRange filter;

        switch (type) {
          case DateFilterType.today:
            filter = DateFilterRange(
              type: type,
              startDate: DateTime(now.year, now.month, now.day),
              endDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
            );
            break;
          case DateFilterType.yesterday:
            final yesterday = now.subtract(const Duration(days: 1));
            filter = DateFilterRange(
              type: type,
              startDate: DateTime(yesterday.year, yesterday.month, yesterday.day),
              endDate: DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59),
            );
            break;
          case DateFilterType.last7Days:
            filter = DateFilterRange(
              type: type,
              startDate: now.subtract(const Duration(days: 7)),
              endDate: now,
            );
            break;
          case DateFilterType.last30Days:
            filter = DateFilterRange(
              type: type,
              startDate: now.subtract(const Duration(days: 30)),
              endDate: now,
            );
            break;
          case DateFilterType.custom:
            _showCustomDatePicker(context);
            return;
          case DateFilterType.none:
            filter = const DateFilterRange(type: DateFilterType.none);
            break;
        }

        onFilterChanged(filter);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: DateFilterType.none,
          child: Text('All Time'),
        ),
        const PopupMenuItem(
          value: DateFilterType.today,
          child: Text('Today'),
        ),
        const PopupMenuItem(
          value: DateFilterType.yesterday,
          child: Text('Yesterday'),
        ),
        const PopupMenuItem(
          value: DateFilterType.last7Days,
          child: Text('Last 7 Days'),
        ),
        const PopupMenuItem(
          value: DateFilterType.last30Days,
          child: Text('Last 30 Days'),
        ),
        const PopupMenuItem(
          value: DateFilterType.custom,
          child: Text('Custom Range...'),
        ),
      ],
    );
  }

  Future<void> _showCustomDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 7)),
        end: now,
      ),
    );

    if (picked != null) {
      onFilterChanged(
        DateFilterRange(
          type: DateFilterType.custom,
          startDate: picked.start,
          endDate: picked.end,
        ),
      );
    }
  }
}