import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/activity_item.dart';
import 'package:flutter_application_1/data/repositories/activity_repository.dart';
import '../../../data/providers/repository_providers.dart';
import '../../../data/models/activity_list_state.dart';
import 'base_activity_viewmodel.dart';
import '../models/activity_filter_config.dart';


class AlertsViewModel extends BaseActivityViewModel {
  AlertsViewModel({
    required super.repository,
    super.initialFilter,
    super.viewingOperatorId,
    super.focusedMachineId,
  }) : super(config: _config);

  static final _config = ActivityFilterConfig(
    screenTitle: 'Alerts Logs',
    filters: const ['All', 'Temperature', 'Moisture', 'Air Quality'],
    categoryMapper: CategoryMappers.simple(),
    categoryHighlighter: CategoryHighlighters.simple(
      ['Temperature', 'Moisture', 'Oxygen'],
    ),
  );

  @override
  Future<List<ActivityItem>> fetchData(String? viewingOperatorId) async {
    return await repository.getAlerts(viewingOperatorId: viewingOperatorId);
  }
}

// Riverpod Provider
final alertsViewModelProvider = StateNotifierProvider.autoDispose
    .family<AlertsViewModel, ActivityListState, AlertsParams>(
  (ref, params) {
    final repository = ref.watch(activityRepositoryProvider);
    return AlertsViewModel(
      repository: repository,
      initialFilter: params.initialFilter,
      viewingOperatorId: params.viewingOperatorId,
      focusedMachineId: params.focusedMachineId,
    );
  },
);

class AlertsParams {
  final String? initialFilter;
  final String? viewingOperatorId;
  final String? focusedMachineId;

  AlertsParams({this.initialFilter, this.viewingOperatorId, this.focusedMachineId});
}