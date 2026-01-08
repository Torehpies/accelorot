import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';

abstract class AuthService {
  Stream<String?> get onAuthStateChanged;
  String? get currentUserUid;
  Future<String> signInWithEmail(String email, String password);
  Future<User> signUp(
    String email,
    String password,
  );
  Future<void> signOut();
  Future<Result<void, DataLayerError>> sendVerificationEmail();
  Future<Result<bool, DataLayerError>> checkEmailVerified();
  Future<Result<void, DataLayerError>> updateDisplayName(
    User user,
    String name,
	);
}
