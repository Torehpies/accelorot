import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  const AppUser({
    required this.uid,
    this.email,
    this.emailVerified = false,
    this.displayName,
    required this.role,
    this.fullName,
  });

  final String uid;
  final String? email;
  final bool emailVerified;
  final String? displayName;

  final String role;
  final String? fullName;

  static AppUser? fromUser(User? user) {
    if (user == null) {
      return null;
    }
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      emailVerified: user.emailVerified,
      role: 'operator',
      fullName: user.displayName,
    );
  }

  factory AppUser.fromFirestore(
    User firebaseUser,
    Map<String, dynamic> firestoreData,
  ) {
    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      emailVerified: firebaseUser.emailVerified,
      role: firestoreData['role'] as String? ?? 'operator',
      fullName: firestoreData['fullName'] as String?,
    );
  }

	bool get isAdmin => role == 'admin';
	bool get isOperator => role == 'operator';
	bool get isStandardUser => role == 'operator';

}
