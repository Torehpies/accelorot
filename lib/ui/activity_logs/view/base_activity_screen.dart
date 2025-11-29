// lib/ui/activity_logs/view/base_activity_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/activity_list_state.dart';
import '../widgets/filter_section.dart';
import '../widgets/activity_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/date_filter_button.dart';

/// Clean base screen that only handles UI rendering
/// All business logic is in ViewModels
abstract class BaseActivityScreen extends ConsumerStatefulWidget {
  final String? initialFilter;
  final String? viewingOperatorId;
  final String? focusedMachineId;

  const BaseActivityScreen({
    super.key,
    this.initialFilter,
    this.viewingOperatorId,
    this.focusedMachineId,
  });
}

/// Base state class - Pure UI logic only
abstract class BaseActivityScreenState<T extends BaseActivityScreen>
    extends ConsumerState<T> {
  // ===== ABSTRACT METHODS - Child classes implement =====

  /// Get the state from Riverpod provider
  ActivityListState getState();

  /// Get screen title
  String getScreenTitle();

  /// Get filter options
  List<String> getFilters();

  /// Callback when filter changes
  void onFilterChanged(String filter);

  /// Callback when search changes
  void onSearchChanged(String query);

  /// Callback when search cleared
  void onSearchCleared();

  /// Callback when date filter changes
  void onDateFilterChanged(DateFilterRange filter);

  /// Optional: Callback for refresh
  Future<void> onRefresh() async {}

  // ===== UI STATE =====
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ===== BUILD METHODS =====

  @override
  Widget build(BuildContext context) {
    final state = getState();

    return GestureDetector(
      onTap: () => _searchFocusNode.unfocus(),
      child: Scaffold(
        appBar: _buildAppBar(state),
        body: _buildBody(state),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ActivityListState state) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getScreenTitle(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          if (state.focusedMachineId != null)
            Text(
              'Machine ID: ${state.focusedMachineId}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
        ],
      ),
      backgroundColor: Colors.teal,
      actions: [
        DateFilterButton(onFilterChanged: onDateFilterChanged),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(ActivityListState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          // Machine filter banner
          if (state.focusedMachineId != null) _buildMachineBanner(),

          // Search bar
          SearchBarWidget(
            onSearchChanged: onSearchChanged,
            onClear: onSearchCleared,
            focusNode: _searchFocusNode,
          ),
          const SizedBox(height: 12),

          // Main content area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                border: Border.all(color: Colors.grey[300]!, width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Filter section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: FilterSection(
                      filters: getFilters(),
                      initialFilter: state.selectedFilter,
                      onSelected: onFilterChanged,
                      autoHighlightedFilters: state.autoHighlightedFilters,
                    ),
                  ),

                  // Content (loading, error, list, empty)
                  Expanded(child: _buildContent(state)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMachineBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade50, Colors.teal.shade100],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt,
            color: Colors.teal.shade700,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Showing activities for this machine only',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.teal.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ActivityListState state) {
    // Loading
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.teal),
      );
    }

    // Not logged in
    if (!state.isLoggedIn) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Please log in to view activity logs',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Error
    if (state.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Error loading data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage ?? 'Unknown error',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRefresh,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (state.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                _getEmptyMessage(state),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              if (state.focusedMachineId != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Activities will appear here once waste is added to this machine',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    }

    // List
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.filteredActivities.length,
        itemBuilder: (context, index) {
          return ActivityCard(item: state.filteredActivities[index]);
        },
      ),
    );
  }

  String _getEmptyMessage(ActivityListState state) {
    if (state.focusedMachineId != null) {
      return 'No activities found for this machine';
    }
    if (state.searchQuery.isNotEmpty) {
      return 'No results found for "${state.searchQuery}"';
    }
    return 'No ${state.selectedFilter.toLowerCase()} activities found';
  }
}