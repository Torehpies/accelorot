// lib/ui/activity_logs/models/unified_activity_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../data/models/activity_log_item.dart';
import 'activity_common.dart';
import 'activity_enums.dart';

part 'unified_activity_state.freezed.dart';

/// State for unified activity view
@freezed
abstract class UnifiedActivityState with _$UnifiedActivityState {
  const factory UnifiedActivityState({
    // Global filters (affect all data)
    String? selectedMachineId,
    String? selectedBatchId,
    @Default(DateFilterRange(type: DateFilterType.none)) DateFilterRange dateFilter,
    @Default('') String searchQuery,
    
    // Table filters - NOW USING ENUMS
    @Default(ActivityCategory.all) ActivityCategory selectedCategory,
    @Default(ActivitySubType.all) ActivitySubType selectedType,
    
    // Sorting
    String? sortColumn,
    @Default(true) bool sortAscending,
    
    // Data
    @Default([]) List<ActivityLogItem> allActivities,
    @Default([]) List<ActivityLogItem> filteredActivities,
    
    // Pagination
    @Default(1) int currentPage,
    @Default(10) int itemsPerPage,
    
    // UI state
    @Default(LoadingStatus.initial) LoadingStatus status,
    String? errorMessage,
    @Default(true) bool isLoggedIn,
  }) = _UnifiedActivityState;

  const UnifiedActivityState._();

  // ===== COMPUTED PROPERTIES =====

  bool get isLoading => status == LoadingStatus.loading;
  bool get hasError => status == LoadingStatus.error;
  bool get isEmpty => filteredActivities.isEmpty && status == LoadingStatus.success;

  /// Get paginated items for current page
  List<ActivityLogItem> get paginatedItems {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    
    if (startIndex >= filteredActivities.length) {
      return [];
    }
    
    return filteredActivities.sublist(
      startIndex,
      endIndex > filteredActivities.length ? filteredActivities.length : endIndex,
    );
  }

  /// Total number of pages
  int get totalPages {
    if (filteredActivities.isEmpty) return 1;
    return (filteredActivities.length / itemsPerPage).ceil();
  }

  /// Check if has any active filters
  bool get hasActiveFilters {
    return selectedMachineId != null ||
        selectedBatchId != null ||
        dateFilter.isActive ||
        searchQuery.isNotEmpty ||
        selectedCategory != ActivityCategory.all ||
        selectedType != ActivitySubType.all;
  }
}