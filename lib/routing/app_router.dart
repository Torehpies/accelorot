import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/repositories/firebase_auth_repository.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/widgets/activity_logs_navigator.dart';
import 'package:flutter_application_1/frontend/screens/home_screen.dart';
import 'package:flutter_application_1/frontend/screens/profile_screen.dart';
import 'package:flutter_application_1/frontend/screens/statistics_screen.dart';
import 'package:flutter_application_1/routing/app_route_enum.dart';
import 'package:flutter_application_1/ui/auth/view/login_screen.dart';
import 'package:flutter_application_1/ui/auth/view/registration_screen.dart';
import 'package:flutter_application_1/ui/scaffold_with_navbar.dart';
import 'package:flutter_application_1/utils/pageTransition.dart';
import 'package:flutter_application_1/utils/refresh_listenable.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _dashboardNavigatorKey = GlobalKey<NavigatorState>();
final _activityNavigatorKey = GlobalKey<NavigatorState>();
final _statisticsNavigatorKey = GlobalKey<NavigatorState>();
final _usersNavigatorKey = GlobalKey<NavigatorState>();
final _machinesNavigatorKey = GlobalKey<NavigatorState>();
final _profileNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter router(Ref ref) {
  final auth = ref.watch(authRepositoryProvider);
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home.path,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNavbar(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _dashboardNavigatorKey,
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, state) =>
                    fadeTransition(const HomeScreen(), state),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _activityNavigatorKey,
            routes: [
              GoRoute(
                path: '/activity',
                builder: (context, state) => const ActivityLogsNavigator(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _statisticsNavigatorKey,
            routes: [
              GoRoute(
                path: '/statistics',
                builder: (context, state) => const StatisticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _usersNavigatorKey,
            routes: [
              GoRoute(
                path: '/users',
                builder: (context, state) => const StatisticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _machinesNavigatorKey,
            routes: [
              GoRoute(
                path: '/machines',
                builder: (context, state) => const StatisticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
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
      GoRoute(
        path: AppRoutes.userVerify.path,
        name: AppRoutes.userVerify.routeName,
        pageBuilder: (context, state) =>
            const MaterialPage(child: RefactoredRegistrationScreen()),
      ),
    ],
    refreshListenable: GoRouterRefreshStream(auth.authStateChanges()),
    redirect: (context, state) async {
      final bool isLoggedIn = auth.currentUser != null;
      final bool isAuthRoute =
          state.matchedLocation == AppRoutes.login.path ||
          state.matchedLocation == AppRoutes.register.path;

      // redirects the user to the login page if not logged in
      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login.path;

      // redirects user to homescreen/dashboard upon logging in
      if (isLoggedIn &&
          isAuthRoute &&
          state.matchedLocation != AppRoutes.home.path) {
        return AppRoutes.home.path;
      }

      return null;
    },
  );
}
