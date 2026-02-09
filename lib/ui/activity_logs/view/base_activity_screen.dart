// lib/ui/activity_logs/view/base_activity_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_list_state.dart';
import '../view_model/activity_viewmodel.dart';
import '../widgets/mobile/activity_card.dart';
import '../widgets/mobile/machine_selector.dart';
import '../widgets/mobile/batch_selector.dart';
import '../../core/widgets/containers/mobile_common_widgets.dart';
import '../../core/widgets/containers/mobile_list_header.dart';
import '../../core/widgets/containers/mobile_list_content.dart';
import '../../core/widgets/buttons/compact_back_button.dart';
import '../../core/widgets/sample_cards/data_card_skeleton.dart';
import '../../core/widgets/filters/mobile_date_filter_button.dart';
import '../../core/themes/app_theme.dart';
import '../models/activity_common.dart';
import '../../../data/models/activity_log_item.dart';

/// Clean base screen that only handles UI rendering
/// All business logic is in ViewModels
/// Filter chips removed - using dropdown filters instead
abstract class BaseActivityScreen extends ConsumerStatefulWidget {
  final String? initialFilter;

  const BaseActivityScreen({super.key, this.initialFilter});
}

/// Base state class - Pure UI logic only
abstract class BaseActivityScreenState<T extends BaseActivityScreen>
    extends ConsumerState<T> {
  // ===== ABSTRACT METHODS - Child classes implement =====

  /// Get the state from Riverpod provider
  ActivityListState getState();

  /// Get the ViewModel notifier for accessing methods
  ActivityViewModel getViewModel();

  /// Callback when search changes
  void onSearchChanged(String query);

  /// Callback when search cleared
  void onSearchCleared();

  /// Callback when date filter changes
  void onDateFilterChanged(DateFilterRange filter);

  /// Callback when batch changes
  void onBatchChanged(String? batchId);

  /// Callback when machine changes
  void onMachineChanged(String? machineId);

  /// Callback when status filter changes (optional - override if needed)
  void onStatusChanged(String? status) {
    // Default implementation - child can override
  }

  /// Callback for refresh
  Future<void> onRefresh() async {}

  /// Callback for load more
  void onLoadMore();

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
    final viewModel = getViewModel();

    return MobileScaffoldContainer(
      onTap: () => _searchFocusNode.unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: MobileListHeader(
          // Custom compact back button - fits within constraints
          leading: const CompactBackButton(),

          // Row 1: Title (from ViewModel config)
          title: viewModel.screenTitle,

          // Row 2: Selectors (Machine + Batch)
          selectorWidgets: [
            MachineSelector(
              selectedMachineId: state.selectedMachineId,
              onChanged: onMachineChanged,
              isCompact: true,
            ),
            BatchSelector(
              selectedBatchId: state.selectedBatchId,
              selectedMachineId: state.selectedMachineId,
              onChanged: onBatchChanged,
              onMachineAutoSelect: onMachineChanged,
              isCompact: true,
            ),
          ],

          // Row 3: Search + Status (TODO) + Date
          searchConfig: SearchBarConfig(
            onSearchChanged: onSearchChanged,
            searchFocusNode: _searchFocusNode,
            searchHint: 'Search activities...',
            isLoading: state.isLoading,
          ),
          filterWidgets: [
            // TODO: Add MobileDropdownFilterButton for status here
            MobileDateFilterButton(
              onFilterChanged: onDateFilterChanged,
              isLoading: state.isLoading,
            ),
          ],
        ),

        // Body: Content cards with top padding for breathing room
        body: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: MobileListContent<ActivityLogItem>(
            isLoading: state.isLoading,
            isInitialLoad: state.status == LoadingStatus.loading,
            hasError: state.hasError,
            errorMessage: state.errorMessage,
            items: state.filteredActivities,
            displayedItems: state.displayedActivities,
            hasMoreToLoad: state.hasMoreToLoad,
            remainingCount: state.remainingCount,
            emptyStateConfig: _getEmptyStateConfig(state),
            onRefresh: onRefresh,
            onLoadMore: onLoadMore,
            onRetry: onRefresh,
            itemBuilder: (context, item, index) => ActivityCard(
              item: item,
              onTap: () => _onActivityTap(item),
            ),
            skeletonBuilder: (context, index) => const DataCardSkeleton(),
          ),
        ),
      ),
    );
  }

  // ===== HELPER METHODS =====

  /// Handle activity card tap - override in child if needed
  void _onActivityTap(ActivityLogItem item) {
    // TODO: Show activity detail modal
    // For now, do nothing - will implement modal later
  }

  EmptyStateConfig _getEmptyStateConfig(ActivityListState state) {
    String message;

    // Not logged in
    if (!state.isLoggedIn) {
      return const EmptyStateConfig(
        icon: Icons.login,
        message: 'Please log in to view activity logs',
      );
    }

    // Search query present
    if (state.searchQuery.isNotEmpty) {
      message = 'No results found for "${state.searchQuery}"';
    } else {
      // Generic message (no more filter-specific messages)
      message = 'No activities found';
    }

    return EmptyStateConfig(
      icon: Icons.inbox_outlined,
      message: message,
    );
  }
}