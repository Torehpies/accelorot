// lib/ui/core/widgets/shared/pagination_controls.dart

import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';

/// Reusable pagination controls with numbered page buttons and enhanced loading state
class PaginationTable extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<int>? onItemsPerPageChanged;
  final bool isLoading;

  const PaginationTable({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.itemsPerPage,
    this.onPageChanged,
    this.onItemsPerPageChanged,
    this.isLoading = false,
  });

  @override
  State<PaginationTable> createState() => _PaginationTableState();
}

class _PaginationTableState extends State<PaginationTable>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  List<int> _getVisiblePages() {
    if (widget.totalPages <= 7) {
      return List.generate(widget.totalPages, (i) => i + 1);
    }

    // Show current page with 2 pages on each side
    int start = (widget.currentPage - 2).clamp(1, widget.totalPages - 4);
    int end = (start + 4).clamp(5, widget.totalPages);

    // Adjust start if we're near the end
    if (end == widget.totalPages) {
      start = (widget.totalPages - 4).clamp(1, widget.totalPages);
    }

    return List.generate(5, (i) => start + i);
  }

  void _showItemsPerPageMenu(BuildContext context) async {
    if (widget.isLoading || widget.onItemsPerPageChanged == null) return;

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    final int? selected = await showMenu<int>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 8,
      color: WebColors.cardBackground,
      constraints: const BoxConstraints(maxHeight: 300),
      items: [10, 25, 50, 100].map((value) {
        return PopupMenuItem<int>(value: value, child: Text('$value'));
      }).toList(),
    );

    if (selected != null && selected != widget.itemsPerPage) {
      widget.onItemsPerPageChanged!(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visiblePages = _getVisiblePages();
    final showLeftEllipsis = visiblePages.first > 1;
    final showRightEllipsis = visiblePages.last < widget.totalPages;

    return AnimatedOpacity(
      opacity: widget.isLoading ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Items per page selector with enhanced loading state
          Row(
            children: [
              const Text(
                'Items per page:',
                style: WebTextStyles.bodyMediumGray,
              ),
              const SizedBox(width: AppSpacing.sm),
              Builder(
                builder: (context) => MouseRegion(
                  cursor:
                      (widget.isLoading || widget.onItemsPerPageChanged == null)
                      ? SystemMouseCursors.basic
                      : SystemMouseCursors.click,
                  child: InkWell(
                    onTap:
                        (widget.isLoading ||
                            widget.onItemsPerPageChanged == null)
                        ? null
                        : () => _showItemsPerPageMenu(context),
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.isLoading
                            ? WebColors.inputBackground.withValues(alpha: 0.5)
                            : WebColors.inputBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: widget.isLoading
                              ? WebColors.tableBorder
                              : WebColors.cardBorder,
                          width: widget.isLoading ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.isLoading)
                            _buildSkeletonBox(width: 24, height: 16)
                          else
                            Text(
                              '${widget.itemsPerPage}',
                              style: WebTextStyles.bodyMedium,
                            ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 20,
                            color: widget.isLoading
                                ? WebColors.textMuted
                                : WebColors.textLabel,
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
                _buildNavButton(
                  icon: Icons.chevron_left,
                  label: 'Back',
                  isEnabled:
                      widget.currentPage > 1 &&
                      widget.onPageChanged != null &&
                      !widget.isLoading,
                  onTap: () => widget.onPageChanged!(widget.currentPage - 1),
                  isNext: false,
                ),

                const SizedBox(width: AppSpacing.sm),

                // First page if not visible
                if (showLeftEllipsis) ...[
                  _buildPageButton(1),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('...', style: WebTextStyles.bodyMediumGray),
                  ),
                ],

                // Visible page numbers
                ...visiblePages.map((page) => _buildPageButton(page)),

                // Last page if not visible
                if (showRightEllipsis) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('...', style: WebTextStyles.bodyMediumGray),
                  ),
                  _buildPageButton(widget.totalPages),
                ],

                const SizedBox(width: AppSpacing.sm),

                // Next button
                _buildNavButton(
                  icon: Icons.chevron_right,
                  label: 'Next',
                  isEnabled:
                      widget.currentPage < widget.totalPages &&
                      widget.onPageChanged != null &&
                      !widget.isLoading,
                  onTap: () => widget.onPageChanged!(widget.currentPage + 1),
                  isNext: true,
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
    final isActive = page == widget.currentPage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: (widget.onPageChanged != null && !widget.isLoading)
            ? () => widget.onPageChanged!(page)
            : null,
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? WebColors.success : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: widget.isLoading
                ? Border.all(
                    color: WebColors.tableBorder.withValues(alpha: 0.5),
                    width: 1,
                  )
                : null,
          ),
          child: widget.isLoading && isActive
              ? _buildSkeletonBox(width: 12, height: 16)
              : Text(
                  '$page',
                  style: isActive
                      ? WebTextStyles.bodyMedium.copyWith(
                          color: WebColors.cardBackground,
                        )
                      : WebTextStyles.bodyMedium,
                ),
        ),
      ),
    );
  }

  /// Navigation button (Back/Next) with hover effect
  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required bool isEnabled,
    required VoidCallback onTap,
    required bool isNext,
  }) {
    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(8),
          hoverColor: isEnabled
              ? WebColors.inputBackground
              : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isNext) ...[
                  Icon(
                    icon,
                    size: 18,
                    color: isEnabled
                        ? WebColors.textSecondary
                        : WebColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: WebTextStyles.bodyMedium.copyWith(
                    color: isEnabled
                        ? WebColors.textSecondary
                        : WebColors.textMuted,
                  ),
                ),
                if (isNext) ...[
                  const SizedBox(width: 6),
                  Icon(
                    icon,
                    size: 18,
                    color: isEnabled
                        ? WebColors.textSecondary
                        : WebColors.textMuted,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Animated skeleton box with pulsing effect
  Widget _buildSkeletonBox({required double width, required double height}) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Color.lerp(
              WebColors.skeletonLoader,
              WebColors.tableBorder,
              _pulseAnimation.value,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}
