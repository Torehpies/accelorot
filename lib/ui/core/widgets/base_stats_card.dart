// lib/ui/core/widgets/base_stats_card.dart

import 'package:flutter/material.dart';

/// Enhanced stats card with change tracking and new UI design
class BaseStatsCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String? changeText;
  final String? subtext;
  final bool? isPositive;
  final bool isLoading;

  const BaseStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.changeText,
    this.subtext,
    this.isPositive,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title and Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              // Icon with colored background
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Value
          if (isLoading)
            Container(
              height: 48,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
            )
          else
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
                height: 1.1,
              ),
            ),

          const SizedBox(height: 5),

          // Divider
          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          const SizedBox(height: 5),

          // Change Badge + Subtext Row
          if (isLoading)
            Container(
              height: 20,
              width: 140,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
            )
          else if (changeText != null)
            Row(
              children: [
                // Change Text (Simplified - no badge background)
                Text(
                  changeText!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _getChangeTextColor(),
                  ),
                ),
                const SizedBox(width: 8),
                // Subtext
                Expanded(
                  child: Text(
                    subtext ?? 'from last month',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          else
            const Text(
              '—',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF9CA3AF),
              ),
            ),
        ],
      ),
    );
  }

  /// Get text color based on change direction
  Color _getChangeTextColor() {
    if (changeText == 'New' || changeText == 'No log yet') {
      return const Color(0xFF4338CA); // Neutral blue text
    }
    return isPositive == true
        ? const Color(0xFF10B981) // Consistent green
        : const Color(0xFFEF4444); // Consistent red
  }
}
