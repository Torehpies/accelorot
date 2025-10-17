import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/repositories/firebase_auth_repository.dart';
import 'package:flutter_application_1/frontend/screens/home_screen.dart';
import 'package:flutter_application_1/routing/app_route_enum.dart';
import 'package:flutter_application_1/ui/auth/view/login_screen.dart';
import 'package:flutter_application_1/ui/auth/view/registration_screen.dart';
import 'package:flutter_application_1/utils/refresh_listenable.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

final _key = GlobalKey<NavigatorState>();

@riverpod
GoRouter router(Ref ref) {
  final auth = ref.watch(authRepositoryProvider);
  return GoRouter(
    navigatorKey: _key,
    initialLocation: AppRoutes.home.path,
    routes: [
      GoRoute(
        path: AppRoutes.home.path,
        name: AppRoutes.home.routeName,
        pageBuilder: (context, state) =>
            const MaterialPage(child: HomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.login.path,
        name: AppRoutes.login.routeName,
        pageBuilder: (context, state) =>
            const MaterialPage(child: RefactoredLoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.register.path,
        name: AppRoutes.register.routeName,
        pageBuilder: (context, state) =>
            const MaterialPage(child: RefactoredRegistrationScreen()),
      ),
    ],
    refreshListenable: GoRouterRefreshStream(auth.authStateChanges()),
    redirect: (context, state) async {
      final bool isLoggedIn = auth.currentUser != null;
      final bool isLoggingIn =
          state.matchedLocation == AppRoutes.login.path ||
          state.matchedLocation == AppRoutes.register.path;

      // redirects the user to the login page if not logged in
      if (!isLoggedIn && !isLoggingIn) {
        return AppRoutes.login.path;
      }

      // redirects user to homescreen/dashboard upon logging in
      if (isLoggedIn && isLoggingIn) {
        return AppRoutes.home.path;
      }
      return null;
    },
  );
}
