import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/app_router.dart';
import 'package:flutter_application_1/routes/auth_notifier.dart';
import 'package:flutter_application_1/routes/auth_status.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

FutureOr<String?> appRouteRedirect(
  BuildContext context,
  Ref ref,
  GoRouterState state,
) {
  final authStatusState = ref.read(authStateProvider);
  final currentPath = state.uri.path;

  // Paths that are part of the initial authentication/onboarding flow
  const flowGatePaths = [
    '/signin',
    '/signup',
    '/verify-email',
    '/team-select',
    '/pending',
    '/loading',
    '/',
    '/restricted',
    '/forgot-password',
  ];

  final isFlowGate = flowGatePaths.contains(currentPath);
  final targetDashboardPath = _getDashboardPath(authStatusState.role);

  switch (authStatusState.status) {
    case AuthStatus.loading:
      // Stay on the loading screen or allow initial path access.
      return currentPath == RoutePath.loading.path ||
              currentPath == RoutePath.initial.path
          ? null
          : RoutePath.loading.path;

    case AuthStatus.unauthenticated:
      return currentPath.startsWith('/sign') ||
              currentPath == RoutePath.forgotPassword.path
          ? null
          : RoutePath.signin.path;

    case AuthStatus.unverified:
      // Must go to Email Verification
      return currentPath == RoutePath.verifyEmail.path
          ? null
          : RoutePath.verifyEmail.path;

    case AuthStatus.teamSelection:
      // Must go to Team Selection
      return currentPath == RoutePath.teamSelect.path
          ? null
          : RoutePath.teamSelect.path;

    case AuthStatus.pendingAdminApproval:
      // Must go to Waiting Approval screen
      return currentPath == RoutePath.pending.path
          ? null
          : RoutePath.pending.path;

    case AuthStatus.archived:
      return currentPath == RoutePath.restricted.path
          ? null
          : RoutePath.restricted.path;

    case AuthStatus.authenticated:
      // User is fully authenticated.
      if (isFlowGate) {
        return targetDashboardPath;
      }
      final userShellPrefix = targetDashboardPath.substring(
        0,
        targetDashboardPath.indexOf('/', 1),
      );
      if (!currentPath.startsWith(userShellPrefix)) {
        return targetDashboardPath;
      }

      return null;
  }
}

String _getDashboardPath(String? role) {
  if (role == null) return RoutePath.signin.path;
  final lowerRole = role.toLowerCase();

  switch (lowerRole) {
    case 'superadmin':
    case 'admin':
      return RoutePath.adminDashboard.path;
    case 'operator':
      return RoutePath.dashboard.path;
    default:
      return RoutePath.restricted.path;
  }
}

//FutureOr<String?> appRouteRedirect(
//  BuildContext context,
//  Ref ref,
//  GoRouterState state,
//) {
//
//  final isLoggedIn = authListenable.isLoggedIn;
//  final isVerified = authListenable.isEmailVerified;
//  final userRole = authListenable.userRole;
//	final isInTeam = authListenable.isInTeam;
//	final isPending = authListenable.isPending;
//
//  final isGoingToLogin = state.matchedLocation == '/signin';
//  final isGoingToSignup = state.matchedLocation == '/signup';
//  final isGoingToPublicPath = isGoingToLogin || isGoingToSignup;
//
//  final isGoingToVerify = state.matchedLocation == '/verify-email';
//  final isGoingToTeam = state.matchedLocation == '/team-select';
//  final isGoingToPending = state.matchedLocation == '/pending';
//
//  if (!isLoggedIn) {
//    return isGoingToPublicPath ? null : '/signin';
//  }
//
//  if (isLoggedIn && !isVerified) {
//    return isGoingToVerify ? null : '/verify-email';
//  }
//
//  if (isLoggedIn && isPending!) {
//    return isGoingToPending ? null : '/pending';
//  }
//
//  if (isLoggedIn && !isInTeam!) {
//    return isGoingToTeam ? null : '/team-select';
//  }
//
//  if (isLoggedIn && isVerified && userRole != null) {
//    final isAdmin = userRole == 'Admin';
//    final adminDashboardPath = '/admin/dashboard';
//    final operatorDashboardPath = '/dashboard';
//    final correctHomePath = isAdmin
//        ? adminDashboardPath
//        : operatorDashboardPath;
//
//    if (isGoingToPublicPath || isGoingToVerify) {
//      return correctHomePath;
//    }
//
//    final isGoingToAdminPath = state.matchedLocation.startsWith('/admin');
//    final isGoingToOperatorPath = state.matchedLocation.startsWith(
//      '/dashboard',
//    );
//
//    if (isAdmin && isGoingToOperatorPath) {
//      return adminDashboardPath;
//    }
//
//    if (!isAdmin && isGoingToAdminPath) {
//      return operatorDashboardPath;
//    }
//  }
//  return null;
//}
