// lib/ui/core/widgets/table/table_badge.dart

import 'package:flutter/material.dart';

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
        style: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6B7280),
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}