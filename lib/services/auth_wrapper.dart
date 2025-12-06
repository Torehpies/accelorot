import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/login_screen.dart';
import 'package:flutter_application_1/ui/team_selection/widgets/team_selection_screen.dart';
import '../frontend/operator/main_navigation.dart';
import '../frontend/screens/admin/admin_screens/admin_main_navigation.dart';
import '../web/admin/admin_navigation/web_admin_navigation.dart';
import '../frontend/screens/Onboarding/email_verify.dart';
import '../frontend/screens/Onboarding/restricted_access_screen.dart';
import '../services/sess_service.dart';
import 'auth_service.dart';

import '../frontend/screens/Onboarding/waiting_approval_screen.dart';
import '../web/operator/web_operator_navigation.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final SessionService sessionService = SessionService();

    return StreamBuilder<User?>(
      stream: sessionService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is not logged in
        if (snapshot.data == null) {
          return const LoginScreen();
        }

        final user = snapshot.data!;

        // User is logged in but email not verified
        if (!user.emailVerified) {
          return EmailVerifyScreen(email: user.email ?? '');
        }

        // User is logged in and verified – choose navigation by role and team status
        return FutureBuilder<Widget>(
          future: () async {
            final role = await sessionService.getCurrentUserRole() ?? '';

            // Admins bypass all checks
            if (role.toLowerCase() == 'admin') {
              debugPrint(
                'AuthWrapper: User is admin, redirecting to AdminMainNavigation (web-aware)',
              );
              return kIsWeb
                  ? const WebAdminNavigation()
                  : const AdminMainNavigation();
            }

            // For non-admin users, check team status
            final auth = AuthService();
            final status = await auth.getUserTeamStatus(user.uid);
            final teamId = status['teamId'];
            final pendingTeamId = status['pendingTeamId'];

            debugPrint(
              'AuthWrapper: teamId=$teamId, pendingTeamId=$pendingTeamId',
            );

            // Check member status across all teams
            try {
              final teamsSnapshot = await FirebaseFirestore.instance
                  .collection('teams')
                  .get();

              debugPrint(
                'AuthWrapper: Checking ${teamsSnapshot.docs.length} teams',
              );

              for (var teamDoc in teamsSnapshot.docs) {
                final memberDoc = await FirebaseFirestore.instance
                    .collection('teams')
                    .doc(teamDoc.id)
                    .collection('members')
                    .doc(user.uid)
                    .get();

                if (memberDoc.exists) {
                  final memberData = memberDoc.data()!;
                  final isArchived = memberData['isArchived'] ?? false;
                  final hasLeft = memberData['hasLeft'] ?? false;

                  debugPrint(
                    'AuthWrapper: Found member in team ${teamDoc.id}, isArchived=$isArchived, hasLeft=$hasLeft',
                  );

                  // Block archived users immediately
                  if (isArchived) {
                    debugPrint(
                      'AuthWrapper: User is archived, showing RestrictedAccessScreen',
                    );
                    return const RestrictedAccessScreen(reason: 'archived');
                  }

                  // If user has left, show team selection screen
                  if (hasLeft) {
                    debugPrint(
                      'AuthWrapper: User has left, redirecting to TeamSelectionScreen',
                    );
                    return const TeamSelectionScreen();
                  }

                  // Found as active member with teamId
                  if (teamId != null && !isArchived && !hasLeft) {
                    debugPrint(
                      'AuthWrapper: User is active member, allowing access',
                    );
                    return kIsWeb
                        ? const WebOperatorNavigation()
                        : const MainNavigation();
                  }
                }
              }

              // User not found in any team
              debugPrint('AuthWrapper: User not found in any team');

              if (pendingTeamId != null) {
                debugPrint(
                  'AuthWrapper: Has pendingTeamId, showing WaitingApprovalScreen',
                );
                return const WaitingApprovalScreen();
              } else {
                debugPrint('AuthWrapper: No team, showing TeamSelectionScreen');
                return const TeamSelectionScreen();
              }
            } catch (e) {
              debugPrint('AuthWrapper error: $e');
              return const TeamSelectionScreen();
            }
          }(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snap.hasError) {
              debugPrint('AuthWrapper FutureBuilder error: ${snap.error}');
              return const TeamSelectionScreen();
            }
            return snap.data ?? const TeamSelectionScreen();
          },
        );
      },
    );
  }
}
