// lib/ui/activity_logs/view_model/alert_config.dart

import '../models/activity_filter_config.dart';

class AlertsConfig {
  static ActivityFilterConfig get config => ActivityFilterConfig(
    screenTitle: 'Alerts Logs',
    filters: const ['All', 'Temperature', 'Moisture', 'Air Quality'],
    categoryMapper: CategoryMappers.simple(),
    categoryHighlighter: CategoryHighlighters.simple([
      'Temperature',
      'Moisture',
      'Air Quality',
    ]),
  );
}