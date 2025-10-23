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

    return {
      'iconCodePoint': iconCodePoint,
      'statusColor': statusColor,
    };
  }
}