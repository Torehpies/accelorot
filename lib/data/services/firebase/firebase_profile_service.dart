import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../contracts/profile_service.dart';
import '../../models/profile_model.dart';

class FirebaseProfileService implements ProfileService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseProfileService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  User? get _currentUser => _auth.currentUser;

  @override
  Future<ProfileModel?> fetchCurrentUserProfile() async {
    final user = _currentUser;
    if (user == null) return null;
    return fetchUserProfile(user.uid);
  }

  @override
  Future<ProfileModel?> fetchUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (!doc.exists) return null;

      return ProfileModel.fromFirestore(uid, doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch profile for uid $uid: $e');
    }
  }

  @override
  Future<void> updateProfile({
    required String uid,
    required String firstName,
    required String lastName,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'firstname': firstName,
        'lastname': lastName,
      });
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Stream<ProfileModel?> watchCurrentUserProfile() {
    final user = _currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return ProfileModel.fromFirestore(user.uid, snapshot.data()!);
    });
  }
}