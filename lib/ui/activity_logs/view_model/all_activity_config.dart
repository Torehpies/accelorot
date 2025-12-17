// lib/ui/activity_logs/view_model/all_activity_config.dart

import '../models/activity_filter_config.dart';

class AllActivityConfig {
  static ActivityFilterConfig get config => ActivityFilterConfig(
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
}