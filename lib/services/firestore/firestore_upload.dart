import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/services/mock_data_service.dart';
import 'firestore_collections.dart';
import 'firestore_helpers.dart';

class FirestoreUpload {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🧠 Utility to determine which user ID to use.
  /// ⭐ CRITICAL: This method expects the userId to ALREADY be resolved by the service layer
  /// It should NEVER be null when called - the service layer handles resolution
  static String _resolveUserId(String? userId) {
    if (userId == null || userId.isEmpty) {
      throw Exception('User ID must be provided. This is a programming error - FirestoreActivityService should always resolve the user ID before calling upload methods.');
    }
    return userId;
  }

  /// Upload substrate mock data to Firestore.
  static Future<void> uploadSubstrates([String? targetUserId]) async {
    try {
      final userId = _resolveUserId(targetUserId);

      final substrates = MockDataService.getSubstrates();
      final batch = _firestore.batch();

      for (var s in substrates) {
        // ⭐ Use timestamp + userId for unique doc ID
        final docId = '${s.timestamp.millisecondsSinceEpoch}_${userId}';
        final docRef = FirestoreCollections.getSubstratesCollection(userId).doc(docId);

        batch.set(docRef, {
          'title': s.title,
          'value': s.value,
          'statusColor': s.statusColor,
          'icon': s.icon.codePoint,
          'description': s.description,
          'category': s.category,
          'timestamp': s.timestamp,
          'userId': userId, // ⭐ This will be the operator's ID when admin is viewing
        });
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Upload alert mock data.
  static Future<void> uploadAlerts([String? targetUserId]) async {
    try {
      final userId = _resolveUserId(targetUserId);

      final alerts = MockDataService.getAlerts();
      final batch = _firestore.batch();

      for (var a in alerts) {
        // ⭐ Use timestamp + userId for unique doc ID
        final docId = '${a.timestamp.millisecondsSinceEpoch}_${userId}';
        final docRef = FirestoreCollections.getAlertsCollection(userId).doc(docId);

        batch.set(docRef, {
          'title': a.title,
          'value': a.value,
          'statusColor': a.statusColor,
          'icon': a.icon.codePoint,
          'description': a.description,
          'category': a.category,
          'timestamp': a.timestamp,
          'userId': userId, // ⭐ This will be the operator's ID when admin is viewing
        });
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Upload cycles & recommendations mock data.
  static Future<void> uploadCyclesRecom([String? targetUserId]) async {
    try {
      final userId = _resolveUserId(targetUserId);

      final cycles = MockDataService.getCyclesRecom();
      final batch = _firestore.batch();

      for (var c in cycles) {
        // ⭐ Use timestamp + userId for unique doc ID
        final docId = '${c.timestamp.millisecondsSinceEpoch}_${userId}';
        final docRef = FirestoreCollections.getCyclesRecomCollection(userId).doc(docId);

        batch.set(docRef, {
          'title': c.title,
          'value': c.value,
          'statusColor': c.statusColor,
          'icon': c.icon.codePoint,
          'description': c.description,
          'category': c.category,
          'timestamp': c.timestamp,
          'userId': userId, // ⭐ This will be the operator's ID when admin is viewing
        });
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Upload all mock data (if not already present).
  static Future<void> uploadAllMockData([String? targetUserId]) async {
    try {
      final userId = _resolveUserId(targetUserId);
      final exists = await FirestoreCollections.dataExists(userId);
      if (exists) return;

      await uploadSubstrates(userId);
      await uploadAlerts(userId);
      await uploadCyclesRecom(userId);
    } catch (e) {
      rethrow;
    }
  }

  /// Force re-upload all mock data (deletes existing first).
  static Future<void> forceUploadAllMockData([String? targetUserId]) async {
    try {
      final userId = _resolveUserId(targetUserId);
      await FirestoreCollections.deleteUserData(userId);

      await uploadSubstrates(userId);
      await uploadAlerts(userId);
      await uploadCyclesRecom(userId);
    } catch (e) {
      rethrow;
    }
  }

  /// Add a single waste product (manual entry)
  /// ⭐ KEY METHOD: This is what gets called when creating new activity logs
  static Future<void> addWasteProduct(Map<String, dynamic> waste, [String? targetUserId]) async {
    try {
      final userId = _resolveUserId(targetUserId);

      final category = waste['category'];
      final iconAndColor = FirestoreHelpers.getWasteIconAndColor(category);

      final timestamp = waste['timestamp'] as DateTime;
      
      // ⭐ Use auto-generated ID or timestamp-based ID (not userId prefix)
      // This ensures uniqueness across all documents in the collection
      final docId = '${timestamp.millisecondsSinceEpoch}_${userId}';
      final docRef = FirestoreCollections.getSubstratesCollection(userId).doc(docId);

      final data = {
        'title': waste['plantTypeLabel'],
        'value': '${waste['quantity']}kg',
        'statusColor': iconAndColor['statusColor'],
        'icon': iconAndColor['iconCodePoint'],
        'description': waste['description'],
        'category': category,
        'timestamp': Timestamp.fromDate(timestamp),
        'userId': userId, // ⭐ This will be the operator's ID when admin is viewing
      };

      await docRef.set(data);
      await Future.delayed(const Duration(milliseconds: 300));

      final verify = await docRef.get();
      if (!verify.exists) throw Exception('Document not saved');
    } catch (e) {
      rethrow;
    }
  }
}