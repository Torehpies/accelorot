// lib/ui/activity_logs/view/unified_activity_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/unified_activity_viewmodel.dart';
import '../widgets/unified/stats_card_row.dart';
import '../widgets/unified/unified_table_container.dart';
import '../../../data/models/activity_log_item.dart';
import '../../core/constants/spacing.dart';
import 'report_detail_view.dart';
import 'alert_detail_view.dart';
import 'substrate_detail_view.dart';
import 'cycle_detail_view.dart';

/// Main unified activity view - replaces WebActivityLogsMainView
class UnifiedActivityView extends ConsumerWidget {
  final String? focusedMachineId;

  const UnifiedActivityView({
    super.key,
    this.focusedMachineId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(unifiedActivityViewModelProvider.notifier);
    final state = ref.watch(unifiedActivityViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.hasError
                ? _buildErrorState(state.errorMessage ?? 'An error occurred')
                : !state.isLoggedIn
                    ? const Center(child: Text('Please log in to view activities'))
                    : _buildContent(context, ref, viewModel, state),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    UnifiedActivityViewModel viewModel,
    state,
  ) {
    final counts = viewModel.getCategoryCounts();

    return Column(
      children: [
        // Stats Cards Row (reduced padding)
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: StatsCardRow(counts: counts),
        ),

        // Unified Table Container (filter bar + table in one)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              0,
              AppSpacing.xxl,
              AppSpacing.xxl,
            ),
            child: UnifiedTableContainer(
              items: state.paginatedItems,
              selectedMachineId: state.selectedMachineId,
              selectedBatchId: state.selectedBatchId,
              dateFilter: state.dateFilter,
              searchQuery: state.searchQuery,
              selectedCategory: state.selectedCategory,
              selectedType: state.selectedType,
              sortColumn: state.sortColumn,
              sortAscending: state.sortAscending,
              onMachineChanged: viewModel.onMachineChanged,
              onBatchChanged: viewModel.onBatchChanged,
              onDateFilterChanged: viewModel.onDateFilterChanged,
              onSearchChanged: viewModel.onSearchChanged,
              onCategoryChanged: viewModel.onCategoryChanged,
              onTypeChanged: viewModel.onTypeChanged,
              onSort: viewModel.onSort,
              onViewDetails: (item) => _showDetailSheet(context, item),
              currentPage: state.currentPage,
              totalPages: state.totalPages,
              itemsPerPage: state.itemsPerPage,
              totalItems: state.filteredActivities.length,
              onPageChanged: viewModel.onPageChanged,
              onItemsPerPageChanged: viewModel.onItemsPerPageChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaginationControls(viewModel, state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Items per page selector
        Row(
          children: [
            const Text(
              'Items per page:',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            DropdownButton<int>(
              value: state.itemsPerPage,
              items: [10, 25, 50, 100].map((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text('$value'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  viewModel.onItemsPerPageChanged(value);
                }
              },
            ),
          ],
        ),

        // Page navigation
        Row(
          children: [
            Text(
              'Page ${state.currentPage} of ${state.totalPages}',
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: state.currentPage > 1
                  ? () => viewModel.onPageChanged(state.currentPage - 1)
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: state.currentPage < state.totalPages
                  ? () => viewModel.onPageChanged(state.currentPage + 1)
                  : null,
            ),
          ],
        ),
      ],
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
            color: Color(0xFFEF4444),
          ),
          const SizedBox(height: 16),
          const Text(
            'Error',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDetailSheet(BuildContext context, ActivityLogItem item) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        Widget detailView;
        switch (item.type) {
          case ActivityType.report:
            detailView = ReportDetailView(item: item);
            break;
          case ActivityType.alert:
            detailView = AlertDetailView(item: item);
            break;
          case ActivityType.substrate:
            detailView = SubstrateDetailView(item: item);
            break;
          case ActivityType.cycle:
            detailView = CycleDetailView(item: item);
            break;
        }
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: detailView,
          ),
        );
      },
    );
  }
}