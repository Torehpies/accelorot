import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import './frontend/screens/home_screen.dart';
import 'package:flutter_application_1/ui/auth/view/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'frontend/screens/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' show PlatformDispatcher; // Required for global error handling
import 'frontend/screens/statistics_screen.dart';
import 'frontend/screens/main_navigation.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

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
      routes: {
        '/main': (context) => const MainNavigation(),
        '/statistics': (context) => const StatisticsScreen(),
        '/login': (context) => const RefactoredLoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
      //home: const SplashScreen(),
      home: authState.when(
        data: (user) =>
            user != null ? const MainNavigation() : const RefactoredLoginScreen(),
        error: (err, _) => Scaffold(
					body: Center(child: Text('Error: $err')),
				),
        loading: () => const Scaffold(
					body: Center(child: CircularProgressIndicator()),
				),
      ),
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
