// lib/ui/activity_logs/view/substrates_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_list_state.dart';
import '../view_model/activity_viewmodel.dart';
import 'base_activity_screen.dart';
import '../models/activity_common.dart';

class SubstratesScreen extends BaseActivityScreen {
  const SubstratesScreen({
    super.key,
    super.initialFilter,
  });

  @override
  ConsumerState<SubstratesScreen> createState() => _SubstratesScreenState();
}

class _SubstratesScreenState extends BaseActivityScreenState<SubstratesScreen> {
  ActivityParams get _params => ActivityParams(
        screenType: ActivityScreenType.substrates,
        initialFilter: widget.initialFilter,
      );

  @override
  ActivityListState getState() {
    return ref.watch(activityViewModelProvider(_params));
  }

  @override
  String getScreenTitle() => 'Substrate Logs';

  @override
  List<String> getFilters() {
    return const ['All', 'Greens', 'Browns', 'Compost'];
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
  void onBatchChanged(String? batchId) {
    ref.read(activityViewModelProvider(_params).notifier).onBatchChanged(batchId);
  }

  @override
  void onMachineChanged(String? machineId) {
    ref.read(activityViewModelProvider(_params).notifier).onMachineChanged(machineId);
  }

  @override
  Future<void> onRefresh() async {
    await ref.read(activityViewModelProvider(_params).notifier).refresh();
  }
}