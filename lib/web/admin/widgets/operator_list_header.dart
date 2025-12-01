// lib/widgets/operator_list_header.dart

import 'package:flutter/material.dart';
import '../../utils/theme_constants.dart';

class OperatorListHeader extends StatelessWidget {
  final bool showArchived;
  final VoidCallback? onBack;

  const OperatorListHeader({
    super.key,
    required this.showArchived,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(ThemeConstants.spacing16),
      child: Row(
        children: [
          // Add back button when viewing archived
          if (showArchived && onBack != null) ...[
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: ThemeConstants.tealShade600,
                size: ThemeConstants.iconSize20,
              ),
              onPressed: onBack,
              tooltip: 'Back to Active Operators',
              padding: EdgeInsets.zero,
              style: IconButton.styleFrom(
                backgroundColor: ThemeConstants.tealShade50,
                minimumSize: const Size(36, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ThemeConstants.borderRadius8,
                  ),
                ),
              ),
            ),
            const SizedBox(width: ThemeConstants.spacing12),
          ],
          Text(
            showArchived ? 'Archived Operators' : 'Active Operators',
            style: TextStyle(
              fontSize: ThemeConstants.fontSize18,
              fontWeight: FontWeight.bold,
              color: ThemeConstants.tealShade600,
            ),
          ),
        ],
      ),
    );
  }
}