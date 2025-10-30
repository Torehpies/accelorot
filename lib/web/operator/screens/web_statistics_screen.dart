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
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 24) / 2; // Account for 24px gap
        final cardHeight = 300.0;

        return SizedBox(
          height: cardHeight * 2 + 24, // Two rows + gap
          child: Stack(
            children: [
              // Oxygen (top-left)
              Positioned(
                top: 0,
                left: 0,
                child: SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: const OxygenStatsView(),
                ),
              ),
              // Temperature (top-right)
              Positioned(
                top: 0,
                left: cardWidth + 24,
                child: SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: const TemperatureStatsView(),
                ),
              ),
              // Moisture (bottom, full width)
              Positioned(
                top: cardHeight + 24,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: cardHeight,
                  child: const MoistureStatsView(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNarrowLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardHeight = 280.0;

        return SizedBox(
          height: cardHeight * 3 + 40, // 3 cards + 2 gaps (20px each)
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: cardHeight,
                  child: const OxygenStatsView(),
                ),
              ),
              Positioned(
                top: cardHeight + 20,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: cardHeight,
                  child: const TemperatureStatsView(),
                ),
              ),
              Positioned(
                top: (cardHeight + 20) * 2,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: cardHeight,
                  child: const MoistureStatsView(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}