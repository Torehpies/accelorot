import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final bool isArchived;

  const StatusBadge({
    super.key,
    required this.isArchived,
  });

  @override
  Widget build(BuildContext context) {
    final status = isArchived ? 'Archived' : 'Active';
    final bgColor = isArchived 
        ? const Color(0xFFFEF3C7) 
        : const Color(0xFFD1FAE5);
    final textColor = isArchived 
        ? const Color(0xFF92400E) 
        : const Color(0xFF065F46);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}