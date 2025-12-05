// lib/ui/activity_logs/mappers/color_mapper.dart

import 'package:flutter/material.dart';

/// Maps status strings and priorities to Colors for UI display
class ActivityColorMapper {
  // ===== SUBSTRATE COLORS =====
  
  static Color getColorForSubstrate(String category) {
    switch (category.toLowerCase()) {
      case 'greens':
        return Colors.green;
      case 'browns':
        return Colors.brown;
      case 'compost':
        return Colors.yellow[700]!;
      default:
        return Colors.grey;
    }
  }

  // ===== ALERT COLORS =====
  
  static Color getColorForAlert(String status) {
    switch (status.toLowerCase()) {
      case 'below':
        return Colors.blue;
      case 'above':
        return Colors.red;
      case 'normal':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // ===== REPORT COLORS (by priority) =====
  
  static Color getColorForReportPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.yellow[700]!;
      case 'high':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ===== CYCLE COLORS =====
  
  static Color getColorForCycle(String category) {
    switch (category.toLowerCase()) {
      case 'recoms':
        return Colors.blue;
      case 'cycles':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  // ===== GENERIC COLOR FROM STRING =====
  
  /// Convert color string to Color (for legacy compatibility)
  static Color colorFromString(String colorStr) {
    switch (colorStr.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow[700]!;
      case 'orange':
        return Colors.orange;
      case 'brown':
        return Colors.brown;
      case 'blue':
        return Colors.blue;
      case 'grey':
      case 'gray':
      default:
        return Colors.grey;
    }
  }

  /// Convert int color to Color (for legacy compatibility)
  static Color colorFromInt(int colorInt) {
    switch (colorInt) {
      case 0xFF4CAF50:
        return Colors.green;
      case 0xFFFFC107:
        return Colors.yellow[700]!;
      case 0xFFFF9800:
        return Colors.orange;
      case 0xFFF44336:
        return Colors.red;
      case 0xFF2196F3:
        return Colors.blue;
      case 0xFF8D6E63:
        return Colors.brown;
      case 0xFF9E9E9E:
      default:
        return Colors.grey;
    }
  }
}