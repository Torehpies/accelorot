// lib/services/firestore/firestore_util.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/activity_item.dart';

class FirestoreUtil {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? getCurrentUserId() => _auth.currentUser?.uid;

  static ActivityItem toActivityItem(DocumentSnapshot doc) {
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
  }

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
      default:
        return Icons.eco;
    }
  }
}
