// lib/ui/activity_logs/view/cycles_recom_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_list_state.dart';
import '../view_model/activity_viewmodel.dart';
import 'base_activity_screen.dart';

class CyclesRecomScreen extends BaseActivityScreen {
  const CyclesRecomScreen({
    super.key,
    super.initialFilter,
    super.focusedMachineId,
  });

  @override
  ConsumerState<CyclesRecomScreen> createState() => _CyclesRecomScreenState();
}

class _CyclesRecomScreenState extends BaseActivityScreenState<CyclesRecomScreen> {
  ActivityParams get _params => ActivityParams(
        screenType: ActivityScreenType.cyclesRecom,
        initialFilter: widget.initialFilter,
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
        ? 'Machine Cycles & Recommendations'
        : 'Cycles & Recommendations';
  }

  @override
  List<String> getFilters() {
    return const ['All', 'Recoms', 'Cycles'];
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