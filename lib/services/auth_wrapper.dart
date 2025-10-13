import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/frontend/screens/splash_screen.dart';
import '../frontend/screens/main_navigation.dart';
import '../frontend/screens/email_verify.dart';
import '../services/sess_service.dart';

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
        
        // User is logged in and verified
        return const MainNavigation();
      },
    );
  }
}