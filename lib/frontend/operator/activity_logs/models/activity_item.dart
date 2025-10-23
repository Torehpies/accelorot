import 'package:flutter/material.dart';

class ActivityItem {
  final String title;
  final String value;
  final String statusColor; // 'red', 'green', 'yellow', 'grey', 'brown', 'orange'
  final IconData icon;
  final String description;
  final String category;
  final DateTime timestamp;

  ActivityItem({
    required this.title,
    required this.value,
    required this.statusColor,
    required this.icon,
    required this.description,
    required this.category,
    required this.timestamp,
  });

  // Helper to get color from string
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

  // Format timestamp as MM/DD/YY, HH:MM AM/PM
  String get formattedTimestamp {
    final hour = timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
    final displayHour = hour == 0 ? 12 : hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = timestamp.hour >= 12 ? 'PM' : 'AM';
    final month = timestamp.month.toString().padLeft(2, '0');
    final day = timestamp.day.toString().padLeft(2, '0');
    final year = timestamp.year.toString().substring(2);
    
    return '$month/$day/$year, $displayHour:$minute $period';
  }

  // Reusable search method - checks if item matches the search query
  bool matchesSearchQuery(String query) {
    if (query.isEmpty) return true;
    
    final lowerQuery = query.toLowerCase();
    final timestampStr = '${timestamp.year}-${timestamp.month}-${timestamp.day} ${timestamp.hour}:${timestamp.minute}';
    
    return title.toLowerCase().contains(lowerQuery) ||
           description.toLowerCase().contains(lowerQuery) ||
           value.toLowerCase().contains(lowerQuery) ||
           category.toLowerCase().contains(lowerQuery) ||
           timestampStr.toLowerCase().contains(lowerQuery);
  }
}