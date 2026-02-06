// lib/ui/core/widgets/base_stats_card.dart

import 'package:flutter/material.dart';
import '../themes/web_colors.dart';

/// Enhanced stats card with change tracking and animated skeleton loader
class BaseStatsCard extends StatefulWidget {
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
  State<BaseStatsCard> createState() => _BaseStatsCardState();
}

class _BaseStatsCardState extends State<BaseStatsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

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
                  widget.title,
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
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, size: 20, color: widget.iconColor),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Value
          if (widget.isLoading)
            _buildSkeletonBox(height: 53, width: 100)
          else
            Text(
              '${widget.value}',
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
          if (widget.isLoading)
            _buildSkeletonBox(height: 18, width: 180)
          else if (widget.changeText != null && widget.changeText!.isNotEmpty)
            Row(
              children: [
                // Change Text
                Text(
                  widget.changeText!,
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
                    widget.subtext ?? 'from last month',
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
          else if (widget.subtext != null)
            // ✅ Show only subtext when changeText is empty/null
            Text(
              widget.subtext!,
              style: const TextStyle(
                fontSize: 11,
                color: WebColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            )
          else
            const Text(
              '—',
              style: TextStyle(fontSize: 12, color: WebColors.textMuted),
            ),
        ],
      ),
    );
  }

  /// Animated skeleton box with pulsing effect
  Widget _buildSkeletonBox({required double height, required double width}) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Color.lerp(
              WebColors.skeletonLoader,
              WebColors.tableBorder,
              _pulseAnimation.value,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }

  /// Get text color based on change direction
  Color _getChangeTextColor() {
    if (widget.changeText == 'New' || widget.changeText == 'No log yet') {
      return WebColors.neutralStatus;
    }
    return widget.isPositive == true ? WebColors.success : WebColors.error;
  }
}
