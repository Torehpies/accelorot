// lib/screens/statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ✅ Critical import
import '../components/system_card.dart';
import '../components/date_filter.dart';
import 'home_screen.dart';
import '../components/history.dart'; // ✅ Now used

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
          final format = DateFormat('MMM d');
          _selectedFilterLabel = '${format.format(range.start)} – ${format.format(range.end)}';
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                const SystemCard(),
                const SizedBox(height: 16),
                if (_selectedRange != null)
                  History(
                    filter: _selectedFilterLabel,
                    range: _selectedRange!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}