// lib/ui/reports/view/web_reports_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/reports_viewmodel.dart';
import '../widgets/web_stats_row.dart';
import '../widgets/web_table_container.dart';
import '../../core/themes/web_colors.dart';
import 'report_detail_view.dart';
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
                      onViewDetails: (report) => _showDetailDialog(context, report, viewModel),
                      onPageChanged: viewModel.onPageChanged,
                      onItemsPerPageChanged: viewModel.onItemsPerPageChanged,
                    ),
                  ),
                ),
    );
  }

  void _showDetailDialog(BuildContext context, report, ReportsViewModel viewModel) {
    WebDialogWrapper.show(
      context: context,
      backgroundColor: WebColors.dialogBackground,
      constraints: const BoxConstraints(maxWidth: 800),
      child: ReportDetailView(
        report: report,
        onUpdate: viewModel.updateReport,
      ),
    );
  }
}