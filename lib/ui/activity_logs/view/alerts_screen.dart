import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/activity_list_state.dart';
import '../view_model/alerts_viewmodel.dart';
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
  @override
  ActivityListState getState() {
    final params = AlertsParams(
      initialFilter: widget.initialFilter,
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    return ref.watch(alertsViewModelProvider(params));
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
    final params = AlertsParams(
      initialFilter: widget.initialFilter,
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    ref.read(alertsViewModelProvider(params).notifier).onFilterChanged(filter);
  }

  @override
  void onSearchChanged(String query) {
    final params = AlertsParams(
      initialFilter: widget.initialFilter,
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    ref.read(alertsViewModelProvider(params).notifier).onSearchChanged(query);
  }

  @override
  void onSearchCleared() {
    final params = AlertsParams(
      initialFilter: widget.initialFilter,
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    ref.read(alertsViewModelProvider(params).notifier).onSearchCleared();
  }

  @override
  void onDateFilterChanged(DateFilterRange filter) {
    final params = AlertsParams(
      initialFilter: widget.initialFilter,
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    ref.read(alertsViewModelProvider(params).notifier).onDateFilterChanged(filter);
  }

  @override
  Future<void> onRefresh() async {
    final params = AlertsParams(
      initialFilter: widget.initialFilter,
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    await ref.read(alertsViewModelProvider(params).notifier).refresh(widget.viewingOperatorId);
  }
}