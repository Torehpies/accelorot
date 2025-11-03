class UserCancelledSignInException implements Exception {

} 

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
