// lib/ui/core/widgets/base_stats_card.dart

import 'package:flutter/material.dart';
import '../themes/web_colors.dart';

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
        color: WebColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WebColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: WebColors.cardShadow,
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
                    color: WebColors.textLabel,
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
                color: WebColors.skeletonLoader,
                borderRadius: BorderRadius.circular(8),
              ),
            )
          else
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: WebColors.textHeading,
                height: 1.1,
              ),
            ),

          const SizedBox(height: 5),

          // Divider
          const Divider(height: 1, color: WebColors.dividerLight),

          const SizedBox(height: 5),

          // Change Badge + Subtext Row
          if (isLoading)
            Container(
              height: 20,
              width: 140,
              decoration: BoxDecoration(
                color: WebColors.skeletonLoader,
                borderRadius: BorderRadius.circular(6),
              ),
            )
          else if (changeText != null)
            Row(
              children: [
                // Change Text
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
                      color: WebColors.textMuted,
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
                color: WebColors.textMuted,
              ),
            ),
        ],
      ),
    );
  }

  /// Get text color based on change direction
  Color _getChangeTextColor() {
    if (changeText == 'New' || changeText == 'No log yet') {
      return WebColors.neutralStatus;
    }
    return isPositive == true ? WebColors.success : WebColors.error;
  }
}