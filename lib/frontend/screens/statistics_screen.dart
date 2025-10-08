// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../widgets/humidity_statistic_card.dart';
import '../widgets/temperature_statistic_card.dart';
import '../components/system_card.dart';
import 'date_filter.dart';
import 'home_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // ignore: unused_field
  DateTimeRange? _selectedRange;
  // ignore: unused_field
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

  // Consistent horizontal padding for all content cards
  static const EdgeInsets _cardPadding = EdgeInsets.symmetric(horizontal: 12);

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
          // 🔹 Header
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
                DateFilter(onChanged: _onDateChanged),
              ],
            ),
          ),

          // 🔹 FIXED: SystemCard stays in place with matching width
          Padding(padding: _cardPadding, child: const SystemCard()),
          const SizedBox(height: 16),

          // 🔹 SCROLLABLE: Only humidity and temperature cards scroll
          Expanded(
            child: SingleChildScrollView(
              padding: _cardPadding.add(
                const EdgeInsets.symmetric(vertical: 8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HumidityStatisticCard(
                    currentHumidity: 38.0,
                    hourlyReadings: [28.0, 45.0, 60.0, 55.0, 42.0, 38.0],
                    lastUpdated: DateTime.now(),
                  ),
                  const SizedBox(height: 16),
                  TemperatureStatisticCard(
                    currentTemperature: 24.5,
                    hourlyReadings: [22.0, 23.5, 25.0, 26.2, 24.8, 24.5],
                    lastUpdated: DateTime.now(),
                  ),
                  const SizedBox(height: 16),
                  // Add more statistic cards here if needed in the future
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
