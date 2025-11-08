// lib/frontend/operator/statistics/widgets/statistics_date_filter_controller.dart
import 'package:flutter/material.dart';
// ignore: unused_import
import '../widgets/web_date_filter.dart'; // your existing DateFilter widget

class StatisticsDateFilterController extends StatefulWidget {
  final Widget child;
  final void Function(DateTimeRange? range, String label)? onFilterChanged;

  const StatisticsDateFilterController({
    super.key,
    required this.child,
    this.onFilterChanged,
  });

  @override
  State<StatisticsDateFilterController> createState() =>
      _StatisticsDateFilterControllerState();
}

class _StatisticsDateFilterControllerState
    extends State<StatisticsDateFilterController> {
  DateTimeRange? _selectedRange;
  String _selectedFilterLabel = "Date Filter";

  void _onDateChanged(DateTimeRange? range) {
    setState(() {
      _selectedRange = range;

      if (range == null) {
        _selectedFilterLabel = "Date Filter";
      } else {
        final daysDiff = range.end.difference(range.start).inDays;
        if (daysDiff == 3) {
          _selectedFilterLabel = "Last 3 Days";
        } else if (daysDiff == 7) {
          _selectedFilterLabel = "Last 7 Days";
        } else if (daysDiff == 14) {
          _selectedFilterLabel = "Last 14 Days";
        } else {
          _selectedFilterLabel =
              "${range.start.month}/${range.start.day} - ${range.end.month}/${range.end.day}";
        }
      }
    });

    widget.onFilterChanged?.call(_selectedRange, _selectedFilterLabel);
  }

  void resetFilter() {
    _onDateChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  // Expose state to parent if needed (optional)
  DateTimeRange? get selectedRange => _selectedRange;
  String get selectedFilterLabel => _selectedFilterLabel;
  VoidCallback get onReset => resetFilter;
}
