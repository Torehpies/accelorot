// lib/ui/tasks/view/mobile_tasks_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/containers/mobile_common_widgets.dart';
import '../../core/widgets/containers/mobile_sliver_header.dart';
import '../../core/widgets/containers/mobile_list_content.dart';
import '../../core/widgets/sample_cards/data_card.dart';
import '../../core/widgets/filters/mobile_dropdown_filter_button.dart';
import '../../core/widgets/filters/mobile_date_filter_button.dart';
import '../../core/widgets/sample_cards/data_card_skeleton.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_snackbar.dart';
import '../../../data/models/task_model.dart';
import '../view_model/mobile_tasks_viewmodel.dart';
import '../models/mobile_tasks_state.dart';
import '../models/task_filters.dart';
import '../bottom_sheets/task_view_bottom_sheet.dart';
import '../bottom_sheets/create_task_bottom_sheet.dart';

class MobileTasksView extends ConsumerStatefulWidget {
  const MobileTasksView({super.key});

  @override
  ConsumerState<MobileTasksView> createState() => _MobileTasksViewState();
}

class _MobileTasksViewState extends ConsumerState<MobileTasksView> {
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(mobileTasksViewModelProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _showTaskView(TaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskViewBottomSheet(
        task: task,
        onMarkComplete: () {
          Navigator.of(context).pop();
          _markTaskComplete(task);
        },
      ),
    );
  }

  Future<void> _markTaskComplete(TaskModel task) async {
    try {
      final request = UpdateTaskRequest(
        taskId: task.id,
        teamId: task.teamId,
        status: 'completed',
      );
      await ref.read(mobileTasksViewModelProvider.notifier).updateTask(request);
      if (mounted) {
        AppSnackbar.show(
          context,
          message: 'Task marked as complete!',
          type: SnackbarType.success,
        );
      }
    } catch (_) {
      if (mounted) {
        AppSnackbar.show(
          context,
          message: 'Failed to update task. Please try again.',
          type: SnackbarType.error,
        );
      }
    }
  }

  void _showCreateTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => const CreateTaskBottomSheet(),
    );
  }

  EmptyStateConfig _getEmptyStateConfig(MobileTasksState state) {
    String message;

    if (state.hasActiveFilters) {
      message = 'No tasks match your filters';
    } else if (state.selectedStatus != TaskStatusFilter.all) {
      message =
          'No ${state.selectedStatus.displayName.toLowerCase()} tasks';
    } else {
      message = 'No tasks yet';
    }

    return EmptyStateConfig(
      icon: Icons.task_alt_outlined,
      message: message,
      actionLabel: state.hasActiveFilters ? 'Clear All Filters' : null,
      onAction: state.hasActiveFilters
          ? () =>
              ref.read(mobileTasksViewModelProvider.notifier).clearAllFilters()
          : null,
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskModel task, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DataCard<TaskModel>(
        data: task,
        icon: _getTaskIcon(task),
        iconBgColor: _getTaskIconColor(task),
        title: task.title,
        category: task.statusLabel,
        status: 'Created ${_formatDate(task.createdAt)}',
        userName: task.assignedToName,
        statusColor: _getStatusColor(task),
        statusTextColor: const Color(0xFF424242),
        onTap: () => _showTaskView(task),
      ),
    );
  }

  IconData _getTaskIcon(TaskModel task) {
    if (task.isCompleted) return Icons.task_alt;
    if (task.isOverdue) return Icons.warning_amber_rounded;
    switch (task.priority.toLowerCase()) {
      case 'high':
        return Icons.priority_high_rounded;
      case 'medium':
        return Icons.pending_actions_outlined;
      case 'low':
        return Icons.low_priority_rounded;
      default:
        return Icons.task_outlined;
    }
  }

  Color _getTaskIconColor(TaskModel task) {
    if (task.isCompleted) return const Color(0xFF10B981);
    if (task.isOverdue) return const Color(0xFFEF4444);
    switch (task.priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'low':
        return const Color(0xFF10B981);
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusColor(TaskModel task) {
    if (task.isOverdue && !task.isCompleted) return const Color(0xFFFFE4E4);
    switch (task.status.toLowerCase()) {
      case 'completed':
        return const Color(0xFFD1FAE5);
      case 'in_progress':
        return const Color(0xFFFEF3C7);
      case 'pending':
        return const Color(0xFFDBEAFE);
      default:
        return AppColors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mobileTasksViewModelProvider);
    final notifier = ref.read(mobileTasksViewModelProvider.notifier);

    return MobileScaffoldContainer(
      onTap: () => _searchFocusNode.unfocus(),
      body: RefreshIndicator(
        onRefresh: () async {
          await notifier.refresh();
        },
        color: AppColors.green100,
        child: CustomScrollView(
          slivers: [
            MobileSliverHeader(
              title: 'Tasks',
              showAddButton: true,
              onAddPressed: _showCreateTask,
              searchConfig: SearchBarConfig(
                onSearchChanged: notifier.setSearchQuery,
                searchHint: 'Search tasks...',
                isLoading: state.isLoading,
                searchFocusNode: _searchFocusNode,
              ),
              filterWidgets: [
                MobileDropdownFilterButton<TaskStatusFilter>(
                  icon: Icons.tune,
                  currentFilter: state.selectedStatus,
                  options: TaskStatusFilter.values,
                  onFilterChanged: notifier.setStatusFilter,
                  isLoading: state.isLoading,
                ),
                const SizedBox(width: 8),
                MobileDateFilterButton(
                  onFilterChanged: notifier.setDateFilter,
                  isLoading: state.isLoading,
                ),
              ],
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 8),
            ),
            MobileListContent<TaskModel>(
              isLoading: state.isLoading,
              isInitialLoad: state.tasks.isEmpty,
              hasError: state.hasError,
              errorMessage: state.errorMessage,
              items: state.filteredTasks,
              displayedItems: state.displayedTasks,
              hasMoreToLoad: state.hasMoreToLoad,
              remainingCount: state.remainingCount,
              emptyStateConfig: _getEmptyStateConfig(state),
              onRefresh: () async {
                await notifier.refresh();
              },
              onLoadMore: notifier.loadMore,
              onRetry: () {
                notifier.clearError();
                notifier.initialize();
              },
              itemBuilder: _buildTaskCard,
              skeletonBuilder: (context, index) => const DataCardSkeleton(),
            ),
          ],
        ),
      ),
    );
  }
}
