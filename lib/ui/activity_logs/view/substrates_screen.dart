import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/activity_list_state.dart';
import '../view_model/substrates_viewmodel.dart';
import 'base_activity_screen.dart';

class SubstratesScreen extends BaseActivityScreen {
  const SubstratesScreen({
    super.key,
    super.initialFilter,
    super.viewingOperatorId,
    super.focusedMachineId,
  });

  @override
  ConsumerState<SubstratesScreen> createState() => _SubstratesScreenState();
}

class _SubstratesScreenState extends BaseActivityScreenState<SubstratesScreen> {
  @override
  ActivityListState getState() {
    final params = SubstratesParams(
      initialFilter: widget.initialFilter,
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    return ref.watch(substratesViewModelProvider(params));
  }

  @override
  String getScreenTitle() {
    final state = getState();
    return state.focusedMachineId != null
        ? 'Machine Substrate Logs'
        : 'Substrate Logs';
  }

  @override
  List<String> getFilters() {
    return const ['All', 'Greens', 'Browns', 'Compost'];
  }

  @override
  void onFilterChanged(String filter) {
    final params = SubstratesParams(
      initialFilter: widget.initialFilter,
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    ref.read(substratesViewModelProvider(params).notifier).onFilterChanged(filter);
  }

  @override
  void onSearchChanged(String query) {
    final params = SubstratesParams(
      initialFilter: widget.initialFilter,
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    ref.read(substratesViewModelProvider(params).notifier).onSearchChanged(query);
  }

  @override
  void onSearchCleared() {
    final params = SubstratesParams(
      initialFilter: widget.initialFilter,
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    ref.read(substratesViewModelProvider(params).notifier).onSearchCleared();
  }

  @override
  void onDateFilterChanged(DateFilterRange filter) {
    final params = SubstratesParams(
      initialFilter: widget.initialFilter,
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    ref.read(substratesViewModelProvider(params).notifier).onDateFilterChanged(filter);
  }

  @override
  Future<void> onRefresh() async {
    final params = SubstratesParams(
      initialFilter: widget.initialFilter,
      viewingOperatorId: widget.viewingOperatorId,
      focusedMachineId: widget.focusedMachineId,
    );
    await ref.read(substratesViewModelProvider(params).notifier).refresh(widget.viewingOperatorId);
  }
}