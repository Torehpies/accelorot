//firestore_collections.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreCollections {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Collection References - accepts optional userId for admin viewing operators
  static CollectionReference getSubstratesCollection(
    String batchId, [
    String? userId,
  ]) {
    return _firestore
        .collection('batches')
        .doc(batchId)
        .collection('substrates');
  }

  static CollectionReference getAlertsCollection([String? userId]) {
    return _firestore.collection('alerts');
  }

  static CollectionReference getCyclesRecomCollection([String? userId]) {
    return _firestore.collection('cyclesRecom');
  }

  static CollectionReference getBatchesCollection() {
    return _firestore.collection('batches');
  }

  // Data Existence Check - checks if specified user has any substrates
  static Future<bool> dataExists([String? userId]) async {
    try {
      final targetUserId = userId ?? getCurrentUserId();
      if (targetUserId == null) return false;

      // Query batches collection for user's batches
      final batches = await getBatchesCollection()
          .where('userId', isEqualTo: targetUserId)
          .limit(1)
          .get();

      return batches.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Delete all data for specified user (for fresh start)
  static Future<void> deleteUserData([String? userId]) async {
    try {
      final targetUserId = userId ?? getCurrentUserId();
      if (targetUserId == null) throw Exception('User not logged in');

      // Delete all batches and their subcollections
      final batchDocs = await getBatchesCollection()
          .where('userId', isEqualTo: targetUserId)
          .get();

      for (var batchDoc in batchDocs.docs) {
        // Delete substrates subcollection
        final substrateDocs = await batchDoc.reference
            .collection('substrates')
            .get();
        for (var substrateDoc in substrateDocs.docs) {
          await substrateDoc.reference.delete();
        }

        // Delete batch document
        await batchDoc.reference.delete();
      }

      // Delete alerts
      final alertDocs = await getAlertsCollection(
        targetUserId,
      ).where('userId', isEqualTo: targetUserId).get();
      for (var doc in alertDocs.docs) {
        await doc.reference.delete();
      }

      // Delete cyclesRecom
      final cyclesRecomDocs = await getCyclesRecomCollection(
        targetUserId,
      ).where('userId', isEqualTo: targetUserId).get();
      for (var doc in cyclesRecomDocs.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      rethrow;
    }
  }
}
