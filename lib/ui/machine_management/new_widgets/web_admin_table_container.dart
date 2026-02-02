// lib/ui/machine_management/new_widgets/web_admin_table_container.dart

import 'package:flutter/material.dart';
import '../../../data/models/machine_model.dart';
import '../../core/widgets/table/table_container.dart';
import '../../core/widgets/shared/pagination_controls.dart';
import '../../core/widgets/filters/search_field.dart';
import '../../core/widgets/filters/date_filter_dropdown.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../../../ui/activity_logs/models/activity_common.dart';
import 'web_table_header.dart';
import 'web_table_body.dart';

class WebAdminTableContainer extends StatelessWidget {
  final List<MachineModel> machines;
  final bool isLoading;

  // Filter states
  final MachineStatusFilter selectedStatusFilter;
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
  final ValueChanged<MachineStatusFilter> onStatusFilterChanged;
  final ValueChanged<DateFilterRange> onDateFilterChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSort;
  final ValueChanged<MachineModel> onEdit;
  final ValueChanged<MachineModel> onView;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onItemsPerPageChanged;
  final VoidCallback onAddMachine;

  const WebAdminTableContainer({
    super.key,
    required this.machines,
    required this.isLoading,
    required this.selectedStatusFilter,
    required this.searchQuery,
    required this.sortColumn,
    required this.sortAscending,
    required this.currentPage,
    required this.totalPages,
    required this.itemsPerPage,
    required this.totalItems,
    required this.onStatusFilterChanged,
    required this.onDateFilterChanged,
    required this.onSearchChanged,
    required this.onSort,
    required this.onEdit,
    required this.onView,
    required this.onPageChanged,
    required this.onItemsPerPageChanged,
    required this.onAddMachine,
  });

  @override
  Widget build(BuildContext context) {
    return BaseTableContainer(
      // Left header: Section title
      leftHeaderWidget: const Text(
        'Machine List',
        style: WebTextStyles.sectionTitle,
      ),

      // Right header: Date filter, Search, Add button
      rightHeaderWidgets: [
        SizedBox(
          height: 32,
          child: DateFilterDropdown(
            onFilterChanged: onDateFilterChanged,
            isLoading: isLoading,
          ),
        ),
        SizedBox(
          height: 32,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
                child: SearchField(
                  hintText: 'Search...',
                  onChanged: onSearchChanged,
                  isLoading: isLoading,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: isLoading ? null : onAddMachine,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Machine'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: WebColors.greenAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],

      // Table header with filters
      tableHeader: MachineTableHeader(
        selectedStatusFilter: selectedStatusFilter,
        sortColumn: sortColumn,
        sortAscending: sortAscending,
        onStatusFilterChanged: onStatusFilterChanged,
        onSort: onSort,
        isLoading: isLoading,
      ),

      // Table body
      tableBody: MachineTableBody(
        machines: machines,
        onEdit: onEdit,
        onView: onView,
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
