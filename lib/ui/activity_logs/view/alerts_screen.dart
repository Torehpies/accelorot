// lib/ui/activity_logs/view/alerts_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/activity_list_state.dart';
import '../view_model/activity_viewmodel.dart';
import 'base_activity_screen.dart';

class AlertsScreen extends BaseActivityScreen {
  const AlertsScreen({
    super.key,
    super.initialFilter,
    super.viewingOperatorId,
    super.focusedMachineId,
  });

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends BaseActivityScreenState<AlertsScreen> {
  ActivityParams get _params => ActivityParams(
        screenType: ActivityScreenType.alerts,
        initialFilter: widget.initialFilter,
        viewingOperatorId: widget.viewingOperatorId,
        focusedMachineId: widget.focusedMachineId,
      );

  @override
  ActivityListState getState() {
    return ref.watch(activityViewModelProvider(_params));
  }

  @override
  String getScreenTitle() {
    final state = getState();
    return state.focusedMachineId != null ? 'Machine Alerts' : 'Alerts Logs';
  }

  @override
  List<String> getFilters() {
    return const ['All', 'Temperature', 'Moisture', 'Air Quality'];
  }

  @override
  void onFilterChanged(String filter) {
    ref.read(activityViewModelProvider(_params).notifier).onFilterChanged(filter);
  }

  @override
  void onSearchChanged(String query) {
    ref.read(activityViewModelProvider(_params).notifier).onSearchChanged(query);
  }

  @override
  void onSearchCleared() {
    ref.read(activityViewModelProvider(_params).notifier).onSearchCleared();
  }

  @override
  void onDateFilterChanged(DateFilterRange filter) {
    ref.read(activityViewModelProvider(_params).notifier).onDateFilterChanged(filter);
  }

  @override
  Future<void> onRefresh() async {
    await ref.read(activityViewModelProvider(_params).notifier).refresh(
          widget.viewingOperatorId,
          widget.focusedMachineId,
        );
  }
}