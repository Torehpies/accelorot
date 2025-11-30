// lib/ui/activity_logs/models/activity_list_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'activity_log_item.dart';

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
    @Default(DateFilterRange(type: DateFilterType.none)) DateFilterRange dateFilter,
    @Default({}) Set<String> autoHighlightedFilters,
    
    // UI state
    @Default(LoadingStatus.initial) LoadingStatus status,
    String? errorMessage,
    @Default(false) bool isLoggedIn,
    
    // Screen configuration
    String? focusedMachineId,
  }) = _ActivityListState;

  const ActivityListState._();

  /// Convenience getters
  bool get isLoading => status == LoadingStatus.loading;
  bool get hasError => status == LoadingStatus.error;
  bool get isEmpty => filteredActivities.isEmpty && status == LoadingStatus.success;
}

/// Loading status enum
enum LoadingStatus {
  initial,
  loading,
  success,
  error,
}

/// Date filter configuration
@freezed
abstract class DateFilterRange with _$DateFilterRange {
  const factory DateFilterRange({
    required DateFilterType type,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? customDate,
  }) = _DateFilterRange;

  const DateFilterRange._();

  bool get isActive => type != DateFilterType.none && startDate != null && endDate != null;
}

enum DateFilterType {
  none,
  today,
  yesterday,
  last7Days,
  last30Days,
  custom,
}