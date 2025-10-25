import 'package:flutter_application_1/frontend/operator/activity_logs/models/activity_item.dart';
import 'firestore_collections.dart';
import 'firestore_helpers.dart';

class FirestoreFetch {
  /// ⭐ Validate that userId is provided (should never be null from service layer)
  static String _validateUserId(String? userId) {
    if (userId == null || userId.isEmpty) {
      throw Exception('User ID must be provided. This is a programming error - FirestoreActivityService should always resolve the user ID before calling fetch methods.');
    }
    return userId;
  }

  // Fetch Substrates - filtered by userId
  static Future<List<ActivityItem>> getSubstrates(String? userId) async {
    try {
      final targetUserId = _validateUserId(userId);

      final snapshot = await FirestoreCollections.getSubstratesCollection(targetUserId)
          .where('userId', isEqualTo: targetUserId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FirestoreHelpers.documentToActivityItem(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Fetch Alerts - filtered by userId
  static Future<List<ActivityItem>> getAlerts(String? userId) async {
    try {
      final targetUserId = _validateUserId(userId);

      final snapshot = await FirestoreCollections.getAlertsCollection(targetUserId)
          .where('userId', isEqualTo: targetUserId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FirestoreHelpers.documentToActivityItem(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Fetch Cycles and Recommendations - filtered by userId
  static Future<List<ActivityItem>> getCyclesRecom(String? userId) async {
    try {
      final targetUserId = _validateUserId(userId);

      final snapshot = await FirestoreCollections.getCyclesRecomCollection(targetUserId)
          .where('userId', isEqualTo: targetUserId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FirestoreHelpers.documentToActivityItem(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Fetch All Activities Combined
  static Future<List<ActivityItem>> getAllActivities(String? userId) async {
    try {
      final substrates = await getSubstrates(userId);
      final alerts = await getAlerts(userId);
      final cyclesRecom = await getCyclesRecom(userId);

      final combined = [...substrates, ...alerts, ...cyclesRecom];
      combined.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return combined;
    } catch (e) {
      return [];
    }
  }
}