import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/services/mock_data_service.dart';
import 'firestore_collections.dart';
import 'firestore_helpers.dart';

class FirestoreUpload {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Upload Substrates
  static Future<void> uploadSubstrates() async {
    try {
      final userId = FirestoreCollections.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final substrates = MockDataService.getSubstrates();
      final batch = _firestore.batch();

      for (var substrate in substrates) {
        final docRef = FirestoreCollections.getSubstratesCollection(userId)
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

  // Upload Alerts
  static Future<void> uploadAlerts() async {
    try {
      final userId = FirestoreCollections.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final alerts = MockDataService.getAlerts();
      final batch = _firestore.batch();

      for (var alert in alerts) {
        final docRef = FirestoreCollections.getAlertsCollection(userId)
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

  // Upload Cycles and Recommendations
  static Future<void> uploadCyclesRecom() async {
    try {
      final userId = FirestoreCollections.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final cyclesRecom = MockDataService.getCyclesRecom();
      final batch = _firestore.batch();

      for (var item in cyclesRecom) {
        final docRef = FirestoreCollections.getCyclesRecomCollection(userId)
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

  // Upload All Mock Data (if doesn't exist)
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

  // Force Upload (delete old + upload fresh)
  static Future<void> forceUploadAllMockData() async {
    try {
      final userId = FirestoreCollections.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      // Delete existing data
      final substrateDocs =
          await FirestoreCollections.getSubstratesCollection(userId).get();
      for (var doc in substrateDocs.docs) {
        await doc.reference.delete();
      }

      final alertDocs =
          await FirestoreCollections.getAlertsCollection(userId).get();
      for (var doc in alertDocs.docs) {
        await doc.reference.delete();
      }

      final cyclesRecomDocs =
          await FirestoreCollections.getCyclesRecomCollection(userId).get();
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

  // Add Waste Product
  static Future<void> addWasteProduct(Map<String, dynamic> waste) async {
    try {
      final userId = FirestoreCollections.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final category = waste['category'];
      final iconAndColor = FirestoreHelpers.getWasteIconAndColor(category);

      final docRef = FirestoreCollections.getSubstratesCollection(userId)
          .doc(waste['timestamp'].millisecondsSinceEpoch.toString());

      await docRef.set({
        'title': waste['plantTypeLabel'],
        'value': '${waste['quantity']} kg',
        'statusColor': iconAndColor['statusColor'],
        'icon': iconAndColor['iconCodePoint'],
        'description': waste['description'],
        'category': category,
        'timestamp': waste['timestamp'],
      });
    } catch (e) {
      rethrow;
    }
  }
}