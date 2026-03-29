// lib/ui/tasks/models/task_filters.dart

import '../../core/widgets/filters/mobile_dropdown_filter_button.dart';

enum TaskStatusFilter implements FilterOption {
  all,
  pending,
  inProgress,
  completed;

  @override
  String get displayName {
    switch (this) {
      case TaskStatusFilter.all:
        return 'All Status';
      case TaskStatusFilter.pending:
        return 'Pending';
      case TaskStatusFilter.inProgress:
        return 'In Progress';
      case TaskStatusFilter.completed:
        return 'Completed';
    }
  }

  @override
  bool get isAll => this == TaskStatusFilter.all;
}

enum TaskPriorityFilter implements FilterOption {
  all,
  high,
  medium,
  low;

  @override
  String get displayName {
    switch (this) {
      case TaskPriorityFilter.all:
        return 'All Priorities';
      case TaskPriorityFilter.high:
        return 'High';
      case TaskPriorityFilter.medium:
        return 'Medium';
      case TaskPriorityFilter.low:
        return 'Low';
    }
  }

  @override
  bool get isAll => this == TaskPriorityFilter.all;
}
