import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/data/services/contracts/auth_service.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthService(this._firebaseAuth);

  @override
  String? get currentUserUid => _firebaseAuth.currentUser?.uid;

  @override
  Stream<String?> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges().map((user) => user?.uid);
  }

  @override
  Future<String> signInWithEmail(String email, String password) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

		return userCredential.user!.uid;
  }

  @override
  Future<void> signOut() async {
		await _firebaseAuth.signOut();
  }
}
