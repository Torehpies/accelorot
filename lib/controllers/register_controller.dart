import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appuser.dart';

class RegisterController {
	final FirebaseAuth _auth = FirebaseAuth.instance;
	final FirebaseFirestore _firestore = FirebaseFirestore.instance;
	
	Future<AppUser?> register({
		required String fullName,
		required String email,
		required String password,
	}) async {
		try {
			// create firebase auth account
			UserCredential cred = await _auth.createUserWithEmailAndPassword(
				email: email.
				password: password,
			);
			User? user = cred.user;
			if (user == null) return null;

			// update display name
			await user.updateDisplayName(fullName);
			await user.reload();

			// save user profile in firestore
			final appUser = AppUser(
				id: user.uid,
				fullName: fullName,
				email: email,
				photoUrl: user.photoURL,
			);

			await _firestore.collection("users").doc(user.uid).set(appUser.toFirestore());

			return appUser;
		} on FirebaseAuthException catch (e) {
			print("Auth error: ${e.code} = ${e.message}");
			rethrow;
		} catch (e) {
			print("Other error: $e");
			rethrow;
		}
	}
}
