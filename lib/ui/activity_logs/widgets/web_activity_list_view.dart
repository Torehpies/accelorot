// lib/ui/activity_logs/widgets/web_activity_list_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/activity_viewmodel.dart';
import 'web_loading_state.dart';
import 'web_empty_state.dart';
import 'web_error_state.dart';
import 'web_activity_card.dart';
import 'web_activity_filter_bar.dart';
import 'web_activity_search_bar.dart';
import 'web_date_filter_button.dart';
import 'web_pagination_bar.dart';
import 'machine_selector.dart'; 
import 'batch_selector.dart';  


/// Composite widget that shows a complete paginated activity list
class WebActivityListView extends ConsumerStatefulWidget {
  final ActivityParams params;
  final int itemsPerPage;

  const WebActivityListView({
    super.key,
    required this.params,
    this.itemsPerPage = 10,
  });

  @override
  ConsumerState<WebActivityListView> createState() => _WebActivityListViewState();
}

class _WebActivityListViewState extends ConsumerState<WebActivityListView> {
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activityViewModelProvider(widget.params));
    final viewModel = ref.read(activityViewModelProvider(widget.params).notifier);

    // Loading state
    if (state.isLoading) {
      return const WebLoadingState();
    }

    // Error state
    if (state.hasError) {
      return WebErrorState(
        error: state.errorMessage ?? 'Unknown error',
        onRetry: () => viewModel.refresh(),
      );
    }

    // Calculate pagination
    final totalItems = state.filteredActivities.length;
    final totalPages = totalItems == 0 ? 1 : (totalItems / widget.itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * widget.itemsPerPage;
    final endIndex = (startIndex + widget.itemsPerPage).clamp(0, totalItems);
    final paginatedItems = state.filteredActivities.sublist(startIndex, endIndex);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Machine & Batch Selector Row
          Row(
            children: [
              Expanded(
                child: MachineSelector(
                  selectedMachineId: state.selectedMachineId,
                  onChanged: (value) => viewModel.onMachineChanged(value),
                  isCompact: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: BatchSelector(
                  selectedBatchId: state.selectedBatchId,
                  selectedMachineId: state.selectedMachineId,
                  onChanged: (value) => viewModel.onBatchChanged(value),
                  isCompact: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Filter Bar
          WebActivityFilterBar(
            filters: viewModel.filters,
            selectedFilter: state.selectedFilter,
            onFilterChanged: (filter) {
              viewModel.onFilterChanged(filter);
              setState(() => _currentPage = 1);
            },
            highlightedFilters: state.autoHighlightedFilters,
          ),

          const SizedBox(height: 16),

          // Search Bar & Date Filter
          Row(
            children: [
              Expanded(
                flex: 4,
                child: WebActivitySearchBar(
                  query: state.searchQuery,
                  onChanged: (query) {
                    viewModel.onSearchChanged(query);
                    setState(() => _currentPage = 1);
                  },
                  onClear: () {
                    viewModel.onSearchCleared();
                    setState(() => _currentPage = 1);
                  },
                ),
              ),
              const SizedBox(width: 16),
              WebDateFilterButton(
                onFilterChanged: (filter) {
                  viewModel.onDateFilterChanged(filter);
                  setState(() => _currentPage = 1);
                },
              ),
              const Spacer(flex: 6),
            ],
          ),

          const SizedBox(height: 12),

          // Results Count
          Text(
            totalItems == 0
                ? 'No results found'
                : 'Showing ${startIndex + 1}-$endIndex of $totalItems',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Activity List
          Expanded(
            child: state.isEmpty
                ? const WebEmptyState(
                    message: 'No activities found',
                    icon: Icons.inbox,
                  )
                : ListView.separated(
                    itemCount: paginatedItems.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: Colors.grey),
                    itemBuilder: (context, index) {
                      return WebActivityCard(item: paginatedItems[index]);
                    },
                  ),
          ),

          // Pagination
          if (totalPages > 1) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            WebPaginationBar(
              currentPage: _currentPage,
              totalPages: totalPages,
              onPageChanged: (page) => setState(() => _currentPage = page),
            ),
          ],
        ],
      ),
    );
  }
}