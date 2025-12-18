// lib/ui/core/widgets/table/table_chip.dart

import 'package:flutter/material.dart';
import '../../themes/web_text_styles.dart';

/// Colored chip for type display in tables
class TableChip extends StatelessWidget {
  final String text;
  final Color color;

  const TableChip({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: WebTextStyles.label.copyWith(fontSize: 12, color: color),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}