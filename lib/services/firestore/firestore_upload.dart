import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/services/mock_data_service.dart';
import 'firestore_collections.dart';
import 'firestore_helpers.dart';

class FirestoreUpload {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Uploads substrate mock data to Firestore for the current user.
  // Each document is uniquely identified by combining user ID and timestamp.
  static Future<void> uploadSubstrates() async {
    try {
      final userId = FirestoreCollections.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final substrates = MockDataService.getSubstrates();
      final batch = _firestore.batch();

      for (var s in substrates) {
        final docRef = FirestoreCollections.getSubstratesCollection()
            .doc('${userId}_${s.timestamp.millisecondsSinceEpoch}');

        batch.set(docRef, {
          'title': s.title,
          'value': s.value,
          'statusColor': s.statusColor,
          'icon': s.icon.codePoint,
          'description': s.description,
          'category': s.category,
          'timestamp': s.timestamp,
          'userId': userId,
        });
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  // Uploads alert mock data to Firestore for the current user.
  // Uses batch writing for efficiency and unique IDs based on user ID and timestamp.
  static Future<void> uploadAlerts() async {
    try {
      final userId = FirestoreCollections.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final alerts = MockDataService.getAlerts();
      final batch = _firestore.batch();

      for (var a in alerts) {
        final docRef = FirestoreCollections.getAlertsCollection()
            .doc('${userId}_${a.timestamp.millisecondsSinceEpoch}');

        batch.set(docRef, {
          'title': a.title,
          'value': a.value,
          'statusColor': a.statusColor,
          'icon': a.icon.codePoint,
          'description': a.description,
          'category': a.category,
          'timestamp': a.timestamp,
          'userId': userId,
        });
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  // Uploads cycle and recommendation mock data to Firestore.
  // Uses batch operations to upload efficiently and prevent duplicate IDs.
  static Future<void> uploadCyclesRecom() async {
    try {
      final userId = FirestoreCollections.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final cycles = MockDataService.getCyclesRecom();
      final batch = _firestore.batch();

      for (var c in cycles) {
        final docRef = FirestoreCollections.getCyclesRecomCollection()
            .doc('${userId}_${c.timestamp.millisecondsSinceEpoch}');

        batch.set(docRef, {
          'title': c.title,
          'value': c.value,
          'statusColor': c.statusColor,
          'icon': c.icon.codePoint,
          'description': c.description,
          'category': c.category,
          'timestamp': c.timestamp,
          'userId': userId,
        });
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  // Uploads all available mock data only if user data does not already exist.
  // Calls helper functions to upload substrates, alerts, and cycles.
  static Future<void> uploadAllMockData() async {
    try {
      final exists = await FirestoreCollections.dataExists();
      if (exists) return;

      await uploadSubstrates();
      await uploadAlerts();
      await uploadCyclesRecom();
    } catch (e) {
      rethrow;
    }
  }

  // Forcefully re-uploads all mock data by deleting existing user data first.
  // Ensures that the Firestore collections are completely refreshed.
  static Future<void> forceUploadAllMockData() async {
    try {
      final userId = FirestoreCollections.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      await FirestoreCollections.deleteUserData();

      await uploadSubstrates();
      await uploadAlerts();
      await uploadCyclesRecom();
    } catch (e) {
      rethrow;
    }
  }

  // Adds a new waste product document to the user's substrates collection.
  // Automatically assigns an icon and status color based on the waste category.
  // Verifies that the document exists after saving.
  static Future<void> addWasteProduct(Map<String, dynamic> waste) async {
    try {
      final userId = FirestoreCollections.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final category = waste['category'];
      final iconAndColor = FirestoreHelpers.getWasteIconAndColor(category);

      final timestamp = waste['timestamp'] as DateTime;
      final docRef = FirestoreCollections.getSubstratesCollection()
          .doc('${userId}_${timestamp.millisecondsSinceEpoch}');

      final data = {
        'title': waste['plantTypeLabel'],
        'value': '${waste['quantity']}kg',
        'statusColor': iconAndColor['statusColor'],
        'icon': iconAndColor['iconCodePoint'],
        'description': waste['description'],
        'category': category,
        'timestamp': Timestamp.fromDate(timestamp),
        'userId': userId,
      };

      await docRef.set(data);
      await Future.delayed(const Duration(milliseconds: 500));

      final verify = await docRef.get();
      if (!verify.exists) throw Exception('Document not saved');
    } catch (e) {
      rethrow;
    }
  }
}
