// lib/ui/reports/widgets/web_table_container.dart

import 'package:flutter/material.dart';
import '../../../data/models/report.dart';
import '../models/reports_state.dart';
import '../../core/widgets/table/table_container.dart';
import '../../core/widgets/shared/pagination_controls.dart';
import '../../core/widgets/filters/search_field.dart';
import '../../core/widgets/filters/date_filter_dropdown.dart';
import '../../core/themes/web_text_styles.dart';
import '../../activity_logs/models/activity_common.dart';
import 'web_table_header.dart';
import 'web_table_body.dart';

class ReportsTableContainer extends StatelessWidget {
  final List<Report> reports;
  final bool isLoading;

  // Filter states
  final ReportStatusFilter selectedStatus;
  final ReportCategoryFilter selectedCategory;
  final ReportPriorityFilter selectedPriority;
  final String searchQuery;

  // Sort states
  final String? sortColumn;
  final bool sortAscending;

  // Pagination states
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final int totalItems;

  // Callbacks
  final ValueChanged<ReportStatusFilter> onStatusChanged;
  final ValueChanged<ReportCategoryFilter> onCategoryChanged;
  final ValueChanged<ReportPriorityFilter> onPriorityChanged;
  final ValueChanged<DateFilterRange> onDateFilterChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSort;
  final ValueChanged<Report> onView;
  final ValueChanged<Report> onEdit;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onItemsPerPageChanged;

  const ReportsTableContainer({
    super.key,
    required this.reports,
    required this.isLoading,
    required this.selectedStatus,
    required this.selectedCategory,
    required this.selectedPriority,
    required this.searchQuery,
    required this.sortColumn,
    required this.sortAscending,
    required this.currentPage,
    required this.totalPages,
    required this.itemsPerPage,
    required this.totalItems,
    required this.onStatusChanged,
    required this.onCategoryChanged,
    required this.onPriorityChanged,
    required this.onDateFilterChanged,
    required this.onSearchChanged,
    required this.onSort,
    required this.onView,
    required this.onEdit,
    required this.onPageChanged,
    required this.onItemsPerPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BaseTableContainer(
      // Left header: Section title
      leftHeaderWidget: const Text(
        'Report List',
        style: WebTextStyles.sectionTitle,
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

      // Table header with filters
      tableHeader: WebTableHeader(
        selectedStatus: selectedStatus,
        selectedCategory: selectedCategory,
        selectedPriority: selectedPriority,
        sortColumn: sortColumn,
        sortAscending: sortAscending,
        onStatusChanged: onStatusChanged,
        onCategoryChanged: onCategoryChanged,
        onPriorityChanged: onPriorityChanged,
        onSort: onSort,
        isLoading: isLoading,
      ),

      // Table body with both view and edit callbacks
      tableBody: WebTableBody(
        reports: reports,
        onView: onView,
        onEdit: onEdit,
        isLoading: isLoading,
      ),

      // Pagination
      paginationWidget: PaginationControls(
        currentPage: currentPage,
        totalPages: totalPages,
        itemsPerPage: itemsPerPage,
        onPageChanged: onPageChanged,
        onItemsPerPageChanged: onItemsPerPageChanged,
        isLoading: isLoading,
      ),
    );
  }
}
