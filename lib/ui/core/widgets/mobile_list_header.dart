// lib/ui/core/widgets/mobile_list_header.dart

import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../../../data/models/machine_model.dart';
import '../../activity_logs/models/activity_common.dart';
import 'filters/mobile_search_bar.dart';
import 'filters/mobile_status_filter_button.dart';
import 'filters/mobile_date_filter_button.dart';

/// Configuration for filter bar
class MobileFilterBarConfig {
  final void Function(String) onSearchChanged;
  final void Function(MachineStatusFilter) onStatusFilterChanged;
  final void Function(DateFilterRange) onDateFilterChanged;
  final MachineStatusFilter currentStatusFilter;
  final DateFilterRange currentDateFilter;
  final bool isLoading;
  final String searchHint;
  final bool showStatusFilter;
  final bool showDateFilter;
  final FocusNode? searchFocusNode;

  const MobileFilterBarConfig({
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
    required this.onDateFilterChanged,
    required this.currentStatusFilter,
    required this.currentDateFilter,
    this.isLoading = false,
    this.searchHint = 'Search...',
    this.showStatusFilter = true,
    this.showDateFilter = true,
    this.searchFocusNode,
  });
}

/// Internal filter bar component
class _MobileFilterBar extends StatelessWidget {
  final MobileFilterBarConfig config;

  const _MobileFilterBar({required this.config});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SearchBarWidget(
            onSearchChanged: config.onSearchChanged,
            onClear: () => config.onSearchChanged(''),
            focusNode: config.searchFocusNode ?? FocusNode(),
            hintText: config.searchHint,
            height: 40,
            borderRadius: 12,
          ),
        ),
        if (config.showStatusFilter) ...[
          const SizedBox(width: 8),
          MobileStatusFilterButton(
            currentFilter: config.currentStatusFilter,
            onFilterChanged: config.onStatusFilterChanged,
            isLoading: config.isLoading,
          ),
        ],
        if (config.showDateFilter) ...[
          const SizedBox(width: 8),
          MobileDateFilterButton(
            onFilterChanged: config.onDateFilterChanged,
            isLoading: config.isLoading,
          ),
        ],
      ],
    );
  }
}

/// Reusable list header with title, action button, and filters
class MobileListHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showAddButton;
  final VoidCallback? onAddPressed;
  final Color? addButtonColor;
  final IconData? addButtonIcon;
  final MobileFilterBarConfig? filterBarConfig;

  const MobileListHeader({
    super.key,
    required this.title,
    this.showAddButton = false,
    this.onAddPressed,
    this.addButtonColor,
    this.addButtonIcon,
    this.filterBarConfig,
  });

  @override
  Size get preferredSize => const Size.fromHeight(108);

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
          toolbarHeight: 108,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTitleRow(),
                  const SizedBox(height: 12),
                  if (filterBarConfig != null)
                    _MobileFilterBar(config: filterBarConfig!),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (showAddButton && onAddPressed != null)
          ElevatedButton.icon(
            onPressed: onAddPressed,
            icon: Icon(
              addButtonIcon ?? Icons.add,
              size: 18,
            ),
            label: const Text('Add Machine'),
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
}