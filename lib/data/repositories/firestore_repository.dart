import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firestore_repository.g.dart';

/// Firestore Repository (uses code gen)

/// Provider for FirebaseFirestore instance
@Riverpod(keepAlive: true)
FirebaseFirestore firebaseFirestore(Ref ref) {
	return FirebaseFirestore.instance;
}

/// Provider for FirestoreRepository itself
@Riverpod(keepAlive: true)
FirestoreRepository firestoreRepository(Ref ref) {
	final firestore = ref.watch(firebaseFirestoreProvider);
	return FirestoreRepository(firestore);
}

class FirestoreRepository {
	/// Constructor alangan
	FirestoreRepository(this._firestore);

	final FirebaseFirestore _firestore;
	static const String _userCollection = 'users';

	/// Firebase API get user data by UID
	Future<DocumentSnapshot> getUserData(String uid) async {
		return _firestore.collection(_userCollection).doc(uid).get();
	}

	/// Save new user into firestore
	Future<void> saveNewUser({
		required String uid,
		required String email,
		required String fullName,
		required String role,
	}) async {
		await _firestore.collection(_userCollection).doc(uid).set({
			'uid': uid,
			'email': email,
			'fullName': fullName,
			'role': role,
			'createdAt': FieldValue.serverTimestamp(),
			'isActive': true,
			'emailVerified': false,
		});
	}
	
	/// Update user verification status
	Future<void> updateEmailVerificationStatus(String uid, bool isVerified) async {
		await _firestore.collection(_userCollection).doc(uid).update({
			'emailVerified': isVerified,
		});
	}
}
