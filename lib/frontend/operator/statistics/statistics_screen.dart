// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'view_screens/oxygen_stats_view.dart';
import 'view_screens/moisture_stats_view.dart';
import 'view_screens/temperature_stats_view.dart';
import 'widgets/date_filter.dart';
import '../../screens/main_navigation.dart';
import '../../components/history.dart'; // make sure this path is correct
import '../dashboard/home_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
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
  }

  void _resetFilter() {
    setState(() {
      _selectedRange = null;
      _selectedFilterLabel = "Date Filter";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          "Statistics",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DateFilter(onChanged: _onDateChanged),
          ),
          if (_selectedRange != null)
            IconButton(
              tooltip: "Reset to Default View",
              icon: const Icon(Icons.refresh),
              onPressed: _resetFilter,
            ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: _selectedRange == null
            ? ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 8),
                  const OxygenStatsView(),
                  const SizedBox(height: 12),
                  const TemperatureStatsView(),
                  const SizedBox(height: 12),
                  const MoistureStatsView(),
                  const SizedBox(height: 12),
                ],
              )
            : HistoryPage(
                filter: _selectedFilterLabel,
                range: _selectedRange!,
              ),
      ),
    );
  }
}
