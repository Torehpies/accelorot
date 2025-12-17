// lib/ui/activity_logs/view_model/report_config.dart

import '../models/activity_filter_config.dart';

class ReportsConfig {
  static ActivityFilterConfig get config => ActivityFilterConfig(
    screenTitle: 'Reports',
    filters: const ['All', 'Maintenance', 'Observation', 'Safety'],
    categoryMapper: CategoryMappers.simple(),
    categoryHighlighter: CategoryHighlighters.simple([
      'Maintenance',
      'Observation',
      'Safety',
    ]),
  );
}