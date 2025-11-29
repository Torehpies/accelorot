// lib/data/models/activity_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityItem {
  final String title;
  final String value;
  final String statusColor;
  final IconData icon;
  final String description;
  final String category;
  final DateTime timestamp;
  final String? machineId;
  final String? machineName;
  final String? batchId;
  final String? operatorName;

  // Report-specific fields
  final bool isReport;
  final String? reportType;
  final String? status;
  final String? priority;

  ActivityItem({
    required this.title,
    required this.value,
    required this.statusColor,
    required this.icon,
    required this.description,
    required this.category,
    required this.timestamp,
    this.machineId,
    this.machineName,
    this.batchId,
    this.operatorName,
    this.isReport = false,
    this.reportType,
    this.status,
    this.priority,
  });

  Color get statusColorValue {
    switch (statusColor.toLowerCase()) {
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

  String get formattedTimestamp {
    return DateFormat('MM/dd/yyyy, hh:mm a').format(timestamp);
  }

  /// Factory constructor to create ActivityItem from Firestore document
  factory ActivityItem.fromMap(Map<String, dynamic> data) {
    final timestamp =
        (data['timestamp'] as Timestamp?)?.toDate() ??
        (data['createdAt'] as Timestamp?)?.toDate() ??
        DateTime.now();

    // Check if this is a report or waste product
    final bool isReport = data['reportType'] != null;

    if (isReport) {
      // This is a report
      return ActivityItem(
        title: data['title'] ?? '',
        value: _capitalizeFirst(data['status'] ?? 'open'),
        statusColor: data['statusColor'] is int
            ? _colorIntToString(data['statusColor'] as int)
            : data['statusColor'] ?? 'grey',
        icon: _getIconFromCodePoint(data['icon'] ?? 0),
        description: data['description'] ?? '',
        category: 'report',
        timestamp: timestamp,
        machineId: data['machineId'],
        machineName: data['machineName'],
        batchId: null,
        operatorName: data['userName'],
        isReport: true,
        reportType: data['reportType'],
        status: data['status'],
        priority: data['priority'],
      );
    } else {
      // This is a waste product
      return ActivityItem(
        title: data['title'] ?? '',
        value: data['value'] ?? '',
        statusColor: data['statusColor'] ?? 'grey',
        icon: _getIconFromCodePoint(data['icon'] ?? 0),
        description: data['description'] ?? '',
        category: data['category'] ?? '',
        timestamp: timestamp,
        machineId: data['machineId'],
        machineName: data['machineName'],
        batchId: data['batchId'],
        operatorName: data['operatorName'],
        isReport: false,
      );
    }
  }

  /// Helper to convert int color to string
  static String _colorIntToString(int colorInt) {
    switch (colorInt) {
      case 0xFF4CAF50:
        return 'green';
      case 0xFFFFC107:
        return 'yellow';
      case 0xFFFF9800:
        return 'orange';
      case 0xFFF44336:
        return 'red';
      case 0xFF2196F3:
        return 'blue';
      case 0xFF8D6E63:
        return 'brown';
      case 0xFF9E9E9E:
      default:
        return 'grey';
    }
  }

  /// Helper to map codePoint to IconData
  static IconData _getIconFromCodePoint(int codePoint) {
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

  /// Helper to capitalize first letter
  static String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Check if this item matches the search query
  bool matchesSearchQuery(String query) {
    final lowerQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowerQuery) ||
        value.toLowerCase().contains(lowerQuery) ||
        description.toLowerCase().contains(lowerQuery) ||
        category.toLowerCase().contains(lowerQuery) ||
        (machineName?.toLowerCase().contains(lowerQuery) ?? false) ||
        (machineId?.toLowerCase().contains(lowerQuery) ?? false) ||
        (operatorName?.toLowerCase().contains(lowerQuery) ?? false) ||
        (batchId?.toLowerCase().contains(lowerQuery) ?? false) ||
        (reportType != null &&
            _getReportTypeLabel(
              reportType!,
            ).toLowerCase().contains(lowerQuery)) ||
        (status?.toLowerCase().contains(lowerQuery) ?? false);
  }

  /// Helper to get report type label for search
  static String _getReportTypeLabel(String reportType) {
    switch (reportType.toLowerCase()) {
      case 'maintenance_issue':
        return 'Maintenance Issue';
      case 'observation':
        return 'Observation';
      case 'safety_concern':
        return 'Safety Concern';
      default:
        return reportType;
    }
  }
}
