//firestore_activity_service.dart
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

  // Get reference to user's activities substrates collection
  static CollectionReference _getSubstratesCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('activities')
        .doc('docu')
        .collection('substrates');
  }

  // Get reference to user's activities alerts collection
  static CollectionReference _getAlertsCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('activities')
        .doc('docu')
        .collection('alerts');
  }

  // Upload mock substrates to Firestore
  static Future<void> uploadSubstrates() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final substrates = MockDataService.getSubstrates();
      final batch = _firestore.batch();

      for (var substrate in substrates) {
        final docRef = _getSubstratesCollection(userId).doc(substrate.timestamp.millisecondsSinceEpoch.toString());

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
      print('Error uploading substrates: $e');
      rethrow;
    }
  }

  // Upload mock alerts to Firestore
  static Future<void> uploadAlerts() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final alerts = MockDataService.getAlerts();
      final batch = _firestore.batch();

      for (var alert in alerts) {
        final docRef = _getAlertsCollection(userId).doc(alert.timestamp.millisecondsSinceEpoch.toString());

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
      print('Error uploading alerts: $e');
      rethrow;
    }
  }

  // Check if data already exists
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

  // Upload all mock data (substrates + alerts) - only if doesn't exist
  static Future<void> uploadAllMockData() async {
    try {
      final exists = await _dataExists();
      if (exists) {
        return;
      }

      await uploadSubstrates();
      await uploadAlerts();
    } catch (e) {
      rethrow;
    }
  }

  // Force upload (deletes old data and uploads fresh)
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

      // Upload fresh data
      await uploadSubstrates();
      await uploadAlerts();
    } catch (e) {
      rethrow;
    }
  }

  // Fetch substrates from Firestore
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

  // Fetch alerts from Firestore
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

  // Fetch all activities (substrates + alerts) combined
  static Future<List<ActivityItem>> getAllActivities() async {
    try {
      final substrates = await getSubstrates();
      final alerts = await getAlerts();
      final combined = [...substrates, ...alerts];
      combined.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return combined;
    } catch (e) {
      print('Error fetching all activities: $e');
      return [];
    }
  }

  // Convert Firestore document to ActivityItem
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

  // Helper to convert icon codepoint back to IconData
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
      default:
        return Icons.eco;
    }
  }
}