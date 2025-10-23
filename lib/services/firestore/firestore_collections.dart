import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreCollections {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Collection References
  static CollectionReference getSubstratesCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('activities')
        .doc('docu')
        .collection('substrates');
  }

  static CollectionReference getAlertsCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('activities')
        .doc('docu')
        .collection('alerts');
  }

  static CollectionReference getCyclesRecomCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('activities')
        .doc('docu')
        .collection('cyclesRecom');
  }

  // Data Existence Check
  static Future<bool> dataExists() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return false;

      final substrates = await getSubstratesCollection(userId).limit(1).get();
      return substrates.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}