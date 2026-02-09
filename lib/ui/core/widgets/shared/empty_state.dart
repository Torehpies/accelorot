// lib/ui/core/widgets/shared/empty_state.dart

import 'package:flutter/material.dart';
import '../../themes/web_text_styles.dart';
import '../../themes/web_colors.dart';

/// Reusable empty state widget
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
            Icon(icon, size: 56, color: WebColors.iconDisabled),
            const SizedBox(height: 12),
            Text(title, style: WebTextStyles.label.copyWith(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: WebTextStyles.bodyMediumGray.copyWith(
                color: WebColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
