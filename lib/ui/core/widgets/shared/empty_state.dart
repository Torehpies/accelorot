// lib/ui/core/widgets/shared/empty_state.dart

import 'package:flutter/material.dart';

/// Reusable empty state widget
/// Replaces all _buildEmptyState methods
class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const EmptyState({
    super.key,
    this.title = 'No activities found',
    this.subtitle = 'Try adjusting your filters',
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 56,
              color: const Color(0xFFD1D5DB),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}