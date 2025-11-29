import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/activity_item.dart';
import 'package:flutter_application_1/data/repositories/activity_repository.dart';
import '../../../data/models/activity_list_state.dart';
import '../../../data/providers/repository_providers.dart';
import 'base_activity_viewmodel.dart';
import '../models/activity_filter_config.dart';

class AllActivityViewModel extends BaseActivityViewModel {
  AllActivityViewModel({
    required super.repository,
    super.initialFilter,
    super.viewingOperatorId,
    super.focusedMachineId,
  }) : super(config: _config);

  static final _config = ActivityFilterConfig(
    screenTitle: 'All Activity Logs',
    filters: const ['All', 'Substrate', 'Alerts', 'Cycles', 'Reports'],
    categoryMapper: CategoryMappers.grouped({
      'Substrate': ['Greens', 'Browns', 'Compost'],
      'Alerts': ['Temperature', 'Moisture', 'Oxygen'],
      'Cycles': ['Recoms', 'Cycles'],
      'Reports': ['Maintenance', 'Observation', 'Safety'],
    }),
    categoryHighlighter: CategoryHighlighters.grouped({
      'Substrate': ['Greens', 'Browns', 'Compost'],
      'Alerts': ['Temperature', 'Moisture', 'Oxygen'],
      'Cycles': ['Recoms', 'Cycles'],
      'Reports': ['Maintenance', 'Observation', 'Safety'],
    }),
  );

  @override
  Future<List<ActivityItem>> fetchData(String? viewingOperatorId) async {
    return await repository.getAllActivities(viewingOperatorId: viewingOperatorId);
  }
}

// Riverpod Provider
final allActivityViewModelProvider = StateNotifierProvider.autoDispose
    .family<AllActivityViewModel, ActivityListState, AllActivityParams>(
  (ref, params) {
    final repository = ref.watch(activityRepositoryProvider);
    return AllActivityViewModel(
      repository: repository,
      viewingOperatorId: params.viewingOperatorId,
      focusedMachineId: params.focusedMachineId,
    );
  },
);

class AllActivityParams {
  final String? viewingOperatorId;
  final String? focusedMachineId;

  AllActivityParams({this.viewingOperatorId, this.focusedMachineId});
}