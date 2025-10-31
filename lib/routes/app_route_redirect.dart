import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/router_notifier.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Assuming authRepositoryProvider is defined elsewhere and provides access to the Firebase User object.
// import '.../auth_repository.dart';

/// The central redirect function for GoRouter based on Firebase/Riverpod authentication state.
/// This function is typically used in the top-level GoRouter configuration.
FutureOr<String?> appRouteRedirect(
  BuildContext context,
  Ref ref,
  GoRouterState state,
) {
	final authListenable = ref.watch(authListenableProvider);

	final isLoggingIn = state.matchedLocation == '/signin';
	final isLoggedIn = authListenable.isLoggedIn;

	if (isLoggedIn && isLoggingIn) {
		return '/dashboard';
	}
	if (!isLoggedIn && !isLoggingIn) {
		return '/signin';
	}
	return null;
}
