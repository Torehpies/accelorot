// lib/ui/activity_logs/models/activity_filter_config.dart

class ActivityFilterConfig {
  final String screenTitle;
  final List<String> filters;
  final CategoryMapper categoryMapper;
  final CategoryHighlighter categoryHighlighter;

  const ActivityFilterConfig({
    required this.screenTitle,
    required this.filters,
    required this.categoryMapper,
    required this.categoryHighlighter,
  });

  /// Get screen title with optional machine ID context
  String getTitle({String? machineId}) {
    if (machineId != null) {
      if (screenTitle.contains('All Activity')) {
        return 'Machine Activity Logs';
      }
      return 'Machine ${screenTitle.replaceAll('Logs', '').trim()}';
    }
    return screenTitle;
  }
}

/// Function type for filtering items by category
typedef CategoryMapper = List<T> Function<T extends Object>(
  List<T> items,
  String filter,
  String Function(T) getCategoryFn,
);

typedef CategoryHighlighter = Set<String> Function(
  Set<String> categoriesInResults,
  List<String> allFilters,
);

class CategoryMappers {
  static CategoryMapper simple() {
    return <T extends Object>(items, filter, getCategoryFn) {
      if (filter == 'All') return items;
      return items.where((item) => getCategoryFn(item) == filter).toList();
    };
  }

  static CategoryMapper grouped(Map<String, List<String>> filterToCategories) {
    return <T extends Object>(items, filter, getCategoryFn) {
      if (filter == 'All') return items;

      final categories = filterToCategories[filter];
      if (categories == null) return items;

      return items
          .where((item) => categories.contains(getCategoryFn(item)))
          .toList();
    };
  }
}

class CategoryHighlighters {
  static CategoryHighlighter simple(List<String> specificFilters) {
    return (categoriesInResults, allFilters) {
      Set<String> result = {};
      for (var filter in specificFilters) {
        if (categoriesInResults.contains(filter)) {
          result.add(filter);
        }
      }
      if (specificFilters.every((f) => categoriesInResults.contains(f))) {
        result.add('All');
      }

      return result;
    };
  }

  static CategoryHighlighter grouped(
    Map<String, List<String>> filterToCategories,
  ) {
    return (categoriesInResults, allFilters) {
      Set<String> result = {};

      for (var entry in filterToCategories.entries) {
        final filter = entry.key;
        final categories = entry.value;

        if (categories.any((cat) => categoriesInResults.contains(cat))) {
          result.add(filter);
        }
      }

      final nonAllFilters = allFilters.where((f) => f != 'All').toList();
      if (nonAllFilters.every((f) => result.contains(f))) {
        result.add('All');
      }

      return result;
    };
  }
}