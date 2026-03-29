// lib/ui/tasks/models/mobile_tasks_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../data/models/task_model.dart';
import '../../activity_logs/models/activity_common.dart';
import 'task_filters.dart';

part 'mobile_tasks_state.freezed.dart';

@freezed
abstract class MobileTasksState with _$MobileTasksState {
  const factory MobileTasksState({
    @Default(TaskStatusFilter.all) TaskStatusFilter selectedStatus,
    @Default(TaskPriorityFilter.all) TaskPriorityFilter selectedPriority,
    @Default(DateFilterRange(type: DateFilterType.none))
    DateFilterRange dateFilter,
    @Default('') String searchQuery,
    @Default([]) List<TaskModel> tasks,
    @Default(5) int displayLimit,
    @Default(LoadingStatus.initial) LoadingStatus status,
    String? errorMessage,
  }) = _MobileTasksState;

  const MobileTasksState._();

  bool get isLoading => status == LoadingStatus.loading;
  bool get hasError => status == LoadingStatus.error;

  List<TaskModel> get filteredTasks {
    var result = List<TaskModel>.from(tasks);

    // Status filter
    if (selectedStatus != TaskStatusFilter.all) {
      final targetStatus = _statusFilterToString(selectedStatus);
      result = result.where((t) => t.status.toLowerCase() == targetStatus).toList();
    }

    // Priority filter
    if (selectedPriority != TaskPriorityFilter.all) {
      final targetPriority = _priorityFilterToString(selectedPriority);
      result = result
          .where((t) => t.priority.toLowerCase() == targetPriority)
          .toList();
    }

    // Date filter
    if (dateFilter.isActive) {
      result = result.where((t) => _matchesDateFilter(t.createdAt)).toList();
    }

    // Search query
    if (searchQuery.isNotEmpty) {
      result =
          result.where((t) => t.matchesSearchQuery(searchQuery)).toList();
    }

    // Sort by createdAt descending
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return result;
  }

  List<TaskModel> get displayedTasks {
    if (filteredTasks.length <= displayLimit) {
      return filteredTasks;
    }
    return filteredTasks.sublist(0, displayLimit);
  }

  bool get hasMoreToLoad => filteredTasks.length > displayLimit;

  int get remainingCount => filteredTasks.length - displayLimit;

  bool get hasActiveFilters {
    return selectedStatus != TaskStatusFilter.all ||
        selectedPriority != TaskPriorityFilter.all ||
        dateFilter.isActive ||
        searchQuery.isNotEmpty;
  }

  String _statusFilterToString(TaskStatusFilter filter) {
    switch (filter) {
      case TaskStatusFilter.pending:
        return 'pending';
      case TaskStatusFilter.inProgress:
        return 'in_progress';
      case TaskStatusFilter.completed:
        return 'completed';
      case TaskStatusFilter.all:
        return '';
    }
  }

  String _priorityFilterToString(TaskPriorityFilter filter) {
    switch (filter) {
      case TaskPriorityFilter.high:
        return 'high';
      case TaskPriorityFilter.medium:
        return 'medium';
      case TaskPriorityFilter.low:
        return 'low';
      case TaskPriorityFilter.all:
        return '';
    }
  }

  bool _matchesDateFilter(DateTime date) {
    final start = dateFilter.startDate;
    final end = dateFilter.endDate;
    if (start == null || end == null) return true;
    return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
        date.isBefore(end);
  }
}
