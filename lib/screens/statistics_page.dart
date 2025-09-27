import 'package:flutter/material.dart';
import 'system_card.dart';
import 'date_filter.dart';
import 'home_screen.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key}); // ✅ const constructor

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
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
        automaticallyImplyLeading: true,
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
                              builder: (context) => const HomeScreen()),
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
                DateFilter(onChanged: _onDateChanged), // not const
              ],
            ),
          ),

          // Scrollable content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: const [
                SystemCard(),
                SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),

    );
  }
}
