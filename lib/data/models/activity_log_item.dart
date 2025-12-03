// lib/ui/activity_logs/models/activity_log_item.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  
  // Optional metadata
  final String? machineId;
  final String? machineName;
  final String? batchId;
  final String? operatorName;
  final String? priority;
  final String? status;

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
    this.operatorName,
    this.priority,
    this.status,
  });

  // ===== COMPUTED PROPERTIES =====

  /// Formatted timestamp for display
  String get formattedTimestamp {
    return DateFormat('MM/dd/yyyy, hh:mm a').format(timestamp);
  }

  /// Check if this is a report type activity
  bool get isReport => type == ActivityType.report;

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
        (batchId?.toLowerCase().contains(lowerQuery) ?? false) ||
        (status?.toLowerCase().contains(lowerQuery) ?? false);
  }
}

/// Enum for activity types
enum ActivityType {
  substrate,
  alert,
  report,
  cycle,
}