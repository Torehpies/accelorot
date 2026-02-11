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
          ...filterWidgets.map(
            (widget) =>
                Padding(padding: const EdgeInsets.only(left: 0), child: widget),
          ),
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

  double get _expandedHeight {
    if (selectorWidgets.isEmpty && searchConfig == null) {
      return _collapsedHeight;
    }

    double height = _collapsedHeight;
    const rowSpacing = 8.0;

    if (selectorWidgets.isNotEmpty) {
      const selectorRowHeight = 40.0;
      height += rowSpacing + selectorRowHeight;
    }

    if (searchConfig != null) {
      const searchRowHeight = 40.0;
      height += rowSpacing + searchRowHeight;
    }

    const bottomPadding = 4.0;
    const dividerHeight = 1.5;
    height += bottomPadding + dividerHeight;

    return height;
  }

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
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      title: _buildTitleRow(),
      flexibleSpace: _expandedHeight > _collapsedHeight
          ? FlexibleSpaceBar(
              background: Container(
                color: Colors.white,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Space for title row
                            const SizedBox(height: 44),

                            // Row 2: Selectors (optional)
                            if (selectorWidgets.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              SizedBox(height: 40, child: _buildSelectorRow()),
                            ],

                            // Row 3: Search + Filters (optional)
                            if (searchConfig != null) ...[
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 40,
                                child: _MobileFilterBar(
                                  searchConfig: searchConfig!,
                                  filterWidgets: filterWidgets,
                                ),
                              ),
                            ],

                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              titlePadding: EdgeInsets.zero,
              expandedTitleScale: 1.0,
            )
          : null,
      // Divider for collapsed state
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.5),
        child: Divider(height: 1.5, thickness: 1.5, color: AppColors.grey),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 8)],
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
            icon: Icon(addButtonIcon ?? Icons.add, size: 18),
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
