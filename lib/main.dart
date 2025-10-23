// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 👈 ADD THIS
import 'package:flutter/foundation.dart' show kIsWeb, PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/screens/login_screen.dart';
import 'package:flutter_application_1/frontend/screens/registration_screen.dart' show RegistrationScreen;
import 'package:flutter_application_1/frontend/screens/statistics_screen.dart';
import 'package:flutter_application_1/web/admin/screens/web_dashboard_screen.dart';
import 'package:flutter_application_1/frontend/screens/main_navigation.dart';
import 'package:flutter_application_1/web/admin/admin_navigation/web_admin_navigation.dart';
import 'package:flutter_application_1/web/admin/screens/web_login_screen.dart';
import 'package:flutter_application_1/web/admin/screens/web_registration_screen.dart' show WebRegistrationScreen;
import 'frontend/screens/web_login_screen.dart'; // 👈 ADD THIS
import 'frontend/screens/web_registration_screen.dart'; // 👈 ADD THIS
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🌐 Global error handler — safe for web
  FlutterError.onError = (details) {
    final message = details.exceptionAsString();
    print('Flutter Error: $message');
  };

  // 🧵 Handle async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    final errorMessage = error.toString();
    print('Uncaught async error: $errorMessage');
    return true;
  };

  // 🔥 Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    print('Firebase init failed: ${e.message ?? "Unknown Firebase error"}');
  } catch (e) {
    print('Firebase init failed: $e');
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
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
      // ✅ Use AuthGate as home — checks if user is logged in
      home: const AuthGate(),
      routes: {
        '/login': (context) => kIsWeb ? const WebLoginScreen() : const LoginScreen(),
        '/signup': (context) => kIsWeb ? const WebRegistrationScreen() : const RegistrationScreen(),
        '/main': (context) => const MainNavigation(),
        '/statistics': (context) => const StatisticsScreen(),
        '/web': (context) => const WebNavigation(),
      },
      builder: (context, child) {
        if (child != null) {
          return child;
        }
        return const Scaffold(
          body: Center(child: Text('An unexpected error occurred.')),
        );
      },
    );
  }
}

// 🔐 AuthGate: Checks if user is signed in
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
          // User is signed in → go to appropriate nav
          if (kIsWeb) {
            return const WebNavigation();
          } else {
            return const MainNavigation();
          }
        } else {
          // User is NOT signed in → go to login
          return kIsWeb
              ? const WebLoginScreen()
              : const LoginScreen();
        }
      },
    );
  }
}