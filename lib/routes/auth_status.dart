enum UserRole { operator, admin, superAdmin }

enum AuthStatus {
  loading,
  unauthenticated,
  unverified,
  teamSelection,
  pendingAdminApproval,
  archived,
  authenticated,
}

class AuthStatusState {
  final AuthStatus status;
  final String? role;
  final String? restrictedReason;

  const AuthStatusState({
    required this.status,
    this.role,
    this.restrictedReason,
  });

  factory AuthStatusState.loading() =>
      const AuthStatusState(status: AuthStatus.loading);
  factory AuthStatusState.unauthenticated() =>
      const AuthStatusState(status: AuthStatus.unauthenticated);
  factory AuthStatusState.unverified() =>
      const AuthStatusState(status: AuthStatus.unverified);
  factory AuthStatusState.teamSelection() =>
      const AuthStatusState(status: AuthStatus.teamSelection);
  factory AuthStatusState.pendingAdminApproval() =>
      const AuthStatusState(status: AuthStatus.pendingAdminApproval);
  factory AuthStatusState.archived() => const AuthStatusState(
    status: AuthStatus.archived,
    restrictedReason: 'archived',
  );
  factory AuthStatusState.authenticated({required String role}) =>
      AuthStatusState(status: AuthStatus.authenticated, role: role);
}
