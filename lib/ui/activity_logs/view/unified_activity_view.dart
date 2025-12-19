// lib/ui/activity_logs/view/unified_activity_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/unified_activity_viewmodel.dart';
import '../widgets/unified/stats_card_row.dart';
import '../widgets/unified/unified_table_container.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import 'base_detail_view.dart';

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
      backgroundColor: const Color(0xFFF0F8FF), // Light blue page background
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

    return Column(
      children: [
        // Stats Cards Row - Shows immediately with loading state
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: StatsCardRow(
            countsWithChange: countsWithChange,
            isLoading: state.isLoading,
          ),
        ),

        // Unified Table Container
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
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
              fontFamily: 'dm-sans',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
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

  void _showDetailSheet(BuildContext context, item) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: BaseDetailView(item: item),
          ),
        );
      },
    );
  }
}