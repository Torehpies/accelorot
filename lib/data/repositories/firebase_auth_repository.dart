import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/data/services/firebase_auth_service.dart';

class FirebaseAuthRepository {
	final FirebaseAuthService _authService;

	FirebaseAuthRepository(this._authService);	

	Stream<User?> get authStateChanges => _authService.authStateChanges();

	Future<User?> login(String email, String password) async {
		final credential = await _authService.signInWithEmail(email, password);
		return credential?.user;
	}

	Future<void> logout() => _authService.signOut();
  
}
