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
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: false,
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
          padding: EdgeInsets.all(isWideScreen ? 32 : 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: _selectedRange == null
                  ? (isWideScreen ? _buildWideLayout() : _buildNarrowLayout())
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

  Widget _buildWideLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Row: Oxygen + Temperature
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Expanded(child: OxygenStatsView()),
            SizedBox(width: 24),
            Expanded(child: TemperatureStatsView()),
          ],
        ),
        const SizedBox(height: 24),
        
        // Bottom Row: Moisture (full width or centered)
        Row(
          children: const [
            Expanded(child: MoistureStatsView()),
            Expanded(child: SizedBox()), // Empty space for balance
          ],
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        OxygenStatsView(),
        SizedBox(height: 20),
        TemperatureStatsView(),
        SizedBox(height: 20),
        MoistureStatsView(),
      ],
    );
  }
}