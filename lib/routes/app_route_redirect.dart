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
    loading: () {
      // Don't redirect during loading state - stay on current path
      // This prevents redirect to /loading then dashboard on refresh
      return null;
    },
    unauthenticated: () =>
        currentPath == RoutePath.initial.path ||
            currentPath == RoutePath.signin.path ||
            currentPath == RoutePath.signup.path ||
            currentPath == RoutePath.forgotPassword.path ||
            currentPath == '/download' ||
            currentPath == '/privacy-policy' ||
            currentPath == '/terms-of-service'
        ? null
        : RoutePath.signin.path,
    unverified: (_) => currentPath == RoutePath.verifyEmail.path
        ? null
        : RoutePath.verifyEmail.path,
    missingUserDoc: (_) =>
        currentPath == RoutePath.signup.path ? null : RoutePath.teamSelect.path,
    authenticated: (firebaseUser, userDoc, status, globalRole, teamRole) {
      switch (status) {
				case UserStatus.approval:
          return currentPath == RoutePath.approval.path
              ? null
              : RoutePath.approval.path;
        case UserStatus.pending:
          return currentPath == RoutePath.pending.path
              ? null
              : RoutePath.pending.path;
        case UserStatus.archived:
          return currentPath == RoutePath.restricted.path
              ? null
              : RoutePath.restricted.path;
        case UserStatus.active:
          if (currentPath.startsWith('/team-details')) {
            if (globalRole == GlobalRole.superadmin) {
              return null;
            } else {
              return globalRole == GlobalRole.user && teamRole == TeamRole.admin
                  ? RoutePath.adminDashboard.path
                  : RoutePath.dashboard.path;
            }
          }
          if (globalRole == GlobalRole.superadmin) {
            debugPrint("ROUTED TO SUPERADMIN");
            // Allow access to all superadmin paths
            if (currentPath.startsWith('/superadmin')) return null;
            // Only redirect to default if on non-superadmin paths
            if (!currentPath.startsWith('/superadmin')) {
              return RoutePath.superAdminTeams.path;
            }
            return null;
          }

          if (globalRole == GlobalRole.user) {
            if (teamRole == TeamRole.admin) {
              debugPrint("ROUTED TO ADMIN");
              // Allow access to all admin paths
              if (currentPath.startsWith('/admin')) return null;
              // Only redirect to dashboard if on non-admin paths
              if (!currentPath.startsWith('/admin')) {
                return RoutePath.adminDashboard.path;
              }
              return null;
            }
            if (teamRole == TeamRole.operator) {
              debugPrint("ROUTED TO OPERATOR");
              // Allow access to all operator paths
              if (currentPath.startsWith('/operator')) return null;
              // Only redirect to dashboard if on non-operator paths
              if (!currentPath.startsWith('/operator')) {
                return RoutePath.dashboard.path;
              }
              return null;
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

