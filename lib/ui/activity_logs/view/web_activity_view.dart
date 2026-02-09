// lib/ui/activity_logs/view/web_activity_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/unified_activity_viewmodel.dart';
import '../widgets/web/stats_card_row.dart';
import '../widgets/web/web_table_container.dart';
import '../dialogs/activity_dialog_helper.dart';
import '../../core/widgets/containers/web_base_container.dart';

/// Main unified activity view with enhanced stats
class WebActivityView extends ConsumerWidget {
  const WebActivityView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(unifiedActivityViewModelProvider.notifier);
    final state = ref.watch(unifiedActivityViewModelProvider);

    return WebScaffoldContainer(
      child: state.hasError
          ? WebErrorState(message: state.errorMessage ?? 'An error occurred')
          : !state.isLoggedIn && !state.isLoading
          ? const WebLoginRequired(message: 'Please log in to view activities')
          : WebContentContainer(
              child: WebStatsTableLayout(
                statsRow: StatsCardRow(
                  countsWithChange: viewModel.getCategoryCountsWithChange(),
                  isLoading: state.isLoading,
                  substratesLoadingStatus: state.substratesLoadingStatus,
                  alertsLoadingStatus: state.alertsLoadingStatus,
                  cyclesLoadingStatus: state.cyclesLoadingStatus,
                  reportsLoadingStatus: state.reportsLoadingStatus,
                ),
                table: WebTableContainer(
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
                  onViewDetails: (item) =>
                      ActivityDialogHelper.show(context, ref, item),
                  currentPage: state.currentPage,
                  totalPages: state.totalPages,
                  itemsPerPage: state.itemsPerPage,
                  totalItems: state.filteredActivities.length,
                  onPageChanged: viewModel.onPageChanged,
                  onItemsPerPageChanged: viewModel.onItemsPerPageChanged,
                ),
              ),
            ),
    );
  }
}
