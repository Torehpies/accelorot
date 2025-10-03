import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;

class DateFilter extends StatefulWidget {
  final void Function(DateTimeRange?) onChanged;

  const DateFilter({super.key, required this.onChanged});

  @override
  
  // ignore: library_private_types_in_public_api
  _DateFilterState createState() => _DateFilterState();
}

class _DateFilterState extends State<DateFilter> {
  DateTimeRange? _selectedRange;

  void _pickDateRange() {
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
              title: const Text("Select Date Range"),
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
                          // ignore: deprecated_member_use
                      color: Colors.green.withOpacity(0.5),
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

  String _formatRange() {
    if (_selectedRange == null) return "Date Filter";
    return "${_selectedRange!.start.month}/${_selectedRange!.start.day}/${_selectedRange!.start.year} - "
        "${_selectedRange!.end.month}/${_selectedRange!.end.day}/${_selectedRange!.end.year}";
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: _pickDateRange,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey.shade400),
      ),
      child: Text(
        _formatRange(),
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}
