import 'package:flutter/material.dart';
import '../widgets/oxygen_statistic_card.dart';
import '../components/date_filter.dart';
import '../components/history.dart';
import 'main_navigation.dart';

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

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea( 
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6), 
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.black),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainNavigation(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Statistics',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                DateFilter(onChanged: _onDateChanged),
              ],
            ),
          ),

          Expanded(
            child: _selectedRange == null
                ? ListView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    children: [
                      const SizedBox(height: 16),
                      OxygenStatisticCard(
                        currentOxygen: 21.0,
                        hourlyReadings: [20.8, 21.1, 21.2, 20.9, 21.0, 21.1],
                        lastUpdated: DateTime.now(),
                      ),
                    ],
                  )
                : HistoryPage(
                    filter: _selectedFilterLabel,
                    range: _selectedRange!,
                  ),
          ),
        ],
      ),
    ),
  );
}
}
