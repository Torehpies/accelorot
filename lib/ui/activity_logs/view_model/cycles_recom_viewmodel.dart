import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/activity_item.dart';
import 'package:flutter_application_1/data/repositories/activity_repository.dart';
import '../../../data/models/activity_list_state.dart';
import '../../../data/providers/repository_providers.dart';
import 'base_activity_viewmodel.dart';
import '../models/activity_filter_config.dart';

class CyclesRecomViewModel extends BaseActivityViewModel {
  CyclesRecomViewModel({
    required super.repository,
    super.initialFilter,
    super.viewingOperatorId,
    super.focusedMachineId,
  }) : super(config: _config);

  static final _config = ActivityFilterConfig(
    screenTitle: 'Cycles & Recommendations',
    filters: const ['All', 'Recoms', 'Cycles'],
    categoryMapper: CategoryMappers.simple(),
    categoryHighlighter: CategoryHighlighters.simple(['Recoms', 'Cycles']),
  );

  @override
  Future<List<ActivityItem>> fetchData(String? viewingOperatorId) async {
    return await repository.getCyclesRecom(viewingOperatorId: viewingOperatorId);
  }
}

// Riverpod Provider
final cyclesRecomViewModelProvider = StateNotifierProvider.autoDispose
    .family<CyclesRecomViewModel, ActivityListState, CyclesRecomParams>(
  (ref, params) {
    final repository = ref.watch(activityRepositoryProvider);
    return CyclesRecomViewModel(
      repository: repository,
      initialFilter: params.initialFilter,
      viewingOperatorId: params.viewingOperatorId,
      focusedMachineId: params.focusedMachineId,
    );
  },
);

class CyclesRecomParams {
  final String? initialFilter;
  final String? viewingOperatorId;
  final String? focusedMachineId;

  CyclesRecomParams({this.initialFilter, this.viewingOperatorId, this.focusedMachineId});
}