class UserCancelledSignInException implements Exception {}

class AuthFailureException implements Exception {
  final String message;

  AuthFailureException(this.message);

  @override
  String toString() => 'AuthFailureException: $message';
}

class UserRegistrationException implements Exception {
  final String message;
  UserRegistrationException(this.message);

  @override
  String toString() => 'UserRegistrationException: $message';
}

class UpdatePendingTeamException implements Exception {
  final String message;
  UpdatePendingTeamException(this.message);

  @override
  String toString() => 'UpdatePendingTeamException: $message';
}

class GetPendingTeamException implements Exception {
  final String message;
  GetPendingTeamException(this.message);

  @override
  String toString() => 'GetPendingTeamException: $message';
}

class SendTeamJoinRequestException implements Exception {
  final String message;
  SendTeamJoinRequestException(this.message);

  @override
  String toString() => 'SendTeamJoinRequestException: $message';
}

class GetTeamIdException implements Exception {
  final String message;
  GetTeamIdException(this.message);

  @override
  String toString() => 'GetTeamIdException: $message';
}

class UpdateIsEmailVerifiedException implements Exception {
  final String message;
  UpdateIsEmailVerifiedException(this.message);

  @override
  String toString() => 'UpdateIsEmailVerifiedException: $message';
}
