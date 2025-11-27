//date_filter_button.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum DateFilterType {
  none,
  today,
  last3Days,
  last7Days,
  last14Days,
  customDate,
}

class DateFilterRange {
  final DateFilterType type;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? customDate;

  DateFilterRange({
    required this.type,
    this.startDate,
    this.endDate,
    this.customDate,
  });

  bool get isActive => type != DateFilterType.none;

  String getDisplayText() {
    switch (type) {
      case DateFilterType.today:
        return 'Today';
      case DateFilterType.last3Days:
        return 'Last 3 Days';
      case DateFilterType.last7Days:
        return 'Last 7 Days';
      case DateFilterType.last14Days:
        return 'Last 14 Days';
      case DateFilterType.customDate:
        if (customDate != null) {
          return DateFormat('MMM d, y').format(customDate!);
        }
        return 'Custom Date';
      case DateFilterType.none:
        return 'Date Filter';
    }
  }
}

class DateFilterButton extends StatefulWidget {
  final ValueChanged<DateFilterRange> onFilterChanged;

  const DateFilterButton({super.key, required this.onFilterChanged});

  @override
  State<DateFilterButton> createState() => _DateFilterButtonState();
}

class _DateFilterButtonState extends State<DateFilterButton> {
  DateFilterRange _currentFilter = DateFilterRange(type: DateFilterType.none);

  void _showFilterMenu() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<DateFilterType>(
      context: context,
      position: position,
      items: [
        const PopupMenuItem(value: DateFilterType.today, child: Text('Today')),
        const PopupMenuItem(
          value: DateFilterType.last3Days,
          child: Text('Last 3 Days'),
        ),
        const PopupMenuItem(
          value: DateFilterType.last7Days,
          child: Text('Last 7 Days'),
        ),
        const PopupMenuItem(
          value: DateFilterType.last14Days,
          child: Text('Last 14 Days'),
        ),
        const PopupMenuItem(
          value: DateFilterType.customDate,
          child: Text('Custom Date'),
        ),
      ],
    ).then((selected) {
      if (selected != null) {
        _handleFilterSelection(selected);
      }
    });
  }

  void _handleFilterSelection(DateFilterType type) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateFilterRange newFilter;

    switch (type) {
      case DateFilterType.today:
        newFilter = DateFilterRange(
          type: DateFilterType.today,
          startDate: today,
          endDate: today.add(const Duration(days: 1)),
        );
        break;

      case DateFilterType.last3Days:
        newFilter = DateFilterRange(
          type: DateFilterType.last3Days,
          startDate: today.subtract(const Duration(days: 2)),
          endDate: today.add(const Duration(days: 1)),
        );
        break;

      case DateFilterType.last7Days:
        newFilter = DateFilterRange(
          type: DateFilterType.last7Days,
          startDate: today.subtract(const Duration(days: 6)),
          endDate: today.add(const Duration(days: 1)),
        );
        break;

      case DateFilterType.last14Days:
        newFilter = DateFilterRange(
          type: DateFilterType.last14Days,
          startDate: today.subtract(const Duration(days: 13)),
          endDate: today.add(const Duration(days: 1)),
        );
        break;

      case DateFilterType.customDate:
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: today,
          firstDate: DateTime(2020),
          lastDate: today,
        );

        if (pickedDate != null) {
          final selectedDay = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
          );
          newFilter = DateFilterRange(
            type: DateFilterType.customDate,
            startDate: selectedDay,
            endDate: selectedDay.add(const Duration(days: 1)),
            customDate: selectedDay,
          );
        } else {
          return; // User cancelled date picker
        }
        break;

      case DateFilterType.none:
        return;
    }

    setState(() {
      _currentFilter = newFilter;
    });
    widget.onFilterChanged(newFilter);
  }

  void _clearFilter() {
    setState(() {
      _currentFilter = DateFilterRange(type: DateFilterType.none);
    });
    widget.onFilterChanged(_currentFilter);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: _showFilterMenu,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _currentFilter.isActive
                  ? Colors.teal.shade100
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: _currentFilter.isActive
                      ? Colors.teal.shade700
                      : Colors.white,
                ),
                if (_currentFilter.isActive) ...[
                  const SizedBox(width: 6),
                  Text(
                    _currentFilter.getDisplayText(),
                    style: TextStyle(
                      color: Colors.teal.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 20,
                    color: Colors.teal.shade700,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_currentFilter.isActive) ...[
          const SizedBox(width: 4),
          InkWell(
            onTap: _clearFilter,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.clear,
                size: 20,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
