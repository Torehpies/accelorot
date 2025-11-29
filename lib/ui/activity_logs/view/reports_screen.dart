
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/activity_list_state.dart';
import '../view_model/reports_viewmodel.dart';
import 'base_activity_screen.dart';

class ReportsScreen extends BaseActivityScreen {
  const ReportsScreen({
    super.key,
    super.initialFilter,
    super.viewingOperatorId,
    super.focusedMachineId,
  });

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends BaseActivityScreenState<ReportsScreen> {
  @override
  ActivityListState getState() {
    final params = ReportsParams(
      initialFilter: widget.initialFilter,
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    return ref.watch(reportsViewModelProvider(params));
  }

  @override
  String getScreenTitle() {
    final state = getState();
    return state.focusedMachineId != null ? 'Machine Reports' : 'Reports';
  }

  @override
  List<String> getFilters() {
    return const ['All', 'Maintenance', 'Observation', 'Safety'];
  }

  @override
  void onFilterChanged(String filter) {
    final params = ReportsParams(
      initialFilter: widget.initialFilter,
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    ref.read(reportsViewModelProvider(params).notifier).onFilterChanged(filter);
  }

  @override
  void onSearchChanged(String query) {
    final params = ReportsParams(
      initialFilter: widget.initialFilter,
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    ref.read(reportsViewModelProvider(params).notifier).onSearchChanged(query);
  }

  @override
  void onSearchCleared() {
    final params = ReportsParams(
      initialFilter: widget.initialFilter,
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    ref.read(reportsViewModelProvider(params).notifier).onSearchCleared();
  }

  @override
  void onDateFilterChanged(DateFilterRange filter) {
    final params = ReportsParams(
      initialFilter: widget.initialFilter,
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    ref.read(reportsViewModelProvider(params).notifier).onDateFilterChanged(filter);
  }

  @override
  Future<void> onRefresh() async {
    final params = ReportsParams(
      initialFilter: widget.initialFilter,
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    await ref.read(reportsViewModelProvider(params).notifier).refresh(widget.viewingOperatorId);
  }
}