import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service to manage "viewing as operator" context for admins
class OperatorViewService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the effective user ID (operator being viewed, or current user)
  static String getEffectiveUserId(String? viewingOperatorId) {
    return viewingOperatorId ?? _auth.currentUser?.uid ?? '';
  }

  /// Fetch operator details by UID
  static Future<Map<String, dynamic>?> getOperatorDetails(String operatorId) async {
    try {
      final doc = await _firestore.collection('users').doc(operatorId).get();
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      return {
        'uid': operatorId,
        'firstname': data['firstname'] ?? '',
        'lastname': data['lastname'] ?? '',
        'email': data['email'] ?? '',
        'role': data['role'] ?? '',
        'teamId': data['teamId'],
      };
    } catch (e) {
      return null;
    }
  }

  /// Get activities for a specific user (for activity logs)
  static CollectionReference getActivitiesSubstratesCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('activities')
        .doc('docu')
        .collection('substrates');
  }

  static CollectionReference getActivitiesAlertsCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('activities')
        .doc('docu')
        .collection('alerts');
  }

  /// Get user data snapshot for profile
  static Future<DocumentSnapshot> getUserData(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }
}
