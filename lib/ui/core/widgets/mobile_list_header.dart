// lib/ui/core/widgets/mobile_list_header.dart

import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import 'filters/mobile_search_bar.dart';

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
        // Add custom filter widgets
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

/// Reusable list header with title, action button, optional selectors, and filters
/// Height automatically adjusts based on content:
/// - Title only: 54px
/// - Title + Search/Filters: 108px
/// - Title + Selectors + Search/Filters: 162px
class MobileListHeader extends StatelessWidget implements PreferredSizeWidget {
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

  const MobileListHeader({
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
  });

  @override
  Size get preferredSize {
    // Calculate height dynamically based on content
    double height = 54;

    // Add selector row height if present
    if (selectorWidgets.isNotEmpty) {
      height += 54;
    }

    // Add search/filter row height if present
    if (searchConfig != null) {
      height += 54;
    }

    return Size.fromHeight(height);
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
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
        child: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: preferredSize.height,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row 1: Title (always present)
                  _buildTitleRow(),

                  // Row 2: Selectors (optional - Machine, Batch, etc.)
                  if (selectorWidgets.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildSelectorRow(),
                  ],

                  // Row 3: Search + Filters (optional)
                  if (searchConfig != null) ...[
                    const SizedBox(height: 12),
                    _MobileFilterBar(
                      searchConfig: searchConfig!,
                      filterWidgets: filterWidgets,
                    ),
                  ],
                ],
              ),
            ),
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
            label: Text(addButtonLabel ?? 'Add Machine'),
            style: ElevatedButton.styleFrom(
              backgroundColor: addButtonColor ?? AppColors.green100,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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