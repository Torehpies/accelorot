// date_filter_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;
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

  /// Normalize any DateTime to midnight
  DateTime _normalize(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  void _setPresetRange(int days) {
  final now = _normalize(DateTime.now());
  final start = now.subtract(Duration(days: days - 1));
  // Make end represent end of the current day (23:59:59)
  final end = now.add(const Duration(hours: 23, minutes: 59, seconds: 59));

  final range = DateTimeRange(start: start, end: end);

  setState(() {
    _selectedRange = range;
    _label = "Last $days Days";
  });

  widget.onChanged(range);
}


  Future<void> _pickCustomRange() async {
    DateTime now = _normalize(DateTime.now());
    DateTime firstDate = DateTime(2020);
    DateTime lastDate = DateTime(2100);

    DateTime start = _selectedRange?.start ?? now.subtract(const Duration(days: 7));
    DateTime end = _selectedRange?.end ?? now;
    DateTimeRange tempRange = DateTimeRange(start: start, end: end);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Select Custom Range"),
              content: SizedBox(
                width: 350,
                height: 300,
                child: dp.RangePicker(
                  selectedPeriod: dp.DatePeriod(tempRange.start, tempRange.end),
                  onChanged: (dp.DatePeriod newPeriod) {
                    setDialogState(() {
                      tempRange = DateTimeRange(
                        start: _normalize(newPeriod.start),
                        end: _normalize(newPeriod.end),
                      );
                    });
                  },
                  firstDate: firstDate,
                  lastDate: lastDate,
                  datePickerStyles: dp.DatePickerRangeStyles(
                    selectedPeriodLastDecoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    selectedPeriodStartDecoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    selectedPeriodMiddleDecoration: BoxDecoration(
                      color: Colors.teal.withAlpha(100),
                      shape: BoxShape.rectangle,
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedRange = DateTimeRange(
                        start: _normalize(tempRange.start),
                        end: _normalize(tempRange.end),
                      );
                      _label = _formatRange(_selectedRange!);
                    });
                    widget.onChanged(_selectedRange);
                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
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

  void _showDropdownMenu() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      items: [
        const PopupMenuItem(value: '3', child: Text("Last 3 Days")),
        const PopupMenuItem(value: '7', child: Text("Last 7 Days")),
        const PopupMenuItem(value: '14', child: Text("Last 14 Days")),
        const PopupMenuItem(value: 'custom', child: Text("Custom Range")),
        if (_selectedRange != null)
          const PopupMenuItem(value: 'clear', child: Text("Clear Filter")),
      ],
    ).then((selected) {
      if (selected == null) return;

      switch (selected) {
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
          setState(() {
            _selectedRange = null;
            _label = "Date Filter";
          });
          widget.onChanged(null);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: _showDropdownMenu,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _selectedRange != null ? Colors.teal.shade100 : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
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
                    color: _selectedRange != null ? Colors.teal.shade700 : Colors.white,
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
          ),
        ),
      ],
    );
  }
}
