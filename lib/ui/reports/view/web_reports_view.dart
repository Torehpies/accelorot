// lib/ui/reports/view/web_reports_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/report.dart';
import '../../core/themes/web_colors.dart';
import '../view_model/reports_viewmodel.dart';
import '../widgets/web_stats_row.dart';
import '../widgets/web_table_container.dart';
import '../dialogs/report_view_details_dialog.dart';
import '../dialogs/report_edit_details_dialog.dart';
import '../../core/widgets/web_common_widgets.dart';

class WebReportsView extends ConsumerWidget {
  const WebReportsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(reportsViewModelProvider.notifier);
    final state = ref.watch(reportsViewModelProvider);

    return WebScaffoldContainer(
      child: state.hasError
          ? WebErrorState(message: state.errorMessage ?? 'An error occurred')
          : !state.isLoggedIn && !state.isLoading
          ? const WebLoginRequired(message: 'Please log in to view reports')
          : WebContentContainer(
              child: WebStatsTableLayout(
                statsRow: WebStatsRow(
                  statsWithChange: viewModel.getStatsWithChange(),
                  isLoading: state.isLoading,
                ),
                table: ReportsTableContainer(
                  reports: state.paginatedReports,
                  isLoading: state.isLoading,
                  selectedStatus: state.selectedStatus,
                  selectedCategory: state.selectedCategory,
                  selectedPriority: state.selectedPriority,
                  searchQuery: state.searchQuery,
                  sortColumn: state.sortColumn,
                  sortAscending: state.sortAscending,
                  currentPage: state.currentPage,
                  totalPages: state.totalPages,
                  itemsPerPage: state.itemsPerPage,
                  totalItems: state.filteredReports.length,
                  onStatusChanged: viewModel.onStatusChanged,
                  onCategoryChanged: viewModel.onCategoryChanged,
                  onPriorityChanged: viewModel.onPriorityChanged,
                  onDateFilterChanged: viewModel.onDateFilterChanged,
                  onSearchChanged: viewModel.onSearchChanged,
                  onSort: viewModel.onSort,
                  onView: (report) => _showViewDialog(context, report),
                  onEdit: (report) =>
                      _showEditDialog(context, report, viewModel),
                  onPageChanged: viewModel.onPageChanged,
                  onItemsPerPageChanged: viewModel.onItemsPerPageChanged,
                ),
              ),
            ),
    );
  }

  void _showViewDialog(BuildContext context, Report report) {
    showDialog(
      context: context,
      barrierColor: WebColors.dialogBarrier,
      barrierDismissible: true,
      builder: (context) => ReportViewDetailsDialog(report: report),
    );
  }

  void _showEditDialog(
    BuildContext context,
    Report report,
    ReportsViewModel viewModel,
  ) {
    showDialog(
      context: context,
      barrierColor: WebColors.dialogBarrier,
      barrierDismissible: false, // Prevent closing while editing
      builder: (context) => ReportEditDetailsDialog(
        report: report,
        onUpdate: viewModel.updateReport,
      ),
    );
  }
}
