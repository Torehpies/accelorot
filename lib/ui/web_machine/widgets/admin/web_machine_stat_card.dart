// lib/ui/machine_management/widgets/admin/web_machine_stat_card.dart
import 'package:flutter/material.dart';
import '../../../core/themes/web_colors.dart';

/// A styled stats card for machine management dashboard,
/// aligned with BaseStatsCard design language.
class MachineStatCard extends StatelessWidget {
  final String title;
  final int count;
  final String percentage;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final bool isPositive;

  const MachineStatCard({
    super.key,
    required this.title,
    required this.count,
    required this.percentage,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    // Determine percentage text color based on direction
    final percentageColor = isPositive ? WebColors.success : WebColors.error;

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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
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

          // Count (as main value)
          Text(
            count.toString(),
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

          // Percentage + Subtitle Row 
          Row(
            children: [
              Text(
                percentage,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: percentageColor, // Green or Red
                ),
              ),
              const SizedBox(width: 4), // Small gap
              Expanded(
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: WebColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}