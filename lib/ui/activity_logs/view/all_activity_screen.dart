// lib/ui/activity_logs/view/all_activity_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_list_state.dart';
import '../view_model/activity_viewmodel.dart';
import 'base_activity_screen.dart';

class AllActivityScreen extends BaseActivityScreen {
  const AllActivityScreen({
    super.key,
    super.focusedMachineId,
  });

  @override
  ConsumerState<AllActivityScreen> createState() => _AllActivityScreenState();
}

class _AllActivityScreenState extends BaseActivityScreenState<AllActivityScreen> {
  ActivityParams get _params => ActivityParams(
        screenType: ActivityScreenType.allActivity,
        focusedMachineId: widget.focusedMachineId,
      );

  @override
  ActivityListState getState() {
    return ref.watch(activityViewModelProvider(_params));
  }

  @override
  String getScreenTitle() {
    final state = getState();
    return state.focusedMachineId != null
        ? 'Machine Activity Logs'
        : 'All Activity Logs';
  }

  @override
  List<String> getFilters() {
    return const ['All', 'Substrate', 'Alerts', 'Cycles', 'Reports'];
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
    await ref.read(activityViewModelProvider(_params).notifier).refresh();
  }
}