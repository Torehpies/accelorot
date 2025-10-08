// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'frontend/screens/splash_screen.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' show PlatformDispatcher; // Required for global error handling

import 'frontend/screens/statistics_screen.dart';
import 'frontend/screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PlatformDispatcher.instance.onError = (error, stack) {
    //print('Uncaught async error: $error');
    return true;
  };

  // Only initialize Firebase on supported platforms
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    //print('Firebase initialization failed: $e');
    // App continues, but Firebase features may be disabled
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
      home: const SplashScreen(),
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
