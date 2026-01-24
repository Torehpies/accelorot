// lib/ui/activity_logs/models/activity_enums.dart

import 'package:flutter/material.dart';
import '../../../data/models/activity_log_item.dart';
import '../../core/themes/web_colors.dart';

/// High-level activity categories for filtering
enum ActivityCategory {
  all,
  substrates,
  alerts,
  reports,
  cycles;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case ActivityCategory.all:
        return 'All';
      case ActivityCategory.substrates:
        return 'Substrates';
      case ActivityCategory.alerts:
        return 'Alerts';
      case ActivityCategory.reports:
        return 'Reports';
      case ActivityCategory.cycles:
        return 'Cycles';
    }
  }

  /// Convert to ActivityType for data filtering
  ActivityType? toActivityType() {
    switch (this) {
      case ActivityCategory.substrates:
        return ActivityType.substrate;
      case ActivityCategory.alerts:
        return ActivityType.alert;
      case ActivityCategory.reports:
        return ActivityType.report;
      case ActivityCategory.cycles:
        return ActivityType.cycle;
      case ActivityCategory.all:
        return null;
    }
  }

  /// Get from ActivityType
  static ActivityCategory fromActivityType(ActivityType type) {
    switch (type) {
      case ActivityType.substrate:
        return ActivityCategory.substrates;
      case ActivityType.alert:
        return ActivityCategory.alerts;
      case ActivityType.report:
        return ActivityCategory.reports;
      case ActivityType.cycle:
        return ActivityCategory.cycles;
    }
  }
}

/// Granular activity sub-types for detailed filtering
enum ActivitySubType {
  all,
  // Substrates
  greens,
  browns,
  compost,
  // Alerts
  temperature,
  moisture,
  airQuality,
  // Reports
  maintenance,
  observation,
  safety,
  // Cycles
  recoms,
  cycles;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case ActivitySubType.all:
        return 'All';
      case ActivitySubType.greens:
        return 'Greens';
      case ActivitySubType.browns:
        return 'Browns';
      case ActivitySubType.compost:
        return 'Compost';
      case ActivitySubType.temperature:
        return 'Temperature';
      case ActivitySubType.moisture:
        return 'Moisture';
      case ActivitySubType.airQuality:
        return 'Air Quality';
      case ActivitySubType.maintenance:
        return 'Maintenance';
      case ActivitySubType.observation:
        return 'Observation';
      case ActivitySubType.safety:
        return 'Safety';
      case ActivitySubType.recoms:
        return 'Recoms';
      case ActivitySubType.cycles:
        return 'Cycles';
    }
  }

  /// Get parent category for this sub-type
  ActivityCategory get parentCategory {
    switch (this) {
      case ActivitySubType.all:
        return ActivityCategory.all;
      case ActivitySubType.greens:
      case ActivitySubType.browns:
      case ActivitySubType.compost:
        return ActivityCategory.substrates;
      case ActivitySubType.temperature:
      case ActivitySubType.moisture:
      case ActivitySubType.airQuality:
        return ActivityCategory.alerts;
      case ActivitySubType.maintenance:
      case ActivitySubType.observation:
      case ActivitySubType.safety:
        return ActivityCategory.reports;
      case ActivitySubType.recoms:
      case ActivitySubType.cycles:
        return ActivityCategory.cycles;
    }
  }

  /// Get color for type chip display using centralized WebColors
  Color get chipColor => WebColors.getActivityTypeColor(this);

  /// Parse from string category (for backward compatibility)
  static ActivitySubType fromString(String category) {
    switch (category.toLowerCase()) {
      case 'greens':
        return ActivitySubType.greens;
      case 'browns':
        return ActivitySubType.browns;
      case 'compost':
        return ActivitySubType.compost;
      case 'temperature':
        return ActivitySubType.temperature;
      case 'moisture':
        return ActivitySubType.moisture;
      case 'air quality':
        return ActivitySubType.airQuality;
      case 'maintenance':
        return ActivitySubType.maintenance;
      case 'observation':
        return ActivitySubType.observation;
      case 'safety':
        return ActivitySubType.safety;
      case 'recoms':
        return ActivitySubType.recoms;
      case 'cycles':
        return ActivitySubType.cycles;
      default:
        return ActivitySubType.all;
    }
  }
}

/// Helper methods for working with activity enums
class ActivityEnumHelpers {
  /// Get all sub-types that belong to a category
  static List<ActivitySubType> getSubTypesForCategory(
    ActivityCategory category,
  ) {
    switch (category) {
      case ActivityCategory.all:
        return ActivitySubType.values;
      case ActivityCategory.substrates:
        return [
          ActivitySubType.all,
          ActivitySubType.greens,
          ActivitySubType.browns,
          ActivitySubType.compost,
        ];
      case ActivityCategory.alerts:
        return [
          ActivitySubType.all,
          ActivitySubType.temperature,
          ActivitySubType.moisture,
          ActivitySubType.airQuality,
        ];
      case ActivityCategory.reports:
        return [
          ActivitySubType.all,
          ActivitySubType.maintenance,
          ActivitySubType.observation,
          ActivitySubType.safety,
        ];
      case ActivityCategory.cycles:
        return [
          ActivitySubType.all,
          ActivitySubType.recoms,
          ActivitySubType.cycles,
        ];
    }
  }

  /// Check if a sub-type is valid for a category
  static bool isValidSubTypeForCategory(
    ActivitySubType subType,
    ActivityCategory category,
  ) {
    if (subType == ActivitySubType.all || category == ActivityCategory.all) {
      return true;
    }
    return subType.parentCategory == category;
  }

  /// Get the neutral gray color for category badges using centralized WebColors
  static const categoryBadgeColor = WebColors.neutral;
}
