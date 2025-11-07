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
  final authStatus = ref.watch(authStateProvider);
  final path = state.uri.toString();
  bool isFlowGate =
      path == '/signin' ||
      path == '/signup' ||
      path == '/verify-email' ||
      path == '/team-select' ||
      path == '/pending';

  return switch (authStatus) {
    Unauthenticated() =>
      path == '/signin' || path == '/signup' ? null : '/signin',
    Unverified() => path == '/verify-email' ? null : '/verify-email',
    TeamSelection() => path == '/team-select' ? null : '/team-select',
    PendingAdminApproval() => path == '/pending' ? null : '/pending',
    Authenticated(role: final role) => () {
      if (isFlowGate || path == '/') {
        return '/${role.name}';
      }
      final correctedDashboardPath = '/${role.name}';
      if (path.startsWith(correctedDashboardPath)) {
        return null;
      }
      return correctedDashboardPath;
    }(),
  };
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
