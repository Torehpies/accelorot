sealed class GoogleAuthResult {}

class GoogleLoginSuccess extends GoogleAuthResult {
  final String uid;
  GoogleLoginSuccess(this.uid);
}

class GoogleLoginFailure extends GoogleAuthResult {
  final String message;
  GoogleLoginFailure(this.message);
}
