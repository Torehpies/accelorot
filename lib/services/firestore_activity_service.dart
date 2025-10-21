// firestore_activity_service.dart
import 'package:flutter/material.dart' show Icons, IconData;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/models/activity_item.dart';
import 'mock_data_service.dart';

class FirestoreActivityService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // 🔹 Firestore Collection References

  static CollectionReference _getSubstratesCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('activities')
        .doc('docu')
        .collection('substrates');
  }

  static CollectionReference _getAlertsCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('activities')
        .doc('docu')
        .collection('alerts');
  }

  // NEW 🔹 Cycles & Recommendations collection reference
  static CollectionReference _getCyclesRecomCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('activities')
        .doc('docu')
        .collection('cyclesRecom');
  }

  // 🔹 Upload mock data to Firestore

  static Future<void> uploadSubstrates() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final substrates = MockDataService.getSubstrates();
      final batch = _firestore.batch();

      for (var substrate in substrates) {
        final docRef = _getSubstratesCollection(userId)
            .doc(substrate.timestamp.millisecondsSinceEpoch.toString());

        batch.set(docRef, {
          'title': substrate.title,
          'value': substrate.value,
          'statusColor': substrate.statusColor,
          'icon': substrate.icon.codePoint,
          'description': substrate.description,
          'category': substrate.category,
          'timestamp': substrate.timestamp,
        });
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> uploadAlerts() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final alerts = MockDataService.getAlerts();
      final batch = _firestore.batch();

      for (var alert in alerts) {
        final docRef = _getAlertsCollection(userId)
            .doc(alert.timestamp.millisecondsSinceEpoch.toString());

        batch.set(docRef, {
          'title': alert.title,
          'value': alert.value,
          'statusColor': alert.statusColor,
          'icon': alert.icon.codePoint,
          'description': alert.description,
          'category': alert.category,
          'timestamp': alert.timestamp,
        });
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  // NEW 🔹 Upload mock Cycles & Recommendations
  static Future<void> uploadCyclesRecom() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final cyclesRecom = MockDataService.getCyclesRecom();
      final batch = _firestore.batch();

      for (var item in cyclesRecom) {
        final docRef = _getCyclesRecomCollection(userId)
            .doc(item.timestamp.millisecondsSinceEpoch.toString());

        batch.set(docRef, {
          'title': item.title,
          'value': item.value,
          'statusColor': item.statusColor,
          'icon': item.icon.codePoint,
          'description': item.description,
          'category': item.category,
          'timestamp': item.timestamp,
        });
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  // 🔹 Data Existence Check

  static Future<bool> _dataExists() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return false;

      final substrates = await _getSubstratesCollection(userId).limit(1).get();
      return substrates.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // 🔹 Upload All Mock Data (Substrates + Alerts + CyclesRecom)
  static Future<void> uploadAllMockData() async {
    try {
      final exists = await _dataExists();
      if (exists) return;

      await uploadSubstrates();
      await uploadAlerts();
      await uploadCyclesRecom(); // 👈 Added here
    } catch (e) {
      rethrow;
    }
  }

  // 🔹 Force Upload (delete old + upload fresh)
  static Future<void> forceUploadAllMockData() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      // Delete existing data
      final substrateDocs = await _getSubstratesCollection(userId).get();
      for (var doc in substrateDocs.docs) {
        await doc.reference.delete();
      }

      final alertDocs = await _getAlertsCollection(userId).get();
      for (var doc in alertDocs.docs) {
        await doc.reference.delete();
      }

      final cyclesRecomDocs = await _getCyclesRecomCollection(userId).get();
      for (var doc in cyclesRecomDocs.docs) {
        await doc.reference.delete();
      }

      // Upload fresh mock data
      await uploadSubstrates();
      await uploadAlerts();
      await uploadCyclesRecom();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> addWasteProduct(Map<String, dynamic> waste) async {
  try {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not logged in');

    final docRef = _getSubstratesCollection(userId)
        .doc(waste['timestamp'].millisecondsSinceEpoch.toString());

    await docRef.set({
      'title': waste['plantTypeLabel'],
      'value': '${waste['quantity']} kg',
      'statusColor': waste['category'] == 'greens'
          ? 'green'
          : waste['category'] == 'browns'
              ? 'brown'
              : 'orange',
      'icon': Icons.eco.codePoint,
      'description': waste['description'],
      'category': waste['category'],
      'timestamp': waste['timestamp'],
    });
  } catch (e) {
    rethrow;
  }
}

  // 🔹 Fetch data from Firestore

  static Future<List<ActivityItem>> getSubstrates() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final snapshot = await _getSubstratesCollection(userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => _documentToActivityItem(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  // Fetch Alerts
  static Future<List<ActivityItem>> getAlerts() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final snapshot = await _getAlertsCollection(userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => _documentToActivityItem(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  // Fetch Cycles & Recommendations
  static Future<List<ActivityItem>> getCyclesRecom() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final snapshot = await _getCyclesRecomCollection(userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => _documentToActivityItem(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  // 🔹 Combined all activities
  static Future<List<ActivityItem>> getAllActivities() async {
    try {
      final substrates = await getSubstrates();
      final alerts = await getAlerts();
      final cyclesRecom = await getCyclesRecom(); // 👈 Added here

      final combined = [...substrates, ...alerts, ...cyclesRecom];
      combined.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return combined;
    } catch (e) {
      return [];
    }
  }

  // 🔹 Convert Firestore document to ActivityItem
  static ActivityItem _documentToActivityItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = (data['timestamp'] as Timestamp).toDate();

    return ActivityItem(
      title: data['title'] ?? '',
      value: data['value'] ?? '',
      statusColor: data['statusColor'] ?? 'grey',
      icon: _getIconFromCodePoint(data['icon'] ?? 0),
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      timestamp: timestamp,
    );
  }

  // 🔹 Helper to map codePoint → IconData
  static IconData _getIconFromCodePoint(int codePoint) {
    switch (codePoint) {
      case 0xe3b6:
        return Icons.eco;
      case 0xe68c:
        return Icons.energy_savings_leaf;
      case 0xe8e0:
        return Icons.recycling;
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
