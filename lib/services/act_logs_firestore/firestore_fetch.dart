import 'package:flutter_application_1/frontend/operator/activity_logs/models/activity_item.dart';
import 'firestore_collections.dart';
import 'firestore_helpers.dart';

class FirestoreFetch {
  // Fetch Substrates - filtered by userId
  static Future<List<ActivityItem>> getSubstrates() async {
    try {
      final userId = FirestoreCollections.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final snapshot = await FirestoreCollections.getSubstratesCollection()
          .where('userId', isEqualTo: userId)
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
  static Future<List<ActivityItem>> getAlerts() async {
    try {
      final userId = FirestoreCollections.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final snapshot = await FirestoreCollections.getAlertsCollection()
          .where('userId', isEqualTo: userId)
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
  static Future<List<ActivityItem>> getCyclesRecom() async {
    try {
      final userId = FirestoreCollections.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final snapshot = await FirestoreCollections.getCyclesRecomCollection()
          .where('userId', isEqualTo: userId)
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
  static Future<List<ActivityItem>> getAllActivities() async {
    try {
      final substrates = await getSubstrates();
      final alerts = await getAlerts();
      final cyclesRecom = await getCyclesRecom();

      final combined = [...substrates, ...alerts, ...cyclesRecom];
      combined.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return combined;
    } catch (e) {
      return [];
    }
  }
}