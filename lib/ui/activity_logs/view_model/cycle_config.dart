// lib/ui/activity_logs/view_model/cycle_config.dart

import '../models/activity_filter_config.dart';

class CyclesConfig {
  static ActivityFilterConfig get config => ActivityFilterConfig(
    screenTitle: 'Cycles & Recommendations',
    filters: const ['All', 'Recoms', 'Cycles'],
    categoryMapper: CategoryMappers.simple(),
    categoryHighlighter: CategoryHighlighters.simple([
      'Recoms',
      'Cycles',
    ]),
  );
}