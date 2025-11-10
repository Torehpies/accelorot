import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/activity_logs_screen.dart';
import 'package:flutter_application_1/frontend/operator/dashboard/home_screen.dart';
import 'package:flutter_application_1/frontend/operator/machine_management/admin_machine/admin_machine_screen.dart';
import 'package:flutter_application_1/frontend/operator/machine_management/operator_machine/operator_machine_screen.dart';
import 'package:flutter_application_1/frontend/operator/statistics/statistics_screen.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/team_selection_screen.dart';
import 'package:flutter_application_1/routes/auth_notifier.dart';
import 'package:flutter_application_1/routes/go_router_refresh_stream.dart';
import 'package:flutter_application_1/screens/email_verify/email_verify_screen.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/forgot_pass.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/restricted_access_screen.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/waiting_approval_screen.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/splash_screen.dart';
import 'package:flutter_application_1/frontend/screens/admin/admin_screens/admin_profile_screen.dart'; // Corrected import reference
import 'package:flutter_application_1/frontend/screens/admin/home_screen/admin_home_screen.dart';
import 'package:flutter_application_1/frontend/screens/admin/operator_management/operator_management_screen.dart';
import 'package:flutter_application_1/routes/navigations/admin_mobile_shell.dart';
import 'package:flutter_application_1/routes/navigations/admin_web_shell.dart';
import 'package:flutter_application_1/routes/app_route_redirect.dart';
import 'package:flutter_application_1/routes/navigations/operator_mobile_shell.dart';
import 'package:flutter_application_1/routes/navigations/operator_web_shell.dart';
import 'package:flutter_application_1/screens/loading_screen.dart';
import 'package:flutter_application_1/screens/login/login_screen.dart';
import 'package:flutter_application_1/screens/registration/registration_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const int kDesktopBreakpoint = 1024;

enum RoutePath {
  initial(path: '/'),
  loading(path: '/loading'),
  signin(path: '/signin'),
  signup(path: '/signup'),
  //qrRefer(path: '/qr-refer'),
  pending(path: '/pending'),
  verifyEmail(path: '/verify-email'),
  teamSelect(path: '/team-select'),
  restricted(path: '/restricted'),
  forgotPassword(path: '/forgot-password'),

  // operator paths
  dashboard(path: '/operator/dashboard'),
  activity(path: '/operator/activity'),
  statistics(path: '/operator/statistics'),
  operatorMachines(path: '/operator/machines'),
  profile(path: '/operator/profile'),

  //admin paths
  adminDashboard(path: '/admin/dashboard'),
  adminActivity(path: '/admin/activity'),
  adminStatistics(path: '/admin/statistics'),
  adminMachines(path: '/admin/machines'),
  adminOperators(path: '/admin/operators'),
  adminProfile(path: '/admin/profile'),

	//TODO placeholder super admin paths
  superAdminDashboard(path: '/superadmin/dashboard'),
  superAdminActivity(path: '/superadmin/activity'),
  superAdminStatistics(path: '/superadmin/statistics'),
  superAdminMachines(path: '/superadmin/machines'),
  superAdminOperators(path: '/superadmin/operators'),
  superAdminProfile(path: '/superadmin/profile');

  const RoutePath({required this.path});
  final String path;
}

final routerProvider = Provider<GoRouter>((ref) {
  final authStateStream = ref.watch(authStateProvider.notifier).stream;

  return GoRouter(
    refreshListenable: GoRouterRefreshStream(authStateStream),
    initialLocation: RoutePath.signin.path,
    debugLogDiagnostics: true,
    redirect: (context, state) => appRouteRedirect(context, ref, state),
    routes: [
      GoRoute(
        path: RoutePath.initial.path,
        name: RoutePath.initial.name,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePath.loading.path,
        name: RoutePath.loading.name,
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(
        path: RoutePath.signin.path,
        name: RoutePath.signin.name,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePath.signup.path,
        name: RoutePath.signup.name,
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: RoutePath.forgotPassword.path,
        name: RoutePath.forgotPassword.name,
        builder: (context, state) => const ForgotPassScreen(),
      ),
      GoRoute(
        path: RoutePath.verifyEmail.path,
        name: RoutePath.verifyEmail.name,
        builder: (context, state) {
          final email =
              (state.extra as String?) ??
              FirebaseAuth.instance.currentUser?.email;
          if (email == null) {
            return const LoginScreen();
          }
          return EmailVerifyScreen(email: email);
        },
      ),
      GoRoute(
        path: RoutePath.teamSelect.path,
        name: RoutePath.teamSelect.name,
        builder: (context, state) => const TeamSelectionScreen(),
      ),
      GoRoute(
        path: RoutePath.pending.path,
        name: RoutePath.pending.name,
        builder: (context, state) => const WaitingApprovalScreen(),
      ),
      GoRoute(
        path: RoutePath.restricted.path,
        name: RoutePath.restricted.name,
        builder: (context, state) {
          final reason = state.extra as String?;
          return RestrictedAccessScreen(reason: reason ?? 'Unknown reason');
        },
      ),
      ShellRoute(
        builder: (context, state, child) {
          final isDesktop =
              MediaQuery.of(context).size.width >= kDesktopBreakpoint;

          if (isDesktop) {
            return WebShell(child: child);
          } else {
            return MobileNavigationShell(child: child);
          }
        },
        routes: [
          GoRoute(
            path: RoutePath.dashboard.path,
            name: RoutePath.dashboard.name,
            pageBuilder: (context, state) =>
                NoTransitionPage(child: const HomeScreen(), key: state.pageKey),
          ),
          GoRoute(
            path: RoutePath.activity.path,
            name: RoutePath.activity.name,
            pageBuilder: (context, state) => NoTransitionPage(
              child: const ActivityLogsScreen(),
              key: state.pageKey,
            ),
          ),
          GoRoute(
            path: RoutePath.statistics.path,
            name: RoutePath.statistics.name,
            pageBuilder: (context, state) => NoTransitionPage(
              child: const StatisticsScreen(),
              key: state.pageKey,
            ),
          ),
          GoRoute(
            path: RoutePath.operatorMachines.path,
            name: RoutePath.operatorMachines.name,
            pageBuilder: (context, state) => NoTransitionPage(
              child: const OperatorMachineScreen(),
              key: state.pageKey,
            ),
          ),
          GoRoute(
            path: RoutePath.profile.path,
            name: RoutePath.profile.name,
            pageBuilder: (context, state) => NoTransitionPage(
              child: const ProfileScreen(),
              key: state.pageKey,
            ),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) {
          final isDesktop =
              MediaQuery.of(context).size.width >= kDesktopBreakpoint;
          if (isDesktop) {
            return AdminWebShell(child: child);
          } else {
            return AdminMobileShell(child: child);
          }
        },
        routes: [
          GoRoute(
            path: RoutePath.adminDashboard.path,
            name: RoutePath.adminDashboard.name,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const AdminHomeScreen(),
            ),
          ),
          GoRoute(
            path: RoutePath.adminOperators.path,
            name: RoutePath.adminOperators.name,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const OperatorManagementScreen(),
            ),
          ),
          GoRoute(
            path: RoutePath.adminMachines.path,
            name: RoutePath.adminMachines.name,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const AdminMachineScreen(),
            ),
          ),
          GoRoute(
            path: RoutePath.adminProfile.path,
            name: RoutePath.adminProfile.name,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ProfileScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});

// The custom GoRouterRefreshStream class is no longer needed 
// because we are using ValueNotifier and ref.listen.

