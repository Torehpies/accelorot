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

  // Collection References - FLAT STRUCTURE (no userId parameter needed)
  static CollectionReference getSubstratesCollection() {
    return _firestore.collection('substrates');
  }

  static CollectionReference getAlertsCollection() {
    return _firestore.collection('alerts');
  }

  static CollectionReference getCyclesRecomCollection() {
    return _firestore.collection('cyclesRecom');
  }

  // Data Existence Check - checks if current user has any substrates
  static Future<bool> dataExists() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return false;

      final substrates = await getSubstratesCollection()
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      return substrates.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Delete all data for current user (for fresh start)
  static Future<void> deleteUserData() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      // Delete substrates
      final substrateDocs = await getSubstratesCollection()
          .where('userId', isEqualTo: userId)
          .get();
      for (var doc in substrateDocs.docs) {
        await doc.reference.delete();
      }

      // Delete alerts
      final alertDocs = await getAlertsCollection()
          .where('userId', isEqualTo: userId)
          .get();
      for (var doc in alertDocs.docs) {
        await doc.reference.delete();
      }

      // Delete cyclesRecom
      final cyclesRecomDocs = await getCyclesRecomCollection()
          .where('userId', isEqualTo: userId)
          .get();
      for (var doc in cyclesRecomDocs.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      rethrow;
    }
  }
}