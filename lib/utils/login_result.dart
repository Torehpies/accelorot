sealed class LoginResult {}

class LoginSuccess extends LoginResult {
  final String uid;
  final String? name;
  LoginSuccess(this.name, this.uid);
}

class LoginFailure extends LoginResult {
  final String message;
  final bool needsVerification;
  LoginFailure(this.message, {this.needsVerification = false});
}
