// lib/ui/activity_logs/widgets/web/web_table_container.dart

import 'package:flutter/material.dart';
import '../../../../data/models/activity_log_item.dart';
import '../../models/activity_common.dart';
import '../../models/activity_enums.dart';
import '../../../core/widgets/shared/pagination_controls.dart';
import '../../../core/widgets/table/table_container.dart';
import '../../../core/widgets/filters/search_field.dart';
import '../../../core/themes/web_text_styles.dart';
import 'web_machine_selector.dart';
import 'web_batch_selector.dart';
import '../../../core/widgets/filters/date_filter_dropdown.dart';
import 'web_table_header.dart';
import 'web_table_body.dart';

enum DropdownDisplayMode { full, iconOnly }

/// Unified container for activity logs using BaseTableContainer
class WebTableContainer extends StatelessWidget {
  final List<ActivityLogItem> items;
  final bool isLoading;

  // Filter states
  final String? selectedMachineId;
  final String? selectedBatchId;
  final DateFilterRange dateFilter;
  final String searchQuery;
  final ActivityCategory selectedCategory;
  final ActivitySubType selectedType;

  // Sort states
  final String? sortColumn;
  final bool sortAscending;

  // Pagination states
  final int? currentPage;
  final int? totalPages;
  final int? itemsPerPage;
  final int? totalItems;

  // Callbacks
  final ValueChanged<String?> onMachineChanged;
  final ValueChanged<String?> onBatchChanged;
  final ValueChanged<DateFilterRange> onDateFilterChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ActivityCategory> onCategoryChanged;
  final ValueChanged<ActivitySubType> onTypeChanged;
  final ValueChanged<String> onSort;
  final ValueChanged<ActivityLogItem> onViewDetails;
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<int>? onItemsPerPageChanged;

  const WebTableContainer({
    super.key,
    required this.items,
    required this.isLoading,
    required this.selectedMachineId,
    required this.selectedBatchId,
    required this.dateFilter,
    required this.searchQuery,
    required this.selectedCategory,
    required this.selectedType,
    required this.sortColumn,
    required this.sortAscending,
    required this.onMachineChanged,
    required this.onBatchChanged,
    required this.onDateFilterChanged,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onTypeChanged,
    required this.onSort,
    required this.onViewDetails,
    this.currentPage,
    this.totalPages,
    this.itemsPerPage,
    this.totalItems,
    this.onPageChanged,
    this.onItemsPerPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Two-tier detection system for icon-only mode
        final displayMode = _calculateDisplayMode(context, constraints);

        return BaseTableContainer(
          // Left header: Machine and Batch selectors
          leftHeaderWidget: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 32,
                child: WebMachineSelector(
                  selectedMachineId: selectedMachineId,
                  onChanged: onMachineChanged,
                  displayMode: displayMode,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 32,
                child: WebBatchSelector(
                  selectedBatchId: selectedBatchId,
                  selectedMachineId: selectedMachineId,
                  onChanged: onBatchChanged,
                  displayMode: displayMode,
                ),
              ),
            ],
          ),

          // Right header: Date filter and Search
          rightHeaderWidgets: [
            SizedBox(
              height: 32,
              child: DateFilterDropdown(
                onFilterChanged: onDateFilterChanged,
                isLoading: isLoading,
              ),
            ),
            SearchField(onChanged: onSearchChanged, isLoading: isLoading),
          ],

          tableHeader: ActivityTableHeader(
            selectedCategory: selectedCategory,
            selectedType: selectedType,
            sortColumn: sortColumn,
            sortAscending: sortAscending,
            onCategoryChanged: onCategoryChanged,
            onTypeChanged: onTypeChanged,
            onSort: onSort,
            isLoading: isLoading,
          ),

          tableBody: ActivityTableBody(
            items: items,
            onViewDetails: onViewDetails,
            isLoading: isLoading,
          ),

          // Pagination
          paginationWidget:
              (currentPage != null &&
                  totalPages != null &&
                  itemsPerPage != null)
              ? PaginationControls(
                  currentPage: currentPage!,
                  totalPages: totalPages!,
                  itemsPerPage: itemsPerPage!,
                  onPageChanged: onPageChanged,
                  onItemsPerPageChanged: onItemsPerPageChanged,
                  isLoading: isLoading,
                )
              : null,
        );
      },
    );
  }

  /// Two-tier detection system for responsive icon-only mode
  /// Tier 1: Content-based - triggers if content would overflow
  /// Tier 2: Container-based - triggers if container is too cramped (<800px)
  DropdownDisplayMode _calculateDisplayMode(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    const rightSectionEstimatedWidth =
        380.0; // Date filter + Search + gaps (more realistic)
    const minGapBetweenSections = 24.0; // Spacer minimum
    const containerCrampedThreshold = 800.0; // Increased threshold

    // Tier 2: Container too cramped (fallback)
    if (constraints.maxWidth < containerCrampedThreshold) {
      return DropdownDisplayMode.iconOnly;
    }

    // Tier 1: Content-based detection
    // Estimate left section width based on current selections
    final leftSectionEstimatedWidth = _estimateLeftSectionWidth(context);

    final totalNeeded =
        leftSectionEstimatedWidth +
        rightSectionEstimatedWidth +
        minGapBetweenSections;

    // Add 10% buffer to be more conservative
    final totalNeededWithBuffer = totalNeeded * 1.1;

    if (totalNeededWithBuffer > constraints.maxWidth) {
      return DropdownDisplayMode.iconOnly;
    }

    return DropdownDisplayMode.full;
  }

  /// Estimates the width needed for the left section (Machine + Batch selectors)
  double _estimateLeftSectionWidth(BuildContext context) {
    const iconWidth = 16.0;
    const paddingPerDropdown = 30.0; // Increased: horizontal padding + borders
    const arrowWidth = 20.0;
    const clearButtonWidth = 20.0; // Increased: includes hover space
    const internalGaps =
        24.0; // Increased: gaps between icon, text, arrow, clear
    const gapBetweenDropdowns = 12.0;

    // Estimate Machine dropdown width
    final machineText = selectedMachineId == null
        ? 'All Machines'
        : _getMachineDisplayName();
    final machineTextWidth = _estimateTextWidth(context, machineText);
    final machineDropdownWidth =
        iconWidth +
        machineTextWidth +
        arrowWidth +
        (selectedMachineId != null ? clearButtonWidth : 0) +
        internalGaps +
        paddingPerDropdown;

    // Estimate Batch dropdown width
    final batchText = selectedBatchId ?? 'All Batches';
    final batchTextWidth = _estimateTextWidth(context, batchText);
    final batchDropdownWidth =
        iconWidth +
        batchTextWidth +
        arrowWidth +
        (selectedBatchId != null ? clearButtonWidth : 0) +
        internalGaps +
        paddingPerDropdown;

    return machineDropdownWidth + gapBetweenDropdowns + batchDropdownWidth;
  }

  /// Gets the display name for the selected machine (needs machine data)
  String _getMachineDisplayName() {
    // Fallback to ID if we can't get the name
    // In a real scenario, you'd fetch from provider/state
    // For estimation purposes, assume average length
    return selectedMachineId ?? 'Machine';
  }

  /// Estimates text width using TextPainter
  double _estimateTextWidth(BuildContext context, String text) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: WebTextStyles.bodyMedium),
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.width;
  }
}