import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/activity_item.dart';
import 'package:flutter_application_1/data/repositories/activity_repository.dart';
import '../../../data/models/activity_list_state.dart';
import '../../../data/providers/repository_providers.dart';
import 'base_activity_viewmodel.dart';
import '../models/activity_filter_config.dart';

class SubstratesViewModel extends BaseActivityViewModel {
  SubstratesViewModel({
    required super.repository,
    super.initialFilter,
    super.viewingOperatorId,
    super.focusedMachineId,
  }) : super(config: _config);

  static final _config = ActivityFilterConfig(
    screenTitle: 'Substrate Logs',
    filters: const ['All', 'Greens', 'Browns', 'Compost'],
    categoryMapper: CategoryMappers.simple(),
    categoryHighlighter: CategoryHighlighters.simple(
      ['Greens', 'Browns', 'Compost'],
    ),
  );

  @override
  Future<List<ActivityItem>> fetchData(String? viewingOperatorId) async {
    return await repository.getSubstrates(viewingOperatorId: viewingOperatorId);
  }
}

// Riverpod Provider
final substratesViewModelProvider = StateNotifierProvider.autoDispose
    .family<SubstratesViewModel, ActivityListState, SubstratesParams>(
  (ref, params) {
    final repository = ref.watch(activityRepositoryProvider);
    return SubstratesViewModel(
      repository: repository,
      initialFilter: params.initialFilter,
      viewingOperatorId: params.viewingOperatorId,
      focusedMachineId: params.focusedMachineId,
    );
  },
);

class SubstratesParams {
  final String? initialFilter;
  final String? viewingOperatorId;
  final String? focusedMachineId;

  SubstratesParams({this.initialFilter, this.viewingOperatorId, this.focusedMachineId});
}