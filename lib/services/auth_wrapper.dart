import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_application_1/frontend/screens/splash_screen.dart';
import '../frontend/screens/main_navigation.dart';
import '../frontend/screens/admin/admin_screens/admin_main_navigation.dart';
import '../frontend/screens/email_verify.dart';
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
            body: Center(
              child: CircularProgressIndicator(),
            ),
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
        
        // User is logged in and verified — choose navigation by role and team status
        return FutureBuilder<Widget>(
          future: () async {
            final role = await sessionService.getCurrentUserRole() ?? '';
            if (role.toLowerCase() == 'admin') {
              return const AdminMainNavigation();
            }

            // For non-admin users, check team status
            final auth = AuthService();
            final status = await auth.getUserTeamStatus(user.uid);
            final teamId = status['teamId'];
            final pendingTeamId = status['pendingTeamId'];

            if (teamId != null) {
              return kIsWeb ? const WebOperatorNavigation() : const MainNavigation();
            } else if (pendingTeamId != null) {
              return const WaitingApprovalScreen();
            } else {
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
              return const MainNavigation();
            }
            return snap.data ?? const MainNavigation();
          },
        );
      },
    );
  }
}