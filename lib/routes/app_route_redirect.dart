import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/providers/app_auth_state.dart';
import 'package:flutter_application_1/routes/route_path.dart';
import 'package:flutter_application_1/utils/roles.dart';
import 'package:flutter_application_1/utils/user_status.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String? appRouteRedirect(
  BuildContext context,
  Ref ref,
  GoRouterState state,
) {
  //  final authStatusState = ref.read(authStateProvider);
  final currentPath = state.uri.path;
  final auth = ref.read(authStateModelProvider);

  switch (auth.status) {
    case UserStatus.loading:
      return currentPath == RoutePath.loading.path ||
              currentPath == RoutePath.initial.path
          ? null
          : RoutePath.loading.path;

    case UserStatus.unauthenticated:
      return currentPath == RoutePath.signin.path ||
              currentPath == RoutePath.signup.path ||
              currentPath == RoutePath.forgotPassword.path
          ? null
          : RoutePath.signin.path;

    case UserStatus.unverified:
      return currentPath == RoutePath.verifyEmail.path
          ? null
          : RoutePath.verifyEmail.path;

    case UserStatus.teamSelect:
      return currentPath == RoutePath.teamSelect.path
          ? null
          : RoutePath.teamSelect.path;

    case UserStatus.pending:
      return currentPath == RoutePath.pending.path
          ? null
          : RoutePath.pending.path;

    case UserStatus.archived:
      return currentPath == RoutePath.restricted.path
          ? null
          : RoutePath.restricted.path;

    case UserStatus.active:
      if (auth.globalRole == GlobalRole.superadmin) {
        if (currentPath.startsWith('/superadmin')) return null;
        return RoutePath.superAdminTeams.path;
      }

      if (auth.globalRole == GlobalRole.user) {
        if (auth.teamRole == TeamRole.admin) {
          if (currentPath.startsWith('/admin')) return null;
          return RoutePath.adminDashboard.path;
        }
      }
  }
  return null;

  //const flowGatePaths = [
  //  '/signin',
  //  '/signup',
  //  '/verify-email',
  //  '/team-select',
  //  '/pending',
  //  '/loading',
  //  '/',
  //  '/restricted',
  //  '/forgot-password',
  //];

  //final isFlowGate = flowGatePaths.contains(currentPath);
  //final targetDashboardPath = _getDashboardPath(authStatusState.role);

  //switch (authStatusState.status) {
  //  case AuthStatus.loading:
  //    // Stay on the loading screen or allow initial path access.
  //    return currentPath == RoutePath.loading.path ||
  //            currentPath == RoutePath.initial.path
  //        ? null
  //        : RoutePath.loading.path;

  //  case AuthStatus.unauthenticated:
  //    return currentPath.startsWith('/sign') ||
  //            currentPath == RoutePath.forgotPassword.path
  //        ? null
  //        : RoutePath.signin.path;

  //  case AuthStatus.unverified:
  //    // Must go to Email Verification
  //    return currentPath == RoutePath.verifyEmail.path
  //        ? null
  //        : RoutePath.verifyEmail.path;

  //  case AuthStatus.teamSelection:
  //    // Must go to Team Selection
  //    return currentPath == RoutePath.teamSelect.path
  //        ? null
  //        : RoutePath.teamSelect.path;

  //  case AuthStatus.pendingAdminApproval:
  //    // Must go to Waiting Approval screen
  //    return currentPath == RoutePath.pending.path
  //        ? null
  //        : RoutePath.pending.path;

  //  case AuthStatus.archived:
  //    return currentPath == RoutePath.restricted.path
  //        ? null
  //        : RoutePath.restricted.path;

  //  case AuthStatus.authenticated:
  //    // User is fully authenticated.
  //    if (isFlowGate) {
  //      return targetDashboardPath;
  //    }
  //    final userShellPrefix = targetDashboardPath.substring(
  //      0,
  //      targetDashboardPath.indexOf('/', 1),
  //    );
  //    if (!currentPath.startsWith(userShellPrefix)) {
  //      return targetDashboardPath;
  //    }

  //    return null;
  //}
}

//String _getDashboardPath(String? role) {
//  if (role == null) return RoutePath.signin.path;
//  final lowerRole = role.toLowerCase();
//
//  switch (lowerRole) {
//    case 'superadmin':
//      //TODO make superadmin dashboard
//      return RoutePath.superAdminTeams.path;
//    case 'admin':
//      return RoutePath.adminDashboard.path;
//    case 'operator':
//      return RoutePath.dashboard.path;
//    default:
//      return RoutePath.restricted.path;
//  }
//}
