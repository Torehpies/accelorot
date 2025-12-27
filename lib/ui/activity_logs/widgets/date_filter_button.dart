// lib/ui/activity_logs/widgets/date_filter_button.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/activity_common.dart';

class DateFilterButton extends StatefulWidget {
  final ValueChanged<DateFilterRange> onFilterChanged;

  const DateFilterButton({super.key, required this.onFilterChanged});

  @override
  State<DateFilterButton> createState() => _DateFilterButtonState();
}

class _DateFilterButtonState extends State<DateFilterButton> {
  DateFilterRange _currentFilter = const DateFilterRange(type: DateFilterType.none);

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
        newFilter = const DateFilterRange(
          type: DateFilterType.today,
        );
        break;

      case DateFilterType.yesterday:
        newFilter = const DateFilterRange(
          type: DateFilterType.yesterday,
        );
        break;

      case DateFilterType.last7Days:
        newFilter = const DateFilterRange(
          type: DateFilterType.last7Days,
        );
        break;

      case DateFilterType.last30Days:
        newFilter = const DateFilterRange(
          type: DateFilterType.last30Days,
        );
        break;

      case DateFilterType.custom:
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
            type: DateFilterType.custom,
            customDate: selectedDay,
          );
        } else {
          return;
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
      _currentFilter = const DateFilterRange(type: DateFilterType.none);
    });
    widget.onFilterChanged(_currentFilter);
  }

  String _getDisplayText() {
    switch (_currentFilter.type) {
      case DateFilterType.today:
        return 'Today';
      case DateFilterType.yesterday:
        return 'Yesterday';
      case DateFilterType.last7Days:
        return 'Last 7 Days';
      case DateFilterType.last30Days:
        return 'Last 30 Days';
      case DateFilterType.custom:
        if (_currentFilter.customDate != null) {
          return DateFormat('MMM d, y').format(_currentFilter.customDate!);
        }
        return 'Custom Date';
      case DateFilterType.none:
        return 'Date Filter';
    }
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
                  size: 18,
                  color: _currentFilter.isActive
                      ? Colors.teal.shade700
                      : const Color(0xFF6B7280),
                ),
                if (_currentFilter.isActive) ...[
                  const SizedBox(width: 6),
                  Text(
                    _getDisplayText(),
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
                color: Colors.black.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
