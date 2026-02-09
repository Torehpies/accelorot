// lib/ui/activity_logs/models/unified_activity_config.dart

import 'package:flutter/material.dart';
import '../../../data/models/activity_log_item.dart';
import 'activity_enums.dart';

/// Centralized config for unified activity log handling
class UnifiedActivityConfig {
  // ===== ENUM-BASED HELPERS =====

  /// Get available sub-types for a category
  static List<ActivitySubType> getSubTypesForCategory(
    ActivityCategory category,
  ) {
    return ActivityEnumHelpers.getSubTypesForCategory(category);
  }

  /// Get color for type chip
  static Color getColorForSubType(ActivitySubType subType) {
    return subType.chipColor;
  }

  /// Get neutral gray color for category badges
  static Color get categoryBadgeColor => ActivityEnumHelpers.categoryBadgeColor;

  /// Get high-level category name from ActivityType
  static String getCategoryNameFromActivityType(ActivityType type) {
    return ActivityCategory.fromActivityType(type).displayName;
  }

  /// Map high-level category to ActivityType (for filtering)
  static ActivityType? getActivityTypeFromCategory(ActivityCategory category) {
    return category.toActivityType();
  }

  /// Check if sub-type is valid for category
  static bool isValidSubTypeForCategory(
    ActivitySubType subType,
    ActivityCategory category,
  ) {
    return ActivityEnumHelpers.isValidSubTypeForCategory(subType, category);
  }

  // ===== BACKWARD COMPATIBILITY HELPERS =====

  /// Parse category from string (for legacy code)
  static ActivityCategory parseCategoryFromString(String category) {
    switch (category.toLowerCase()) {
      case 'substrates':
        return ActivityCategory.substrates;
      case 'alerts':
        return ActivityCategory.alerts;
      case 'reports':
        return ActivityCategory.reports;
      case 'cycles':
        return ActivityCategory.cycles;
      default:
        return ActivityCategory.all;
    }
  }

  /// Parse sub-type from string (for legacy code)
  static ActivitySubType parseSubTypeFromString(String type) {
    return ActivitySubType.fromString(type);
  }
}
