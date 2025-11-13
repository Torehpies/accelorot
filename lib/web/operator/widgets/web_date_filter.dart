// lib/frontend/operator/statistics/widgets/date_filter_button.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFilter extends StatefulWidget {
  final void Function(DateTimeRange?) onChanged;

  const DateFilter({super.key, required this.onChanged});

  @override
  DateFilterState createState() => DateFilterState();
}

class DateFilterState extends State<DateFilter> {
  DateTimeRange? _selectedRange;
  String _label = "Date Filter";

  void _setPresetRange(int days) {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days - 1));
    final range = DateTimeRange(start: start, end: now);

    setState(() {
      _selectedRange = range;
      _label = "Last $days Days";
    });

    widget.onChanged(range);
  }

  // ✅ Web-friendly custom picker using Flutter's native date range picker
  Future<void> _pickCustomRange() async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
      initialDateRange: _selectedRange,
      // Web-specific: use calendar mode
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: 'Select date range',
      cancelText: 'Cancel',
      confirmText: 'Apply',
      // Optional: style to match your app
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedRange = result;
        _label = _formatRange(result);
      });
      widget.onChanged(result);
    }
  }

  String _formatRange(DateTimeRange range) {
    final start = range.start;
    final end = range.end;
    final fmt = DateFormat('MMM d');
    if (start.month == end.month) {
      return "${fmt.format(start)}–${end.day}";
    } else {
      return "${fmt.format(start)}–${fmt.format(end)}";
    }
  }

  void _clearFilter() {
    setState(() {
      _selectedRange = null;
      _label = "Date Filter";
    });
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            size: 20,
            color: _selectedRange != null ? Colors.teal.shade700 : Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            _label,
            style: TextStyle(
              color: _selectedRange != null
                  ? Colors.teal.shade700
                  : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 2),
          Icon(
            Icons.arrow_drop_down,
            size: 20,
            color: _selectedRange != null ? Colors.teal.shade700 : Colors.white,
          ),
        ],
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (String value) {
        switch (value) {
          case '3':
            _setPresetRange(3);
            break;
          case '7':
            _setPresetRange(7);
            break;
          case '14':
            _setPresetRange(14);
            break;
          case 'custom':
            _pickCustomRange();
            break;
          case 'clear':
            _clearFilter();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: '3', child: Text("Last 3 Days")),
        const PopupMenuItem(value: '7', child: Text("Last 7 Days")),
        const PopupMenuItem(value: '14', child: Text("Last 14 Days")),
        const PopupMenuItem(value: 'custom', child: Text("Custom Range")),
        if (_selectedRange != null)
          const PopupMenuItem(value: 'clear', child: Text("Clear Filter")),
      ],
      // Style the button container
      offset: const Offset(0, 8),
      constraints: const BoxConstraints(minWidth: 120),
    );
  }
}
