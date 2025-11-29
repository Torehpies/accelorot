import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/activity_item.dart';
import 'package:flutter_application_1/data/repositories/activity_repository.dart';
import '../../../data/models/activity_list_state.dart';
import '../../../data/providers/repository_providers.dart';
import 'base_activity_viewmodel.dart';
import '../models/activity_filter_config.dart';

class ReportsViewModel extends BaseActivityViewModel {
  ReportsViewModel({
    required super.repository,
    super.initialFilter,
    super.viewingOperatorId,
    super.focusedMachineId,
  }) : super(config: _config);

  static final _config = ActivityFilterConfig(
    screenTitle: 'Reports',
    filters: const ['All', 'Maintenance', 'Observation', 'Safety'],
    categoryMapper: CategoryMappers.simple(),
    categoryHighlighter: CategoryHighlighters.simple(
      ['Maintenance', 'Observation', 'Safety'],
    ),
  );

  @override
  Future<List<ActivityItem>> fetchData(String? viewingOperatorId) async {
    return await repository.getReports(viewingOperatorId: viewingOperatorId);
  }
}

// Riverpod Provider
final reportsViewModelProvider = StateNotifierProvider.autoDispose
    .family<ReportsViewModel, ActivityListState, ReportsParams>(
  (ref, params) {
    final repository = ref.watch(activityRepositoryProvider);
    return ReportsViewModel(
      repository: repository,
      initialFilter: params.initialFilter,
      viewingOperatorId: params.viewingOperatorId,
      focusedMachineId: params.focusedMachineId,
    );
  },
);

class ReportsParams {
  final String? initialFilter;
  final String? viewingOperatorId;
  final String? focusedMachineId;

  ReportsParams({this.initialFilter, this.viewingOperatorId, this.focusedMachineId});
}