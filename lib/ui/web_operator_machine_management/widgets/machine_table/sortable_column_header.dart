import 'package:flutter/material.dart';

class SortableColumnHeader extends StatelessWidget {
  final String text;
  final bool isCurrentSort;
  final bool ascending;
  final VoidCallback onTap;

  const SortableColumnHeader({
    super.key,
    required this.text,
    required this.isCurrentSort,
    required this.ascending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isCurrentSort 
                  ? const Color(0xFF3B82F6) 
                  : const Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isCurrentSort
                ? (ascending ? Icons.arrow_upward : Icons.arrow_downward)
                : Icons.unfold_more,
            size: 16,
            color: isCurrentSort 
                ? const Color(0xFF3B82F6) 
                : const Color(0xFF9CA3AF),
          ),
        ],
      ),
    );
  }
}