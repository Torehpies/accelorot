class UserCancelledSignInException implements Exception {}

class AuthFailureException implements Exception {
  final String message;

  AuthFailureException(this.message);

  @override
  String toString() => 'AuthFailureException: $message';
}
