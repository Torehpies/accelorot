import 'package:flutter/material.dart';
import '../components/system_card.dart';
import '../components/date_filter.dart';
import 'home_screen.dart';
import '../components/history.dart';


class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  StatisticsScreenState createState() => StatisticsScreenState();
}

class StatisticsScreenState extends State<StatisticsScreen> {
  DateTimeRange? selectedRange;
  String selectedFilterLabel = "Date Filter";

  void onDateChanged(DateTimeRange? range) {
    setState(() {
      selectedRange = range;

      if (range == null) {
        selectedFilterLabel = "Date Filter";
      } else {
        final daysDiff = range.end.difference(range.start).inDays;
        if (daysDiff == 3) {
          selectedFilterLabel = "Last 3 Days";
        } else if (daysDiff == 7) {
          selectedFilterLabel = "Last 7 Days";
        } else if (daysDiff == 14) {
          selectedFilterLabel = "Last 14 Days";
        } else {
          // Custom Range label
          selectedFilterLabel =
              "${range.start.month}/${range.start.day} - ${range.end.month}/${range.end.day}";
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea( // 👈 Add this
        child: Column(
          children: [
            // Header (Statistics + Date Filter)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
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
                  DateFilter(onChanged: onDateChanged),
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

                  if (selectedRange != null)
                    HistoryPage(
                      filter: selectedFilterLabel,
                      range: selectedRange!,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
