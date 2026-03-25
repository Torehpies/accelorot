import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/app_router.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/data/providers/core_providers.dart';
import 'package:flutter_application_1/data/providers/auth_observer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';

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
    debugPrint(e.toString());
    // Handle or log general initialization errors appropriately
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize push notifications (requests permissions and sets up handlers)
    ref.read(pushNotificationServiceProvider).initialize();
  }

  @override
  Widget build(BuildContext context) {
    // Activate auth observer to handle side effects like FCM token registration
    ref.watch(authObserverProvider);
    
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Accel-o-Rot',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routerConfig: router,
    );
  }
}

