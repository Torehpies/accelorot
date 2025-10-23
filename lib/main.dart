// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, PlatformDispatcher;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart'; // ✅ Make sure this file exists and includes web + android configs
import 'package:flutter_application_1/frontend/operator/statistics/statistics_screen.dart';
import 'package:flutter_application_1/frontend/screens/login_screen.dart';
import 'package:flutter_application_1/frontend/screens/registration_screen.dart' show RegistrationScreen;
import 'package:flutter_application_1/frontend/screens/main_navigation.dart';
import 'package:flutter_application_1/web/admin/admin_navigation/web_admin_navigation.dart';
import 'package:flutter_application_1/web/admin/screens/web_login_screen.dart';
import 'package:flutter_application_1/web/admin/screens/web_registration_screen.dart' show WebRegistrationScreen;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🌐 Global error handler (safe for web)
  FlutterError.onError = (details) {
    final message = details.exceptionAsString();
    print('Flutter Error: $message');
  };

  // 🧵 Async error handler
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
    print('✅ Firebase initialized successfully for ${kIsWeb ? "Web" : "Mobile"}');
  } on FirebaseException catch (e) {
    print('❌ Firebase init failed (FirebaseException): ${e.message}');
  } catch (e) {
    print('❌ Firebase init failed: $e');
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
        textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.grey[700])),
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
      home: const AuthGate(),
      routes: {
        '/login': (context) => kIsWeb ? const WebLoginScreen() : const LoginScreen(),
        '/signup': (context) => kIsWeb ? const WebRegistrationScreen() : const RegistrationScreen(),
        '/main': (context) => const MainNavigation(),
        '/statistics': (context) => const StatisticsScreen(),
        '/web': (context) => const WebNavigation(),
      },
      builder: (context, child) {
        if (child != null) return child;
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
          // ✅ User is signed in
          return kIsWeb ? const WebNavigation() : const MainNavigation();
        } else {
          // 🚪 User is NOT signed in
          return kIsWeb ? const WebLoginScreen() : const LoginScreen();
        }
      },
    );
  }
}
