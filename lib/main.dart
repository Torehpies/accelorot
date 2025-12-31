import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, PlatformDispatcher;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'package:flutter_application_1/frontend/operator/statistics/statistics_screen.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/login_screen.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/registration_screen.dart'
    show RegistrationScreen;
import 'package:flutter_application_1/frontend/operator/main_navigation.dart';
import 'package:flutter_application_1/web/admin/admin_navigation/web_admin_navigation.dart';
import 'package:flutter_application_1/services/auth_wrapper.dart';
import 'package:flutter_application_1/ui/web_landing_page/widgets/landing_page_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    // Consider using a logging service here in production
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    return true;
  };

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException {
    // Handle or log Firebase initialization errors appropriately
  } catch (e) {
    // Handle or log general initialization errors appropriately
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accel-O-Rot - Smart IoT Composting System',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/landing': (context) => const LandingPageView(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const RegistrationScreen(), // ✅ Use same screen for both web and mobile
        '/main': (context) => const MainNavigation(),
        '/statistics': (context) => const StatisticsScreen(),
        '/web': (context) => const WebAdminNavigation(),
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
          return const AuthWrapper();
        } else {
          return kIsWeb ? const LandingPageView() : const LoginScreen();
        }
      },
    );
  }
}