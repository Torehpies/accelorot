// lib/ui/activity_logs/models/activity_list_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../data/models/activity_log_item.dart';
import 'activity_common.dart';

part 'activity_list_state.freezed.dart';

/// Represents the complete state of an activity list screen
@freezed
abstract class ActivityListState with _$ActivityListState {
  const factory ActivityListState({
    // Data
    @Default([]) List<ActivityLogItem> allActivities,
    @Default([]) List<ActivityLogItem> filteredActivities,
    
    // Filter state
    @Default('All') String selectedFilter,
    @Default('') String searchQuery,
    @Default(false) bool isManualFilter,
    @Default(DateFilterRange(type: DateFilterType.none))
    DateFilterRange dateFilter,
    @Default({}) Set<String> autoHighlightedFilters,
    String? selectedBatchId,
    String? selectedMachineId,
    
    // UI state
    @Default(LoadingStatus.initial) LoadingStatus status,
    String? errorMessage,
    @Default(false) bool isLoggedIn,
    
    // Screen configuration
    String? focusedMachineId,
    
    // Pagination
    @Default(10) int displayLimit,
  }) = _ActivityListState;

  const ActivityListState._();

  /// Convenience getters
  bool get isLoading => status == LoadingStatus.loading;
  bool get hasError => status == LoadingStatus.error;
  bool get isEmpty =>
      filteredActivities.isEmpty && status == LoadingStatus.success;

  /// Pagination getters
  List<ActivityLogItem> get displayedActivities {
    if (filteredActivities.length <= displayLimit) {
      return filteredActivities;
    }
    return filteredActivities.take(displayLimit).toList();
  }

  bool get hasMoreToLoad => filteredActivities.length > displayLimit;

  int get remainingCount =>
      (filteredActivities.length - displayLimit).clamp(0, filteredActivities.length);
}