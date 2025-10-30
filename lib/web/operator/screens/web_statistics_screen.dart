// lib/frontend/operator/web/web_statistics_screen.dart
import 'package:flutter/material.dart';
import '../../../frontend/operator/statistics/view_screens/oxygen_stats_view.dart';
import '../../../frontend/operator/statistics/view_screens/moisture_stats_view.dart';
import '../../../frontend/operator/statistics/view_screens/temperature_stats_view.dart';
import '../../../frontend/operator/statistics/widgets/date_filter.dart';
import '../../../frontend/operator/statistics/history/history.dart';

class WebStatisticsScreen extends StatefulWidget {
  final String? viewingOperatorId;

  const WebStatisticsScreen({super.key, this.viewingOperatorId});

  @override
  State<WebStatisticsScreen> createState() => _WebStatisticsScreenState();
}

class _WebStatisticsScreenState extends State<WebStatisticsScreen> {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1200;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Statistics",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade700, Colors.teal.shade900],
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 2,
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
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isWideScreen ? 32 : 16),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: _selectedRange == null
                  ? _buildFlatLayout()
                  : HistoryPage(
                      filter: _selectedFilterLabel,
                      range: _selectedRange!,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // FLAT LAYOUT — NO CARDS, JUST DIRECT CONTENT WITH SPACING
  Widget _buildFlatLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Oxygen Stats
        Padding(
          padding: const EdgeInsets.only(bottom: 24), // Space between sections
          child: const OxygenStatsView(),
        ),
        // Temperature Stats
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: const TemperatureStatsView(),
        ),
        // Moisture Stats
        const MoistureStatsView(),
      ],
    );
  }
}