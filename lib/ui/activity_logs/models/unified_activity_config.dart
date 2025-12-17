// lib/ui/activity_logs/models/unified_activity_config.dart

import 'package:flutter/material.dart';
import '../../../data/models/activity_log_item.dart';

/// Handles category-type relationships, colors, and filtering
class UnifiedActivityConfig {
  // ===== MAIN CATEGORIES =====
  
  static const categories = [
    'All',
    'Substrates',
    'Alerts',
    'Reports',
    'Cycles',
  ];

  // ===== ALL GRANULAR TYPES =====
  
  static const allTypes = [
    'All',
    // Substrates
    'Greens', 'Browns', 'Compost',
    // Alerts
    'Temperature', 'Moisture', 'Air Quality',
    // Reports
    'Maintenance', 'Observation', 'Safety',
    // Cycles
    'Recoms', 'Cycles',
  ];

  // ===== TYPES PER CATEGORY =====
  
  static const categoryTypeMap = {
    'All': allTypes,
    'Substrates': ['All', 'Greens', 'Browns', 'Compost'],
    'Alerts': ['All', 'Temperature', 'Moisture', 'Air Quality'],
    'Reports': ['All', 'Maintenance', 'Observation', 'Safety'],
    'Cycles': ['All', 'Recoms', 'Cycles'],
  };

  // ===== REVERSE LOOKUP: Type → Category =====
  
  static const typeToCategoryMap = {
    'Greens': 'Substrates',
    'Browns': 'Substrates',
    'Compost': 'Substrates',
    'Temperature': 'Alerts',
    'Moisture': 'Alerts',
    'Air Quality': 'Alerts',
    'Maintenance': 'Reports',
    'Observation': 'Reports',
    'Safety': 'Reports',
    'Recoms': 'Cycles',
    'Cycles': 'Cycles',
  };

  // ===== TYPE CHIP COLORS =====
  
  static const typeChipColors = {
    // Substrates
    'Greens': Color(0xFF10B981),      // emerald-500
    'Browns': Color(0xFFF59E0B),      // amber-500
    'Compost': Color(0xFF84CC16),     // lime-500
    
    // Alerts
    'Temperature': Color(0xFFF97316), // orange-500
    'Moisture': Color(0xFF3B82F6),    // blue-500
    'Air Quality': Color(0xFF8B5CF6), // violet-500
    
    // Reports
    'Maintenance': Color(0xFFFBBF24), // amber-400
    'Observation': Color(0xFF06B6D4), // cyan-500
    'Safety': Color(0xFFEF4444),      // red-500
    
    // Cycles
    'Recoms': Color(0xFF22C55E),      // green-500
    'Cycles': Color(0xFF14B8A6),      // teal-500
  };

  // ===== CATEGORY BADGE COLOR (neutral gray) =====
  
  static const categoryBadgeColor = Color(0xFF9CA3AF); // gray-400

  // ===== HELPER METHODS =====

  /// Get available types for a category
  static List<String> getTypesForCategory(String category) {
    return categoryTypeMap[category] ?? ['All'];
  }

  /// Detect category from type
  static String? detectCategoryFromType(String type) {
    return typeToCategoryMap[type];
  }

  /// Get color for type chip
  static Color getColorForType(String type) {
    return typeChipColors[type] ?? Colors.grey;
  }

  /// Get high-level category name from ActivityType
  static String getCategoryNameFromActivityType(ActivityType type) {
    switch (type) {
      case ActivityType.substrate:
        return 'Substrates';
      case ActivityType.alert:
        return 'Alerts';
      case ActivityType.report:
        return 'Reports';
      case ActivityType.cycle:
        return 'Cycles';
    }
  }

  /// Map high-level category to ActivityType (for filtering)
  static ActivityType? getActivityTypeFromCategory(String category) {
    switch (category) {
      case 'Substrates':
        return ActivityType.substrate;
      case 'Alerts':
        return ActivityType.alert;
      case 'Reports':
        return ActivityType.report;
      case 'Cycles':
        return ActivityType.cycle;
      default:
        return null; // 'All' = no filter
    }
  }
}