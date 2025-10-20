import 'package:firebase_auth/firebase_auth.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

String getFriendlyErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'network-request-failed':
        return 'Unable to connect. Please check your internet connection.';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already in use. Please try again.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return 'Authentication failed. Please try again later.';
    }
  }
  return 'Something went wrong. Please try again.';
}
