// lib/ui/activity_logs/view_model/substrate_config.dart

import '../models/activity_filter_config.dart';

class SubstratesConfig {
  static ActivityFilterConfig get config => ActivityFilterConfig(
    screenTitle: 'Substrate Logs',
    filters: const ['All', 'Greens', 'Browns', 'Compost'],
    categoryMapper: CategoryMappers.simple(),
    categoryHighlighter: CategoryHighlighters.simple([
      'Greens',
      'Browns',
      'Compost',
    ]),
  );
}
