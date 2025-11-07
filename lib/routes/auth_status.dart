enum UserRole { Operator, Admin, SuperAdmin }

sealed class AuthStatus {}

class Unauthenticated extends AuthStatus {}

class Unverified extends AuthStatus {}

class TeamSelection extends AuthStatus {}

class PendingAdminApproval extends AuthStatus {
  final String teamId;
  PendingAdminApproval(this.teamId);
}

class Authenticated extends AuthStatus {
  final UserRole role;
  Authenticated(this.role);
}
