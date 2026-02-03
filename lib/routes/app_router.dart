import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/forgot_pass.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/restricted_access_screen.dart';
import 'package:flutter_application_1/ui/machine_management/view/admin_machine_screen.dart';
import 'package:flutter_application_1/ui/machine_management/view/operator_machine_screen.dart';
import 'package:flutter_application_1/ui/profile_screen/view/profile_screen.dart';
import 'package:flutter_application_1/routes/app_route_redirect.dart';
import 'package:flutter_application_1/routes/navigations/admin_mobile_shell.dart';
import 'package:flutter_application_1/routes/navigations/admin_web_shell.dart';
import 'package:flutter_application_1/routes/navigations/operator_mobile_shell.dart';
import 'package:flutter_application_1/routes/navigations/operator_web_shell.dart';
import 'package:flutter_application_1/routes/navigations/super_admin_mobile_shell.dart';
import 'package:flutter_application_1/routes/navigations/super_admin_web_shell.dart';
import 'package:flutter_application_1/routes/route_path.dart';
import 'package:flutter_application_1/routes/router_notifier.dart';
import 'package:flutter_application_1/ui/core/ui/loading_screen.dart';
import 'package:flutter_application_1/ui/email_verify/email_verify_screen.dart';
import 'package:flutter_application_1/ui/operator_dashboard/view/responsive_dashboard.dart';
import 'package:flutter_application_1/ui/login/views/login_screen.dart';
import 'package:flutter_application_1/ui/machine_management/view/mobile_admin_machine_view.dart';
import 'package:flutter_application_1/ui/registration/views/registration_screen.dart';
import 'package:flutter_application_1/ui/reports/view/reports_route.dart';
import 'package:flutter_application_1/ui/statistics/view/web_statistics_screen.dart';
import 'package:flutter_application_1/ui/team_management/widgets/team_management_screen.dart';
import 'package:flutter_application_1/ui/team_selection/widgets/team_selection_screen.dart';
import 'package:flutter_application_1/ui/waiting_approval/views/waiting_approval_screen.dart';
import 'package:flutter_application_1/ui/admin_dashboard/view/admin_home_view.dart';
import 'package:flutter_application_1/ui/web_operator/view/operator_management_screen.dart';
//import 'package:flutter_application_1/ui/statistics/view/responsive_statistics.dart';
import 'package:flutter_application_1/ui/web_landing_page/widgets/download_app.dart';
//import 'package:flutter_application_1/ui/machine_management/view/web_operator_machine_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/ui/activity_logs/view/activity_logs_route.dart';
import 'package:go_router/go_router.dart';
//import 'package:flutter_application_1/ui/web_landing_page/view/web_landing_page_view.dart';
import 'package:flutter_application_1/ui/web_landing_page/view/responsive_landing_page.dart';
import 'package:flutter_application_1/ui/settings/view/settings_screen.dart';
// ADD THESE TWO IMPORTS:
import 'package:flutter_application_1/ui/web_landing_page/widgets/terms_of_service_page.dart';
import 'package:flutter_application_1/ui/web_landing_page/widgets/privacy_policy_page.dart';

const int kDesktopBreakpoint = 1024;

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: RoutePath.initial.path,
    debugLogDiagnostics: true,
    redirect: (context, state) => appRouteRedirect(context, ref, state),
    routes: [
      GoRoute(
        path: RoutePath.initial.path,
        name: RoutePath.initial.name,
        builder: (context, state) => const ResponsiveLandingPage(),
      ),
      GoRoute(
        path: '/download',
        name: 'download',
        builder: (context, state) => const DownloadApp(),
      ),
      GoRoute(
        path: '/terms-of-service',
        name: 'terms-of-service',
        builder: (context, state) => const TermsOfServicePage(),
      ),
      GoRoute(
        path: '/privacy-policy',
        name: 'privacy-policy',
        builder: (context, state) => const PrivacyPolicyPage(),
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
          final fallbackReason = "archived";
          final reason = extraReason ?? fallbackReason;
          return RestrictedAccessScreen(reason: reason);
        },
      ),
      // OPERATOR SHELL
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
              child: const ResponsiveDashboard(),
              key: state.pageKey,
            ),
          ),
          GoRoute(
            path: RoutePath.activity.path,
            name: RoutePath.activity.name,
            pageBuilder: (context, state) => NoTransitionPage(
              child: const ActivityLogsRoute(),
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
              child: const OperatorMachineScreens(),
              key: state.pageKey,
            ),
          ),
          GoRoute(
            path: RoutePath.operatorSettings.path,
            name: RoutePath.operatorSettings.name,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
            ),
          ),
          GoRoute(
            path: RoutePath.profile.path,
            name: RoutePath.profile.name,
            pageBuilder: (context, state) => NoTransitionPage(
              child: const ProfileScreenRoute(),
              key: state.pageKey,
            ),
          ),
        ],
      ),
      // ADMIN SHELL
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
              child: const AdminDashboard(),
            ),
          ),
          GoRoute(
            path: RoutePath.adminActivity.path,
            name: RoutePath.adminActivity.name,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ActivityLogsRoute(),
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
              child: const AdminMachineScreens(),
              key: state.pageKey,
            ),
          ),
          GoRoute(
            path: RoutePath.adminReports.path,
            name: RoutePath.adminReports.name,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ReportsRoute(),
            ),
          ),
          GoRoute(
            path: RoutePath.adminSettings.path,
            name: RoutePath.adminSettings.name,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
            ),
          ),
          GoRoute(
            path: RoutePath.adminProfile.path,
            name: RoutePath.adminProfile.name,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ProfileScreenRoute(),
            ),
          ),
        ],
      ),
      // SUPER ADMIN SHELL
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
            path: RoutePath.superAdminSettings.path,
            name: RoutePath.superAdminSettings.name,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
            ),
          ),
          GoRoute(
            path: RoutePath.superAdminProfile.path,
            name: RoutePath.superAdminProfile.name,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ProfileScreenRoute(),
            ),
          ),
        ],
      ),
    ],
  );
});