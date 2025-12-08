import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/app_auth_state.dart';
import 'package:flutter_application_1/data/providers/app_auth_state.dart';
import 'package:flutter_application_1/routes/route_path.dart';
import 'package:flutter_application_1/utils/roles.dart';
import 'package:flutter_application_1/utils/user_status.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String? appRouteRedirect(BuildContext context, Ref ref, GoRouterState state) {
  final currentPath = state.uri.path;
  final auth = ref.read(authStateModelProvider);

  return auth.when(
    loading: () => RoutePath.loading.path,
    unauthenticated: () =>
        currentPath == RoutePath.signin.path ||
            currentPath == RoutePath.signup.path ||
            currentPath == RoutePath.forgotPassword.path
        ? null
        : RoutePath.signin.path,
    unverified: (_) => currentPath == RoutePath.verifyEmail.path
        ? null
        : RoutePath.verifyEmail.path,
    missingUserDoc: (_) => currentPath == RoutePath.signup.path
        ? null
        : RoutePath.teamSelect.path,
    authenticated: (firebaseUser, userDoc, status, globalRole, teamRole) {
      switch (status) {
        case UserStatus.pending:
          return currentPath == RoutePath.pending.path
              ? null
              : RoutePath.pending.path;
        case UserStatus.archived:
          return currentPath == RoutePath.restricted.path
              ? null
              : RoutePath.restricted.path;
        case UserStatus.active:
          if (globalRole == GlobalRole.superadmin) {
            if (currentPath.startsWith('/superAdmin')) return null;
            return RoutePath.superAdminTeams.path;
          }

          if (globalRole == GlobalRole.user) {
            if (teamRole == TeamRole.admin) {
              if (currentPath.startsWith('/admin')) return null;
              return RoutePath.adminDashboard.path;
            }
            if (teamRole == TeamRole.operator) {
              if (currentPath.startsWith('/operator')) return null;
              return RoutePath.dashboard.path;
            }
          }
          return null;
        case UserStatus.teamSelect:
          return currentPath == RoutePath.teamSelect.path
              ? null
              : RoutePath.teamSelect.path;

        default:
          return null;
      }
    },
  );
}
