
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/activity_list_state.dart';
import '../view_model/all_activity_viewmodel.dart';
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
  @override
  ActivityListState getState() {
    final params = AllActivityParams(
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    return ref.watch(allActivityViewModelProvider(params));
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
    final params = AllActivityParams(
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    ref.read(allActivityViewModelProvider(params).notifier).onFilterChanged(filter);
  }

  @override
  void onSearchChanged(String query) {
    final params = AllActivityParams(
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    ref.read(allActivityViewModelProvider(params).notifier).onSearchChanged(query);
  }

  @override
  void onSearchCleared() {
    final params = AllActivityParams(
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    ref.read(allActivityViewModelProvider(params).notifier).onSearchCleared();
  }

  @override
  void onDateFilterChanged(DateFilterRange filter) {
    final params = AllActivityParams(
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    ref.read(allActivityViewModelProvider(params).notifier).onDateFilterChanged(filter);
  }

  @override
  Future<void> onRefresh() async {
    final params = AllActivityParams(
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    await ref.read(allActivityViewModelProvider(params).notifier).refresh(widget.viewingOperatorId);
  }
}
