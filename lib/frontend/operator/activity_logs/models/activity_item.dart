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

  ActivityItem({
    required this.title,
    required this.value,
    required this.statusColor,
    required this.icon,
    required this.description,
    required this.category,
    required this.timestamp,
    this.userId,
  });

  // Firestore: Convert document to model
  factory ActivityItem.fromMap(Map<String, dynamic> data) {
    return ActivityItem(
      title: data['title'] ?? '',
      value: data['value'] ?? '',
      statusColor: data['statusColor'] ?? 'grey',
      icon: IconData(data['icon'] ?? Icons.info.codePoint, fontFamily: 'MaterialIcons'),
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      userId: data['userId'],
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
           value.toLowerCase().contains(lower);
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
    );
  }
}
