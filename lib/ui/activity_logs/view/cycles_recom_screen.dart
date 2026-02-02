// lib/ui/activity_logs/view/cycles_recom_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_list_state.dart';
import '../view_model/activity_viewmodel.dart';
import 'base_activity_screen.dart';
import '../models/activity_common.dart';

class CyclesRecomScreen extends BaseActivityScreen {
  const CyclesRecomScreen({super.key, super.initialFilter});

  @override
  ConsumerState<CyclesRecomScreen> createState() => _CyclesRecomScreenState();
}

class _CyclesRecomScreenState
    extends BaseActivityScreenState<CyclesRecomScreen> {
  ActivityParams get _params => ActivityParams(
    screenType: ActivityScreenType.cyclesRecom,
    initialFilter: widget.initialFilter,
  );

  @override
  ActivityListState getState() {
    return ref.watch(activityViewModelProvider(_params));
  }

  @override
  String getScreenTitle() => 'Cycles & Recommendations';

  @override
  List<String> getFilters() {
    return const ['All', 'Recoms', 'Cycles'];
  }

  @override
  void onFilterChanged(String filter) {
    ref
        .read(activityViewModelProvider(_params).notifier)
        .onFilterChanged(filter);
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
}
