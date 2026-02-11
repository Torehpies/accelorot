// lib/ui/core/widgets/containers/mobile_sliver_header.dart

import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';
import '../filters/mobile_search_bar.dart';

/// Configuration for search bar
class SearchBarConfig {
  final void Function(String) onSearchChanged;
  final String searchHint;
  final bool isLoading;
  final FocusNode? searchFocusNode;

  const SearchBarConfig({
    required this.onSearchChanged,
    this.searchHint = 'Search...',
    this.isLoading = false,
    this.searchFocusNode,
  });
}

/// Internal filter bar component with generic filter widgets
class _MobileFilterBar extends StatelessWidget {
  final SearchBarConfig searchConfig;
  final List<Widget> filterWidgets;

  const _MobileFilterBar({
    required this.searchConfig,
    required this.filterWidgets,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SearchBarWidget(
            onSearchChanged: searchConfig.onSearchChanged,
            onClear: () => searchConfig.onSearchChanged(''),
            focusNode: searchConfig.searchFocusNode ?? FocusNode(),
            hintText: searchConfig.searchHint,
            height: 40,
            borderRadius: 12,
          ),
        ),
        if (filterWidgets.isNotEmpty) ...[
          const SizedBox(width: 8),
          ...filterWidgets.map((widget) => Padding(
                padding: const EdgeInsets.only(left: 0),
                child: widget,
              )),
        ],
      ],
    );
  }
}

class MobileSliverHeader extends StatelessWidget {
  final String title;
  final Widget? leading;
  final bool showAddButton;
  final VoidCallback? onAddPressed;
  final Color? addButtonColor;
  final IconData? addButtonIcon;
  final String? addButtonLabel;
  final List<Widget> selectorWidgets;
  final SearchBarConfig? searchConfig;
  final List<Widget> filterWidgets;
  final bool pinned;
  final bool floating;

  const MobileSliverHeader({
    super.key,
    required this.title,
    this.leading,
    this.showAddButton = false,
    this.onAddPressed,
    this.addButtonColor,
    this.addButtonIcon,
    this.addButtonLabel,
    this.selectorWidgets = const [],
    this.searchConfig,
    this.filterWidgets = const [],
    this.pinned = true,
    this.floating = false,
  });

  /// Calculate expanded height based on content rows
  double get _expandedHeight {
    // If no expandable content (no selectors, no search), just use collapsed height
    if (selectorWidgets.isEmpty && searchConfig == null) {
      return _collapsedHeight;
    }
    
    double height = _collapsedHeight; // Start with collapsed height (title row)
    
    // Add spacing and content for expandable rows
    const rowSpacing = 12.0;
    
    // Row 2: Selectors (optional)
    if (selectorWidgets.isNotEmpty) {
      const selectorRowHeight = 40.0;
      height += rowSpacing + selectorRowHeight;
    }
    
    // Row 3: Search + Filters (optional)
    if (searchConfig != null) {
      const searchRowHeight = 40.0;
      height += rowSpacing + searchRowHeight;
    }
    
    // Add bottom padding for expanded content
    const bottomPadding = 12.0;
    height += bottomPadding;
    
    return height;
  }

  /// Collapsed height - just title row
  double get _collapsedHeight {
    const topPadding = 12.0;
    const bottomPadding = 12.0;
    const titleRowHeight = 32.0;
    return topPadding + titleRowHeight + bottomPadding;
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: pinned,
      floating: floating,
      expandedHeight: _expandedHeight,
      collapsedHeight: _collapsedHeight,
      toolbarHeight: _collapsedHeight,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      automaticallyImplyLeading: false,
      
      // Title row (visible in both collapsed and expanded states)
      title: _buildTitleRow(),
      
      // Expanded content (visible when expanded) - NO DUPLICATE TITLE
      flexibleSpace: _expandedHeight > _collapsedHeight
          ? FlexibleSpaceBar(
              background: Container(
                color: AppColors.background,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Space for title row (handled by SliverAppBar.title)
                        SizedBox(height: _collapsedHeight),

                        // Row 2: Selectors (optional)
                        if (selectorWidgets.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 40,
                            child: _buildSelectorRow(),
                          ),
                        ],

                        // Row 3: Search + Filters (optional)
                        if (searchConfig != null) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 40,
                            child: _MobileFilterBar(
                              searchConfig: searchConfig!,
                              filterWidgets: filterWidgets,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              titlePadding: EdgeInsets.zero,
              expandedTitleScale: 1.0,
            )
          : null, // No flexible space if no expandable content
      
      // Bottom border shadow
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (showAddButton && onAddPressed != null)
          ElevatedButton.icon(
            onPressed: onAddPressed,
            icon: Icon(
              addButtonIcon ?? Icons.add,
              size: 18,
            ),
            label: Text(
              addButtonLabel ?? 'Add Machine',
              style: const TextStyle(
                fontSize: 14,
                height: 1.2,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: addButtonColor ?? AppColors.green100,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
      ],
    );
  }

  Widget _buildSelectorRow() {
    return Row(
      children: [
        for (int i = 0; i < selectorWidgets.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: selectorWidgets[i]),
        ],
      ],
    );
  }
}