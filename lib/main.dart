import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/app_router.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🌐 Global error handler (safe for web)
  FlutterError.onError = (details) {
		debugPrint(details.toString());
    // Consider using a logging service here in production
    // e.g., Sentry.captureException(details.exception, stackTrace: details.stack);
  };

  // 🧵 Async error handler
  PlatformDispatcher.instance.onError = (error, stack) {
    // Consider using a logging service here in production
		debugPrint(error.toString());
    return true;
  };

  // 🔥 Initialize Firebase
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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
		final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Accel-o-Rot',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
			routerConfig: router,
    );
  }
}
