// lib/screens/statistics_screen.dart

// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../widgets/humidity_statistic_card.dart'; 
import '../screens/system_card.dart';           
import 'date_filter.dart';
import 'home_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // ignore: unused_field
  DateTimeRange? _selectedRange;

  void _onDateChanged(DateTimeRange? range) {
    setState(() {
      _selectedRange = range;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // 👈 Remove default back button (you have custom one)
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
                      // ignore: deprecated_member_use
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

          // Scrollable content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                // ✅ Full-width System Card
                const SystemCard(),
                const SizedBox(height: 16),

                // ✅ Full-width Humidity Card (no Center or extra padding)
                HumidityStatisticCard(
                  currentHumidity: 38.0,
                  hourlyReadings: [28.0, 45.0, 60.0, 55.0, 42.0, 38.0],
                  lastUpdated: DateTime.now(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}