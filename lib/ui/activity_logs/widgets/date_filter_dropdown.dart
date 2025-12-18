// lib/ui/activity_logs/widgets/date_filter_dropdown.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/themes/web_text_styles.dart';
import '../models/activity_common.dart';

/// Web-optimized date filter dropdown that matches Machine/Batch selector style
class DateFilterDropdown extends StatefulWidget {
  final ValueChanged<DateFilterRange> onFilterChanged;

  const DateFilterDropdown({super.key, required this.onFilterChanged});

  @override
  State<DateFilterDropdown> createState() => _DateFilterDropdownState();
}

class _DateFilterDropdownState extends State<DateFilterDropdown> {
  DateFilterRange _currentFilter = const DateFilterRange(type: DateFilterType.none);

  void _showFilterMenu() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<DateFilterType>(
      context: context,
      position: position,
      color: Colors.white, // White background for popup menu
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 8,
      items: [
        const PopupMenuItem(value: DateFilterType.today, child: Text('Today')),
        const PopupMenuItem(value: DateFilterType.yesterday, child: Text('Yesterday')),
        const PopupMenuItem(value: DateFilterType.last7Days, child: Text('Last 7 Days')),
        const PopupMenuItem(value: DateFilterType.last30Days, child: Text('Last 30 Days')),
        const PopupMenuItem(value: DateFilterType.custom, child: Text('Custom Date')),
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

      case DateFilterType.yesterday:
        final yesterday = today.subtract(const Duration(days: 1));
        newFilter = DateFilterRange(
          type: DateFilterType.yesterday,
          startDate: yesterday,
          endDate: today,
        );
        break;

      case DateFilterType.last7Days:
        newFilter = DateFilterRange(
          type: DateFilterType.last7Days,
          startDate: today.subtract(const Duration(days: 6)),
          endDate: today.add(const Duration(days: 1)),
        );
        break;

      case DateFilterType.last30Days:
        newFilter = DateFilterRange(
          type: DateFilterType.last30Days,
          startDate: today.subtract(const Duration(days: 29)),
          endDate: today.add(const Duration(days: 1)),
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
          final selectedDay = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
          newFilter = DateFilterRange(
            type: DateFilterType.custom,
            startDate: selectedDay,
            endDate: selectedDay.add(const Duration(days: 1)),
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
    final isActive = _currentFilter.isActive;

    return InkWell(
      onTap: _showFilterMenu,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: isActive ? const Color(0xFF0D9488) : const Color(0xFF6B7280),
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                _getDisplayText(),
                style: WebTextStyles.bodyMedium,
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 20,
                color: const Color(0xFF0D9488),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: _clearFilter,
                borderRadius: BorderRadius.circular(4),
                child: const Icon(
                  Icons.clear,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}