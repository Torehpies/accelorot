// lib/ui/core/widgets/base_stats_card.dart

import 'package:flutter/material.dart';
import '../constants/spacing.dart';

/// Reusable stats card with icon in top-right corner
class BaseStatsCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;
  final String? changeText;
  final bool showIconBackground;

  const BaseStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.backgroundColor,
    this.changeText,
    this.showIconBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title on left, Icon on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              // Icon (top-right)
              _buildIcon(),
            ],
          ),
          
          const Spacer(),
          
          // Value
          Text(
            '$value',
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: Color(0xFF374151),
              height: 1.0,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Change/Percentage (placeholder)
          Text(
            changeText ?? '—',
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    if (showIconBackground && backgroundColor != null) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      );
    }
    
    return Icon(icon, color: iconColor, size: 26);
  }
}