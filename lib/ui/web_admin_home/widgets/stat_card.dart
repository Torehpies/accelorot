  // lib/ui/web_admin_home/widgets/stat_card.dart
  import 'package:flutter/material.dart';

  class StatCard extends StatelessWidget {
    final String title;
    final int value;
    final double growth;
    final IconData icon;
    final Color iconBackgroundColor;

    const StatCard({
      super.key, 
      required this.title, 
      required this.value, 
      required this.growth,
      required this.icon,
      required this.iconBackgroundColor,
    });

    @override
    Widget build(BuildContext context) {
      final isNegative = growth < 0;
      final growthColor = isNegative ? const Color(0xFFEF4444) : const Color(0xFF10B981);
      
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF6B7280))),
                      const SizedBox(height: 4),
                      Text('$value', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            isNegative ? Icons.arrow_downward : Icons.arrow_upward,
                            size: 12,
                            color: growthColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${growth.abs().toStringAsFixed(0)}%',
                            style: TextStyle(fontSize: 11, color: growthColor, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'compared this month',
                              style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: iconBackgroundColor),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }