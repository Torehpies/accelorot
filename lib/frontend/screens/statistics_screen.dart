// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import '../widgets/oxygen_statistic_card.dart';
import '../widgets/moisture_statistic_card.dart';
import '../widgets/temperature_statistic_card.dart';
import 'date_filter.dart';
import 'main_navigation.dart';
import '../components/history.dart'; // make sure this path is correct
//import '../../operator/dashboard/home_screen.dart';

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
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigation()),
              (route) => false,
            );
          },
        ),
        actions: [
          // Date Filter Button
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DateFilter(onChanged: _onDateChanged),
          ),

          // 👇 Reset Button (only visible when range is selected)
          if (_selectedRange != null)
            IconButton(
              tooltip: "Reset to Default View",
              icon: const Icon(Icons.refresh),
              onPressed: _resetFilter,
            ),
        ],
      ),

      // Body
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: _selectedRange == null
            ? ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 8),
                  OxygenStatisticCard(
                    currentOxygen: 38.0,
                    hourlyReadings: [28.0, 45.0, 60.0, 55.0, 42.0, 38.0],
                    lastUpdated: DateTime.now(),
                  ),
                  const SizedBox(height: 12),
                  TemperatureStatisticCard(
                    currentTemperature: 22.5,
                    hourlyReadings: [20.0, 21.5, 22.0, 22.5, 23.0, 21.0],
                    lastUpdated: DateTime.now(),
                  ),
                  const SizedBox(height: 12),
                  MoistureStatisticCard(
                    currentMoisture: 45.0,
                    hourlyReadings: [30.0, 35.0, 40.0, 45.0, 50.0, 55.0],
                    lastUpdated: DateTime.now(),
                  ),
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
