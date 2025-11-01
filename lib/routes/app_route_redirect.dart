import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/router_notifier.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

FutureOr<String?> appRouteRedirect(
  BuildContext context,
  Ref ref,
  GoRouterState state,
) {
  final authListenable = ref.watch(authListenableProvider);

  final isLoggedIn = authListenable.isLoggedIn;
  final isVerified = authListenable.isEmailVerified;
  final userRole = authListenable.userRole;

  final isGoingToLogin = state.matchedLocation == '/signin';
  final isGoingToSignup = state.matchedLocation == '/signup';
  final isGoingToPublicPath = isGoingToLogin || isGoingToSignup;

  final isGoingToVerify = state.matchedLocation == '/verify-email';

  if (!isLoggedIn) {
    return isGoingToPublicPath ? null : '/signin';
  }

  if (isLoggedIn && !isVerified) {
    return isGoingToVerify ? null : '/verify-email';
  }

  if (isLoggedIn && isVerified && userRole != null) {
    final isAdmin = userRole == 'Admin';
    final adminDashboardPath = '/admin/dashboard';
    final operatorDashboardPath = '/dashboard';
    final correctHomePath = isAdmin
        ? adminDashboardPath
        : operatorDashboardPath;

    if (isGoingToPublicPath || isGoingToVerify) {
      return correctHomePath;
    }

    final isGoingToAdminPath = state.matchedLocation.startsWith('/admin');
    final isGoingToOperatorPath = state.matchedLocation.startsWith(
      '/dashboard',
    );

    if (isAdmin && isGoingToOperatorPath) {
      return adminDashboardPath;
    }

    if (!isAdmin && isGoingToAdminPath) {
      return operatorDashboardPath;
    }
  }
  return null;
}
