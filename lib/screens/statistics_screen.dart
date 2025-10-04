// lib/screens/statistics_screen.dart
import 'package:flutter/material.dart';
import '../widgets/humidity_statistic_card.dart'; 
import '../components/system_card.dart';           
import 'date_filter.dart';
import 'home_screen.dart';
// import '../components/history.dart'; // Optional: remove if not used

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key}); // ✅ Only one constructor

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState(); // ✅ Correct return type
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // ignore: unused_field
  DateTimeRange? _selectedRange; // ✅ Declare private fields
  // ignore: unused_field
  String _selectedFilterLabel = "Date Filter";

  void _onDateChanged(DateTimeRange? range) { // ✅ Match method name passed to DateFilter
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header (Statistics + Date Filter)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.2),
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
                            builder: (context) => const HomeScreen(),
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
                DateFilter(onChanged: _onDateChanged), // ✅ Now matches method name
              ],
            ),
          ),

          // Scrollable content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                const SystemCard(),
                const SizedBox(height: 16),
                HumidityStatisticCard(
                  currentHumidity: 38.0,
                  hourlyReadings: [28.0, 45.0, 60.0, 55.0, 42.0, 38.0],
                  lastUpdated: DateTime.now(),
                ),
                const SizedBox(height: 16),
                // Optional: Add History widget here if needed later
                // if (_selectedRange != null)
                //   History(filter: _selectedFilterLabel, range: _selectedRange!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}