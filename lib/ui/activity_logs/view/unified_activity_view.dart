// lib/ui/activity_logs/view/unified_activity_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/unified_activity_viewmodel.dart';
import '../widgets/unified/stats_card_row.dart';
import '../widgets/unified/unified_table_container.dart';
import '../dialogs/activity_dialog_helper.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';

/// Main unified activity view with enhanced stats
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
      backgroundColor: WebColors.pageBackground,
      body: SafeArea(
        child: state.hasError
            ? _buildErrorState(state.errorMessage ?? 'An error occurred')
            : !state.isLoggedIn && !state.isLoading
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
    // Get enhanced counts with change data
    final countsWithChange = viewModel.getCategoryCountsWithChange();

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
              StatsCardRow(
                countsWithChange: countsWithChange,
                isLoading: state.isLoading,
              ),

              const SizedBox(height: 12),

              // Unified Table Container
              Expanded(
                child: UnifiedTableContainer(
                  items: state.paginatedItems,
                  isLoading: state.isLoading,
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
                  onViewDetails: (item) => ActivityDialogHelper.show(context, ref, item),
                  currentPage: state.currentPage,
                  totalPages: state.totalPages,
                  itemsPerPage: state.itemsPerPage,
                  totalItems: state.filteredActivities.length,
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
}