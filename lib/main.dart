// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'package:flutter_application_1/frontend/screens/login_screen.dart';
import 'package:flutter_application_1/frontend/screens/registration_screen.dart';
import 'package:flutter_application_1/frontend/screens/main_navigation.dart';
import 'package:flutter_application_1/web/admin/screens/web_login_screen.dart';
import 'package:flutter_application_1/web/admin/screens/web_registration_screen.dart' show WebRegistrationScreen;
import 'package:flutter_application_1/services/auth_wrapper.dart';
import "package:flutter_application_1/web/admin/admin_navigation/web_admin_navigation.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    // Log to Sentry, etc. in production
  };

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Handle init error
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accel-o-Rot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.grey),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.teal, width: 2),
          ),
        ),
      ),
      home: const AuthGate(),
      routes: {
        '/login': (context) => kIsWeb ? const WebLoginScreen() : const LoginScreen(),
        '/signup': (context) => kIsWeb ? const WebRegistrationScreen() : const RegistrationScreen(),
        '/main': (context) => const MainNavigation(),
        '/web': (context) => const WebAdminMainNavigation(),
      },
      builder: (context, child) {
        return child ?? const Scaffold(
          body: Center(child: Text('An unexpected error occurred.')),
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // ✅ User is signed in - use AuthWrapper to determine navigation
          return const AuthWrapper();
        } else {
          return kIsWeb ? const WebLoginScreen() : const LoginScreen();
        }
      },
    );
  }
}