// lib/ui/activity_logs/view/alerts_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_list_state.dart';
import '../view_model/activity_viewmodel.dart';
import '../models/activity_common.dart';
import 'base_activity_screen.dart';

class AlertsScreen extends BaseActivityScreen {
  const AlertsScreen({super.key, super.initialFilter});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends BaseActivityScreenState<AlertsScreen> {
  ActivityParams get _params => ActivityParams(
        screenType: ActivityScreenType.alerts,
        initialFilter: widget.initialFilter,
      );

  @override
  ActivityListState getState() {
    return ref.watch(activityViewModelProvider(_params));
  }

  @override
  ActivityViewModel getViewModel() {
    return ref.read(activityViewModelProvider(_params).notifier);
  }

  @override
  void onSearchChanged(String query) {
    ref
        .read(activityViewModelProvider(_params).notifier)
        .onSearchChanged(query);
  }

  @override
  void onSearchCleared() {
    ref.read(activityViewModelProvider(_params).notifier).onSearchCleared();
  }

  @override
  void onDateFilterChanged(DateFilterRange filter) {
    ref
        .read(activityViewModelProvider(_params).notifier)
        .onDateFilterChanged(filter);
  }

  @override
  Future<void> onRefresh() async {
    await ref.read(activityViewModelProvider(_params).notifier).refresh();
  }

  @override
  void onBatchChanged(String? batchId) {
    ref
        .read(activityViewModelProvider(_params).notifier)
        .onBatchChanged(batchId);
  }

  @override
  void onMachineChanged(String? machineId) {
    ref
        .read(activityViewModelProvider(_params).notifier)
        .onMachineChanged(machineId);
  }

  @override
  void onLoadMore() {
    ref.read(activityViewModelProvider(_params).notifier).loadMore();
  }
}