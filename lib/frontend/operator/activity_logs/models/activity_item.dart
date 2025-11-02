// activity_item.dart
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
  final String? userId;

  final String? machineId;
  final String? machineName;
  final String? operatorName;
  final String? batchId;

  ActivityItem({
    required this.title,
    required this.value,
    required this.statusColor,
    required this.icon,
    required this.description,
    required this.category,
    required this.timestamp,
    this.userId,
    this.machineId,
    this.machineName,
    this.operatorName,
    this.batchId,
  });

  // Firestore: Convert document to model
  factory ActivityItem.fromMap(Map<String, dynamic> data) {
    // handle timestamp being either Timestamp or DateTime (defensive)
    DateTime ts;
    final rawTs = data['timestamp'];
    if (rawTs is Timestamp) {
      ts = rawTs.toDate();
    } else if (rawTs is DateTime) {
      ts = rawTs;
    } else {
      ts = DateTime.now();
    }

    return ActivityItem(
      title: data['title'] ?? '',
      value: data['value'] ?? '',
      statusColor: data['statusColor'] ?? 'grey',
      icon: IconData(data['icon'] ?? Icons.info.codePoint, fontFamily: 'MaterialIcons'),
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      timestamp: ts,
      userId: data['userId'],
      machineId: data['machineId'],
      machineName: data['machineName'],
      operatorName: data['operatorName'],
      batchId: data['batchId'],
    );
  }

  // Firestore: Convert model to document
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'value': value,
      'statusColor': statusColor,
      'icon': icon.codePoint,
      'description': description,
      'category': category,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId,
      'machineId': machineId,
      'machineName': machineName,
      'operatorName': operatorName,
      'batchId': batchId, 
    };
  }

  // UI: Formatted time
  String get formattedTimestamp {
    return DateFormat('MM/dd/yyyy, hh:mm a').format(timestamp);
  }

  // UI: Color parser
  Color get statusColorValue {
    switch (statusColor.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow.shade700;
      case 'grey':
        return Colors.grey;
      case 'brown':
        return Colors.brown;
      case 'orange':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Search utility
  bool matchesSearchQuery(String query) {
    final lower = query.toLowerCase();
    return title.toLowerCase().contains(lower) ||
           description.toLowerCase().contains(lower) ||
           category.toLowerCase().contains(lower) ||
           value.toLowerCase().contains(lower) ||
           (machineName ?? machineId ?? '').toLowerCase().contains(lower) ||
           (operatorName ?? '').toLowerCase().contains(lower) ||
           (batchId ?? '').toLowerCase().contains(lower); 
  }

  // Immutable copying
  ActivityItem copyWith({
    String? title,
    String? value,
    String? statusColor,
    IconData? icon,
    String? description,
    String? category,
    DateTime? timestamp,
    String? userId,
    String? machineId,
    String? machineName,
    String? operatorName,
    String? batchId,
  }) {
    return ActivityItem(
      title: title ?? this.title,
      value: value ?? this.value,
      statusColor: statusColor ?? this.statusColor,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      machineId: machineId ?? this.machineId,
      machineName: machineName ?? this.machineName,
      operatorName: operatorName ?? this.operatorName,
      batchId: batchId ?? this.batchId,
    );
  }
}