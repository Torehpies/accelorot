// lib/data/models/activity_log_item.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// UI model for displaying activity items in the feed
/// This is what the UI layer uses - contains presentation logic
class ActivityLogItem {
  final String id;
  final String title;
  final String value;
  final Color statusColor;
  final IconData icon;
  final String description;
  final String category;
  final DateTime timestamp;
  final ActivityType type;

  final String? reportType;
  
  // Optional metadata
  final String? machineId;
  final String? machineName;
  final String? batchId;
  final String? batchName;
  final String? operatorName;
  final String? priority;
  final String? status;

  // Cycle-specific fields
  final String? controllerType; // 'drum_controller' or 'aerator'
  final int? activeMinutes;
  final int? restMinutes;
  final int? totalRuntimeSeconds;

  const ActivityLogItem({
    required this.id,
    required this.title,
    required this.value,
    required this.statusColor,
    required this.icon,
    required this.description,
    required this.category,
    required this.timestamp,
    required this.type,
    this.machineId,
    this.machineName,
    this.batchId,
    this.batchName,
    this.operatorName,
    this.reportType,
    this.priority,
    this.status,
    this.controllerType,
    this.activeMinutes,
    this.restMinutes,
    this.totalRuntimeSeconds,
  });


  // ===== FACTORY CONSTRUCTORS =====

  /// Create ActivityLogItem from Firestore document
  /// Supports migration from old ActivityItem format
  factory ActivityLogItem.fromFirestore(String id, Map<String, dynamic> data) {
    // Get timestamp with fallbacks
    final timestamp =
        (data['timestamp'] as Timestamp?)?.toDate() ??
        (data['createdAt'] as Timestamp?)?.toDate() ??
        (data['startedAt'] as Timestamp?)?.toDate() ??
        DateTime.now();

    // Detect activity type
    final bool isReport = data['reportType'] != null;
    final bool isCycle = data['controllerType'] != null;
    final bool isAlert = data['sensorType'] != null;
    
    ActivityType type;
    if (isCycle) {
      type = ActivityType.cycle;
    } else if (isReport) {
      type = ActivityType.report;
    } else if (isAlert) {
      type = ActivityType.alert;
    } else {
      type = ActivityType.substrate;
    }

    // Convert string color to Color object
    Color statusColor;
    final colorData = data['statusColor'];
    if (colorData is int) {
      statusColor = Color(colorData);
    } else if (colorData is String) {
      statusColor = _parseColorString(colorData);
    } else {
      statusColor = Colors.grey;
    }

    // Get icon
    IconData icon;
    final iconData = data['icon'];
    if (iconData is int) {
      icon = IconData(iconData, fontFamily: 'MaterialIcons');
    } else {
      icon = Icons.eco;
    }

    return ActivityLogItem(
      id: id,
      title: data['title'] ?? '',
      value: data['value'] ?? '',
      statusColor: statusColor,
      icon: icon,
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      timestamp: timestamp,
      type: type,
      machineId: data['machineId'],
      machineName: data['machineName'],
      batchId: data['batchId'],
      batchName: data['batchName'],
      operatorName: data['operatorName'] ?? data['userName'],
      priority: data['priority'],
      status: data['status'],
      controllerType: data['controllerType'],
      activeMinutes: data['activeMinutes'] as int?,
      restMinutes: data['restMinutes'] as int?,
      totalRuntimeSeconds: data['totalRuntimeSeconds'],
    );
  }

  /// Parse color string to Color object
  static Color _parseColorString(String colorStr) {
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

  

  // ===== COMPUTED PROPERTIES =====
  
  // Convenience getters
  bool get isCycle => type == ActivityType.cycle;
  bool get isRunning => status == 'running';
  bool get isCompleted => status == 'completed';

  /// Formatted timestamp for display
  String get formattedTimestamp {
    return DateFormat('MM/dd/yyyy, hh:mm a').format(timestamp);
  }

  

  /// Check if this is a report type activity
  bool get isReport => reportType?.toLowerCase() == 'reports';

  // ===== SEARCH =====

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
        (batchName?.toLowerCase().contains(lowerQuery) ?? false) ||
        (batchId?.toLowerCase().contains(lowerQuery) ?? false) ||
        (status?.toLowerCase().contains(lowerQuery) ?? false) ||
        (controllerType?.toLowerCase().contains(lowerQuery) ?? false); 
  }
}

/// Enum for activity types
enum ActivityType {
  substrate,
  alert,
  report,
  cycle,
}