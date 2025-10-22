// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_wrapper.dart';

import 'firebase_options.dart';
import 'frontend/screens/main_navigation.dart';
import 'frontend/screens/statistics_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🌐 Global error handler — safe for web
  FlutterError.onError = (details) {
    // Avoid printing raw error objects on web
    final message = details.exceptionAsString();
    // Use print (safe) — never debugPrint or pass to JS directly
    print('Flutter Error: $message');
  };

  // 🧵 Handle async errors (e.g., from Firebase)
  PlatformDispatcher.instance.onError = (error, stack) {
    // ✅ SAFE: Convert to string before logging
    final errorMessage = error.toString();
    print('Uncaught async error: $errorMessage');
    return true; // Prevents default red screen
  };

  // 🔥 Initialize Firebase — with web-safe fallback
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    // ✅ Only use e.message (String), never raw e
    print('Firebase init failed: ${e.message ?? "Unknown Firebase error"}');
  } catch (e) {
    // Fallback for non-Firebase errors (e.g., network, config)
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
      home: const AuthWrapper(),
      routes: {
        '/main': (context) => const MainNavigation(),
        '/statistics': (context) => const StatisticsScreen(),
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