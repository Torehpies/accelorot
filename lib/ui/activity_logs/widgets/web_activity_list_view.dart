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
import '../models/activity_list_state.dart';
import '../../../data/providers/batch_providers.dart';
import '../../../data/providers/machine_providers.dart';
import '../../../services/sess_service.dart';

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
              // Machine Selector
              Expanded(child: _buildMachineSelector(state, viewModel)),
              const SizedBox(width: 16),
              
              // Batch Selector
              Expanded(child: _buildBatchSelector(state, viewModel)),
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

  Widget _buildMachineSelector(ActivityListState state, ActivityViewModel viewModel) {
    final sessionService = SessionService();
    
    return FutureBuilder<Map<String, dynamic>?>(
      future: sessionService.getCurrentUserData(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final userData = userSnapshot.data;
        final teamId = userData?['teamId'] as String?;

        if (teamId == null) return const SizedBox.shrink();

        final machinesAsync = ref.watch(machinesStreamProvider(teamId));

        return machinesAsync.when(
          data: (machines) {
            if (machines.isEmpty) return const SizedBox.shrink();

            final activeMachines = machines.where((m) => !m.isArchived).toList();
            if (activeMachines.isEmpty) return const SizedBox.shrink();

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.precision_manufacturing, color: Colors.teal.shade700, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<String>(
                      value: state.selectedMachineId,
                      hint: const Text(
                        'All Machines',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: Icon(Icons.arrow_drop_down, color: Colors.teal.shade700),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Machines'),
                        ),
                        ...activeMachines.map((machine) {
                          return DropdownMenuItem<String>(
                            value: machine.id,
                            child: Text(
                              machine.machineName,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }),
                      ],
                      onChanged: (value) => viewModel.onMachineChanged(value),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildBatchSelector(ActivityListState state, ActivityViewModel viewModel) {
    final batchesAsync = ref.watch(userTeamBatchesProvider);

    return batchesAsync.when(
      data: (batches) {
        if (batches.isEmpty) return const SizedBox.shrink();

        // Filter batches by selected machine if applicable
        final filteredBatches = state.selectedMachineId != null
            ? batches.where((b) => b.machineId == state.selectedMachineId).toList()
            : batches;

        if (filteredBatches.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(Icons.inventory_2, color: Colors.teal.shade700, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String>(
                  value: state.selectedBatchId,
                  hint: const Text(
                    'All Batches',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.teal.shade700),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Batches'),
                    ),
                    ...filteredBatches.map((batch) {
                      return DropdownMenuItem<String>(
                        value: batch.id,
                        child: Text(
                          batch.id, // Display actual Firestore batch ID
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) => viewModel.onBatchChanged(value),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}