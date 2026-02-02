// lib/ui/web_admin_home/widgets/activity_chart.dart
import 'package:flutter/material.dart';

class ActivityChart extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const ActivityChart({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    int maxCount = 0;
    for (var item in activities) {
      final count = item['count'] as int;
      if (count > maxCount) maxCount = count;
    }

    // Calculate dynamic max value
    // Ensure at least 5 for empty/low states
    // Round up to nearest multiple of 5 for nice 5-step intervals
    final interval = ((maxCount > 0 ? maxCount : 5) / 5).ceil();
    final maxValue = interval * 5;

    final yAxisLabels = List.generate(
      6,
      (index) => maxValue - (index * interval),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Activity Overview',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const Spacer(),
              Row(
                children: const [
                  Icon(Icons.square, size: 12, color: Color(0xFF10B981)),
                  SizedBox(width: 6),
                  Text(
                    'Number of Activities Per Day',
                    style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Y-axis labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: yAxisLabels.map((label) {
                    return Text(
                      '$label',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9CA3AF),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 12),
                // Chart area with grid lines and bars
                Expanded(
                  child: Stack(
                    children: [
                      // Horizontal grid lines
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return Container(
                            height: 1,
                            color: const Color(0xFFE5E7EB),
                          );
                        }),
                      ),
                      // Chart bars
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: activities.map((item) {
                          final count = item['count'] as int;
                          final heightFactor = count / maxValue;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: FractionallySizedBox(
                                      alignment: Alignment.bottomCenter,
                                      heightFactor: heightFactor,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981),
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(4),
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item['day'].toString(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
