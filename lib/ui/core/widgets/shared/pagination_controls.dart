// lib/ui/core/widgets/shared/pagination_controls.dart

import 'package:flutter/material.dart';
import '../../constants/spacing.dart';

/// Reusable pagination controls
/// Extracted from UnifiedTableContainer
class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<int>? onItemsPerPageChanged;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.itemsPerPage,
    this.onPageChanged,
    this.onItemsPerPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Items per page selector
        Row(
          children: [
            const Text(
              'Items per page:',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            DropdownButton<int>(
              value: itemsPerPage,
              items: [10, 25, 50, 100].map((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text('$value'),
                );
              }).toList(),
              onChanged: onItemsPerPageChanged != null
                  ? (value) {
                      if (value != null) {
                        onItemsPerPageChanged!(value);
                      }
                    }
                  : null,
            ),
          ],
        ),

        // Page navigation
        Row(
          children: [
            Text(
              'Page $currentPage of $totalPages',
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: (currentPage > 1 && onPageChanged != null)
                  ? () => onPageChanged!(currentPage - 1)
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: (currentPage < totalPages && onPageChanged != null)
                  ? () => onPageChanged!(currentPage + 1)
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}