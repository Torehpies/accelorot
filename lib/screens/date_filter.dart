import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;

class DateFilter extends StatefulWidget {
  final void Function(DateTimeRange?) onChanged;

  const DateFilter({super.key, required this.onChanged});

  @override
  _DateFilterState createState() => _DateFilterState();
}

class _DateFilterState extends State<DateFilter> {
  DateTimeRange? _selectedRange;
  String _currentSelection = "Date Filter";

  void _showQuickOptions() {
    DateTime now = DateTime.now();
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(16),
            width: 200, // Smaller width
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Date Range",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildQuickOption("3 Days", () {
                  _setDateRange(DateTimeRange(
                    start: now.subtract(const Duration(days: 3)),
                    end: now,
                  ));
                  Navigator.pop(context);
                }),
                _buildQuickOption("7 Days", () {
                  _setDateRange(DateTimeRange(
                    start: now.subtract(const Duration(days: 7)),
                    end: now,
                  ));
                  Navigator.pop(context);
                }),
                _buildQuickOption("14 Days", () {
                  _setDateRange(DateTimeRange(
                    start: now.subtract(const Duration(days: 14)),
                    end: now,
                  ));
                  Navigator.pop(context);
                }),
                _buildQuickOption("Custom", () {
                  Navigator.pop(context);
                  _pickCustomDateRange();
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickOption(String text, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }

  void _setDateRange(DateTimeRange range) {
    setState(() {
      _selectedRange = range;
      _currentSelection = _getQuickOptionText(range);
    });
    widget.onChanged(_selectedRange);
  }

  String _getQuickOptionText(DateTimeRange range) {
    final now = DateTime.now();
    final daysDiff = range.end.difference(range.start).inDays;
    
    if (daysDiff == 3) return "Last 3 Days";
    if (daysDiff == 7) return "Last 7 Days";
    if (daysDiff == 14) return "Last 14 Days";
    return _formatRange();
  }

  void _pickCustomDateRange() {
    DateTime now = DateTime.now();
    DateTime firstDate = DateTime(2020);
    DateTime lastDate = DateTime(2100);

    DateTime start = _selectedRange?.start ?? now.subtract(const Duration(days: 7));
    DateTime end = _selectedRange?.end ?? now;

    DateTimeRange tempRange = DateTimeRange(start: start, end: end);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              child: Container(
                padding: const EdgeInsets.all(16),
                width: 350,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Custom Range",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
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
                            color: Colors.green.withOpacity(0.5),
                            shape: BoxShape.rectangle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel", style: TextStyle(fontSize: 14)),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedRange = tempRange;
                              _currentSelection = _formatRange();
                            });
                            widget.onChanged(_selectedRange);
                            Navigator.pop(context);
                          },
                          child: const Text("OK", style: TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
      onPressed: _showQuickOptions,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey.shade400),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        _currentSelection,
        style: const TextStyle(fontSize: 14, color: Colors.black),
      ),
    );
  }
}