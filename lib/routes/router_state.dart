import 'package:flutter_application_1/routes/auth_status.dart';

class RouterState {
	final AuthStatus status;
	final String? uid;
	final bool isEmailVerified;

	RouterState({
		required this.status,
		this.uid,
		required this.isEmailVerified,
	});
}
