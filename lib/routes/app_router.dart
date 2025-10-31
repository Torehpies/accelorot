import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/activity_logs_screen.dart';
import 'package:flutter_application_1/frontend/operator/dashboard/home_screen.dart';
import 'package:flutter_application_1/frontend/operator/machine_management/admin_machine/admin_machine_screen.dart';
import 'package:flutter_application_1/frontend/operator/machine_management/operator_machine/operator_machine_screen.dart';
import 'package:flutter_application_1/frontend/operator/statistics/statistics_screen.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/email_verify.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/forgot_pass.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/qr_refer.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/registration_screen.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/restricted_access_screen.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/waiting_approval_screen.dart';
import 'package:flutter_application_1/frontend/screens/admin/admin_screens/admin_profile_screen.dart';
import 'package:flutter_application_1/frontend/screens/admin/home_screen/admin_home_screen.dart';
import 'package:flutter_application_1/frontend/screens/admin/operator_management/operator_management_screen.dart';
import 'package:flutter_application_1/routes/admin_mobile_shell.dart';
import 'package:flutter_application_1/routes/admin_web_shell.dart';
import 'package:flutter_application_1/routes/mobile_shell.dart';
import 'package:flutter_application_1/routes/web_shell.dart';
import 'package:flutter_application_1/screens/login/login_screen.dart';
import 'package:flutter_application_1/viewmodels/auth_state_notifier.dart';
import 'package:flutter_application_1/web/admin/screens/web_registration_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

const double kDesktopBreakpoint = 900.0;
const String dashboardPath = '/dashboard';
const String loginPath = '/login';
const String registrationPath = '/signup';
const String forgotPasswordPath = '/forgot-password';
// Correct route constants to match their intended screens
const String verifyEmailPath = '/verify-email';
const String pendingApprovalPath = '/pending-approval';
const String referralPath = '/referral';
const String restrictedPath = '/restricted';

final List<String> unauthenticatedPaths = [
  loginPath,
  registrationPath,
  forgotPasswordPath,
];

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  final redirect = (BuildContext context, GoRouterState state) {
    if (authState.isLoading) {
      return null;
    }

    final AuthState status = authState.value!;
    final String locationPath = state.uri.path;
    final bool isUnauthenticatedLocation = unauthenticatedPaths.contains(
      locationPath,
    );

    if (!status.isInitialCheckDone) {
      return null;
    }

    final bool isLoggedIn = status.firebaseUser != null;
    final bool isVerified = status.isVerified;
    final bool hasProfile = status.userEntity != null;
    final bool isRestricted = status.isRestricted;
    final bool isPendingApproval = status.isPendingApproval;
    final bool isVerificationLocation = locationPath == verifyEmailPath;

    if (!isLoggedIn) {
      return isUnauthenticatedLocation ? null : loginPath;
    }

    // Strict authorization order:
    // 1) Unverified email -> verify email
    // 2) No profile -> referral (enter code / complete profile)
    // 3) Restricted (archived/left) -> restricted
    // 4) Pending approval -> waiting approval
    if (!isVerified) {
      return isVerificationLocation ? null : verifyEmailPath;
    }

    if (!hasProfile) {
      return (locationPath == referralPath) ? null : referralPath;
    }

    if (isRestricted) {
      return (locationPath == restrictedPath) ? null : restrictedPath;
    }

    if (isPendingApproval) {
      return (locationPath == pendingApprovalPath) ? null : pendingApprovalPath;
    }

    if (isUnauthenticatedLocation ||
        isVerificationLocation ||
        locationPath == referralPath ||
        locationPath == restrictedPath ||
        locationPath == pendingApprovalPath) {
      return status.isAdmin ? '/admin/dashboard' : dashboardPath;
    }

    return null;
  };

  return GoRouter(
    initialLocation: loginPath,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: loginPath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: registrationPath,
        pageBuilder: (context, state) {
          final isWeb = MediaQuery.of(context).size.width >= kDesktopBreakpoint;
          return NoTransitionPage(
            child: isWeb
                ? const WebRegistrationScreen()
                : const RegistrationScreen(),
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        path: forgotPasswordPath,
        builder: (context, state) => const ForgotPassScreen(),
      ),
      GoRoute(
        path: verifyEmailPath,
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
        path: pendingApprovalPath,
        builder: (context, state) => const WaitingApprovalScreen(),
      ),
      GoRoute(
        path: referralPath,
        builder: (context, state) => const QRReferScreen(),
      ),
      GoRoute(
        path: restrictedPath,
        builder: (context, state) {
          final reason = state.extra as String?;
          return RestrictedAccessScreen(reason: reason ?? 'Unknown reason');
          //unknown amp
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
    redirect: redirect,
  );
});
