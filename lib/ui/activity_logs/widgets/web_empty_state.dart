// lib/ui/activity_logs/widgets/web_empty_state.dart

import 'package:flutter/material.dart';

/// Widget displayed when no data is found
class WebEmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;

  const WebEmptyState({
    super.key,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
          ],
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}