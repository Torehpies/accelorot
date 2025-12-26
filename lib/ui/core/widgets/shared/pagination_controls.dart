// lib/ui/core/widgets/shared/pagination_controls.dart

import 'package:flutter/material.dart';
import '../../constants/spacing.dart';
import '../../themes/web_text_styles.dart';
import '../../themes/web_colors.dart';

/// Reusable pagination controls with numbered page buttons
class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<int>? onItemsPerPageChanged;
  final bool isLoading;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.itemsPerPage,
    this.onPageChanged,
    this.onItemsPerPageChanged,
    this.isLoading = false,
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

  void _showItemsPerPageMenu(BuildContext context) async {
    if (isLoading || onItemsPerPageChanged == null) return;

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final int? selected = await showMenu<int>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 8,
      color: WebColors.cardBackground,
      constraints: const BoxConstraints(
        maxHeight: 300,
      ),
      items: [10, 25, 50, 100].map((value) {
        return PopupMenuItem<int>(
          value: value,
          child: Text('$value'),
        );
      }).toList(),
    );

    if (selected != null && selected != itemsPerPage) {
      onItemsPerPageChanged!(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visiblePages = _getVisiblePages();
    final showLeftEllipsis = visiblePages.first > 1;
    final showRightEllipsis = visiblePages.last < totalPages;

    return Opacity(
      opacity: isLoading ? 0.6 : 1.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Items per page selector with filter chip styling
          Row(
            children: [
              const Text(
                'Items per page:',
                style: WebTextStyles.bodyMediumGray,
              ),
              const SizedBox(width: AppSpacing.sm),
              Builder(
                builder: (context) => MouseRegion(
                  cursor: (isLoading || onItemsPerPageChanged == null) 
                      ? SystemMouseCursors.basic 
                      : SystemMouseCursors.click,
                  child: InkWell(
                    onTap: (isLoading || onItemsPerPageChanged == null) 
                        ? null 
                        : () => _showItemsPerPageMenu(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: WebColors.inputBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: WebColors.cardBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$itemsPerPage',
                            style: WebTextStyles.bodyMedium,
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_drop_down,
                            size: 20,
                            color: WebColors.textLabel,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
                  onPressed: (currentPage > 1 && onPageChanged != null && !isLoading)
                      ? () => onPageChanged!(currentPage - 1)
                      : null,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: WebColors.textSecondary,
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.chevron_left, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Back',
                        style: WebTextStyles.bodyMedium,
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
                      style: WebTextStyles.bodyMediumGray,
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
                      style: WebTextStyles.bodyMediumGray,
                    ),
                  ),
                  _buildPageButton(totalPages),
                ],

                const SizedBox(width: AppSpacing.sm),

                // Next button
                TextButton(
                  onPressed: (currentPage < totalPages && onPageChanged != null && !isLoading)
                      ? () => onPageChanged!(currentPage + 1)
                      : null,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: WebColors.textSecondary,
                  ),
                  child: Row(
                    children: const [
                      Text(
                        'Next',
                        style: WebTextStyles.bodyMedium,
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 150),
        ],
      ),
    );
  }

  Widget _buildPageButton(int page) {
    final isActive = page == currentPage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: (onPageChanged != null && !isLoading) ? () => onPageChanged!(page) : null,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? WebColors.success : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$page',
            style: isActive 
              ? WebTextStyles.bodyMedium.copyWith(color: WebColors.cardBackground) 
              : WebTextStyles.bodyMedium,
          ),
        ),
      ),
    );
  }
}