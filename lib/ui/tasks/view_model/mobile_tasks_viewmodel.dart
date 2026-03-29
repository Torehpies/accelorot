// lib/ui/tasks/view_model/mobile_tasks_viewmodel.dart

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/task_model.dart';
import '../../../data/providers/task_providers.dart';
import '../services/task_aggregator_service.dart';
import '../models/mobile_tasks_state.dart';
import '../../activity_logs/models/activity_common.dart';
import '../models/task_filters.dart';

part 'mobile_tasks_viewmodel.g.dart';

@Riverpod(keepAlive: true)
TaskAggregatorService taskAggregatorService(Ref ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return TaskAggregatorService(taskRepo: repository);
}

@Riverpod(keepAlive: true)
class MobileTasksViewModel extends _$MobileTasksViewModel {
  static const int _loadMoreIncrement = 5;

  late TaskAggregatorService _aggregator;

  @override
  MobileTasksState build() {
    _aggregator = ref.read(taskAggregatorServiceProvider);
    return const MobileTasksState();
  }

  // ===== INITIALIZATION =====

  Future<void> initialize() async {
    state = state.copyWith(status: LoadingStatus.loading, errorMessage: null);

    try {
      final tasks = await _aggregator
          .getTasks()
          .timeout(const Duration(seconds: 10));

      state = state.copyWith(
        tasks: tasks,
        status: LoadingStatus.success,
      );
    } catch (e) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage:
            'Failed to load: ${e.toString().replaceAll('Exception:', '').trim()}',
      );
    }
  }

  Future<void> refresh() async {
    try {
      final tasks = await _aggregator
          .getTasks()
          .timeout(const Duration(seconds: 10));

      state = state.copyWith(tasks: tasks);
    } catch (e) {
      state = state.copyWith(
        errorMessage:
            'Failed to refresh: ${e.toString().replaceAll('Exception:', '').trim()}',
      );
    }
  }

  // ===== FILTERING =====

  void setStatusFilter(TaskStatusFilter filter) {
    HapticFeedback.selectionClick();
    state = state.copyWith(
      selectedStatus: filter,
      displayLimit: _loadMoreIncrement,
    );
  }

  void setPriorityFilter(TaskPriorityFilter filter) {
    HapticFeedback.selectionClick();
    state = state.copyWith(
      selectedPriority: filter,
      displayLimit: _loadMoreIncrement,
    );
  }

  void setDateFilter(DateFilterRange dateFilter) {
    HapticFeedback.selectionClick();
    state = state.copyWith(
      dateFilter: dateFilter,
      displayLimit: _loadMoreIncrement,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query,
      displayLimit: _loadMoreIncrement,
    );
  }

  void clearAllFilters() {
    state = state.copyWith(
      selectedStatus: TaskStatusFilter.all,
      selectedPriority: TaskPriorityFilter.all,
      dateFilter: const DateFilterRange(type: DateFilterType.none),
      searchQuery: '',
      displayLimit: _loadMoreIncrement,
    );
  }

  // ===== LOAD MORE =====

  void loadMore() {
    state = state.copyWith(
      displayLimit: state.displayLimit + _loadMoreIncrement,
    );
  }

  // ===== TASK OPERATIONS =====

  Future<void> createTask(CreateTaskRequest request) async {
    try {
      await _aggregator.createTask(request);
      await Future.delayed(const Duration(milliseconds: 500));
      await refresh();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to create task: $e',
      );
      rethrow;
    }
  }

  Future<void> updateTask(UpdateTaskRequest request) async {
    try {
      await _aggregator.updateTask(request);
      await Future.delayed(const Duration(milliseconds: 500));
      await refresh();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to update task: $e',
      );
      rethrow;
    }
  }

  Future<Map<String, String?>> getCurrentUserInfo() =>
      _aggregator.getCurrentUserInfo();

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
