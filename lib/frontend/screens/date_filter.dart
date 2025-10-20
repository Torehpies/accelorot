import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;
import 'package:intl/intl.dart';

class DateFilter extends StatefulWidget {
  final void Function(DateTimeRange?) onChanged;

  const DateFilter({super.key, required this.onChanged});

  @override
  _DateFilterState createState() => _DateFilterState();
}

class _DateFilterState extends State<DateFilter> {
  DateTimeRange? _selectedRange;
  String _label = "Date Filter";

  // Handle preset selections
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

  // Handle custom selection
  void _pickCustomRange() {
    DateTime now = DateTime.now();
    DateTime firstDate = DateTime(2020);
    DateTime lastDate = DateTime(2100);

    DateTime start =
        _selectedRange?.start ?? now.subtract(const Duration(days: 7));
    DateTime end = _selectedRange?.end ?? now;

    DateTimeRange tempRange = DateTimeRange(start: start, end: end);

    showDialog(
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
                        start: newPeriod.start,
                        end: newPeriod.end,
                      );
                    });
                  },
                  firstDate: firstDate,
                  lastDate: lastDate,
                  datePickerStyles: dp.DatePickerRangeStyles(
                    selectedPeriodLastDecoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    selectedPeriodStartDecoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    selectedPeriodMiddleDecoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.5),
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
                      _selectedRange = tempRange;
                      _label = _formatRange(tempRange);
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

  // Format range label for custom selection
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

  // Show dialog with options
  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_view_day),
                title: const Text("Last 3 Days"),
                onTap: () {
                  Navigator.pop(context);
                  _setPresetRange(3);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_view_week),
                title: const Text("Last 7 Days"),
                onTap: () {
                  Navigator.pop(context);
                  _setPresetRange(7);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text("Last 14 Days"),
                onTap: () {
                  Navigator.pop(context);
                  _setPresetRange(14);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text("Custom Range"),
                onTap: () {
                  Navigator.pop(context);
                  _pickCustomRange();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: _showFilterOptions,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey.shade400),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      child: Text(
        _label,
        style: const TextStyle(color: Colors.black, fontSize: 13),
      ),
    );
  }
}
