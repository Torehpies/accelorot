// lib/ui/activity_logs/models/activity_enums.dart

import 'package:flutter/material.dart';
import '../../../data/models/activity_log_item.dart';

/// High-level activity categories for filtering
/// Maps to the main filter dropdown in the UI
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
  /// Returns null for 'all' (no filter)
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
/// Each sub-type belongs to a parent category
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

  /// Get color for type chip display
  Color get chipColor {
    switch (this) {
      case ActivitySubType.all:
        return const Color(0xFF9CA3AF); // gray-400
      // Substrates
      case ActivitySubType.greens:
        return const Color(0xFF10B981); // emerald-500
      case ActivitySubType.browns:
        return const Color(0xFFF59E0B); // amber-500
      case ActivitySubType.compost:
        return const Color(0xFF84CC16); // lime-500
      // Alerts
      case ActivitySubType.temperature:
        return const Color(0xFFF97316); // orange-500
      case ActivitySubType.moisture:
        return const Color(0xFF3B82F6); // blue-500
      case ActivitySubType.airQuality:
        return const Color(0xFF8B5CF6); // violet-500
      // Reports
      case ActivitySubType.maintenance:
        return const Color(0xFFFBBF24); // amber-400
      case ActivitySubType.observation:
        return const Color(0xFF06B6D4); // cyan-500
      case ActivitySubType.safety:
        return const Color(0xFFEF4444); // red-500
      // Cycles
      case ActivitySubType.recoms:
        return const Color(0xFF22C55E); // green-500
      case ActivitySubType.cycles:
        return const Color(0xFF14B8A6); // teal-500
    }
  }

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
  static List<ActivitySubType> getSubTypesForCategory(ActivityCategory category) {
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

  /// Get the neutral gray color for category badges
  static const categoryBadgeColor = Color(0xFF9CA3AF); // gray-400
}