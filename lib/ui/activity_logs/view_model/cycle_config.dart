// lib/ui/activity_logs/view_model/cycle_config.dart

import '../models/activity_filter_config.dart';

class CyclesConfig {
  static ActivityFilterConfig get config => ActivityFilterConfig(
    screenTitle: 'Operations & AI',
    filters: const ['All', 'Drum Controller', 'Aerator'],
    categoryMapper: CategoryMappers.grouped({
      'Drum Controller': ['Drum Controller'],
      'Aerator': ['Aerator'],
    }),
    categoryHighlighter: CategoryHighlighters.grouped({
      'Drum Controller': ['Drum Controller'],
      'Aerator': ['Aerator'],
    }),
  );
}
