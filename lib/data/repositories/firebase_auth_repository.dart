import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/data/repositories/auth_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthRepository extends AuthRepository{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;

  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize();
      _isGoogleSignInInitialized = true;
    } catch (e) {
      print('Failed to initialize Google Sign-In: $e');
    }
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _initializeGoogleSignIn();
    }
  }

  @override
  Stream<User?> authStateChanges() {
		return FirebaseAuth.instance.authStateChanges();
  }

  @override
  Future<User?> registerWithEmail(String email, String password, String fullName) async {
		try {
			final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
				email: email,
				password: password,
			);
			User? user = credential.user;
			await user?.updateDisplayName(fullName);
			return credential.user;
		} on FirebaseAuthException catch (e) {
			if (e.code == 'weak-password') {
				print('The password provided is too weak.');
			} else if (e.code == 'email-already-in-use') {
				print('The account already exists for that email.');
			}
		} catch (e) {
			print(e);
		}
		return null;
  }

  @override
  Future<User?> signInWithEmail(String email, String password) async {
		try {
			final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
				email: email,
				password: password
			);
			return credential.user;
		} on FirebaseAuthException catch (e) {
			if (e.code == 'user-not-found') {
				print('No user found for that email.');
			} else if (e.code == 'wrong-password') {
				print('Wrong password provided for that user.');
			}
		}
		return null;
  }

  @override
  Future<User?> signInWithGoogle() async {
		_ensureGoogleSignInInitialized();
		final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

		final GoogleSignInAuthentication googleAuth = googleUser.authentication;

		final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);

		await FirebaseAuth.instance.signInWithCredential(credential);

		return FirebaseAuth.instance.currentUser;
  }

  @override
  Future<void> signOut() async {
		await FirebaseAuth.instance.signOut();
  }

}
