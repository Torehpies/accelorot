import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/forgot_pass.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/restricted_access_screen.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/splash_screen.dart';
import 'package:flutter_application_1/frontend/screens/admin/home_screen/admin_home_screen.dart';
import 'package:flutter_application_1/routes/app_route_redirect.dart';
import 'package:flutter_application_1/routes/navigations/admin_mobile_shell.dart';
import 'package:flutter_application_1/routes/navigations/admin_web_shell.dart';
import 'package:flutter_application_1/routes/navigations/operator_mobile_shell.dart';
import 'package:flutter_application_1/routes/navigations/operator_web_shell.dart';
import 'package:flutter_application_1/routes/navigations/super_admin_mobile_shell.dart';
import 'package:flutter_application_1/routes/navigations/super_admin_web_shell.dart';
import 'package:flutter_application_1/routes/route_path.dart';
import 'package:flutter_application_1/routes/router_notifier.dart';
import 'package:flutter_application_1/ui/activity_logs/view/unified_activity_view.dart';
import 'package:flutter_application_1/ui/core/ui/loading_screen.dart';
import 'package:flutter_application_1/ui/email_verify/email_verify_screen.dart';
import 'package:flutter_application_1/ui/operator_dashboard/view/web_home_screen.dart';
import 'package:flutter_application_1/ui/login/views/login_screen.dart';
import 'package:flutter_application_1/ui/machine_management/widgets/admin_machine_view.dart';
import 'package:flutter_application_1/ui/profile_screen/web_widgets/web_profile_view.dart';
import 'package:flutter_application_1/ui/registration/views/registration_screen.dart';
import 'package:flutter_application_1/ui/reports/view/web_reports_view.dart';
import 'package:flutter_application_1/ui/team_management/widgets/team_management_screen.dart';
import 'package:flutter_application_1/ui/team_selection/widgets/team_selection_screen.dart';
import 'package:flutter_application_1/ui/waiting_approval/views/waiting_approval_screen.dart';
import 'package:flutter_application_1/ui/web_machine/widgets/admin/web_admin_machine_view.dart';
import 'package:flutter_application_1/ui/web_operator/view/operator_management_screen.dart';
import 'package:flutter_application_1/ui/web_statistics/web_statistics_screen.dart';
import 'package:flutter_application_1/ui/web_operator_machine_management/view/machines_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const int kDesktopBreakpoint = 1024;

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    refreshListenable: notifier,
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
          final extraReason = state.extra as String?;

          //final authStatusState = ref.read(authStateProvider);
          //final fallbackReason = authStatusState.restrictedReason;

          final fallbackReason = "archived";

          final reason = extraReason ?? fallbackReason;
          return RestrictedAccessScreen(reason: reason);
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
            pageBuilder: (context, state) => NoTransitionPage(
              child: const WebHomeScreen(),
              key: state.pageKey,
            ),
          ),
          GoRoute(
            path: RoutePath.activity.path,
            name: RoutePath.activity.name,
            pageBuilder: (context, state) => NoTransitionPage(
              child: const UnifiedActivityView(),
              key: state.pageKey,
            ),
          ),
          GoRoute(
            path: RoutePath.statistics.path,
            name: RoutePath.statistics.name,
            pageBuilder: (context, state) => NoTransitionPage(
              child: const WebStatisticsScreen(),
              key: state.pageKey,
            ),
          ),
          GoRoute(
            path: RoutePath.operatorMachines.path,
            name: RoutePath.operatorMachines.name,
            pageBuilder: (context, state) => NoTransitionPage(
              child: const MachinesView(),
              key: state.pageKey,
            ),
          ),
          GoRoute(
            path: RoutePath.profile.path,
            name: RoutePath.profile.name,
            pageBuilder: (context, state) => NoTransitionPage(
              child: const WebProfileView(),
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
              // child: const OperatorManagementScreen(),
              child: const OperatorManagementScreen(),
            ),
          ),
          GoRoute(
            path: RoutePath.adminMachines.path,
            name: RoutePath.adminMachines.name,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const WebAdminMachineView(),
            ),
          ),
          GoRoute(
            path: RoutePath.adminReports.path,
            name: RoutePath.adminReports.name,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const WebReportsView(),
            ),
          ),
          GoRoute(
            path: RoutePath.adminProfile.path,
            name: RoutePath.adminProfile.name,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const WebProfileView(),
            ),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) {
          final isDesktop =
              MediaQuery.of(context).size.width >= kDesktopBreakpoint;
          if (isDesktop) {
            return SuperAdminWebShell(child: child);
          } else {
            return SuperAdminMobileShell(child: child);
          }
        },
        routes: [
          GoRoute(
            path: RoutePath.superAdminTeams.path,
            name: RoutePath.superAdminTeams.name,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const TeamManagementScreen(),
            ),
          ),
          GoRoute(
            path: RoutePath.superAdminMachines.path,
            name: RoutePath.superAdminMachines.name,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const AdminMachineView(),
            ),
          ),
          GoRoute(
            path: RoutePath.superAdminProfile.path,
            name: RoutePath.superAdminProfile.name,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const WebProfileView(),
            ),
          ),
        ],
      ),
    ],
  );
});
