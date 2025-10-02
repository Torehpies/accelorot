import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository { 
	final FirebaseAuth _firebaseAuth;

	AuthRepository(this._firebaseAuth);

	Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

	Future<void> signIn(String email, String password) async {
		await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
	}

	Future<void> signOut() async {
		await _firebaseAuth.signOut();
	}
}
