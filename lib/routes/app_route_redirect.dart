import 'dart:async';
import 'package:flutter/material.dart';
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
  final isLoggedIn = authStatusState.status != AuthStatus.unauthenticated;
  final isLoggingIn =
      state.uri.path == '/signin' || state.uri.path == '/signup';

  final String signinPath = '/signin';
  final String signupPath = '/signup';
  final String verifyPath = '/verify-email';
  final String selectTeamPath = '/select-team';
  final String waitingPath = '/waiting-approval';
  final String dashboardPath =
      authStatusState.status == AuthStatus.authenticated
      ? _getDashboardPath(authStatusState.role)
      : '/';

  switch (authStatusState.status) {
    case AuthStatus.loading:
      return null;
    case AuthStatus.unauthenticated:
      return isLoggingIn ? null : signinPath;
    case AuthStatus.unverified:
      return state.uri.path == verifyPath ? null : verifyPath;
    case AuthStatus.teamSelection:
      return state.uri.path == selectTeamPath ? null : selectTeamPath;
    case AuthStatus.pendingAdminApproval:
      return state.uri.path == waitingPath ? null : waitingPath;
    case AuthStatus.authenticated:
      if (isLoggingIn ||
          state.uri.path == verifyPath ||
          state.uri.path == selectTeamPath ||
          state.uri.path == waitingPath) {
        return dashboardPath;
      }
      // Otherwise, allow navigation to the intended path (or stay put).
      return null;
  }
}

String _getDashboardPath(String? role) {
  if (role == 'SuperAdmin') return '/superadmin';
  if (role == 'Admin') return '/admin';
  if (role == 'Operator') return '/operator';
  return '/signin';
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
