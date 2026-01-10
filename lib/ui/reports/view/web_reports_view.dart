// lib/ui/reports/view/web_reports_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/reports_viewmodel.dart';
import '../widgets/web_stats_row.dart';
import '../widgets/web_table_container.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import 'report_detail_view.dart';

class WebReportsView extends ConsumerWidget {
  const WebReportsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(reportsViewModelProvider.notifier);
    final state = ref.watch(reportsViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: state.hasError
            ? _buildErrorState(state.errorMessage ?? 'An error occurred')
            : !state.isLoggedIn && !state.isLoading
                ? const Center(child: Text('Please log in to view reports'))
                : _buildContent(context, ref, viewModel, state),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ReportsViewModel viewModel,
    state,
  ) {
    final statsWithChange = viewModel.getStatsWithChange();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: WebColors.primaryBorder, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Stats Cards Row
              WebStatsRow(
                statsWithChange: statsWithChange,
                isLoading: state.isLoading,
              ),

              const SizedBox(height: 12),

              // Reports Table Container
              Expanded(
                child: ReportsTableContainer(
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: WebColors.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error',
            style: TextStyle(
              fontFamily: 'dm-sans',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: WebColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: WebTextStyles.bodyMediumGray.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(BuildContext context, report, ReportsViewModel viewModel) {
    showDialog(
      context: context,
      barrierColor: WebColors.dialogBarrier,
      builder: (context) {
        return Dialog(
          backgroundColor: WebColors.dialogBackground,
          insetPadding: const EdgeInsets.all(40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ReportDetailView(
              report: report,
              onUpdate: viewModel.updateReport,
            ),
          ),
        );
      },
    );
  }
}