// lib/ui/core/widgets/table/table_badge.dart

import 'package:flutter/material.dart';
import '../../themes/web_text_styles.dart';

/// Gray badge for category display in tables
class TableBadge extends StatelessWidget {
  final String text;

  const TableBadge({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: WebTextStyles.bodyMediumGray.copyWith(fontSize: 12),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}