
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/activity_list_state.dart';
import '../view_model/cycles_recom_viewmodel.dart';
import 'base_activity_screen.dart';

class CyclesRecomScreen extends BaseActivityScreen {
  const CyclesRecomScreen({
    super.key,
    super.initialFilter,
    super.viewingOperatorId,
    super.focusedMachineId,
  });

  @override
  ConsumerState<CyclesRecomScreen> createState() => _CyclesRecomScreenState();
}

class _CyclesRecomScreenState extends BaseActivityScreenState<CyclesRecomScreen> {
  @override
  ActivityListState getState() {
    final params = CyclesRecomParams(
      initialFilter: widget.initialFilter,
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    return ref.watch(cyclesRecomViewModelProvider(params));
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
    final params = CyclesRecomParams(
      initialFilter: widget.initialFilter,
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    ref.read(cyclesRecomViewModelProvider(params).notifier).onFilterChanged(filter);
  }

  @override
  void onSearchChanged(String query) {
    final params = CyclesRecomParams(
      initialFilter: widget.initialFilter,
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    ref.read(cyclesRecomViewModelProvider(params).notifier).onSearchChanged(query);
  }

  @override
  void onSearchCleared() {
    final params = CyclesRecomParams(
      initialFilter: widget.initialFilter,
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    ref.read(cyclesRecomViewModelProvider(params).notifier).onSearchCleared();
  }

  @override
  void onDateFilterChanged(DateFilterRange filter) {
    final params = CyclesRecomParams(
      initialFilter: widget.initialFilter,
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    ref.read(cyclesRecomViewModelProvider(params).notifier).onDateFilterChanged(filter);
  }

  @override
  Future<void> onRefresh() async {
    final params = CyclesRecomParams(
      initialFilter: widget.initialFilter,
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    await ref.read(cyclesRecomViewModelProvider(params).notifier).refresh(widget.viewingOperatorId);
  }
}