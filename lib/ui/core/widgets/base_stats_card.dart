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
    this.isPositive,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title and Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              // Icon with colored background
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: iconColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Value
          if (isLoading)
            Container(
              height: 36,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
            )
          else
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
                height: 1,
              ),
            ),

          const SizedBox(height: 12),

          // Change Badge + Subtext Row
          if (isLoading)
            Container(
              height: 20,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
            )
          else if (changeText != null)
            Row(
              children: [
                // Change Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getChangeBadgeColor(),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    changeText!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getChangeTextColor(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Subtext
                const Expanded(
                  child: Text(
                    'from last month',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
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

  /// Get badge background color based on change direction
  Color _getChangeBadgeColor() {
    if (changeText == 'New' || changeText == 'No log yet') {
      return const Color(0xFFE0E7FF); // Neutral blue
    }
    return isPositive == true
        ? const Color(0xFFD1FAE5) // Green
        : const Color(0xFFFEE2E2); // Red
  }

  /// Get text color based on change direction
  Color _getChangeTextColor() {
    if (changeText == 'New' || changeText == 'No log yet') {
      return const Color(0xFF4338CA); // Neutral blue text
    }
    return isPositive == true
        ? const Color(0xFF065F46) // Dark green
        : const Color(0xFF991B1B); // Dark red
  }
}