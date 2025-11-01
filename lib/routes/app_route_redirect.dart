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

  if (isLoggedIn && isVerified) {
    if (isGoingToPublicPath || isGoingToVerify) {
      return '/dashboard';
    }
  }
  return null;
}
