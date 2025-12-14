// lib/ui/activity_logs/mappers/icon_mapper.dart

import 'package:flutter/material.dart';

/// Maps categories and types to IconData for UI display
class ActivityIconMapper {
  // ===== SUBSTRATE ICONS =====
  
  static IconData getIconForSubstrate(String category) {
    switch (category.toLowerCase()) {
      case 'greens':
        return Icons.eco;
      case 'browns':
        return Icons.nature;
      case 'compost':
        return Icons.recycling;
      default:
        return Icons.recycling;
    }
  }

  // ===== ALERT ICONS =====
  
  static IconData getIconForAlert(String sensorType) {
    final lower = sensorType.toLowerCase();
    if (lower.contains('temp')) {
      return Icons.thermostat;
    } else if (lower.contains('moisture')) {
      return Icons.water_drop;
    } else if (lower.contains('oxygen') || lower.contains('air')) {
      return Icons.air;
    } else {
      return Icons.warning;
    }
  }

  // ===== REPORT ICONS =====
  
  static IconData getIconForReport(String reportType) {
    switch (reportType.toLowerCase()) {
      case 'maintenance_issue':
        return Icons.build;
      case 'observation':
        return Icons.visibility;
      case 'safety_concern':
        return Icons.warning;
      default:
        return Icons.report;
    }
  }

  // ===== CYCLE ICONS =====
  
  static IconData getIconForCycle(String category) {
    switch (category.toLowerCase()) {
      case 'recoms':
        return Icons.lightbulb;
      case 'cycles':
        return Icons.play_circle;
      default:
        return Icons.eco;
    }
  }

  // ===== GENERIC ICON FROM CODE POINT =====
  
  /// Fallback method to get icon from code point (for legacy compatibility)
  static IconData getIconFromCodePoint(int codePoint) {
    switch (codePoint) {
      case 0xe3b6:
        return Icons.eco;
      case 0xe3b7:
        return Icons.nature;
      case 0xe8e0:
        return Icons.recycling;
      case 0xe68c:
        return Icons.energy_savings_leaf;
      case 0xe429:
        return Icons.thermostat;
      case 0xe7ec:
        return Icons.water_drop;
      case 0xeac1:
        return Icons.bubble_chart;
      case 0xe002:
        return Icons.warning;
      case 0xe037:
        return Icons.play_circle;
      case 0xe0c2:
        return Icons.lightbulb;
      case 0xe86c:
        return Icons.check_circle;
      case 0xf8e5:
        return Icons.thumb_up;
      case 0xe047:
        return Icons.pause_circle;
      case 0xe63d:
        return Icons.air;
      case 0xe5d9:
        return Icons.build;
      case 0xe8f4:
        return Icons.visibility;
      default:
        return Icons.eco;
    }
  }
}