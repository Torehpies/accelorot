sealed class LoginFlowResult {}

class LoginFlowSuccess extends LoginFlowResult {}

class LoginFlowSuccessAdmin extends LoginFlowResult {}

class LoginFlowNeedsVerification extends LoginFlowResult {
  final String email;
  LoginFlowNeedsVerification(this.email);
}

class LoginFlowPendingApproval extends LoginFlowResult {}

class LoginFlowRestricted extends LoginFlowResult {
  final String reason;
  LoginFlowRestricted(this.reason);
}

class LoginFlowError extends LoginFlowResult {
  final String? message;
  LoginFlowError(this.message);
}
