// lib/ui/core/widgets/shared/pagination_controls.dart

import 'package:flutter/material.dart';
import '../../constants/spacing.dart';

/// Reusable pagination controls with numbered page buttons
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

  List<int> _getVisiblePages() {
    if (totalPages <= 7) {
      return List.generate(totalPages, (i) => i + 1);
    }

    // Show current page with 2 pages on each side
    int start = (currentPage - 2).clamp(1, totalPages - 4);
    int end = (start + 4).clamp(5, totalPages);
    
    // Adjust start if we're near the end
    if (end == totalPages) {
      start = (totalPages - 4).clamp(1, totalPages);
    }

    return List.generate(5, (i) => start + i);
  }

  @override
  Widget build(BuildContext context) {
    final visiblePages = _getVisiblePages();
    final showLeftEllipsis = visiblePages.first > 1;
    final showRightEllipsis = visiblePages.last < totalPages;

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

        // Centered page navigation with numbered buttons
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Back button
              TextButton(
                onPressed: (currentPage > 1 && onPageChanged != null)
                    ? () => onPageChanged!(currentPage - 1)
                    : null,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  children: const [
                    Icon(Icons.chevron_left, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // First page if not visible
              if (showLeftEllipsis) ...[
                _buildPageButton(1),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '...',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],

              // Visible page numbers
              ...visiblePages.map((page) => _buildPageButton(page)),

              // Last page if not visible
              if (showRightEllipsis) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '...',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
                _buildPageButton(totalPages),
              ],

              const SizedBox(width: AppSpacing.sm),

              // Next button
              TextButton(
                onPressed: (currentPage < totalPages && onPageChanged != null)
                    ? () => onPageChanged!(currentPage + 1)
                    : null,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  children: const [
                    Text(
                      'Next',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Empty spacer to keep items-per-page on the left
        const SizedBox(width: 150),
      ],
    );
  }

  Widget _buildPageButton(int page) {
    final isActive = page == currentPage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: onPageChanged != null ? () => onPageChanged!(page) : null,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF10B981) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$page',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.white : const Color(0xFF374151),
            ),
          ),
        ),
      ),
    );
  }
}