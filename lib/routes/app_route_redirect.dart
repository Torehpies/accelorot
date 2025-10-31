import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/repositories/auth_repository.dart';
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
  // 1. Fetch the user state safely
  // We assume authRepositoryProvider exposes a method/stream to get the current user.
  final user = ref.read(authRepositoryProvider).currentUser;
  final isLoggedIn = user != null;

  // The path the user is trying to navigate to
  final location = state.uri.toString();

  // Define Public Routes and Redirect Destinations
  const signInRoute = '/signin';
  const signUpRoute = '/signup';
  const verifyEmailRoute = '/verify-email';
  const dashboardRoute = '/dashboard';

  // Routes that do NOT require the user to be logged in
  const publicRoutes = [signInRoute, signUpRoute];
  final isGoingToPublicRoute = publicRoutes.contains(location);

  // --- Core Redirection Logic ---

  // CASE 1: User is NOT logged in.
  if (!isLoggedIn) {
    // If they are already trying to navigate to a public route, allow it.
    if (isGoingToPublicRoute) {
      return null; // Go to the requested public route
    }
    // For any other route (e.g., trying to access /dashboard), redirect to sign in.
    return signInRoute;
  }

  // CASE 2: User IS logged in (user is guaranteed not null here).

  final isVerified = user.emailVerified;

  // Subcase 2A: Logged in, but NOT verified.
  if (!isVerified) {
    // If they are trying to go to the verification page, allow it.
    if (location == verifyEmailRoute) {
      return null;
    }
    // For any other route (including /dashboard or public routes), force them to verify.
    return verifyEmailRoute;
  }

  // Subcase 2B: Logged in AND Verified.
  // If they are trying to access public/auth-related routes, redirect them to dashboard.
  if (isGoingToPublicRoute || location == verifyEmailRoute) {
    return dashboardRoute;
  }

  // FINAL: Logged in, verified, and going to a non-auth/public route. Allow it.
  return null;
}
// Always compute the latest auth state from the notifier used to refresh the router.
//  final latest = notifier.value ?? const AuthState.checking();
//  final currentPath = routerState.fullPath ?? routerState.matchedLocation;
//
//  // 1. Handle loading state
//  if (!latest.isInitialCheckDone) {
//    // Allow splash and unauth routes while checking to avoid redirect loops during logout/login transitions
//    if (currentPath == '/splash' ||
//        unauthenticatedRoutes.contains(currentPath)) {
//      return null;
//    }
//    return '/splash';
//  }
//
//  final isLoggedIn = latest.firebaseUser != null;
//  final isUnauthRoute = unauthenticatedRoutes.contains(currentPath);
//
//  // 2. Handle Logged Out state
//  if (!isLoggedIn) {
//    // Allow access to unauthenticated routes, otherwise go to login
//    if (isUnauthRoute) {
//      return null;
//    }
//    return '/login';
//  }
//
//  // --- User is Logged In from here ---
//
//  // 3. Handle Restricted state (Highest priority for logged-in users)
//  if (latest.isRestricted) {
//    if (currentPath == '/restricted-access') return null;
//    return '/restricted-access';
//  }
//
//  // 4. Handle Email Verification
//  if (!latest.isVerified) {
//    if (currentPath == '/verify-email') return null;
//    return '/verify-email';
//  }
//
//  final hasNoTeamSubmitted =
//      latest.userEntity?.teamId == null &&
//      latest.userEntity?.pendingTeamId == null;
//
//  if (hasNoTeamSubmitted) {
//    if (currentPath == '/qr-refer') return null;
//    return '/qr-refer';
//  }
//
//  // 6. Handle Team Pending Approval (User has submitted a team ID and is waiting)
//  if (latest.isPendingApproval) {
//    // isPendingApproval = userEntity?.pendingTeamId != null
//    if (currentPath == '/waiting-approval') return null;
//    return '/waiting-approval';
//  }
//
//  // --- END OF FUNNEL: User is Fully Approved and Verified ---
//
//  // 7. Redirect fully approved users away from unauth/onboarding pages
//  if (currentPath == '/splash' ||
//      isUnauthRoute ||
//      onboardingRoutes.contains(currentPath)) {
//    return latest.isAdmin ? '/admin/dashboard' : '/dashboard';
//  }
//
//  // 8. Handle role-based access to dashboards
//  // If operator tries to access admin routes
//  if (!latest.isAdmin && currentPath.startsWith('/admin')) {
//    return '/dashboard';
//  }
//  // If admin is on operator dashboard (or '/'), redirect to admin dashboard
//  if (latest.isAdmin && (currentPath == '/dashboard' || currentPath == '/')) {
//    return '/admin/dashboard';
//  }
//
//  // 9. No redirect needed
//  return null;
//}
