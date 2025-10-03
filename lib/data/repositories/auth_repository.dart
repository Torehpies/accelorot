import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
	Future<User?> signInWithGoogle();
	Future<User?> registerWithEmail(String email, String password, String fullName);
	Future<User?> signInWithEmail(String email, String password);
	Future<void> signOut();
	Stream<User?> authStateChanges();
}
