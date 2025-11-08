// lib/services/firestore/firestore_helpers.dart
import 'package:flutter/material.dart' show Icons, IconData;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/models/activity_item.dart';

class FirestoreHelpers {
  // Convert Firestore document to ActivityItem
  static ActivityItem documentToActivityItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = (data['timestamp'] as Timestamp).toDate();

    return ActivityItem(
      title: data['title'] ?? '',
      value: data['value'] ?? '',
      statusColor: data['statusColor'] ?? 'grey',
      icon: getIconFromCodePoint(data['icon'] ?? 0),
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      timestamp: timestamp,
    );
    // Note: userId is stored in Firestore but not needed in the model
  }

  // Helper to map codePoint → IconData
  static IconData getIconFromCodePoint(int codePoint) {
    switch (codePoint) {
      case 0xe3b6: // Icons.eco
        return Icons.eco;
      case 0xe3b7: // Icons.nature
        return Icons.nature;
      case 0xe8e0: // Icons.recycling
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
      default:
        return Icons.eco;
    }
  }

  // Get icon and color based on waste category (case-insensitive)
  static Map<String, dynamic> getWasteIconAndColor(String category) {
    int iconCodePoint;
    String statusColor;

    final lowerCategory = category.toLowerCase();

    if (lowerCategory == 'greens') {
      iconCodePoint = Icons.eco.codePoint;
      statusColor = 'green';
    } else if (lowerCategory == 'browns') {
      iconCodePoint = Icons.nature.codePoint;
      statusColor = 'brown';
    } else {
      // Default for compost or other categories
      iconCodePoint = Icons.recycling.codePoint;
      statusColor = 'yellow';
    }

    return {'iconCodePoint': iconCodePoint, 'statusColor': statusColor};
  }

  /// Returns icon and color for report types
  static Map<String, dynamic> getReportIconAndColor(String? reportType) {
    switch (reportType?.toLowerCase()) {
      case 'maintenance_issue':
        return {'iconCodePoint': Icons.build.codePoint, 'icon': Icons.build};
      case 'observation':
        return {
          'iconCodePoint': Icons.visibility.codePoint,
          'icon': Icons.visibility,
        };
      case 'safety_concern':
        return {
          'iconCodePoint': Icons.warning.codePoint,
          'icon': Icons.warning,
        };
      default:
        return {'iconCodePoint': Icons.report.codePoint, 'icon': Icons.report};
    }
  }

  /// Returns color based on priority level
  static int getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'low':
        return 0xFF4CAF50; // Green
      case 'medium':
        return 0xFFFFC107; // Amber/Yellow
      case 'high':
        return 0xFFFF9800; // Orange
      case 'critical':
        return 0xFFF44336; // Red
      default:
        return 0xFF9E9E9E; // Gray
    }
  }

  /// Returns display label for priority
  static String getPriorityLabel(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      default:
        return 'Unknown';
    }
  }

  /// Returns display label for report type
  static String getReportTypeLabel(String? reportType) {
    switch (reportType?.toLowerCase()) {
      case 'maintenance_issue':
        return 'Maintenance Issue';
      case 'observation':
        return 'Observation';
      case 'safety_concern':
        return 'Safety Concern';
      default:
        return 'Unknown';
    }
  }

  /// Converts int color to string color name for ActivityItem compatibility
  static String colorIntToString(int colorInt) {
    switch (colorInt) {
      case 0xFF4CAF50: // Green
        return 'green';
      case 0xFFFFC107: // Amber/Yellow
        return 'yellow';
      case 0xFFFF9800: // Orange
        return 'orange';
      case 0xFFF44336: // Red
        return 'red';
      case 0xFF2196F3: // Blue
        return 'blue';
      case 0xFF8D6E63: // Brown
        return 'brown';
      case 0xFF9E9E9E: // Gray
      default:
        return 'grey';
    }
  }
}
