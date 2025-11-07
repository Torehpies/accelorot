import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/activity_logs_screen.dart';
import 'package:flutter_application_1/frontend/operator/dashboard/home_screen.dart';
import 'package:flutter_application_1/frontend/operator/machine_management/admin_machine/admin_machine_screen.dart';
import 'package:flutter_application_1/frontend/operator/machine_management/operator_machine/operator_machine_screen.dart';
import 'package:flutter_application_1/frontend/operator/statistics/statistics_screen.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/team_selection_screen.dart';
import 'package:flutter_application_1/routes/go_router_refresh_stream.dart';
import 'package:flutter_application_1/screens/email_verify/email_verify_screen.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/forgot_pass.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/qr_refer.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/restricted_access_screen.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/waiting_approval_screen.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/splash_screen.dart';
import 'package:flutter_application_1/frontend/screens/admin/admin_screens/admin_profile_screen.dart'; // Corrected import reference
import 'package:flutter_application_1/frontend/screens/admin/home_screen/admin_home_screen.dart';
import 'package:flutter_application_1/frontend/screens/admin/operator_management/operator_management_screen.dart';
import 'package:flutter_application_1/routes/admin_mobile_shell.dart';
import 'package:flutter_application_1/routes/admin_web_shell.dart';
import 'package:flutter_application_1/routes/app_route_redirect.dart';
import 'package:flutter_application_1/routes/mobile_shell.dart';
import 'package:flutter_application_1/routes/router_notifier.dart';
import 'package:flutter_application_1/routes/web_shell.dart';
import 'package:flutter_application_1/screens/loading_screen.dart';
import 'package:flutter_application_1/screens/login/login_screen.dart';
import 'package:flutter_application_1/screens/registration/registration_screen.dart';
import 'package:flutter_application_1/viewmodels/auth_state_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const int kDesktopBreakpoint = 1024;

enum RoutePath {
  initial(path: '/'),
  loading(path: '/loading'),
  signin(path: '/signin'),
  signup(path: '/signup'),
  qrRefer(path: '/qr-refer'),
  pending(path: '/pending'),
  verifyEmail(path: '/verify-email'),
	teamSelect(path: '/team-select'),
  restricted(path: '/restricted'),
  forgotPassword(path: '/forgot-password'),
  dashboard(path: '/dashboard'),
  activity(path: '/activity'),
  machines(path: '/machines'),
  statistics(path: '/statistics'),
  profile(path: '/profile');

  const RoutePath({required this.path});
  final String path;
}

final routerProvider = Provider<GoRouter>((ref) {
	final goRouterRefreshStream = GoRouterRefreshStream(ref);

  return GoRouter(
    refreshListenable: goRouterRefreshStream,
    initialLocation: RoutePath.signin.path, // Start at the splash screen
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
            // This case should be handled by redirect, but as a fallback:
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
        path: RoutePath.qrRefer.path,
        builder: (context, state) => const QRReferScreen(),
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
            path: '/stats',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const StatisticsScreen(),
              key: state.pageKey,
            ),
          ),
          GoRoute(
            path: '/machines',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const OperatorMachineScreen(),
              key: state.pageKey,
            ),
          ),
          GoRoute(
            path: '/profile',
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
            path: '/admin/dashboard',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const AdminHomeScreen(),
            ),
          ),
          GoRoute(
            path: '/admin/operators',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const OperatorManagementScreen(),
            ),
          ),
          GoRoute(
            path: '/admin/machines',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const AdminMachineScreen(),
            ),
          ),
          GoRoute(
            path: '/admin/profile',
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

