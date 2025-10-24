import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/frontend/screens/splash_screen.dart';
import '../frontend/screens/main_navigation.dart';
import '../frontend/screens/admin/admin_screens/admin_main_navigation.dart';
import '../frontend/screens/email_verify.dart';
import '../frontend/screens/restricted_access_screen.dart';
import '../services/sess_service.dart';
import 'auth_service.dart';
import '../frontend/screens/qr_refer.dart';
import '../frontend/screens/waiting_approval_screen.dart';
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
          return const SplashScreen();
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
              debugPrint('AuthWrapper: User is admin, redirecting to AdminMainNavigation');
              return const AdminMainNavigation();
            }

            // For non-admin users, check team status
            final auth = AuthService();
            final status = await auth.getUserTeamStatus(user.uid);
            final teamId = status['teamId'];
            final pendingTeamId = status['pendingTeamId'];

            debugPrint('AuthWrapper: teamId=$teamId, pendingTeamId=$pendingTeamId');

            // Check member status across all teams
            try {
              final teamsSnapshot = await FirebaseFirestore.instance
                  .collection('teams')
                  .get();

              debugPrint('AuthWrapper: Checking ${teamsSnapshot.docs.length} teams');

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

                  debugPrint('AuthWrapper: Found member in team ${teamDoc.id}, isArchived=$isArchived, hasLeft=$hasLeft');

                  // Block archived users immediately
                  if (isArchived) {
                    debugPrint('AuthWrapper: User is archived, showing RestrictedAccessScreen');
                    return const RestrictedAccessScreen(reason: 'archived');
                  }

                  // If user has left, clear their teamId and send to QR screen
                  if (hasLeft) {
                    debugPrint('AuthWrapper: User has left, redirecting to QRReferScreen');
                    return const QRReferScreen();
                  }

                  // Found as active member with teamId
                  if (teamId != null && !isArchived && !hasLeft) {
                    debugPrint('AuthWrapper: User is active member, allowing access');
                    return kIsWeb
                        ? const WebOperatorNavigation()
                        : const MainNavigation();
                  }
                }
              }

              // User not found in any team
              debugPrint('AuthWrapper: User not found in any team');

              if (pendingTeamId != null) {
                debugPrint('AuthWrapper: Has pendingTeamId, showing WaitingApprovalScreen');
                return const WaitingApprovalScreen();
              } else {
                debugPrint('AuthWrapper: No team, showing QRReferScreen');
                return const QRReferScreen();
              }
            } catch (e) {
              debugPrint('AuthWrapper error: $e');
              return const QRReferScreen();
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
              return const QRReferScreen();
            }
            return snap.data ?? const QRReferScreen();
          },
        );
      },
    );
  }
}