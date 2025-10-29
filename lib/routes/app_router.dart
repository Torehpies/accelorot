import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/activity_logs_screen.dart';
import 'package:flutter_application_1/frontend/operator/dashboard/home_screen.dart';
import 'package:flutter_application_1/frontend/operator/machine_management/admin_machine/admin_machine_screen.dart';
import 'package:flutter_application_1/frontend/operator/machine_management/operator_machine/operator_machine_screen.dart';
import 'package:flutter_application_1/frontend/operator/statistics/statistics_screen.dart';
import 'package:flutter_application_1/frontend/screens/admin/admin_screens/admin_profile_screen.dart';
import 'package:flutter_application_1/frontend/screens/admin/home_screen/admin_home_screen.dart';
import 'package:flutter_application_1/frontend/screens/admin/operator_management/operator_management_screen.dart';
import 'package:flutter_application_1/routes/admin_mobile_shell.dart';
import 'package:flutter_application_1/routes/admin_web_shell.dart';
import 'package:flutter_application_1/routes/mobile_shell.dart';
import 'package:flutter_application_1/routes/web_shell.dart';
import 'package:flutter_application_1/screens/login/login_screen.dart';
import 'package:go_router/go_router.dart';

const int kDesktopBreakpoint = 800;

final GoRouter router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
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
          path: '/dashboard',
          pageBuilder: (context, state) =>
              NoTransitionPage(child: const HomeScreen(), key: state.pageKey),
        ),
        GoRoute(
          path: '/activity',
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
					)
				),
				GoRoute(
					path: '/admin/operators',
					pageBuilder: (context, state) => NoTransitionPage(
						key: state.pageKey,
						child: const OperatorManagementScreen(),
					)
				),
				GoRoute(
					path: '/admin/machines',
					pageBuilder: (context, state) => NoTransitionPage(
						key: state.pageKey,
						child: const AdminMachineScreen(),
					)
				),
				GoRoute(
					path: '/admin/profile',
					pageBuilder: (context, state) => NoTransitionPage(
						key: state.pageKey,
						child: const ProfileScreen(),
					)
				),
			]
    ),
  ],
);
