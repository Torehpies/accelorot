// lib/ui/mobile_admin_home/widgets/status_indicator.dart

import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final bool isArchived;
  final bool showText;
  final double size;

  const StatusIndicator({
    super.key,
    required this.isArchived,
    this.showText = false,
    this.size = 12,
  });

  @override
  Widget build(BuildContext context) {
    final color = isArchived ? Colors.grey[500]! : Colors.teal.shade600;
    if (showText) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            isArchived ? 'Archived' : 'Active',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isArchived ? Colors.grey[700] : Colors.teal.shade800,
            ),
          ),
        ],
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
