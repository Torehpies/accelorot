// lib/ui/core/widgets/shared/pagination_controls.dart

import 'package:flutter/material.dart';
import '../../constants/spacing.dart';
import '../../themes/web_text_styles.dart';
import '../../themes/web_colors.dart';

/// Reusable pagination controls with numbered page buttons and enhanced loading state
class PaginationControls extends StatefulWidget {
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

  @override
  State<PaginationControls> createState() => _PaginationControlsState();
}

class _PaginationControlsState extends State<PaginationControls>
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

  List<int> _getVisiblePages({required bool isCompact}) {
    final maxVisible = isCompact ? 3 : 5;
    if (widget.totalPages <= maxVisible) {
      return List.generate(widget.totalPages, (i) => i + 1);
    }

    final sidePages = isCompact ? 1 : 2;
    final windowSize = 1 + (sidePages * 2);

    int start = (widget.currentPage - sidePages).clamp(
      1,
      widget.totalPages - (windowSize - 1),
    );
    int end = (start + (windowSize - 1)).clamp(windowSize, widget.totalPages);

    if (end == widget.totalPages) {
      start = (widget.totalPages - (windowSize - 1)).clamp(
        1,
        widget.totalPages,
      );
    }

    return List.generate(windowSize, (i) => start + i);
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        final visiblePages = _getVisiblePages(isCompact: isCompact);
        final showLeftEllipsis = visiblePages.first > 1;
        final showRightEllipsis = visiblePages.last < widget.totalPages;
        final pageControls = _buildPageControls(
          showLeftEllipsis: showLeftEllipsis,
          showRightEllipsis: showRightEllipsis,
          visiblePages: visiblePages,
          isCompact: isCompact,
        );
        final spacing = isCompact ? 6.0 : AppSpacing.sm;

        return AnimatedOpacity(
          opacity: widget.isLoading ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildItemsPerPage(context, isCompact: isCompact),
              Expanded(
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _withSpacing(pageControls, spacing),
                  ),
                ),
              ),
              if (!isCompact) const SizedBox(width: 150),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemsPerPage(BuildContext context, {required bool isCompact}) {
    final labelStyle = WebTextStyles.bodyMediumGray.copyWith(
      fontSize: isCompact ? 12 : null,
    );
    final valueStyle = WebTextStyles.bodyMedium.copyWith(
      fontSize: isCompact ? 12 : null,
    );
    final padding = EdgeInsets.symmetric(
      horizontal: isCompact ? 6 : 8,
      vertical: isCompact ? 2 : 4,
    );

    return Row(
      children: [
        Text('Items per page:', style: labelStyle),
        const SizedBox(width: AppSpacing.sm),
        Builder(
          builder: (context) => MouseRegion(
            cursor:
                (widget.isLoading || widget.onItemsPerPageChanged == null)
                ? SystemMouseCursors.basic
                : SystemMouseCursors.click,
            child: InkWell(
              onTap:
                  (widget.isLoading || widget.onItemsPerPageChanged == null)
                  ? null
                  : () => _showItemsPerPageMenu(context),
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: padding,
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
                        style: valueStyle,
                      ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      size: isCompact ? 18 : 20,
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
    );
  }

  List<Widget> _buildPageControls({
    required bool showLeftEllipsis,
    required bool showRightEllipsis,
    required List<int> visiblePages,
    required bool isCompact,
  }) {
    final widgets = <Widget>[
      _buildNavButton(
        icon: Icons.chevron_left,
        label: 'Back',
        isEnabled:
            widget.currentPage > 1 &&
            widget.onPageChanged != null &&
            !widget.isLoading,
        onTap: () => widget.onPageChanged!(widget.currentPage - 1),
        isNext: false,
        isCompact: isCompact,
      ),
    ];

    if (showLeftEllipsis) {
      widgets.addAll([
        _buildPageButton(1),
        Text(
          '...',
          style: WebTextStyles.bodyMediumGray.copyWith(
            fontSize: isCompact ? 12 : null,
          ),
        ),
      ]);
    }

    widgets.addAll(visiblePages.map(_buildPageButton));

    if (showRightEllipsis) {
      widgets.addAll([
        Text(
          '...',
          style: WebTextStyles.bodyMediumGray.copyWith(
            fontSize: isCompact ? 12 : null,
          ),
        ),
        _buildPageButton(widget.totalPages),
      ]);
    }

    widgets.add(
      _buildNavButton(
        icon: Icons.chevron_right,
        label: 'Next',
        isEnabled:
            widget.currentPage < widget.totalPages &&
            widget.onPageChanged != null &&
            !widget.isLoading,
        onTap: () => widget.onPageChanged!(widget.currentPage + 1),
        isNext: true,
        isCompact: isCompact,
      ),
    );

    return widgets;
  }

  List<Widget> _withSpacing(List<Widget> widgets, double spacing) {
    if (widgets.isEmpty) return widgets;
    final spaced = <Widget>[];
    for (var i = 0; i < widgets.length; i++) {
      spaced.add(widgets[i]);
      if (i < widgets.length - 1) {
        spaced.add(SizedBox(width: spacing));
      }
    }
    return spaced;
  }

  Widget _buildPageButton(int page) {
    final isActive = page == widget.currentPage;
    final isCompact = contextSizeIsCompact(context);
    final padding = EdgeInsets.symmetric(
      horizontal: isCompact ? 8 : 12,
      vertical: isCompact ? 4 : 6,
    );
    final textStyle = WebTextStyles.bodyMedium.copyWith(
      fontSize: isCompact ? 12 : null,
      color: isActive ? WebColors.cardBackground : null,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: (widget.onPageChanged != null && !widget.isLoading)
            ? () => widget.onPageChanged!(page)
            : null,
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: padding,
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
                  style: textStyle,
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
    required bool isCompact,
  }) {
    final textStyle = WebTextStyles.bodyMedium.copyWith(
      fontSize: isCompact ? 12 : null,
      color: isEnabled ? WebColors.textSecondary : WebColors.textMuted,
    );

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
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 8 : 16,
              vertical: isCompact ? 6 : 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isNext) ...[
                  Icon(
                    icon,
                    size: isCompact ? 16 : 18,
                    color: isEnabled
                        ? WebColors.textSecondary
                        : WebColors.textMuted,
                  ),
                  SizedBox(width: isCompact ? 4 : 6),
                ],
                Text(
                  label,
                  style: textStyle,
                ),
                if (isNext) ...[
                  SizedBox(width: isCompact ? 4 : 6),
                  Icon(
                    icon,
                    size: isCompact ? 16 : 18,
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

  bool contextSizeIsCompact(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width < 900;
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
