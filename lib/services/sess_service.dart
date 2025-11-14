//sess_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SessionService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser {
    return _auth.currentUser;
  }

  bool get isUserLoggedIn =>
      currentUser != null && (currentUser?.emailVerified ?? false);

  // Returns current user firestore document data or null
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  // Convenience helper: returns role string from user doc (or null)
  Future<String?> getCurrentUserRole() async {
    final data = await getCurrentUserData();
    if (data == null) return null;
    final role = data['role'];
    if (role is String) return role;
    return null;
  }

  Future<void> updateLastLogin() async {
    final user = currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
