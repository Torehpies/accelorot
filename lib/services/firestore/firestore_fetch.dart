import 'package:flutter_application_1/frontend/operator/activity_logs/models/activity_item.dart';
import 'firestore_collections.dart';
import 'package:flutter/material.dart';
//ignore: unused_import
import 'firestore_helpers.dart';

class FirestoreFetch {
  /// Validate that userId is provided (should never be null from service layer)
  // ignore: unused_element
  static String _validateUserId(String? userId) {
    if (userId == null || userId.isEmpty) {
      throw Exception('User ID must be provided. This is a programming error - FirestoreActivityService should always resolve the user ID before calling fetch methods.');
    }
    return userId;
  }
    static String _resolveUserId(String? userId) {
    if (userId == null || userId.isEmpty) {
      throw Exception('User ID must be provided');
    }
    return userId;
  }

  // Fetch Substrates - filtered by userId
  static Future<List<ActivityItem>> getSubstrates([String? targetUserId]) async {
    try {
      final userId = _resolveUserId(targetUserId);
      
      // Get all batches for this user
      final batchesSnapshot = await FirestoreCollections.getBatchesCollection()
          .where('userId', isEqualTo: userId)
          .get();

      List<ActivityItem> allSubstrates = [];

      // Fetch substrates from each batch
      for (var batchDoc in batchesSnapshot.docs) {
        final substratesSnapshot = await FirestoreCollections
            .getSubstratesCollection(batchDoc.id, userId)
            .get();

        final substrates = substratesSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return ActivityItem.fromMap(data);
        }).toList();

        allSubstrates.addAll(substrates);
      }

      // Sort all substrates by timestamp
      allSubstrates.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      debugPrint('✅ Fetched ${allSubstrates.length} substrates for user: $userId');

      return allSubstrates;
    } catch (e) {
      debugPrint('Error fetching substrates: $e');
      rethrow;
    }
  }

  // Fetch Alerts - filtered by userId
  static Future<List<ActivityItem>> getAlerts([String? targetUserId]) async {
    try {
      final userId = _resolveUserId(targetUserId);
      final snapshot = await FirestoreCollections.getAlertsCollection(userId)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ActivityItem.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching alerts: $e');
      rethrow;
    }
  }

  // Fetch Cycles and Recommendations - filtered by userId
  static Future<List<ActivityItem>> getCyclesRecom([String? targetUserId]) async {
    try {
      final userId = _resolveUserId(targetUserId);
      final snapshot = await FirestoreCollections.getCyclesRecomCollection(userId)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ActivityItem.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching cycles: $e');
      rethrow;
    }
  }

  // Fetch All Activities Combined
  static Future<List<ActivityItem>> getAllActivities([String? targetUserId]) async {
    try {
      final userId = _resolveUserId(targetUserId);
      
      // Fetch all collections in parallel
      final results = await Future.wait([
        getSubstrates(userId),
        getAlerts(userId),
        getCyclesRecom(userId),
      ]);

      // Combine all lists
      final allActivities = <ActivityItem>[
        ...results[0],
        ...results[1],
        ...results[2],
      ];

      // Sort by timestamp descending
      allActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      debugPrint('✅ Fetched ${allActivities.length} total activities for user: $userId');
      
      if (allActivities.isNotEmpty) {
        final first = allActivities.first;
        debugPrint('   First activity: machineId=${first.machineId}, machineName=${first.machineName}, operator=${first.operatorName}');
      }

      return allActivities;
    } catch (e) {
      debugPrint('❌ Error fetching all activities: $e');
      rethrow;
    }
  }
}